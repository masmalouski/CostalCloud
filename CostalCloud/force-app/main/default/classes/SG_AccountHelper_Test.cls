/***************************************************
* Name:         SG_AccountHelper_Test
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         14 Jun 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       14 Jun 2021     FMF     Initial Development
* 
****************************************************/

@isTest
public with sharing class SG_AccountHelper_Test {
	@TestSetup
	public static void setupData() {
		Account a = getNewAccount();
		insert a;

	}

	public static Account getNewAccount() {
		Account a = new Account();
		a.Name = 'SGI Test INSTALLER One';
		a.RecordTypeId = SG_FSLTestDataSetup.installerRTId;
		return a;
	}

	@isTest
	public static void duplicateNameTest() {
		Test.startTest();

		// create/query objects to test
		Account a = getNewAccount();

		String errorMsg;
		try {
			insert a;
		} catch( Exception e ) {
			errorMsg = e.getMessage();
		}

		Test.stopTest();

		system.assert( errorMsg.containsIgnoreCase( 'There is already an installer with the name' )
				, 'duplicate name account should fail validation' );
	}

	@isTest
	public static void nonDuplicateNameTest() {
		Test.startTest();

		// create/query objects to test
		Account a = getNewAccount();
		a.Name = 'Non-duplicate Name';

		String errorMsg;
		try {
			insert a;
		} catch( Exception e ) {
			errorMsg = e.getMessage();
		}

		Test.stopTest();

		system.assert( errorMsg == null
				, 'non-duplicate name account should pass validation' );
	}

	@IsTest
	public static void testDisabledTrigger() {
		Test.startTest();

		Apex_Activation_Settings__c settings = Apex_Activation_Settings__c.getInstance();
		settings = (Apex_Activation_Settings__c) ( settings == null ? settings : new Apex_Activation_Settings__c() );
		settings.Disable_Account_Triggers__c = true;
		if( settings.Id != null ) {
			update settings;
		} else {
			insert settings;
		}

		// create/query objects to test
		Account a = getNewAccount();

		String errorMsg;
		try {
			insert a;
		} catch( Exception e ) {
			errorMsg = e.getMessage();
		}

		Test.stopTest();

		system.assert( errorMsg == null
				, 'validation should not apply' );
	}
}