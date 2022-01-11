/***************************************************
* Name:         SG_WorkOrderHelper
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         03 Jun 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       03 Jun 2021     FMF     Initial Development
* 1.1       19 Jul 2021     SWM         Updated line 110 to be 'M' => 'Measure'  instead of 'M' => 'Measurement' which it was previously. 
* 
****************************************************/

public without sharing class SG_WorkOrderHelper {
	@TestVisible
    private static final String PRIMARY_INSTALLER_STATUS = 'Primary';
	@TestVisible
	private static final Integer RRP_YEAR = 1978;
	@TestVisible
	private static final String ANY_STATE_SUFFIX = '^All';
	@TestVisible
	private static final String NOT_REQUIRED_RULE_REGULATION_STATE = 'No';
	@TestVisible
	private static final String REQUIRED_RULE_REGULATION_STATE = 'Yes';
	@TestVisible
	private static final String REQUIRED_RULE_REGULATION_STATE_YEAR_DIFF = 'Yes - year difference'; // 10/25/2021 - should always return "Yes"
	//private static final String REQUIRED_RULE_REGULATION_STATE_YEAR_DIFF = 'Yes';
    //@TestVisible
    //private static final String RRP_APPROVAL_PROCESS_NAME = 'Work_Order_RRP_Exception_Request';
    //@TestVisible
    //private static final String PERMIT_APPROVAL_PROCESS_NAME = 'Work_Order_Permit_Attached_for_Review';
    private static final String ALL = 'ALL';

    public static Boolean triggerDisabledDuringTransaction = false;

    public static Boolean hasDoneRollups = false;
    public static Boolean hasDoneShares = false;
    public static Boolean hasUpdatedSATerrs = false;

    // perform rollups...
    public static void doRollups(System.TriggerOperation triggerEvent, List<WorkOrder> newObj, Map<Id, WorkOrder> oldObjs)
    {
        System.debug(LoggingLevel.WARN, '---> start doRollups');
        // set the enum of allowed trigger operations (before insert, after update, etc)
        List<TriggerOperation> triggerTypes = new List<TriggerOperation>{
                TriggerOperation.AFTER_INSERT
                , TriggerOperation.AFTER_UPDATE
                , TriggerOperation.AFTER_DELETE
                , triggerOperation.AFTER_UNDELETE
        };
        if (!SG_DisplayUtils.canFireTrigger(triggerEvent, triggerTypes, hasDoneRollups)) {
            System.debug(LoggingLevel.WARN, '---> already hasDoneRollups: ' + hasDoneRollups + ' or wrong trigger type; skip');
            return;
        }

        // prevents recursive triggers...
        hasDoneRollups = true;

        //Initialize the rollup helper
        SG_LookupRollupHelper lh = new SG_LookupRollupHelper();

        // take care of assigning the correct lists based on the trigger type (Insert vs Update vs Delete vs Undelete)
        lh.setTriggerLists(Trigger.operationType, Trigger.new, Trigger.old);

        // do the rollup(s) -- will execute all active rollups for current object
        lh.doRollupSummary();
    }


    @InvocableMethod( label='Create Work Order'
            description='Creates Work Order asynchronously.'
            category='WorkOrder' )
    public static void createWorkOrder( List<WorkOrder> workOrderList ) {
        system.debug( 'workOrderList for createWorkOrder= ' + workOrderList );

        if( triggerDisabledDuringTransaction ) {
            system.debug( 'trigger disabled during transaction in other objects' );
            return;
        }

        if( workOrderList.isEmpty() ) {
            return;
        }

        // NOTE: this is a new record to be created so the JSON doesn't contain
        // outdated data
        String JSONWorkOrderList = JSON.serialize( workOrderList );
        createWorkOrdersAtFuture( JSONWorkOrderList );

//        List<WorkOrder> newWorkOrderList = new List<WorkOrder>();
//        for( WorkOrder aWorkOrder : workOrderList ) {
//            WorkOrder newWorkOrder = new WorkOrder();
//            newWorkOrder.LocationId = '1317j000000097n';
//            newWorkOrder.RecordTypeId = '0127j00000094hX';
//            newWorkOrder.WorkTypeId = '08q7j00000001f0';
//            newWorkOrder.Subject = 'Kitchen Product Check-in Appointment';
//            newWorkOrder.Installer_PO_Status__c = 'Pending Initial Contact';
//            newWorkOrder.Status = 'New';
//            newWorkOrder.ParentWorkOrderId = aWorkOrder.Id;
//            newWorkOrder.AccountId = aWorkOrder.AccountId;
//            newWorkOrder.Client_Store__c = aWorkOrder.Client_Store__c;
//            newWorkOrder.Installer__c = aWorkOrder.Installer__c;
//            newWorkOrder.Job_SKU_lookup__c = aWorkOrder.Job_SKU_lookup__c;
//            newWorkOrder.StartDate = aWorkOrder.Expected_Arrival_Date__c;
//
//            newWorkOrderList.add( newWorkOrder );
//        }
//
//        insert newWorkOrderList;
    }

    @Future
    public static void createWorkOrdersAtFuture( String JSONWorkOrderList ) {
        system.debug( 'JSONWorkOrderList= ' + JSONWorkOrderList );
        List<WorkOrder> workOrderList = (List<WorkOrder>) JSON.deserialize(
                        JSONWorkOrderList, List<WorkOrder>.class );

        insert workOrderList;
    }

// case 3361 - we no longer want the work type to auto populate on create, remove the above from the code
//    public static Map<String, Id> workTypeIdMap {
//        get{
//            if( workTypeIdMap == null ) {
//                List<WorkType> workTypeList = [
//                        SELECT Id, Name
//                        FROM WorkType
//                ];
//                system.debug( 'workTypeList= ' + workTypeList );
//                workTypeIdMap = new Map<String, Id>();
//                for( WorkType aWorkType : workTypeList ) {
//                    workTypeIdMap.put( aWorkType.Name, aWorkType.Id );
//                }
//            }
//            return workTypeIdMap;
//        }
//        set;
//    }

    public static Set<String> recordIdsAlreadyProcessedSet = new Set<String>();
    public static Set<String> integrationKeysAlreadyProcessedSet = new Set<String>();
    public static void populateLookups( TriggerOperation operationType, List<WorkOrder> newList
            , Map<ID, WorkOrder> oldMap ) {

        if( triggerDisabledDuringTransaction ) {
            system.debug( 'trigger disabled during transaction in other objects' );
            return;
        }

        if( operationType != TriggerOperation.BEFORE_INSERT
                && operationType != TriggerOperation.BEFORE_UPDATE ) {
            return;
        }
        system.debug( '*** starting populateLookups ***' );

        //1) Populate lookup field Installer_c. on the work order
        //******When a work order is created (not on update/edit) and has a value in Client_Store_c field we need to
        // go to the Client_Store (account) and look for a related Account record in related list "Installers
        // Available" (there can be many).
        //The Installer should have status "Primary" and have an exact match Category_c field on Installers
        // Available and Job_Category__c (formula field) on work order .
        //When match is found populate the Installer_c (Account) on the work order.
        //Also populate lookup field Service_Territory_c on the work order from the Installer Account
        // "Service_Territory_c" field.
        //
        //3) Populate WorkType field. ***** When a work order is created and has a value of "I" in field
        // svcTypeCode_c, populate with Work Type of "Installation". When svcTypeCode_c = M, populate Work
        // Type with type "Measurement"
        //Work Type is a separate FSL object and we are matching on the Work Type Name.
        //
        //4) Populate Price Book ****** When a work order is created and has an account in Client_Store_c field
        // we need to assign a price book. This is done by looking at the Client_Store lookup field "Client_Market_c
        // and Client Market Number (for example 234), there will be a pricebook with that exact same number.
        // (Example Price Book Name = 234)

        //RFI uses person accounts. When a work order is created several fields are populated with a persons
        // information (First Name, Last Name, Email, Phone, Address etc.).
        //We want the trigger to see if a Contact with specific matching points can be found (person account),
        // if Yes link it to the Work Order. If not Create the person account and then link to the work order.
        // Add to both Account and Contact lookup field on the work order.
        //
        //Current vendor is using a specific code snippet. I have attached their current code in files.

        // when an Installation Work order is created (from integration) there should be a Measure Work Order for
        // the same location already created/completed. Measure first, install 2nd.
        //
        // We need a way to identify the Measure work order and assign it as the Parent to the Installation
        // Work Order.
        // When a Work Order is created (only on create no update/edit) and there is a value of "I" in custom
        // field "svcTypeCode_c" look for an existing Work Order, related to the same Person Account that is
        // no more than 90 days old (90 days from creation date) and has a value of "M" in custom field
        // "svcTypeCode_c".
        //
        // If there is a work order that match the above criteria make that "M" (Measurement) work order the
        // Parent of the "I"  (Install) work order.
        //
        // If no Measurement w/o match the criteria take no action.  If more than 1 Measurement work order match
        // the criteria take no action.
        // ...
        // 2) On the Work Order we have a Client/Store (Account) Lookup field. We also have an Account Lookup
        // field for Installers. We do not allow an Installer to be added to the Work Order that does not
        // have a current relationship with the Client account. Needs to be of status either Backup or
        // Primary (cannot select an installer that does not have a relationship to the store or has
        // any other status).

        // collect client stores and job categories to find an installer

        // 10/25 -- populate additional lookups
        // * RFI_Reporting_Market_c from the Client_Store__c lookup (field Reporting_Market__c)
        // * Primary_Field_Manager_c from the RFI Reporting Market -- can be either Kitchen Field Manager or Field Manager. if WO.Program__c contains "kitchen" it is a Kitchen Field Manager
        // * set the WO Owner from the Primary Field Manager



        Set<ID> clientStoreIDset = new Set<ID>();
        Set<String> jobCategorySet = new Set<String>();
        Set<String> marketNumberSet = new Set<String>();
        Set<String> firstNameSet = new Set<String>();
        Set<String> lastNameSet = new Set<String>();
        Set<String> phoneSet = new Set<String>();
        Set<String> emailSet = new Set<String>();
        Set<String> uniqueNameSet = new Set<String>();
        Set<ID> accountIDset = new Set<ID>();
        Set<Id> workOrderIdsWhoseInstallerChanged = new Set<ID>();
        // case 3361 - we no longer want the work type to auto populate on create, remove the above from the code
//        Map<String, String> svcCodeMap = new Map<String, String> {
//                'I' => 'Installation'
//                , 'M' => 'Measure'        //                 , 'M' => 'Measurement'
//        };



        for( WorkOrder aWorkOrder : newList ) {
            if( recordIsAlreadyProcessed( recordIdsAlreadyProcessedSet, aWorkOrder.Id ) ) {
                continue;
            }
            if( recordIsAlreadyProcessed( integrationKeysAlreadyProcessedSet, aWorkOrder.Integration_Key_WorkOrder__c ) ) {
                continue;
            }

            if ( String.isNotBlank( aWorkOrder.CustomerUniqueID__c) )
            {
                uniqueNameSet.add( aWorkOrder.CustomerUniqueID__c );
            }

            if( aWorkOrder.Client_Market_Number__c != null ) {
                marketNumberSet.add( String.valueOf( aWorkOrder.Client_Market_Number__c ) );
            }

            // find contact/person account matching by first last name and phone or email
            if( ! workOrderHasBlankNames( aWorkOrder ) ) {
                firstNameSet.add( aWorkOrder.CustomerFirstName__c );
                lastNameSet.add( aWorkOrder.CustomerLastName__c );

                if( aWorkOrder.CustomerPhone__c != null ) {
                    phoneSet.add( aWorkOrder.CustomerPhone__c );
                }
                if( aWorkOrder.CustomerEmail__c != null ) {
                    emailSet.add( aWorkOrder.CustomerEmail__c );
                }
            }

            if( aWorkOrder.AccountId != null ) {
                accountIDset.add( aWorkOrder.AccountId );
            }

            // case 3361 - we no longer want the work type to auto populate on create, remove the above from the code
//            String workTypeName = svcCodeMap.get( aWorkOrder.svcTypeCode__c );
//            system.debug( 'workTypeName= ' + workTypeName );
//            if( workTypeName != null ) {
//                aWorkOrder.WorkTypeId = workTypeIdMap.get( workTypeName );
//            }

            // detect when installer changed to only validate it if changed/new
            WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : null );
            if( oldWorkOrder == null
                    || oldWorkOrder.Installer__c != aWorkOrder.Installer__c ) {
                workOrderIdsWhoseInstallerChanged.add( aWorkOrder.Id );
            }

            clientStoreIDset.add( aWorkOrder.Client_Store__c );
            jobCategorySet.add( aWorkOrder.Job_Category__c );



        }
        system.debug( 'workOrderIdsWhoseInstallerChanged= ' + workOrderIdsWhoseInstallerChanged );
        system.debug( 'clientStoreIDset= ' + clientStoreIDset );
        system.debug( 'jobCategorySet= ' + jobCategorySet );
        system.debug( 'marketNumberSet= ' + marketNumberSet );
        system.debug( 'firstNameSet= ' + firstNameSet );
        system.debug( 'lastNameSet= ' + lastNameSet );
        system.debug( 'phoneSet= ' + phoneSet );
        system.debug( 'emailSet= ' + emailSet );
        system.debug( 'accountIDset= ' + accountIDset );
        system.debug( 'uniqueNameSet= ' + uniqueNameSet );

        Map<Id, Account> accountByIdMap = ( accountIDset == null ? null
                                            : getAccountByIdMap( accountIDset ) );

        Map<String, Account> accountMap = getAccountMap( firstNameSet, lastNameSet, phoneSet, emailSet, uniqueNameSet );

        // retrieve pricebooks that match client market numbers
        Map<String, Id> pricebookIdMap = getPricebookIdMap( marketNumberSet );

        // NOTE:  creates accounts
        populatePricebookIdParentAccountAndWorkOrder( newList, accountMap
                        , accountByIdMap, pricebookIdMap );

//        // find and assign pricebook id whose name matches Client_Market_Number__c
//        populatePricebook( newList, pricebookIdMap );

        // the next step will require client store ids to find available installers
        if( clientStoreIDset.isEmpty() ) {
            return;
        }

        // retrieve client stores and their installers
        AvailableInstallersMaps installerMaps = getInstallerMaps(
                                            jobCategorySet, clientStoreIDset );

        // match installer by category and store account
        // assign matching pricebook id that matches client market #
        populateInstaller( newList, installerMaps, workOrderIdsWhoseInstallerChanged );

        // set the reportingMarket
        populateReportingMarket( newList, clientStoreIdSet );

        // set the primary manager
        populatePrimaryManagerAndOwner( newList );




    }

    public static void populatePrimaryManagerAndOwner( List<WorkOrder> newList )
    {
        System.debug(LoggingLevel.WARN, '---> start populatePrimaryManagerAndOwner');
        // populate the Primary Field Manager field - based on the RFI Reporting Market; if WO Program__c contains "kitchen" get the rfi reporting market's Field_Manager_Kitchen__c; otherwise get Field_Mananger__c
        Map<Id, List<WorkOrder>> reportingMarketToWoMap_Kitchen = new Map<Id, List<WorkOrder>>();
        Map<Id, List<WorkOrder>> reportingMarketToWoMap_Field = new Map<Id, List<WorkOrder>>();
        Set<Id> allRfiIds = new Set<Id>();
        if ( newList != null && newList.size() > 0 )
        {
            // group by RFI - kitchen/non-kitchen
            for ( WorkOrder wo : newList )
            {
                System.debug(LoggingLevel.WARN, '---> looping wo; rfi reporting market: ' + wo.RFI_Reporting_Market__c );
                System.debug(LoggingLevel.WARN, '---> program: ' + wo.Program__c );
                if ( wo.RFI_Reporting_Market__c != null )
                {
                    allRfiIds.add( wo.RFI_Reporting_Market__c );
                    if ( String.isNotBlank( wo.Program__c) && wo.Program__c.toLowerCase().contains( 'kitchen'))
                    {
                        List<WorkOrder> tmpList = reportingMarketToWoMap_Kitchen.get( wo.RFI_Reporting_Market__c );
                        if ( tmpList == null ) tmpList = new List<WorkOrder>();
                        tmpList.add( wo );
                        reportingMarketToWoMap_Kitchen.put( wo.RFI_Reporting_Market__c, tmpList );
                    }
                    else
                    {
                        List<WorkOrder> tmpList = reportingMarketToWoMap_Field.get( wo.RFI_Reporting_Market__c );
                        if ( tmpList == null ) tmpList = new List<WorkOrder>();
                        tmpList.add( wo );
                        reportingMarketToWoMap_Field.put( wo.RFI_Reporting_Market__c, tmpList );
                    }


                }
            }
            System.debug(LoggingLevel.WARN, '---> reportingMarketToWoMap_Kitchen: '+ reportingMarketToWoMap_Kitchen);
            System.debug(LoggingLevel.WARN, '---> reportingMarketToWoMap_Field: '+ reportingMarketToWoMap_Field);

            System.debug(LoggingLevel.WARN, '---> allRfiIds: ' + allRfiIds);
            if ( allRfiIds != null && allRfiIds.size() > 0 )
            {
                // set one of the managers...
                for ( RFI_Reporting_Markets__c a : [SELECT Id, Name, Field_Manager__c, Field_Manager_Kitchen__c FROM RFI_Reporting_Markets__c WHERE Id IN :allRfiIds])
                {
                    System.debug(LoggingLevel.WARN, '---> looping accounts: ' + a );
                    if ( reportingMarketToWoMap_Kitchen.containsKey(a.Id) )
                    {
                        for ( WorkOrder wo : reportingMarketToWoMap_Kitchen.get( a.Id) )
                        {
                            wo.Primary_Field_Manager__c = a.Field_Manager_Kitchen__c;
                            wo.OwnerId = a.Field_Manager_Kitchen__c;
                        }
                    }
                    if ( reportingMarketToWoMap_Field.containsKey( a.Id ) )
                    {
                        for ( WorkOrder wo : reportingMarketToWoMap_Field.get( a.Id) )
                        {
                            wo.Primary_Field_Manager__c = a.Field_Manager__c;
                            wo.OwnerId = a.Field_Manager__c;
                        }
                    }

                }
            }

        }

    }

    public static void populateReportingMarket( List<WorkOrder> newList, Set<ID> clientStoreIDset )
    {
        //set RFI_Reporting_Market__c (on WO) from the Client_Store__c lookup (Reporting_Market__c on Acct)
        System.debug(LoggingLevel.WARN, '---> start populateReportingMarket');
        Map<Id, List<WorkOrder>> clientStoreToWoMap = new Map<Id, List<WorkOrder>>();

        if ( newList != null && newList.size() > 0 && clientStoreIdSet != null && clientStoreIDset.size() > 0 )
        {
            for ( WorkOrder aWorkOrder : newList )
            {
                List<WorkOrder> tmpList = clientStoreToWoMap.get( aWorkOrder.Client_Store__c );
                if ( tmpList == null ) tmpList = new List<WorkOrder>();
                tmpList.add( aWorkOrder );
                clientStoreToWoMap.put( aWorkOrder.Client_Store__c, tmpList );
            }
        }

        if ( clientStoreToWoMap != null && clientStoreToWoMap.keySet().size() > 0 )
        {
            for ( Account a : [SELECT Id, Name, Reporting_Market__c FROM Account WHERE Id IN :clientStoreToWoMap.keySet() ])
            {
                List<WorkOrder> wos = clientStoreToWoMap.get( a.Id );
                if ( wos != null && wos.size() > 0 )
                {
                    for ( WorkOrder wo : wos )
                    {
                        wo.RFI_Reporting_Market__c  = a.Reporting_Market__c;
                    }
                }
            }
        }
    }

    public static Boolean recordIsAlreadyProcessed(
                    Set<String> recordIdsAlreadyProcessedSet, String aWorkOrderIdOrKey ) {
        if( recordIdsAlreadyProcessedSet.contains( aWorkOrderIdOrKey ) ) {
            return true;
        }
        if( aWorkOrderIdOrKey != null ) {
            recordIdsAlreadyProcessedSet.add( aWorkOrderIdOrKey );
        }
        return false;
    }

    public static Map<Id, Account> getAccountByIdMap( Set<Id> accountIDset ) {
        List<Account> accountList = [
                SELECT Id, FirstName, LastName, Phone, PersonEmail
                        , PersonHomePhone, PersonMobilePhone
                        , PersonContactId, CustomerUniqueID__c
                        , (
                        SELECT Id
                        FROM WorkOrders
                        WHERE svcTypeCode__c = 'M'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                )
                FROM Account
                WHERE Id IN :accountIDset
        ];
        System.debug(LoggingLevel.WARN, '---> accountList: ' + accountList );
        Map<Id, Account> accountMap = new Map<Id, Account>( accountList );
        return accountMap;
    }

    public static Map<String, Account> getAccountMap( Set<String> firstNameSet, Set<String> lastNameSet, Set<String> phoneSet, Set<String> emailSet, Set<String> uniqueNameSet ) {
        List<Account> accountList = [
                SELECT Id, FirstName, LastName, Phone, PersonEmail
                        , PersonHomePhone, PersonMobilePhone
                        , PersonContactId, CustomerUniqueID__c
                        , (
                        SELECT Id
                        FROM WorkOrders
                        WHERE svcTypeCode__c = 'M'
                        ORDER BY CreatedDate DESC
                        LIMIT 1
                        )
                FROM Account
                WHERE LastName IN :lastNameSet
                    AND (
                        FirstName IN :firstNameSet
                        OR Phone IN :phoneSet
                        OR PersonHomePhone IN :phoneSet
                        OR PersonMobilePhone IN :phoneSet
                        OR PersonEmail IN :emailSet
                        OR CustomerUniqueID__c IN :uniqueNameSet)
        ];
        system.debug( 'accountList= ' + accountList );
        System.debug(LoggingLevel.WARN, '---> searching for matching accounts; found: ' + accountList );
        System.debug(LoggingLevel.WARN, '---> phoneSet: ' + phoneSet );
        System.debug(LoggingLevel.WARN, '---> firstNameSet: ' + firstNameSet );
        System.debug(LoggingLevel.WARN, '---> lastNameSet: ' + lastNameSet );
        System.debug(LoggingLevel.WARN, '---> emailSet: ' + emailSet );
        System.debug(LoggingLevel.WARN, '---> uniqueNameSet: ' + uniqueNameSet);

        // index accounts by FL names, email and phones
        Map<String, Account> accountMap = new Map<String, Account>();
        for( Account anAccount : accountList ) {
            String fullNameKey = anAccount.FirstName + '^' + anAccount.LastName;
            String emailKey = ( anAccount.PersonEmail != null ? '^' + anAccount.PersonEmail : '' );
            String phoneKey = ( anAccount.Phone != null ? '^' + anAccount.Phone : '' );
            accountMap.put( fullNameKey + emailKey, anAccount );
            accountMap.put( fullNameKey + phoneKey, anAccount );
            // add key for uniqueId
            accountMap.put( anAccount.CustomerUniqueID__c, anAccount );

            phoneKey = ( anAccount.PersonHomePhone != null ? '^' + anAccount.PersonHomePhone : '' );
            accountMap.put( fullNameKey + phoneKey, anAccount );

            phoneKey = ( anAccount.PersonMobilePhone != null ? '^' + anAccount.PersonMobilePhone : '' );
            accountMap.put( fullNameKey + phoneKey, anAccount );
        }
        return accountMap;
    }

    public static void populatePricebookIdParentAccountAndWorkOrder( List<WorkOrder> workOrderList
                                , Map<String, Account> accountMap
                                , Map<Id, Account> accountByIdMap
                                , Map<String, Id> pricebookIdMap ) {

        System.debug(LoggingLevel.WARN, '---> start populatePricebookIdParentAccountAndWorkOrder');
        // find matching parent person account
        // find measure work order (svcTypeCode_c=M) to set as parent of
        //  a current install work order (svcTypeCode_c=I)
        //  measure work order has the same person acct and created more recent than 90 days

        // case 3362 - should only occur when a Work Order is created by SF Integration User.
        String userName = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
        Boolean userIsIntegration = userName.containsIgnoreCase( 'integration' );

        Map<String, Account> newAccountMap = new Map<String, Account>();

        System.debug(LoggingLevel.WARN, '---> acountByIdMap: ' + accountByIdMap);

        for( WorkOrder aWorkOrder : workOrderList ) {
            System.debug(LoggingLevel.WARN, '---> looping WorkOrders: ' + aWorkOrder );
            // populate pricebook id if applicable
            Id pbId = pricebookIdMap.get( String.valueOf( aWorkOrder.Client_Market_Number__c ) );
            if( pbId != null ) {
                aWorkOrder.Pricebook2Id = pbId;
            }

            if( accountByIdMap != null && aWorkOrder.AccountId != null ) {
                Account theAccount = accountByIdMap.get( aWorkOrder.AccountId );
                // case 3362 - should only occur when a Work Order is created by SF Integration User.
                if( theAccount != null && userIsIntegration ) {
                    System.debug(LoggingLevel.WARN, '---> setting parentWorkOrder');
                    // set measure work order as parent of a current install work order
                    setParentWorkOrder( theAccount, aWorkOrder );
                }
                continue;
            }

            // prevent creation of person account without name
            if( workOrderHasBlankNames( aWorkOrder ) ) {
                System.debug(LoggingLevel.WARN, '---> work order has blank name');
                continue;
            }

            String uniqueId = aWorkOrder.CustomerUniqueID__c;
            System.debug(LoggingLevel.WARN, '---> string uniqueId: ' + uniqueId );

            String fullNameKey = aWorkOrder.CustomerFirstName__c + '^' + aWorkOrder.CustomerLastName__c;
            String emailKey = ( aWorkOrder.CustomerEmail__c != null ? '^' + aWorkOrder.CustomerEmail__c : '' );
            String phoneKey = ( aWorkOrder.CustomerPhone__c != null ? '^' + aWorkOrder.CustomerPhone__c : '' );

            // first try to find by uniqueId...
            Account theAccount = accountMap.get(uniqueId );
            System.debug(LoggingLevel.WARN, '---> found this account by uniqueId: ' + theAccount );
            if ( theAccount == null )
            {
                // try to find contact by FL name + email
                theAccount = accountMap.get( fullNameKey + emailKey );
            }

            if( theAccount == null ) {
                // try to find contact by FL name + phone
                theAccount = accountMap.get( fullNameKey + phoneKey );
            }

            if( theAccount == null )
            {
                System.debug(LoggingLevel.WARN, '---> no matching account found');
                // collect person account to be created
                String newAccountKey = fullNameKey + emailKey + phoneKey;
                    newAccountMap.put( newAccountKey, getNewPersonAccount( aWorkOrder ) );

                continue;
            }

            /*
            if( theAccount == null ) {
                System.debug(LoggingLevel.WARN, '---> no matching account found');
                // collect person account to be created
                //String newAccountKey = fullNameKey + emailKey + phoneKey;
                if ( String.isNotBlank( uniqueId ))
                {
                    String newAccountkey = uniqueId;
                    newAccountMap.put( newAccountKey, getNewPersonAccount( aWorkOrder ) );
                    System.debug(LoggingLevel.WARN, '---> putting account into map ');
                }

                continue;
            }
             */

            aWorkOrder.ContactId = theAccount.PersonContactId;
            aWorkOrder.AccountId = theAccount.Id;

            // set measure work order as parent of a current install work order
            if( userIsIntegration ) {
                // case 3362 - should only occur when a Work Order is created by SF Integration User.
                setParentWorkOrder( theAccount, aWorkOrder );
            }
        }


        if( ! newAccountMap.isEmpty() ) {
            // create accounts, then assign them to each work order
            createAccountsForWorkOrders( newAccountMap, workOrderList );
        }
    }

    public static void setParentWorkOrder( Account theAccount, WorkOrder aWorkOrder ) {
        // find measure work order (svcTypeCode_c=M) to set as parent of
        //  a current install work order (svcTypeCode_c=I)
        //  measure work order has the same person acct and created more recent than 90 days
        if( theAccount.WorkOrders != null
                && theAccount.WorkOrders.size() == 1
                && aWorkOrder.svcTypeCode__c == 'I' ) {
            system.debug( 'theAccount.WorkOrders= ' + theAccount.WorkOrders );
            aWorkOrder.ParentWorkOrderId = theAccount.WorkOrders[ 0 ].Id;
        }
    }

    public static Boolean workOrderHasBlankNames( WorkOrder aWorkOrder ) {
        return aWorkOrder.CustomerFirstName__c == null || aWorkOrder.CustomerLastName__c == null
                || aWorkOrder.CustomerFirstName__c == '' || aWorkOrder.CustomerLastName__c == '';
    }

    public static void createAccountsForWorkOrders( Map<String, Account> newAccountMap, List<WorkOrder> workOrderList ) {
        List<Account> accountList = newAccountMap.values();
        insert accountList;

        // NOTE: removed query to set PersonContactId since it doesn't seem necessary (already has account id)
        // left it here just in case it is needed in the future

//        // fetch PersonContactId
//        Map<Id, Account> accountWithContactIdMap = new Map<Id, Account> ( [
//                SELECT Id, PersonContactId
//                FROM Account
//                WHERE Id IN :accountList
//        ] );
//        system.debug( 'accountWithContactIdMap= ' + accountWithContactIdMap );

        for( WorkOrder aWorkOrder : workOrderList ) {
            String fullNameKey = aWorkOrder.CustomerFirstName__c + '^' + aWorkOrder.CustomerLastName__c;
            String emailKey = ( aWorkOrder.CustomerEmail__c != null ? '^' + aWorkOrder.CustomerEmail__c : '' );
            String phoneKey = ( aWorkOrder.CustomerPhone__c != null ? '^' + aWorkOrder.CustomerPhone__c : '' );
            String newAccountKey = fullNameKey + emailKey + phoneKey;
            Account theAccount = newAccountMap.get( newAccountKey );
            if( theAccount == null ) {
                continue;
            }

            aWorkOrder.AccountId = theAccount.Id;

//            Id contactId = accountWithContactIdMap.get( theAccount.Id ).PersonContactId;
//            aWorkOrder.ContactId = contactId;
        }
    }

    public static Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get( 'PersonAccount' ).getRecordTypeId();
    public static Account getNewPersonAccount( WorkOrder aWorkOrder ) {
        System.debug(LoggingLevel.WARN, '---> start getNewPersonAccount');
        Account newAccount = new Account();
        newAccount.RecordTypeId = personAccountRecordTypeId;
        newAccount.FirstName = aWorkOrder.CustomerFirstName__c;
        newAccount.LastName = aWorkOrder.CustomerLastName__c;
        newAccount.PersonEmail = aWorkOrder.CustomerEmail__c;
        newAccount.PersonMobilePhone = aWorkOrder.CustomerPhone__c;

        newAccount.PersonHomePhone = aWorkOrder.Customer_Home_Phone__c;
        newAccount.PersonOtherPhone = aWorkOrder.Customer_Work_Phone__c;

        newAccount.PersonOtherStreet = aWorkOrder.Street;
        newAccount.PersonOtherCity = aWorkOrder.City;
        newAccount.PersonOtherState = aWorkOrder.State;
        newAccount.PersonOtherPostalCode = aWorkOrder.PostalCode;

        newAccount.PersonMailingStreet = aWorkOrder.Street;
        newAccount.PersonMailingCity = aWorkOrder.City;
        newAccount.PersonMailingState = aWorkOrder.State;
        newAccount.PersonMailingPostalCode = aWorkOrder.PostalCode;

        newAccount.CustomerUniqueID__c = aWorkOrder.CustomerUniqueID__c;
        System.debug(LoggingLevel.WARN, '---> returning new personaccount: ' + newAccount );

        return newAccount;
    }

    public static Map<String, Id> getPricebookIdMap( Set<String> marketNumberSet ) {
        List<Pricebook2> pricebookList = [
                SELECT Id, Name
                FROM Pricebook2
                WHERE Name IN :marketNumberSet
        ];
        system.debug( 'pricebookList= ' + pricebookList );

        // index installers by store id and category
        Map<String, Id> pricebookMap = new Map<String, Id>();
        for( Pricebook2 aPB : pricebookList ) {
            pricebookMap.put( aPB.Name, aPB.Id );
        }
        return pricebookMap;
    }

    public class AvailableInstallersMaps {
        public Map<String, Installers_Available__c> primaryInstallersMap = new Map<String, Installers_Available__c>();
        public Map<String, Set<Id>> allInstallersMap = new Map<String, Set<Id>>();
        public Map<Id, Id> installerToTerritoryMap = new Map<Id, Id>();
    }
    public static AvailableInstallersMaps getInstallerMaps(
                        Set<String> jobCategorySet, Set<Id> clientStoreIDset ) {

        if( clientStoreIDset.isEmpty() ) {
            return new AvailableInstallersMaps();
        }

        List<Account> clientStoreList = [
                SELECT Id, Client_Market__c, Client_Market_Number__c
                        , (
                        SELECT Id, Store_Account__c, Category__c, Status__c
                                , Installer_Account__c
                                , Installer_Account__r.Service_Territory__c
                                , Installer_Account__r.Service_Territory__r.Name
                                , SvcTypeCode__c, Percent__c
                        FROM Resource_Backup__r
                        WHERE Category__c IN :jobCategorySet
                )
                FROM Account
                WHERE Id IN :clientStoreIDset
        ];
        system.debug( 'clientStoreList= ' + clientStoreList );

        // index installers by store id and category
        AvailableInstallersMaps resultMaps = new AvailableInstallersMaps();
        for( Account aStore : clientStoreList ) {
            if( aStore.Resource_Backup__r == null || aStore.Resource_Backup__r.isEmpty() ) {
                continue;
            }

            for( Installers_Available__c anAvailableInstaller : aStore.Resource_Backup__r ) {

                resultMaps.installerToTerritoryMap.put( anAvailableInstaller.Installer_Account__c
                        , anAvailableInstaller.Installer_Account__r.Service_Territory__c );

                String theKey = anAvailableInstaller.Store_Account__c
                        + '^' + anAvailableInstaller.Category__c
                        + '^' + anAvailableInstaller.SvcTypeCode__c;

                Set<Id> installerIdSet = resultMaps.allInstallersMap.get( theKey );
                if( installerIdSet == null ) {
                    installerIdSet = new Set<Id>();
                }
                installerIdSet.add( anAvailableInstaller.Installer_Account__c );
                resultMaps.allInstallersMap.put( theKey, installerIdSet );

                if( anAvailableInstaller.Status__c == PRIMARY_INSTALLER_STATUS ) {
                    resultMaps.primaryInstallersMap.put( theKey, anAvailableInstaller );
                }
            }
        }
        system.debug( 'resultMaps.installerToTerritoryMap= ' + resultMaps.installerToTerritoryMap );
        system.debug( 'resultMaps.allInstallersMap= ' + resultMaps.allInstallersMap );
        system.debug( 'resultMaps.primaryInstallersMap= ' + resultMaps.primaryInstallersMap );
        return resultMaps;
    }

//    public static void populatePricebook( List<WorkOrder> newList
//                                    , Map<String, Id> pricebookIdMap ) {
//        for( WorkOrder aWorkOrder : newList ) {
//            Id pbId = pricebookIdMap.get( String.valueOf( aWorkOrder.Client_Market_Number__c ) );
//            if( pbId == null ) {
//                continue;
//            }
//            aWorkOrder.Pricebook2Id = pbId;
//        }
//        system.debug( 'newList with Pricebook= ' + newList );
//    }

    public static void populateInstaller( List<WorkOrder> newList
                        , AvailableInstallersMaps installerMaps
                        , Set<Id> workOrderIdsWhoseInstallerChanged ) {
        System.debug(LoggingLevel.WARN, '---> start populateInstaller');
        for( WorkOrder aWorkOrder : newList )
        {
            String theKey = aWorkOrder.Client_Store__c
                        + '^' + aWorkOrder.Job_Category__c
                        + '^' + aWorkOrder.SvcTypeCode__c;
            system.debug( 'theKey= ' + theKey );

            // if there is an installer, validate it
            if( aWorkOrder.Installer__c != null ) {
                if( ! workOrderIdsWhoseInstallerChanged.contains( aWorkOrder.Id ) ) {
                    // skip validation if installer didn't change/not new
                    continue;
                }
                // check if installer is in the store list for this category
                validateInstallerAndSetTerritory( installerMaps, theKey, aWorkOrder );

                // no need to assign primary installer since it already has a valid installer
                continue;
            }

            Installers_Available__c primaryAvailableInstaller =
                                installerMaps.primaryInstallersMap.get( theKey );
            if( primaryAvailableInstaller == null ) {
                system.debug( 'primary installer not found, leaving installer blank' );
                continue;
            }

            aWorkOrder.Installer__c = primaryAvailableInstaller.Installer_Account__c;
            aWorkOrder.ServiceTerritoryId = primaryAvailableInstaller.Installer_Account__r.Service_Territory__c;

            // populate the installer percentage...
            Double installerPercent = 0;
            if ( primaryAvailableInstaller.Percent__c != null )
            {
                installerPercent = primaryAvailableInstaller.Percent__c * 100;
            }
            /*// override for certain types...
            System.debug(LoggingLevel.WARN, '---> checking for override percent: ' + aWorkOrder.Installer_Payment_Override__c );
            if ( aWorkOrder.Installer_Payment_Override__c != null )
            {
                installerPercent = aWorkOrder.Installer_Payment_Override__c;
            }*/
            System.debug(LoggingLevel.WARN, '---> installer percent: ' + installerPercent);
            aWorkOrder.Installer_Percent__c = installerPercent;

        }
        system.debug( 'newList with Pricebook/Installer= ' + newList );
    }

    public static void validateInstallerAndSetTerritory( AvailableInstallersMaps installerMaps
                                        , String theKey, WorkOrder aWorkOrder )
    {
        Set<Id> installersForStoreAndCategory = installerMaps.allInstallersMap.get( theKey );
        system.debug( 'installersForStoreAndCategory= ' + installersForStoreAndCategory );

       if( aWorkOrder.Job_SKU_lookup__c != null &&  (installersForStoreAndCategory == null
                || ! installersForStoreAndCategory.contains( aWorkOrder.Installer__c )) ) {

           // todo: add the installer name and store name
            String errorMsg = 'The specified installer is not available for this store';
            system.debug( errorMsg );
            //aWorkOrder.addError( 'The specified installer is not available for this store.' );
            aWorkOrder.addError( errorMsg );

        } else {

            Id territoryId = installerMaps.installerToTerritoryMap.get( aWorkOrder.Installer__c );
            aWorkOrder.ServiceTerritoryId = territoryId;
        }
    }

	public static Set<String> recordIdsAlreadyCheckedRRPSet = new Set<String>();
    public static Set<String> integrationKeysAlreadyCheckedRRPSet = new Set<String>();
	public static void flagPermitOrRRPRequired( TriggerOperation operationType, List<WorkOrder> newList
			, Map<ID, WorkOrder> oldMap ) {

        if( triggerDisabledDuringTransaction ) {
            system.debug( 'trigger disabled during transaction in other objects' );
            return;
        }

		if( operationType != TriggerOperation.BEFORE_INSERT
				&& operationType != TriggerOperation.BEFORE_UPDATE ) {
			return;
		}
        system.debug( '*** starting flagPermitOrRRPRequired ***' );

		Set<String> rrpKeySet = getRrpKeySetFromWorkOrders( newList, oldMap );

        System.debug(LoggingLevel.WARN, '---> rrpKeySet: ' + rrpKeySet );

		if( rrpKeySet.isEmpty() ) {
			return;
		}

		Set<String> uniqueKeySet = getRulesRegsKeySet( rrpKeySet );
        System.debug(LoggingLevel.WARN, '---> uniqueKeySet: ' + uniqueKeySet );

		for( WorkOrder aWorkOrder : newList ) {
            System.debug(LoggingLevel.WARN, '---> looping work order: ' + aWorkOrder );
			String rrpKey = getRRPRulesRegPartialKeyFromWorkOrder( aWorkOrder );
            System.debug(LoggingLevel.WARN, '---> rrpKey: ' + rrpKey );

			Boolean RRPrulesAndRegulationsExistForThisWorkOrder =
					checkIfRulesAndRegulationsExistForThisWorkOrder( uniqueKeySet, rrpKey, aWorkOrder );
            System.debug(LoggingLevel.WARN, '---> RRPrulesAndRegulationsExistForThisWorkOrder: ' + RRPrulesAndRegulationsExistForThisWorkOrder);

			aWorkOrder.RRP_Required_Calculated__c = getRequiredStatusIfRuleFound(
							aWorkOrder, RRPrulesAndRegulationsExistForThisWorkOrder );
            System.debug(LoggingLevel.WARN, '---> aWorkOrder.RRP_Required_Calculated__c= ' + aWorkOrder.RRP_Required_Calculated__c );

			// skip permit check if job type request change
			if( aWorkOrder.Job_Type_request_change__c != null ) {
				continue;
			}

            System.debug(LoggingLevel.WARN, '---> start permit logic');
			String permitKey = getPermitRulesRegPartialKeyFromWorkOrder( aWorkOrder );
            System.debug(LoggingLevel.WARN, '---> permitKey: ' + permitKey);

			Boolean permitRulesAndRegulationsExistForThisWorkOrder =
					checkIfRulesAndRegulationsExistForThisWorkOrder( uniqueKeySet, permitKey, aWorkOrder );
            System.debug(LoggingLevel.WARN, '---> permitRulesAndRegulationsExistForThisWorkOrder: ' + permitRulesAndRegulationsExistForThisWorkOrder);

			aWorkOrder.Permit_Required_Calculated__c = getRequiredStatusIfRuleFound_Permit( aWorkOrder, permitRulesAndRegulationsExistForThisWorkOrder, uniqueKeySet, permitKey );
            system.debug( 'aWorkOrder.Permit_Required_Calculated__c= ' + aWorkOrder.Permit_Required_Calculated__c );
		}

	}

	public static Boolean checkIfRulesAndRegulationsExistForThisWorkOrder( Set<String> uniqueKeySet, String rrpKey, WorkOrder aWorkOrder ) {
        System.debug(LoggingLevel.WARN, '---> start checkIfRulesandRegsRequired');
        System.debug(LoggingLevel.WARN, '---> incoming uniqueKeySet: ' + uniqueKeySet);
        System.debug(LoggingLevel.WARN, '---> incoming rrpKey: ' + rrpKey);
        System.debug(LoggingLevel.WARN, '---> incoming aWorkOrder.StateCode: ' + aWorkOrder.StateCode);

        String keyWithState = rrpKey + '^' + aWorkOrder.StateCode;
        String keyWithALL = rrpKey + ANY_STATE_SUFFIX;
        System.debug(LoggingLevel.WARN, '---> rrpKeyWithState: ' + keyWithState );
        System.debug(LoggingLevel.WARN, '---> rrpKeyWithState: ' + keyWithALL );

		Boolean RRPrulesAndRegulationsExistForThisWorkOrder = uniqueKeySet.contains( keyWithState ) || uniqueKeySet.contains( keyWithALL );
        System.debug(LoggingLevel.WARN, '---> RRPrulesAndRegulationsExistForThisWorkOrder= ' + RRPrulesAndRegulationsExistForThisWorkOrder );
		return RRPrulesAndRegulationsExistForThisWorkOrder;
	}

    /*
        todo: need a separate method for Permit
            if matching Permit with matching category
                check the State on the WO and populate
            so - if matches the uniqueKeyIndex **** WITH THE STATE *** or if installation state is ALL -- then it is required (Yes); otherwise No
     */

    public static String getRequiredStatusIfRuleFound_Permit( WorkOrder aWorkOrder, Boolean rulesAndRegulationsExistForThisWorkOrder, Set<String> uniqueKeySet, String rrpKey )
    {
        System.debug(LoggingLevel.WARN, '---> start getRequiredStatusIfRuleFound_Permit');
        System.debug(LoggingLevel.WARN, '---> incoming rulesAndRegulationsExistForThisWorkOrder: ' + rulesAndRegulationsExistForThisWorkOrder);
        String theRRPState = NOT_REQUIRED_RULE_REGULATION_STATE;
        System.debug(LoggingLevel.WARN, '---> theRRPState: '+ theRRPState);
        System.debug(LoggingLevel.WARN, '---> aWorkOrder.Home_Year_Built__c: ' + aWorkOrder.Home_Year_Built__c);
        System.debug(LoggingLevel.WARN, '---> aWorkOrder.epaInfo_calcYrBuilt__c: ' + aWorkOrder.epaInfo_calcYrBuilt__c);
        // if we find a match in the keyset OR if there is a State for "ALL", then it's a Yes; otherwise No
        if ( rulesAndRegulationsExistForThisWorkOrder )
        {
            theRRPState = REQUIRED_RULE_REGULATION_STATE;
        }
        else
        {
            theRRPState = NOT_REQUIRED_RULE_REGULATION_STATE;
        }
        System.debug(LoggingLevel.WARN, '---> theRRPState (Permit): ' + theRRPState );
        return theRRPState;
    }

	public static String getRequiredStatusIfRuleFound( WorkOrder aWorkOrder
						, Boolean rulesAndRegulationsExistForThisWorkOrder )
    {
        System.debug(LoggingLevel.WARN, '---> start getRequiredStatusIfRuleFound');
        System.debug(LoggingLevel.WARN, '---> incoming rulesAndRegulationsExistForThisWorkOrder: ' + rulesAndRegulationsExistForThisWorkOrder);
		//String theRRPState = NOT_REQUIRED_RULE_REGULATION_STATE;
		String theRRPState;
        System.debug(LoggingLevel.WARN, '---> theRRPState: '+ theRRPState);
        System.debug(LoggingLevel.WARN, '---> aWorkOrder.Home_Year_Built__c: ' + aWorkOrder.Home_Year_Built__c);
        System.debug(LoggingLevel.WARN, '---> aWorkOrder.epaInfo_calcYrBuilt__c: ' + aWorkOrder.epaInfo_calcYrBuilt__c);
		if( rulesAndRegulationsExistForThisWorkOrder ) {
            /*
                change 11/23/21
                IF Year Home Built <1978
                THEN “Yes”
                IF Year Home Built >= 1978 AND (Client Calculated Year Home Built <1978 OR NULL OR 0)
                THEN “Yes – Year Difference”
                IF Year Home Built >=1978 AND Client Calculated Year Home Built >= 1978
                THEN “No”
             */
            if (  String.isNotBlank(aWorkOrder.Home_Year_Built__c ) )
            {
                if ( Integer.valueOf( aWorkOrder.Home_Year_Built__c ) <  RRP_YEAR )
                {
                    // Yes
                    theRRPState = REQUIRED_RULE_REGULATION_STATE;
                }
                else if ( Integer.valueOf( aWorkOrder.Home_Year_Built__c ) >= RRP_Year
                        && ( aWorkOrder.epaInfo_calcYrBuilt__c == NULL || Integer.valueOf( aWorkOrder.epaInfo_calcYrBuilt__c ) < RRP_YEAR || Integer.valueOf( aWorkOrder.epaInfo_calcYrBuilt__c ) == 0) )
                {
                    // Yes, year difference
                    theRRPState = REQUIRED_RULE_REGULATION_STATE_YEAR_DIFF;
                }
                else if (  Integer.valueOf( aWorkOrder.Home_Year_Built__c ) >= RRP_YEAR && ( aWorkOrder.epaInfo_calcYrBuilt__c != null && Integer.valueOf( aWorkOrder.epaInfo_calcYrBuilt__c ) >= RRP_YEAR) )
                {
                    // NO
                    theRRPState = NOT_REQUIRED_RULE_REGULATION_STATE;
                }
            }


			//theRRPState = ( aWorkOrder.Home_Year_Built__c != null ?
              //              ( aWorkOrder.epaInfo_calcYrBuilt__c != aWorkOrder.Home_Year_Built__c ?
				//	            REQUIRED_RULE_REGULATION_STATE_YEAR_DIFF : REQUIRED_RULE_REGULATION_STATE )
                  //      : null );
		}
        system.debug( 'theRRPState= ' + theRRPState );
		return theRRPState;
	}

	public static Set<String> getRrpKeySetFromWorkOrders( List<WorkOrder> newList, Map<Id, WorkOrder> oldMap ) {
		Set<String> rrpKeySet = new Set<String>();
        String rrpYearString = String.valueOf( RRP_YEAR );
		for( WorkOrder aWorkOrder : newList ) {
            if( recordIsAlreadyProcessed( recordIdsAlreadyCheckedRRPSet, aWorkOrder.Id ) ) {
                continue;
            }
            if( recordIsAlreadyProcessed( integrationKeysAlreadyCheckedRRPSet, aWorkOrder.Integration_Key_WorkOrder__c ) ) {
                continue;
            }

			// skip non-relevant record types
            if( aWorkOrder.Skip_RRP_Permit_Check__c == true ) {
			//if( recordTypesToSkipSet.contains( aWorkOrder.RecordTypeId ) ) {
				continue;
			}

			// skip if relevant year fields haven't changed
			WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : null );
			if( oldWorkOrder != null
					&& oldWorkOrder.epaInfo_calcYrBuilt__c == aWorkOrder.epaInfo_calcYrBuilt__c
					&& aWorkOrder.epaInfo_calcYrBuilt__c != null
					&& oldWorkOrder.Home_Year_Built__c == aWorkOrder.Home_Year_Built__c
					&& aWorkOrder.Home_Year_Built__c != null ) {
				continue;
			}

			// collect key to find corresponding Rules_Regs__c of type Permit
			// Permit doesn't care about year fields
			String permitKey = getPermitRulesRegPartialKeyFromWorkOrder( aWorkOrder );
			rrpKeySet.add( permitKey + '^' + aWorkOrder.StateCode );
			rrpKeySet.add( permitKey + ANY_STATE_SUFFIX );

			// apply RRP rule check if year is older than the RRP year
            Boolean atLeastOneYearFieldIsOlderThanRRPYear =
                    aWorkOrder.epaInfo_calcYrBuilt__c < rrpYearString
                    || aWorkOrder.Home_Year_Built__c < rrpYearString;

			if( atLeastOneYearFieldIsOlderThanRRPYear ) {
				// collect key to find corresponding Rules_Regs__c of type RRP
				String rrpKey = getRRPRulesRegPartialKeyFromWorkOrder( aWorkOrder );
				rrpKeySet.add( rrpKey + '^' + aWorkOrder.StateCode );
				rrpKeySet.add( rrpKey + ANY_STATE_SUFFIX );
			}
		}
		system.debug( 'rrpKeySet= ' + rrpKeySet );
		return rrpKeySet;
	}

    public static String getRRPRulesRegPartialKeyFromWorkOrder( WorkOrder aWorkOrder ) {
		// this uses Client Type
		String theKey = 'RRP^' + aWorkOrder.Client_Type__c + '^' + aWorkOrder.Program__c
				+ '^' + aWorkOrder.Job_Category__c + '^' + aWorkOrder.svcTypeCode__c;
		return theKey;
	}

	public static String getPermitRulesRegPartialKeyFromWorkOrder( WorkOrder aWorkOrder ) {
		// this uses Client Store
		String clientStoreId = aWorkOrder.Client_Store__c;
		String theKey = 'Permit^' + clientStoreId?.left( 15 ) + '^' + aWorkOrder.Program__c
				+ '^' + aWorkOrder.Job_Category__c + '^' + aWorkOrder.svcTypeCode__c;
		return theKey;
	}

	public static Set<String> getRulesRegsKeySet( Set<String> rrpKeySet ) {
		List<Rules_Regs__c> rulesRegsList = [
				SELECT Id, Index_Key__c
				FROM Rules_Regs__c
				WHERE Index_Key__c IN :rrpKeySet
		];
        // replaced Unique_Key__c (formula) with external id Index_Key__c
        // removed non used fields: , RecordType.Name, Client_Type__c
        //						, Program__c, Category__c, svcCodeType__c
        //						, Installation_State__c
		system.debug( 'rulesRegsList= ' + rulesRegsList );

		Set<String> uniqueKeySet = new Set<String>();
		for( Rules_Regs__c aRuleReg : rulesRegsList ) {
			uniqueKeySet.add( aRuleReg.Index_Key__c );
		}
		return uniqueKeySet;
	}

    public static Set<String> recordIdsAlreadyCheckedForApprovalSet = new Set<String>();
    public static Set<String> integrationKeysAlreadyCheckedForApprovalSet = new Set<String>();

    public static void startGenericApprovalProcesses( TriggerOperation operationType
            , List<WorkOrder> newList, Map<ID, WorkOrder> oldMap ) {

        if( triggerDisabledDuringTransaction ) {
            system.debug( 'trigger disabled during transaction in other objects' );
            return;
        }

        if( operationType != TriggerOperation.BEFORE_UPDATE ) {
            return;
        }
        system.debug( '*** starting startGenericApprovalProcesses ***' );

        // load correlation between approval process and field name from custom metadata
        Map<String, String> approvalProcessToFieldNameMap = getApprovalProcessToFieldNameMap();

        // NOTE:  approvalProcessToFieldNameMap is like below
        // when fields change to true, the respective approval process will be started
        // {
        // RRP_APPROVAL_PROCESS_NAME => 'RRP_Exception_Request_Review_Request__c'
        // , PERMIT_APPROVAL_PROCESS_NAME => 'Permit_Attached_Review_Request__c'
        // };

        Map<String, Set<Id>> setIdsPerApprovalProcessMap =
                collectWorkOrderIdsPerApprovalProcess( newList, oldMap
                        , approvalProcessToFieldNameMap );

        // if none of the record Ids had fields triggering the approval, skip logic
        if( setIdsPerApprovalProcessMap.get( ALL ).isEmpty() ) {
            return;
        }

        String mapJSON = JSON.serialize( setIdsPerApprovalProcessMap );
        processApprovalsAtFuture( mapJSON );

    }

    @Future
    public static void processApprovalsAtFuture( String mapJSON ) {
        Map<String, Set<Id>> setIdsPerApprovalProcessMap = (Map<String, Set<Id>>)
                JSON.deserialize( mapJSON, Map<String, Set<Id>>.class );

        Set<Id> idsWithApprovalRunninngSet = getObjectIdSetFromExistingApprovalProcesses(
                                    setIdsPerApprovalProcessMap );

        // remove from the sets the work orders for which there is already a process
        removeIdsWhoseApprovalProcessAlreadyRuns( setIdsPerApprovalProcessMap
                                    , idsWithApprovalRunninngSet );

        // if none of the Ids were left, skip logic
        if( setIdsPerApprovalProcessMap.get( ALL ).isEmpty() ) {
            return;
        }

        // remove ALL from the map since we're done checking it
        setIdsPerApprovalProcessMap.remove( ALL );

        // collect approval requests for the remaining work orders
        List<Approval.ProcessSubmitRequest> approvalSubmissionList =
                getNewApprovalRequestList( setIdsPerApprovalProcessMap );

        // submit the approval requests
        submitApprovalProcesses( approvalSubmissionList );
    }

    public static Map<String, String> getApprovalProcessToFieldNameMap() {
        List<Work_Order_Approval_Process__mdt> approvalProcConfigList = [
                SELECT Id, DeveloperName, Field_Name__c
                FROM Work_Order_Approval_Process__mdt
        ];
        system.debug( 'approvalProcConfigList= ' + approvalProcConfigList );

        Map<String, String> approvalProcessToFieldNameMap = new Map<String, String>();
        for( Work_Order_Approval_Process__mdt approvalConfig : approvalProcConfigList ) {
            approvalProcessToFieldNameMap.put( approvalConfig.DeveloperName, approvalConfig.Field_Name__c );
        }

        return approvalProcessToFieldNameMap;
    }

    public static Map<String, Set<Id>> collectWorkOrderIdsPerApprovalProcess(
                    List<WorkOrder> newList, Map<Id, WorkOrder> oldMap
                    , Map<String, String> approvalProcessToFieldNameMap ) {

        // collects work order ids per each approval process
        Map<String, Set<Id>> setIdsPerApprovalProcesMap = new Map<String, Set<Id>>();

        // this will accumulate all ids that will participate in approval processes (not segregated)
        // this set is just to check if any id was added to the other sets and skip logic if empty
        setIdsPerApprovalProcesMap.put( ALL, new Set<Id>() );

        for( WorkOrder aWorkOrder : newList ) {
            if( recordIsAlreadyProcessed( recordIdsAlreadyCheckedForApprovalSet, aWorkOrder.Id ) ) {
                continue;
            }
            if( recordIsAlreadyProcessed( integrationKeysAlreadyCheckedForApprovalSet, aWorkOrder.Integration_Key_WorkOrder__c ) ) {
                continue;
            }

            // skip if relevant fields haven't changed to true
            WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : new WorkOrder() );

            for( String approvalProcessName : approvalProcessToFieldNameMap.keySet() ) {
                // check if the field that corresponds to the approval process has changed to true
                String fieldName = approvalProcessToFieldNameMap.get( approvalProcessName );

                Boolean fieldHasChangedToTrue =
                        ( oldWorkOrder.get( fieldName ) != aWorkOrder.get( fieldName )
                                && aWorkOrder.get( fieldName ) == true );

                if( ! fieldHasChangedToTrue ) {
                    continue;
                }

                // add work order id to the respective approval process set
                Set<Id> innerIdSet = setIdsPerApprovalProcesMap.get( approvalProcessName );
                if( innerIdSet == null ) {
                    innerIdSet = new Set<Id>();
                }
                innerIdSet.add( aWorkOrder.Id );
                setIdsPerApprovalProcesMap.put( approvalProcessName, innerIdSet );

                // add id to the unsegregated set too
                innerIdSet = setIdsPerApprovalProcesMap.get( ALL );
                innerIdSet.add( aWorkOrder.Id );
                setIdsPerApprovalProcesMap.put( ALL, innerIdSet );
            }
        }
        system.debug( 'setIdsPerApprovalProcesMap= ' + setIdsPerApprovalProcesMap );
        return setIdsPerApprovalProcesMap;
    }

    public static Set<Id> getObjectIdSetFromExistingApprovalProcesses(
                            Map<String, Set<Id>> setIdsPerApprovalProcesMap ) {

        Set<Id> targetObjIdSet = setIdsPerApprovalProcesMap.get( ALL );

        List<ProcessInstance> processList = getProcessListForRecordIds( targetObjIdSet );

        // return ids of the objects for which there are already approvals running
        Set<Id> objectIdSet = new Set<Id>();
        for( ProcessInstance aProcess : processList ) {
            objectIdSet.add( aProcess.TargetObjectId );
        }
        return objectIdSet;
    }
    public static List<ProcessInstance> getProcessListForRecordIds( Set<Id> targetObjIdSet ) {
        List<ProcessInstance> processList = [
                SELECT Id, Status, TargetObjectId
                FROM ProcessInstance
                WHERE TargetObjectId IN :targetObjIdSet
        ];
        system.debug( 'processList= ' + processList );
        return processList;
    }

    public static void removeIdsWhoseApprovalProcessAlreadyRuns(
            Map<String, Set<Id>> setIdsPerApprovalProcessMap
            , Set<Id> idsWithApprovalRunninngSet ) {
        for( String approvalProcessName : setIdsPerApprovalProcessMap.keySet() ) {
            Set<Id> innerIdSet = setIdsPerApprovalProcessMap.get( approvalProcessName );
            innerIdSet.removeAll( idsWithApprovalRunninngSet );
            setIdsPerApprovalProcessMap.put( approvalProcessName, innerIdSet );
        }

        Set<Id> innerIdSet = setIdsPerApprovalProcessMap.get( ALL );
        innerIdSet.removeAll( idsWithApprovalRunninngSet );
        setIdsPerApprovalProcessMap.put( ALL, innerIdSet );
    }

    public static List<Approval.ProcessSubmitRequest> getNewApprovalRequestList(
            Map<String, Set<Id>> setIdsPerApprovalProcessMap ) {

        // create approval processes for each id
        List<Approval.ProcessSubmitRequest> approvalSubmissionList =
                new List<Approval.ProcessSubmitRequest>();
        for( String approvalProcessName : setIdsPerApprovalProcessMap.keySet() ) {
            Set<Id> workOrderIdSet = setIdsPerApprovalProcessMap.get( approvalProcessName );
            for( Id aWorkOrderId : workOrderIdSet ) {
                Approval.ProcessSubmitRequest aRequest =
                        getNewApprovalProcessRequest( aWorkOrderId, approvalProcessName );

                approvalSubmissionList.add( aRequest );
            }
        }
        system.debug( 'approvalSubmissionList= ' + approvalSubmissionList );
        return approvalSubmissionList;
    }
    
    public static Approval.ProcessSubmitRequest getNewApprovalProcessRequest(
            Id aWorkOrderId, String processName ) {
        Approval.ProcessSubmitRequest aRequest = new Approval.ProcessSubmitRequest();
        aRequest.setObjectId( aWorkOrderId );
        aRequest.setSubmitterId( UserInfo.getUserId() );
        aRequest.setComments( 'Submitted via Quick Action.' );
        aRequest.setProcessDefinitionNameOrId( processName );
        aRequest.setSkipEntryCriteria( true );

        // avoid error MANAGER_NOT_DEFINED, This approval request requires the next approver to be determined by the Primary Field Manager field. This value is empty.
        if( Test.isRunningTest() ) {
            aRequest.setNextApproverIds( new List<Id>{
                    UserInfo.getUserId()
            } );
        }

        return aRequest;
    }

    public static void submitApprovalProcesses(
            List<Approval.ProcessSubmitRequest> approvalSubmissionList ) {

        system.debug( 'approvalSubmissionList= ' + approvalSubmissionList );

        if( approvalSubmissionList.isEmpty() ) {
            return;
        }
        List<Approval.ProcessResult> processResultList =
                                    Approval.process( approvalSubmissionList );
        for( Approval.ProcessResult anApprovalResult : processResultList ) {
            if( anApprovalResult.isSuccess() ) {
                continue;
            }

            List<Database.Error> approvalErrors = anApprovalResult.getErrors();
            String errorList = '';
            for( Database.Error anError : approvalErrors ) {
                errorList = errorList + anError.getStatusCode()
                        + ' - ' + anError.getMessage()
                        + ' - ' + anError.getFields() + '\n';
            }
            system.debug( 'errors for work order '
                        + anApprovalResult.getEntityId() + ' = ' + errorList );
        }
    }

    // AFTER trigger context

    public static Set<String> recordIdsAlreadySharedSet = new Set<String>();
    public static Set<String> integrationKeysAlreadySharedSet = new Set<String>();
    public class WorkOrderCollections {
        public Map<Id, String> territoryNameMap = new Map<Id, String> ();
        public Set<Id> workOrdersWithChangedTerritorySet = new Set<Id> ();
        public Map<Id, Work_Order_History__c> newWorkOrderHistoryMap =
                            new Map<Id, Work_Order_History__c>();
    }
    public static WorkOrderCollections collectDataFromWorkOrder( TriggerOperation operationType
            , List<WorkOrder> newList, Map<ID, WorkOrder> oldMap ) {

        // single loop to collect data for all AFTER trigger processing

        if( triggerDisabledDuringTransaction ) {
            system.debug( 'trigger disabled during transaction in other objects' );
            return null;
        }

        if( operationType != TriggerOperation.AFTER_INSERT
                && operationType != TriggerOperation.AFTER_UPDATE ) {
            return null;
        }
        system.debug( '*** starting collectDataFromWorkOrder ***' );

        if( ! canCallAsynchronous() ) {
            return null;
        }

        WorkOrderCollections theCollections = new WorkOrderCollections();
        for( WorkOrder aWorkOrder : newList ) {
            if( recordIsAlreadyProcessed( recordIdsAlreadySharedSet, aWorkOrder.Id ) ) {
                continue;
            }
            if( recordIsAlreadyProcessed( integrationKeysAlreadySharedSet, aWorkOrder.Integration_Key_WorkOrder__c ) ) {
                continue;
            }

            // collect territory name to fetch public groups
            theCollections.territoryNameMap.put( aWorkOrder.ServiceTerritoryId, aWorkOrder.Territory_Name__c );

            // collect OLD territory name to remove group shares
            WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : null );
            if( oldWorkOrder != null && aWorkOrder.ServiceTerritoryId != oldWorkOrder.ServiceTerritoryId ) {
                theCollections.workOrdersWithChangedTerritorySet.add( aWorkOrder.Id );
            }

            if( oldWorkOrder != null
                    && oldWorkOrder.Status == aWorkOrder.Status
                    && oldWorkOrder.Sub_Status__c == aWorkOrder.Sub_Status__c )
            {
                continue;
            }
            Work_Order_History__c newHistory = getNewWorkOrderHistory( oldWorkOrder, aWorkOrder );

            theCollections.newWorkOrderHistoryMap.put( aWorkOrder.Id, newHistory );
        }
        system.debug( 'territoryNameMap= ' + theCollections.territoryNameMap );
        system.debug( 'workOrdersWithChangedTerritorySet= ' + theCollections.workOrdersWithChangedTerritorySet );
        system.debug( 'newWorkOrderHistoryMap= ' + theCollections.newWorkOrderHistoryMap );

        // in case no data was collected, return null
        if( theCollections.territoryNameMap.isEmpty()
                && theCollections.workOrdersWithChangedTerritorySet.isEmpty()
                && theCollections.newWorkOrderHistoryMap.isEmpty() ) {
            return null;
        }

        return theCollections;
    }

    public static void syncSATerritories( System.TriggerOperation triggerEvent, List<WorkOrder> newWos, Map<Id, WorkOrder> oldWos)
    {
        System.debug(LoggingLevel.WARN, '---> start updateSATerritories');

        List<TriggerOperation> triggerTypes = new List<TriggerOperation>{
                TriggerOperation.AFTER_INSERT
                , TriggerOperation.AFTER_UPDATE
        };
        if (!SG_DisplayUtils.canFireTrigger(triggerEvent, triggerTypes, hasUpdatedSATerrs)) {
            System.debug(LoggingLevel.WARN, '---> already hasDoneShares: ' + hasUpdatedSATerrs + ' or wrong trigger type; skip');
            return;
        }

        hasUpdatedSATerrs = true;

        Map<Id, WorkOrder> updatedWosMap = new Map<Id, WorkOrder>();
        if ( newWos != null && newWos.size() > 0 )
        {
            for ( WorkOrder wo : newWos )
            {
                WorkOrder oldWo;
                if ( oldWos != null && oldWos.containsKey( wo.Id ))
                {
                    oldWo = oldWos.get( wo.Id );
                }
                if ( SG_DisplayUtils.hasChanged( oldWo, wo, 'ServiceTerritoryId'))
                {
                    updatedWosMap.put( wo.Id, wo );
                }
            }

            System.debug(LoggingLevel.WARN, '---> updatedWosMap: ' + updatedWosMap );
            if ( updatedWosMap != null && updatedWosMap.keySet().size() > 0 )
            {
                List<ServiceAppointment> updateSAList = new List<ServiceAppointment>();
                System.debug(LoggingLevel.WARN, '---> finding SAs...');
                for ( ServiceAppointment sa : [SELECT Id, ServiceTerritoryId, ParentRecordId FROM ServiceAppointment WHERE ParentRecordId IN :updatedWosMap.keySet()] )
                {
                    WorkOrder wo = updatedWosMap.get( sa.ParentRecordId );
                    if ( wo != null )
                    {
                        sa.ServiceTerritoryId = wo.ServiceTerritoryId;
                        updateSAList.add( sa );
                    }
                }
                System.debug(LoggingLevel.WARN, '---> update SAs: ' + updateSAList );
                String errMsg = SG_DB.updateRecords( updateSAList );
                System.debug(LoggingLevel.WARN, '---> errs from update: ' + errMsg );
            }

        }
    }

    public static void createAndDeleteShares( System.TriggerOperation triggerEvent, List<WorkOrder> newWos, Map<Id, WorkOrder> oldWos)
    {
        System.debug(LoggingLevel.WARN, '---> start createAndDeleteShares');

        List<TriggerOperation> triggerTypes = new List<TriggerOperation>{
                TriggerOperation.AFTER_INSERT
                , TriggerOperation.AFTER_UPDATE
        };
        if (!SG_DisplayUtils.canFireTrigger(triggerEvent, triggerTypes, hasDoneShares)) {
            System.debug(LoggingLevel.WARN, '---> already hasDoneShares: ' + hasDoneShares + ' or wrong trigger type; skip');
            return;
        }

        hasDoneShares = true;
        // 11/16/2021 -- fire every time the installer changes
        List<WorkOrder> newList = new List<WorkOrder>();
        Map<Id, String> territoryNameMap = new Map<Id, String> ();
        Set<Id> workOrdersWithChangedTerritorySet = new Set<Id>();
        if ( newWos != null && newWos.size() > 0 )
        {
            for ( WorkOrder wo : newWos )
            {
                WorkOrder oldWo;
                if ( oldWos != null && oldWos.containsKey( wo.Id ))
                {
                    oldWo = oldWos.get( wo.Id );
                    if ( SG_DisplayUtils.hasChanged( oldWo, wo, 'Installer__c'))
                    {
                        territoryNameMap.put( wo.ServiceTerritoryId, wo.Territory_Name__c );
                        workOrdersWithChangedTerritorySet.add( wo.Id );
                        newList.add( wo );
                    }
                }
            }
        }



        if(!system.isFuture()) deleteOldWorkOrderShares( workOrdersWithChangedTerritorySet );

        if( territoryNameMap.isEmpty() ) {
            System.debug(LoggingLevel.WARN, '---> empty territory');
            return;
        }

        // get unique set of territory names and retrieve groups matching those names
        Map<String, Id> groupMap = getGroupMap( territoryNameMap );
        System.debug(LoggingLevel.WARN, '---> groupMap: ' + groupMap );

        // create share to public groups that match territory name
        // remove shares to groups that NO LONGER match territory name
        List<WorkOrderShare> workOrderShareList = new List<WorkOrderShare> ();
        Map<Id, Id> woIdToGroupIdMap = new Map<Id, Id> ();
        for( WorkOrder aWorkOrder : newList ) {
            if( aWorkOrder.ServiceTerritoryId == null ) {
                continue;
            }

            String territoryName = territoryNameMap.get( aWorkOrder.ServiceTerritoryId );
            if( territoryName == null ) {
                continue;
            }

            Id groupId = groupMap.get( territoryName );
            if( groupId == null ) {
                continue;
            }

            woIdToGroupIdMap.put( aWorkOrder.Id, groupId );
        }
        System.debug(LoggingLevel.WARN, '---> woIdToGroupIdMap = ' + woIdToGroupIdMap);

        if( ! woIdToGroupIdMap.isEmpty() ) {
            System.debug(LoggingLevel.WARN, '---> about to create shares...');
            createWorkOrderShares( woIdToGroupIdMap );
        }
    }
    public static void trackStatusChanges( Map<Id, Work_Order_History__c> newWorkOrderHistoryMap ) {
        if( newWorkOrderHistoryMap.isEmpty() ) {
            return;
        }

        String newWOHistoryMapJSON = JSON.serialize( newWorkOrderHistoryMap );
        createWorkOrderHistoryAtFuture( newWOHistoryMapJSON );
    }
//    public static void createAndDeleteShares( TriggerOperation operationType
//                        , List<WorkOrder> newList, Map<ID, WorkOrder> oldMap ) {
//
//        if( triggerDisabledDuringTransaction ) {
//            system.debug( 'trigger disabled during transaction in other objects' );
//            return;
//        }
//
//        if( operationType != TriggerOperation.AFTER_INSERT
//                && operationType != TriggerOperation.AFTER_UPDATE ) {
//            return;
//        }
//        system.debug( '*** starting createAndDeleteShares ***' );
//
//        if( ! canCallAsynchronous() ) {
//            return;
//        }
//
//        Map<Id, String> territoryNameMap = new Map<Id, String> ();
//        Set<Id> workOrdersWithChangedTerritorySet = new Set<Id> ();
//        for( WorkOrder aWorkOrder : newList ) {
//            if( recordIsAlreadyProcessed( recordIdsAlreadySharedSet, aWorkOrder.Id ) ) {
//                continue;
//            }
//            if( recordIsAlreadyProcessed( integrationKeysAlreadySharedSet, aWorkOrder.Integration_Key_WorkOrder__c ) ) {
//                continue;
//            }
//
//            // collect territory name to fetch public groups
//            territoryNameMap.put( aWorkOrder.ServiceTerritoryId, aWorkOrder.Territory_Name__c );
//
//            // collect OLD territory name to remove group shares
//            WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : null );
//            if( oldWorkOrder != null && aWorkOrder.ServiceTerritoryId != oldWorkOrder.ServiceTerritoryId ) {
//                workOrdersWithChangedTerritorySet.add( aWorkOrder.Id );
//            }
//        }
//        system.debug( 'territoryNameMap= ' + territoryNameMap );
//        system.debug( 'workOrdersWithChangedTerritorySet= ' + workOrdersWithChangedTerritorySet );
//
//        deleteOldWorkOrderShares( workOrdersWithChangedTerritorySet );
//
//        if( territoryNameMap.isEmpty() ) {
//            return;
//        }
//
//        // get unique set of territory names and retrieve groups matching those names
//        Map<String, Id> groupMap = getGroupMap( territoryNameMap );
//
//        // create share to public groups that match territory name
//        // remove shares to groups that NO LONGER match territory name
//        List<WorkOrderShare> workOrderShareList = new List<WorkOrderShare> ();
//        Map<Id, Id> woIdToGroupIdMap = new Map<Id, Id> ();
//        for( WorkOrder aWorkOrder : newList ) {
//            if( aWorkOrder.ServiceTerritoryId == null ) {
//                continue;
//            }
//
//            String territoryName = territoryNameMap.get( aWorkOrder.ServiceTerritoryId );
//            if( territoryName == null ) {
//                continue;
//            }
//
//            Id groupId = groupMap.get( territoryName );
//            if( groupId == null ) {
//                continue;
//            }
//
//            woIdToGroupIdMap.put( aWorkOrder.Id, groupId );
//        }
//        system.debug( 'woIdToGroupIdMap= ' + woIdToGroupIdMap );
//
//        if( ! woIdToGroupIdMap.isEmpty() ) {
//            createWorkOrderShares( woIdToGroupIdMap );
//        }
//
//    }

    public static Boolean canCallAsynchronous() {
        return !system.isFuture() && !system.isBatch()
                && !system.isScheduled() && !System.isQueueable();
    }

    @future
    public static void createWorkOrderShares( Map<Id, Id> woIdToGroupIdMap )
    {
        System.debug(LoggingLevel.WARN, '---> start createWorkOrderShares');
        system.debug( 'woIdToGroupIdMap= ' + woIdToGroupIdMap );
        List<WorkOrderShare> workOrderShareList = new List<WorkOrderShare>();
        for( Id aWorkOrderId : woIdToGroupIdMap.keySet() ) {
            Id groupId = woIdToGroupIdMap.get( aWorkOrderId );
            WorkOrderShare aShare = new WorkOrderShare();
            aShare.ParentId = aWorkOrderId;
            aShare.UserOrGroupId = groupId;
            aShare.AccessLevel = 'Edit';
            aShare.RowCause = 'Manual';

            workOrderShareList.add( aShare );
        }
        System.debug(LoggingLevel.WARN, '---> workOrderShareList: ' + workOrderShareList);

        //insert workOrderShareList;
        //String errMsg = SG_DB.insertRecords( workorderShareList );
        Database.SaveResult[] results = Database.insert(workorderShareList,false);

        // Iterate through each returned result
        String allErrors = '';
        for (Integer i = 0; i < results.size(); i++)
        {
            Database.SaveResult sr = results[i];
            if (!sr.isSuccess())
            {
                String fullErrorMsg = 'There was an error updating the record with WoId ' + workorderShareList[i].get('ParentId') + ' GroupId: ' + workorderShareList[i].get('groupId') + '\n';
                // Operation failed, so get all errors
                for(Database.Error err : sr.getErrors())
                {
                    String errorMsg = 'The following error has occurred: ' + '\n';
                    errorMsg += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                    errorMsg += ' fields that affected this error: ' + err.getFields();
                    System.debug(errorMsg);

                    allErrors += errorMsg + '\n';
                }
            }
        }

        System.debug(LoggingLevel.WARN, '---> errors: ' + allErrors );
        if ( String.isNotBlank( allErrors ))
        {
            ia_crm__Error_Log__c error = new ia_crm__Error_Log__c();
            error.Name = DateTime.now().format();
            error.ia_crm__Error_Stack_Trace__c = allErrors;
            insert error;
        }

    }

    public static Map<String, Id> getGroupMap( Map<Id, String> territoryNameMap ) {
        Set<String> territoryNameSet = new Set<String>( territoryNameMap.values() );
        List<Group> groupList = [
                SELECT Id, Name
                FROM Group
                WHERE Type = 'Regular'
                AND Name IN :territoryNameSet
        ];
        system.debug( 'groupList= ' + groupList );

        // index groups by their names
        Map<String, Id> groupMap = new Map<String, Id>();
        for( Group aGroup : groupList ) {
            groupMap.put( aGroup.Name, aGroup.Id );
        }
        return groupMap;
    }

    @future
    public static void deleteOldWorkOrderShares( Set<Id> workOrdersWithChangedTerritorySet )
    {
        System.debug(LoggingLevel.WARN, '---> start deleteshares');
        System.debug(LoggingLevel.WARN, '---> workOrdersWithChangedTerritorySet: ' + workOrdersWithChangedTerritorySet);
        if( workOrdersWithChangedTerritorySet.isEmpty() ) {
            return;
        }

        // TODO:  should we filter by UserOrGroup.Name (territory) too ?

        List<WorkOrderShare> oldShareList = [
                SELECT Id, UserOrGroupId, UserOrGroup.Name
                FROM WorkOrderShare
                WHERE ParentId IN :workOrdersWithChangedTerritorySet
                    AND AccessLevel = 'Edit'
                    AND RowCause = 'Manual'
        ];
        system.debug( 'oldShareList= ' + oldShareList );

        if( ! oldShareList.isEmpty() ) {
            delete oldShareList;
        }
    }

//    public static Set<Id> statusChangesAlreadyProcessedSet = new Set<Id>();
//    public static void trackStatusChanges( TriggerOperation operationType, List<WorkOrder> newList
//            , Map<ID, WorkOrder> oldMap ) {
//
//        if( triggerDisabledDuringTransaction ) {
//            system.debug( 'trigger disabled during transaction in other objects' );
//            return;
//        }
//
//        if( operationType != TriggerOperation.AFTER_INSERT
//                && operationType != TriggerOperation.AFTER_UPDATE ) {
//            return;
//        }
//        system.debug( '*** starting trackStatusChanges ***' );
//
//        if( ! canCallAsynchronous() ) {
//            return;
//        }
//
//        // collect WO status changes and create respective history records
//        Map<Id, Work_Order_History__c> newWorkOrderHistoryMap =
//                getNewWorkOrderHistoryMap( newList, oldMap );
//
//        if( newWorkOrderHistoryMap.isEmpty() ) {
//            return;
//        }
//
//        String newWOHistoryMapJSON = JSON.serialize( newWorkOrderHistoryMap );
//        createWorkOrderHistoryAtFuture( newWOHistoryMapJSON );
//    }

    @Future
    public static void createWorkOrderHistoryAtFuture( String newWOHistoryMapJSON ) {

        Map<Id, Work_Order_History__c> newWorkOrderHistoryMap = (Map<Id, Work_Order_History__c>)
                JSON.deserialize( newWOHistoryMapJSON, Map<Id, Work_Order_History__c>.class );

        // get latest work order history for each work order BEFORE inserting new ones
        Set<Id> workOrderIdSet = newWorkOrderHistoryMap.keySet();
        List<WorkOrder> workOrderList = [
                SELECT Id
                    , ( SELECT Id, Date_Time_of_Change__c
                            , Status_Changed_to__c, Sub_Status_Changed_To__c
                        FROM Work_Order_History__r
                        ORDER BY Date_Time_of_Change__c DESC
                        LIMIT 1 )
                FROM WorkOrder
                WHERE Id IN :workOrderIdSet
        ];
        system.debug( 'workOrderList= ' + workOrderList );

        // insert history records
        List<Work_Order_History__c> newWorkOrderHistoryList = newWorkOrderHistoryMap.values();
        Database.SaveResult[] resultList = Database.insert( newWorkOrderHistoryList, false );
        if( reportErrors( newWorkOrderHistoryList, resultList ) ) {

            return;
        }

        // link previous history records to the recent ones
        List<Work_Order_History__c> oldWorkOrderHistoryList = new List<Work_Order_History__c>();
        for( WorkOrder aWorkOrder : workOrderList ) {
            if( aWorkOrder.Work_Order_History__r == null
                    || aWorkOrder.Work_Order_History__r.isEmpty() ) {
                continue;
            }

            Work_Order_History__c newWOHistory = newWorkOrderHistoryMap.get( aWorkOrder.Id );

            // link old statuses to the new statuses
            Work_Order_History__c oldWOHistory = aWorkOrder.Work_Order_History__r[ 0 ];
            oldWOHistory.Next_History_Change__c = newWOHistory.Id;

            // calculate time difference in minutes
            oldWOHistory.Duration_In_Minutes__c =
                            minutesBetween( oldWOHistory.Date_Time_of_Change__c
                                    , newWOHistory.Date_Time_of_Change__c );

            oldWorkOrderHistoryList.add( oldWOHistory );
        }
        system.debug( 'oldWorkOrderHistoryList= ' + oldWorkOrderHistoryList );

        if( ! oldWorkOrderHistoryList.isEmpty() ) {
            Database.SaveResult[] saveResults = Database.update( oldWorkOrderHistoryList, false );
            reportErrors( oldWorkOrderHistoryList, resultList );
        }

    }

    public static Decimal minutesBetween( DateTime startDT, DateTime endDT ) {
        Long startDTmilisecs = startDT.getTime();
        Long endDTmilisecs = endDT.getTime();

        Decimal nbrMinutes = Decimal.valueOf( endDTmilisecs - startDTmilisecs ) / 1000 / 60;
        return nbrMinutes.setScale( 0 );
    }

//    public static Map<Id, Work_Order_History__c> getNewWorkOrderHistoryMap(
//                                List<WorkOrder> newList, Map<Id, WorkOrder> oldMap ) {
//        Map<Id, Work_Order_History__c> newWorkOrderHistoryMap =
//                                        new Map<Id, Work_Order_History__c>();
//        for( WorkOrder aWorkOrder : newList ) {
//            if( statusChangesAlreadyProcessedSet.contains( aWorkOrder.Id ) ) {
//                continue;
//            }
//            statusChangesAlreadyProcessedSet.add( aWorkOrder.Id );
//
//            WorkOrder oldWorkOrder = ( oldMap != null ? oldMap.get( aWorkOrder.Id ) : null );
//            if( oldWorkOrder != null
//                    && oldWorkOrder.Status == aWorkOrder.Status
//                    && oldWorkOrder.Sub_Status__c == aWorkOrder.Sub_Status__c ) {
//                continue;
//            }
//            Work_Order_History__c newHistory = getNewWorkOrderHistory( oldWorkOrder, aWorkOrder );
//
//            newWorkOrderHistoryMap.put( aWorkOrder.Id, newHistory );
//        }
//        system.debug( 'newWorkOrderHistoryMap= ' + newWorkOrderHistoryMap );
//        return newWorkOrderHistoryMap;
//    }

    public static Work_Order_History__c getNewWorkOrderHistory(
                                WorkOrder oldWorkOrder, WorkOrder aWorkOrder ) {
        String oldStatus = ( oldWorkOrder != null ? oldWorkOrder.Status : '' );
        String oldSubStatus = ( oldWorkOrder != null ? oldWorkOrder.Sub_Status__c : '' );

        Work_Order_History__c newHistory = new Work_Order_History__c();
        newHistory.Work_Order__c = aWorkOrder.Id;
        newHistory.Date_Time_of_Change__c = DateTime.now();
        newHistory.Status_Changed_to__c = aWorkOrder.Status;
        newHistory.Sub_Status_Changed_To__c = aWorkOrder.Sub_Status__c;
        String name = aWorkOrder.WorkOrderNumber
                + ( oldWorkOrder == null ? 'NEW: '
                        : ': from ' + oldStatus + '/' + oldSubStatus+ ' to ' )
                 + aWorkOrder.Status + '/' + aWorkOrder.Sub_Status__c;
        newHistory.Name = name.left( 80 );
        return newHistory;
    }

    public static Boolean reportErrors( List<SObject> sobjList, Database.SaveResult[] results ) {
        Boolean hasErrors = false;
        Integer i = 0;
        for( Database.SaveResult result : results ) {
            if( result != null && result.isSuccess() == false ) {
                hasErrors = true;
                String recordErrors = concatenateErrors( result.getErrors() );
                system.debug( 'record errors f/ ' + sobjList[ i ].Id
                                + ' = ' + recordErrors );

                sobjList[ i ].addError( recordErrors );
            }
            i++;
        }

        return hasErrors;
    }

    public static String concatenateErrors( Database.Error[] errors ) {
        String errorList = 'ERROR:  ';
        for( Database.Error anError : errors ) {
            errorList = errorList + ' / ' + anError.message;
        }
        return errorList;
    }

}