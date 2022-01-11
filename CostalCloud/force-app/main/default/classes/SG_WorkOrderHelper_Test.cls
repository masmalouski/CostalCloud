/***************************************************
* Name:         SG_WorkOrderHelper_Test
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

@isTest
public with sharing class SG_WorkOrderHelper_Test {
	@TestSetup
	public static void setupData() {

//		// add approval user to queue
//		addUserToApprovalQueue( 'Work Order RRP Queue' );

		WorkType installWorkType = SG_FSLTestDataSetup.getNewWorkType( 'Installation' );
		WorkType measureWorkType = SG_FSLTestDataSetup.getNewWorkType( 'Measurement' );
		insert new List<WorkType> {
				installWorkType, measureWorkType
		};

		OperatingHours theHours = SG_FSLTestDataSetup.getNewOperatingHours();
		insert theHours;

		ServiceTerritory aSvcTerr = SG_FSLTestDataSetup.getNewServiceTerritory( theHours.ID );
		insert aSvcTerr;

		Pricebook2 aPB = new Pricebook2();
		aPB.Name = '123';
		insert aPB;

		List<Account> accountList = SG_FSLTestDataSetup.getNewStoreInstallerAccounts();
		Account anInstaller = accountList[ 0 ];
		anInstaller.Service_Territory__c = aSvcTerr.Id;

		Account aStore = accountList[ 1 ];
		insert accountList;

		Installers_Available__c instAvail =
				SG_FSLTestDataSetup.getNewInstallerAvailable(
						anInstaller.Id, aStore.Id );
		insert instAvail;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( null, null );

		Account personAccount = SG_WorkOrderHelper.getNewPersonAccount( aWorkOrder );
		insert personAccount;

		aWorkOrder.svcTypeCode__c = 'M';
		aWorkOrder.AccountId = personAccount.Id;
		insert aWorkOrder;

		String orgId = Userinfo.getOrganizationID();
		String uniqueEmail = 'test@' + orgId + '.net.test';
		User anIntegrationUser = new User( Alias = 'TST'
				, CommunityNickname = 'TST'
				, Email = uniqueEmail
				, EmailEncodingKey = 'UTF-8'
				, LastName = 'Integration Testing'
				, LanguageLocaleKey = 'en_US'
				, LocaleSidKey = 'en_US'
				, Profile = new Profile( Name = 'Standard User' )
				, TimezoneSidKey = 'America/Los_Angeles'
				, UserName = uniqueEmail );
		insert anIntegrationUser;
	}

//	public static void addUserToApprovalQueue( String queueName ) {
//		User u = SG_FSLTestDataSetup.getNewUser( 'Manager' );
//		u.ManagerId = UserInfo.getUserId();
//		u.Profile = new Profile( Name = 'System Administrator' );
//		insert u;
//
//		system.runAs( u ) {
//			Group approvalQueue = [
//					SELECT Id
//					FROM Group
//					WHERE Name = :queueName
//					AND Type = 'Queue'
//			];
//			system.debug( 'approvalQueue= ' + approvalQueue );
//
//			GroupMember member = new GroupMember();
//			member.UserOrGroupId = u.Id;
//			member.GroupId = approvalQueue.Id;
//			insert member;
//		}
//	}

	@IsTest
	public static void testBulkWorkOrders() {
		Test.startTest();

		Integer nbrRecords = 140;

		Account store = SG_FSLTestDataSetup.getTestStore();

		Id rrpRTId = ruleRegRtMap.get( 'RRP' ).getRecordTypeId();

		// create matching rules/regulations record
		Rules_Regs__c ruleReg = getNewRuleRegulation( rrpRTId );
		system.debug( 'creating RRP ruleReg= ' + ruleReg );
		insert ruleReg;

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		Installers_Available__c instAvail = [
				SELECT Id, Installer_Account__c
				FROM Installers_Available__c
				WHERE Store_Account__c = :store.Id
				LIMIT 1
		];

		List<WorkOrder> workOrderList = new List<WorkOrder>();
		WorkOrder templateWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		for( Integer i = 0; i < nbrRecords; i++ ) {
			WorkOrder aWorkOrder = templateWorkOrder.clone();
			aWorkOrder.Integration_Key_WorkOrder__c = 'TEST' + i;
			workOrderList.add( aWorkOrder );
		}
		insert workOrderList;


		Test.stopTest();
	}

	@IsTest
	public static void approvalProcessTest() {
		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Primary_Field_Manager__c = UserInfo.getUserId();
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		insert aWorkOrder;

		SG_WorkOrderHelper.recordIdsAlreadyCheckedForApprovalSet.clear();
		SG_WorkOrderHelper.integrationKeysAlreadyCheckedForApprovalSet.clear();

		aWorkOrder.Permit_Attached_Review_Request__c = true;
		system.debug( 'updating work order for permit approval process= ' + aWorkOrder );
		update aWorkOrder;

		Test.stopTest();

		List<ProcessInstance> processList =
				SG_WorkOrderHelper.getProcessListForRecordIds( new Set<Id> { aWorkOrder.Id } );

		system.assertEquals( 1, processList.size(), 'workorder must now have an approval process started' );

	}

	@IsTest
	public static void flagPermitRequiredTest() {
		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Id permitRTId = ruleRegRtMap.get( 'Permit' ).getRecordTypeId();

		// create matching rules/regulations record
		Rules_Regs__c ruleReg = getNewRuleRegulation( permitRTId );
		ruleReg.Store_Client__c = store.Id;
		system.debug( 'creating Permit ruleReg= ' + ruleReg );
		insert ruleReg;

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.epaInfo_calcYrBuilt__c = '1999';
		aWorkOrder.Home_Year_Built__c = '1999';
		aWorkOrder.Job_Type_request_change__c = null;
		aWorkOrder.StateCode = 'TX';
		aWorkOrder.Integration_Key_WorkOrder__c = 'DEF456';
		system.debug( 'inserting aWorkOrder for permit= ' + aWorkOrder );
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assertEquals( SG_WorkOrderHelper.REQUIRED_RULE_REGULATION_STATE
				, aWorkOrder.Permit_Required_Calculated__c
				, 'Permit flag should be Yes' );

		system.assertEquals( SG_WorkOrderHelper.NOT_REQUIRED_RULE_REGULATION_STATE
				, aWorkOrder.RRP_Required_Calculated__c
				, 'RRP flag should be No since there is no rule/regulation for RRP' );
	}

	@IsTest
	public static void flagRRPRequiredWithDifferentYearsTest() {
		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Id rrpRTId = ruleRegRtMap.get( 'RRP' ).getRecordTypeId();

		// create matching rules/regulations record
		Rules_Regs__c ruleReg = getNewRuleRegulation( rrpRTId );
		system.debug( 'creating RRP ruleReg= ' + ruleReg );
		insert ruleReg;

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.epaInfo_calcYrBuilt__c = '1970';
		aWorkOrder.Home_Year_Built__c = '1969';
		aWorkOrder.Job_Type_request_change__c = null;
		aWorkOrder.StateCode = 'TX';
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		system.debug( 'inserting aWorkOrder for permit= ' + aWorkOrder );
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assertEquals( SG_WorkOrderHelper.REQUIRED_RULE_REGULATION_STATE_YEAR_DIFF
					, aWorkOrder.RRP_Required_Calculated__c
				, 'RRP flag should be Yes with year difference noted' );

		system.assertEquals( SG_WorkOrderHelper.NOT_REQUIRED_RULE_REGULATION_STATE
				, aWorkOrder.Permit_Required_Calculated__c
				, 'Permit flag should be No since there is no rule/regulation for Permit' );
	}

	@IsTest
	public static void flagRRPRequiredTest() {
		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Id rrpRTId = ruleRegRtMap.get( 'RRP' ).getRecordTypeId();

		// create matching rules/regulations record
		Rules_Regs__c ruleReg = getNewRuleRegulation( rrpRTId );
		ruleReg.Installation_State__c = 'TX';
		system.debug( 'creating RRP ruleReg for TX= ' + ruleReg );
		insert ruleReg;

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Job_Type_request_change__c = null;
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		system.debug( 'inserting aWorkOrder for permit= ' + aWorkOrder );
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assertEquals( SG_WorkOrderHelper.NOT_REQUIRED_RULE_REGULATION_STATE
				, aWorkOrder.Permit_Required_Calculated__c
				, 'Permit flag should be No since there is no rule/regulation for Permit' );

		system.assertEquals( SG_WorkOrderHelper.REQUIRED_RULE_REGULATION_STATE
				, aWorkOrder.RRP_Required_Calculated__c
				, 'RRP flag should be Yes' );
	}

	public static Map<String, Schema.RecordTypeInfo> ruleRegRtMap = Schema.SObjectType.Rules_Regs__c.getRecordTypeInfosByName();

	public static Rules_Regs__c getNewRuleRegulation( Id permitRTId ) {
		Rules_Regs__c ruleReg = new Rules_Regs__c();
		//ruleReg.Name = '';
		ruleReg.RecordTypeId = permitRTId;
		ruleReg.Client_Type__c = 'THD';
		ruleReg.Program__c = 'Doors';
		ruleReg.Category__c = 'Exterior Door';
		ruleReg.svcCodeType__c = 'I';
		ruleReg.Installation_State__c = 'All';
		system.debug( 'new ruleReg for testing= ' + ruleReg );
		return ruleReg;
	}

	@isTest
	public static void populateLookupTest() {
		Test.startTest();

		Account store = SG_FSLTestDataSetup.getTestStore();

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.svcTypeCode__c = 'I';
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		system.debug( 'inserting aWorkOrder= ' + aWorkOrder );
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assertEquals( 'SGI Test Installer', aWorkOrder.Installer__r.Name
				, 'Work order should now have a installer' );
		system.assert( aWorkOrder.ServiceTerritoryId != null
				, 'Work order should now have a service territory' );
		// case 3361 - we no longer want the work type to auto populate on create, remove the above from the code
//		system.assertEquals( 'Installation', aWorkOrder.WorkType.Name
//				, 'Work order should have the correct work type' );
		system.assertEquals( '123', aWorkOrder.Pricebook2.Name
				, 'Work order should have the correct pricebook' );
		system.assert( aWorkOrder.AccountId != null
				, 'Work order should have a person account' );

		// this part only applies to integration users
		system.assertEquals( null, aWorkOrder.ParentWorkOrder.svcTypeCode__c
				, 'Work order should NOT have parent work order for Measurement while changed by non-integration user' );

		// increase coverage
		Set<Id> woIdSet = new Set<Id> { aWorkOrder.Id };
		List<WorkOrderShare> newShareList = [
				SELECT Id, UserOrGroupId, UserOrGroup.Name
				FROM WorkOrderShare
				WHERE ParentId IN :woIdSet
					AND AccessLevel = 'Edit'
					AND RowCause = 'Manual'
		];
		system.assertEquals( 1, newShareList.size()
				, 'Work order shares should have been created for territory' );
		SG_WorkOrderHelper.deleteOldWorkOrderShares( woIdSet );
	}

	@isTest
	public static void populateLookupAsIntegrationUserTest() {
		Test.startTest();

		User integrationUser = [
				SELECT Id
				FROM User
				WHERE LastName = 'Integration Testing'
		];

		Account store = SG_FSLTestDataSetup.getTestStore();

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder;
		system.runAs( integrationUser ) {

			Account anotherStore = store.clone( false );
			anotherStore.Name = '2nd Store';
			insert anotherStore;

			aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( anotherStore, sku );
			aWorkOrder.svcTypeCode__c = 'I';
			aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
			system.debug( 'inserting aWorkOrder= ' + aWorkOrder );
			insert aWorkOrder;
		}

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		// this part only applies to integration users
		system.assertEquals( 'M', aWorkOrder.ParentWorkOrder.svcTypeCode__c
				, 'Work order should have parent work order for Measurement while changed by integration user' );
	}

		@isTest
	public static void validateMeasurementInstallerTest() {
		Test.startTest();

		Account store = SG_FSLTestDataSetup.getTestStore();

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		Account anInstaller = [
				SELECT Id
				FROM Account
				WHERE Name = 'SGI Test Installer'
		];

		Installers_Available__c instAvail = [
				SELECT Id, Installer_Account__c
				FROM Installers_Available__c
				WHERE Store_Account__c = :store.Id
				LIMIT 1
		];
		instAvail.SvcTypeCode__c = 'M';
		instAvail.Status__c = 'Secondary';
		update instAvail;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.svcTypeCode__c = 'M';
		aWorkOrder.Installer__c = instAvail.Installer_Account__c;
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		system.debug( 'inserting aWorkOrder= ' + aWorkOrder );
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assertEquals( 'SGI Test Installer', aWorkOrder.Installer__r.Name
				, 'Work order should now have a installer' );
	}

	@isTest
	public static void workOrderWithNewAccountTest() {
		Test.startTest();

		Account store = SG_FSLTestDataSetup.getTestStore();

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.svcTypeCode__c = 'I';
		aWorkOrder.CustomerFirstName__c = 'Mary';
		aWorkOrder.CustomerLastName__c = 'Lunchbucket';
		aWorkOrder.Integration_Key_WorkOrder__c = 'MaryLunchbucket123';
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assert( aWorkOrder.AccountId != null
				, 'Work order should have a person account' );
//		system.assert( aWorkOrder.ContactId != null
//				, 'Work order should have a person account contact' );

	}

	@isTest
	public static void workOrderWithoutAccountTest() {
		Test.startTest();

		Account store = SG_FSLTestDataSetup.getTestStore();

		// create/query objects to test
		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		// work order without full customer information should not have account assigned
		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.svcTypeCode__c = 'I';
		aWorkOrder.CustomerFirstName__c = '';
		aWorkOrder.CustomerLastName__c = 'Lunchbucket';
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assert( aWorkOrder.AccountId == null
				, 'Work order should NOT have a person account' );
		system.assert( aWorkOrder.ContactId == null
				, 'Work order should NOT have a person account contact' );

	}

	public static WorkOrder getWorkOrder( Id aWorkOrderId ) {
		WorkOrder aWorkOrder = [
				SELECT Id, Installer__c, Installer__r.Name, ServiceTerritoryId
						, WorkType.Name, Pricebook2.Name, AccountId, ContactId
						, ParentWorkOrder.svcTypeCode__c
						, RRP_Required_Calculated__c
						, Permit_Required_Calculated__c
				FROM WorkOrder
				WHERE Id = :aWorkOrderId
		];
		return aWorkOrder;
	}

	@IsTest
	public static void testDisabledTrigger() {
		Test.startTest();

		Apex_Activation_Settings__c settings = Apex_Activation_Settings__c.getInstance();
		settings = (Apex_Activation_Settings__c) ( settings == null ? settings : new Apex_Activation_Settings__c() );
		settings.Disable_WorkOrder_Triggers__c = true;
		if( settings.Id != null ) {
			update settings;
		} else {
			insert settings;
		}

		// create/query objects to test
		WorkOrder aWorkOrder = new WorkOrder();
		insert aWorkOrder;

		aWorkOrder = getWorkOrder( aWorkOrder.Id );

		Test.stopTest();

		system.assert( aWorkOrder.Installer__c == null
				, 'Work order should NOT have a installer' );
	}

	@IsTest
	public static void statusHistoryTrackingTest() {
		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Primary_Field_Manager__c = UserInfo.getUserId();
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		aWorkOrder.Status = 'Open';
		aWorkOrder.Sub_Status__c = 'Pending Initial Contact';
		insert aWorkOrder;

		//SG_WorkOrderHelper.statusChangesAlreadyProcessedSet.clear();
		SG_WorkOrderHelper.recordIdsAlreadySharedSet.clear();
		SG_WorkOrderHelper.integrationKeysAlreadySharedSet.clear();

		aWorkOrder.Status = 'Scheduled';
		aWorkOrder.Sub_Status__c = 'Scheduled';
		system.debug( 'updating work order for status tracking= ' + aWorkOrder );
		update aWorkOrder;

		Test.stopTest();

		List<Work_Order_History__c> statusHistoryList = [
				SELECT Id, Date_Time_of_Change__c
				, Status_Changed_to__c, Sub_Status_Changed_To__c
				FROM Work_Order_History__c
				WHERE Work_Order__c = :aWorkOrder.Id
				ORDER BY Date_Time_of_Change__c
		];

		system.assertEquals( 2, statusHistoryList.size(), 'status history should have 2 records' );
		system.assertEquals( 'Pending Initial Contact', statusHistoryList[ 0 ].Sub_Status_Changed_To__c
				, 'status history should contain PAST sub status' );
		system.assertEquals( 'Scheduled', statusHistoryList[ 1 ].Sub_Status_Changed_To__c
				, 'status history should contain CURRENT sub status' );

	}
}