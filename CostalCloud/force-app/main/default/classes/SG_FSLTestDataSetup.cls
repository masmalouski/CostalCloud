/***************************************************
* Name:         SG_FSLTestDataSetup
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
* 
****************************************************/
@IsTest
public with sharing class SG_FSLTestDataSetup {
    private static final String DOORS_PROGRAM = 'Doors';
    private static final String STORE_NAME = 'SGI THD Store Test';

    public static Id requiredLicenseRTId = Schema.SObjectType.Licenses__c.getRecordTypeInfosByName().get( 'Store Required License' ).getRecordTypeId();
    public static Id installerLicenseRTId = Schema.SObjectType.Licenses__c.getRecordTypeInfosByName().get( 'Installer License' ).getRecordTypeId();
    public static Id installerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Installer' ).getRecordTypeId();
    public static Id storeRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get( 'Client' ).getRecordTypeId();

    public static WorkOrder getNewWorkOrder( Account store, Job_SKU__c sku ) {
        WorkOrder aWorkOrder = new WorkOrder();
        aWorkOrder.Client_Store__c = ( store != null ? store.Id : null );
        aWorkOrder.Job_SKU_lookup__c = ( sku != null ? sku.Id : null );
        aWorkOrder.CustomerFirstName__c = 'Joe';
        aWorkOrder.CustomerLastName__c = 'Sixpack';
        aWorkOrder.CustomerPhone__c = '2142142144';
        aWorkOrder.CustomerEmail__c = 'joeSixpack@mailinator.com';
        aWorkOrder.SvcTypeCode__c = 'I';
        aWorkOrder.epaInfo_calcYrBuilt__c = '1960';
        aWorkOrder.Home_Year_Built__c = '1960';
        aWorkOrder.StateCode = 'TX';
        aWorkOrder.Integration_Key_WorkOrder__c = 'JoeSixpackTest';
        system.debug( 'new WorkOrder for testing= ' + aWorkOrder );
        return aWorkOrder;
    }

    public static List<Account> getNewStoreInstallerAccounts() {
        List<Account> accountList = new List<Account>();
        Account anInstaller = new Account();
        anInstaller.Name = 'SGI Test Installer';
        anInstaller.RecordTypeId = installerRTId;
        anInstaller.BillingStateCode = 'TX';
        accountList.add( anInstaller );

        Client_Market__c aMarket = new Client_Market__c();
        aMarket.Market_Number__c = 123;
        insert aMarket;

        Account aStore = new Account();
        aStore.Name = STORE_NAME;
        aStore.RecordTypeId = storeRTId;
        aStore.Client_Market__c = aMarket.Id;
        aStore.BillingStateCode = 'TX';
        aStore.Type = 'THD';
        accountList.add( aStore );

        return accountList;
    }

    public static Account getTestStore() {
        Account store = [
                SELECT Id
                FROM Account
                WHERE Name = :STORE_NAME
        ];
        system.debug( 'got store for testing= ' + store );
        return store;
    }

    public static Licenses__c getNewLicense( Id aRecordTypeId, Id parentAccountId ) {
        Licenses__c installerLicense = new Licenses__c();
        installerLicense.RecordTypeId = aRecordTypeId;
        installerLicense.Account__c = parentAccountId;
        installerLicense.Type__c = 'City';
        installerLicense.City__c = 'Contractor';
        installerLicense.Status__c = 'Active';
        return installerLicense;
    }

    public static Installers_Available__c getNewInstAvailWithoutDependencies(
            Id installerId, Id storeId ) {
        Installers_Available__c instAvail = new Installers_Available__c();
        instAvail.Installer_Account__c = installerId;
        instAvail.Store_Account__c = storeId;
        instAvail.Status__c = 'Primary';
        return instAvail;
    }

    public static final String EXTERIOR_DOOR = 'Exterior Door';

    public static Installers_Available__c getNewInstallerAvailable(
            Id installerId, Id storeId ) {
        Installers_Available__c instAvail = getNewInstAvailWithoutDependencies( installerId, storeId );
        instAvail.Job_Type__c = 'Install';

        // if any of the dependencies below change, it will break
        instAvail.Client__c = 'THD';
        instAvail.Program__c = DOORS_PROGRAM;
        instAvail.Category__c = EXTERIOR_DOOR;
        instAvail.SvcTypeCode__c = 'I';

        return instAvail;
    }

    public static Job_SKU__c getNewSku() {
        Job_SKU__c sku = new Job_SKU__c();
        sku.Category__c = EXTERIOR_DOOR;
        sku.Program__c = DOORS_PROGRAM;
        system.debug( 'new sku for testing= ' + sku );
        return sku;
    }

    public static List<Account> getAccounts() {
        List<Account> accountList = [
                SELECT Id, Name
                FROM Account
                ORDER BY CreatedDate
        ];
        return accountList;
    }

    public static OperatingHours getNewOperatingHours() {
        OperatingHours theHours = new OperatingHours();
        theHours.Name = 'Sixpack hours';
        theHours.TimeZone = 'America/Chicago';
        return theHours;
    }

    public static ServiceTerritory getNewServiceTerritory( Id operHoursId ) {
        ServiceTerritory resourcesTerritory = new ServiceTerritory();
        resourcesTerritory.Name = 'Sixpack TEST territory';
        resourcesTerritory.OperatingHoursId = operHoursId;
        resourcesTerritory.IsActive = true;
        return resourcesTerritory;
    }

    public static ServiceAppointment getNewServiceAppointment( WorkOrder aWorkOrder ) {
        ServiceAppointment svcAppt = new ServiceAppointment();
        svcAppt.ParentRecordId = aWorkOrder.Id;
        return svcAppt;
    }

    public static WorkType getNewWorkType( String aName ) {
        WorkType aWorkType = new WorkType();
        aWorkType.Name = aName;
        aWorkType.EstimatedDuration = 1;
        return aWorkType;
    }

    public static Contact getNewContact( String lastName ) {
        Contact workOrderContact = new Contact();
        workOrderContact.FirstName = 'Joe';
        workOrderContact.LastName = lastName;
        workOrderContact.Phone = '2142142144';
        workOrderContact.Email = 'joe' + lastName + '@mailinator.com';
        workOrderContact.MailingStreet = '123 Main';
        workOrderContact.MailingCity = 'Somewhere';
        return workOrderContact;
    }

    public static User getNewUser( String aName ) {
        String orgId = Userinfo.getOrganizationID();
        String uniqueEmail = 'test' + aName + '@' + orgId + '.net.test';
        User anUser = new User( Alias = 'TST'
                , CommunityNickname = uniqueEmail.remove( '@' )
                , Email = uniqueEmail
                , EmailEncodingKey = 'UTF-8'
                , FirstName = 'Joe'
                , LastName = aName + ' TEST'
                , LanguageLocaleKey = 'en_US'
                , LocaleSidKey = 'en_US'
                // TODO:  change this profile name
                , Profile = new Profile( Name = '#Custom: RFI Standard' )
                , TimezoneSidKey = 'America/Los_Angeles'
                , UserName = uniqueEmail );
        return anUser;
    }

    public static Schema.Location getNewLocation( String name ) {
        Schema.Location territoryLocation = new Schema.Location();
        //territoryLocation.RecordTypeId = ( name.containsIgnoreCase( 'van' ) ? vanRTId : siteRTId );
        territoryLocation.Name = name;
        //territoryLocation.IsInventoryLocation = false;
        territoryLocation.IsInventoryLocation = true;
        territoryLocation.IsMobile = true;
        return territoryLocation;
    }

    public static Schema.Location getLocationWithAddress( String name ) {
        Schema.Location territoryLocation = getNewLocation( name );
        insert territoryLocation;

        Schema.Address aTerritoryAddress = new Schema.Address();
        aTerritoryAddress.ParentId = territoryLocation.Id;
        aTerritoryAddress.PostalCode = '30070';
        //aTerritoryAddress.LocationType = ( name.containsIgnoreCase( 'van' ) ? 'Van' : 'Site' );
        insert aTerritoryAddress;

        return territoryLocation;
    }

    public static ServiceResource getNewServiceResource( User anUser, Id resourceLocationId ) {
        ServiceResource aResource = new ServiceResource();
        aResource.Name = anUser.FirstName + ' ' + anUser.LastName + ', the resource';
        aResource.RelatedRecordId = anUser.Id;
        aResource.LocationId = resourceLocationId;
        aResource.IsActive = true;
        return aResource;
    }

    public static Product2 getNewProduct( Integer nbr ) {
        Product2 p = new Product2();
        p.IsActive = true;
        p.Name = 'Test Product #' + nbr;
        p.ProductCode = 'TestPCode #1' + nbr;
        insert p;

        // create pricebookentries
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = p.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 1;
        insert pbe;

        return p;
    }

}