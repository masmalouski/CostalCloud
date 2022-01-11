/***************************************************
* Name:         SG_SAHelper_Test
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         09 Sep 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       09 Sep 2021     FMF     Initial Development
*
****************************************************/

@IsTest
public with sharing class SG_SAHelper_Test {
	@TestSetup
	public static void setupData() {
		List<Account> accountList = SG_FSLTestDataSetup.getNewStoreInstallerAccounts();
		insert accountList;
	}

	@IsTest
	public static void testWorkOrderDates() {

		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Primary_Field_Manager__c = UserInfo.getUserId();
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		insert aWorkOrder;

		ServiceAppointment svcAppt = SG_FSLTestDataSetup.getNewServiceAppointment( aWorkOrder );
		svcAppt.Status = SG_SAHeper.APPT_STATUS_DISPATCHED;
		svcAppt.SchedStartTime = Datetime.now().addDays( 12 );
		svcAppt.SchedEndTime = Datetime.now().addDays( 14 );
		insert svcAppt;

		Test.stopTest();

		aWorkOrder = [
				SELECT Id, StartDate, EndDate, Sub_Status__c
				FROM WorkOrder
				WHERE Id = :aWorkOrder.Id
		];

		system.assertEquals( svcAppt.SchedStartTime.date(), aWorkOrder.StartDate.date()
										, 'WO start date must match svc appt' );
		system.assertEquals( svcAppt.SchedEndTime.date(), aWorkOrder.EndDate.date()
										, 'WO end date must match svc appt' );
		system.assertEquals( SG_SAHeper.WO_SUBSTATUS_SCHEDULED, aWorkOrder.Sub_Status__c
										, 'WO sub status must be Scheduled' );
	}

	@IsTest
	public static void testResetWorkOrderDates() {

		Test.startTest();

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Primary_Field_Manager__c = UserInfo.getUserId();
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		insert aWorkOrder;

		ServiceAppointment svcAppt = SG_FSLTestDataSetup.getNewServiceAppointment( aWorkOrder );
		svcAppt.Status = SG_SAHeper.APPT_STATUS_CANCELED;
		svcAppt.SchedStartTime = Datetime.now().addDays( 2 );
		svcAppt.SchedEndTime = Datetime.now().addDays( 4 );
		insert svcAppt;

		Test.stopTest();

		aWorkOrder = [
				SELECT Id, StartDate, EndDate, Sub_Status__c
				FROM WorkOrder
				WHERE Id = :aWorkOrder.Id
		];

		system.assertEquals( null, aWorkOrder.StartDate, 'WO start date must be null' );
		system.assertEquals( null, aWorkOrder.EndDate, 'WO end date must be null' );
		system.assertEquals( SG_SAHeper.WO_SUBSTATUS_CANCELED, aWorkOrder.Sub_Status__c
				, 'WO sub status must be Canceled' );
	}

	@IsTest
	public static void testDisabledTrigger() {
		Test.startTest();

		Apex_Activation_Settings__c settings = Apex_Activation_Settings__c.getInstance();
		settings = (Apex_Activation_Settings__c) ( settings == null ? settings : new Apex_Activation_Settings__c() );
		settings.Disable_SA_Triggers__c = true;
		if( settings.Id != null ) {
			update settings;
		} else {
			insert settings;
		}

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		insert aWorkOrder;

		ServiceAppointment svcAppt = SG_FSLTestDataSetup.getNewServiceAppointment( aWorkOrder );
		svcAppt.Status = SG_SAHeper.APPT_STATUS_CANCELED;
		svcAppt.SchedStartTime = Datetime.now().addDays( 2 );
		svcAppt.SchedEndTime = Datetime.now().addDays( 4 );
		insert svcAppt;

		Test.stopTest();
	}

	@IsTest
	public static void testXrefMatch() {

		// create/query objects to test
		Account store = SG_FSLTestDataSetup.getTestStore();
		Account installer = SG_FSLTestDataSetup.getNewStoreInstallerAccounts()[0];

		Job_SKU__c sku = SG_FSLTestDataSetup.getNewSku();
		insert sku;

		WorkOrder aWorkOrder = SG_FSLTestDataSetup.getNewWorkOrder( store, sku );
		aWorkOrder.Primary_Field_Manager__c = UserInfo.getUserId();
		aWorkOrder.Integration_Key_WorkOrder__c = 'ABC123';
		insert aWorkOrder;

		ServiceAppointment svcAppt = SG_FSLTestDataSetup.getNewServiceAppointment( aWorkOrder );
		svcAppt.Status = SG_SAHeper.APPT_STATUS_CANCELED;
		svcAppt.SchedStartTime = Datetime.now().addDays( 2 );
		svcAppt.SchedEndTime = Datetime.now().addDays( 4 );
		insert svcAppt;


		TCS_Resource_Cross_Reference__c xref = new TCS_Resource_Cross_Reference__c();
		String unique = 'Xref XYZ zdf__ ' + String.valueOf( Crypto.getRandomInteger() );
		xref.Name = unique;
		xref.Unique_Name__c = unique;
		xref.Installer_Account__c = installer.Id;
		insert xref;

		svcAppt = [SELECT Id, Installer__c FROM ServiceAppointment WHERE Id = :svcAppt.Id LIMIT 1];
		System.assertEquals(null, svcAppt.Installer__c );

		Test.startTest();
		SG_SAHeper.hasMatchedInstaller = false;
		svcAppt.TCS_Assigned_Resource__c = unique;
		update svcAppt;
		Test.stopTest();

		svcAppt = [SELECT Id, Installer__c FROM ServiceAppointment WHERE Id = :svcAppt.Id LIMIT 1];
		System.assertEquals( svcAppt.Installer__c, installer.Id );
	}


}