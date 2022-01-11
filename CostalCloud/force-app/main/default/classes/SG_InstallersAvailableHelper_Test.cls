/***************************************************
* Name:         SG_InstallersAvailableHelper_Test
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         18 May 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       18 May 2021     FMF     Initial Development
* 
****************************************************/

@isTest
public with sharing class SG_InstallersAvailableHelper_Test {
	@TestSetup
	public static void setupData() {

		List<Account> accountList = SG_FSLTestDataSetup.getNewStoreInstallerAccounts();
		insert accountList;
		Account anInstaller = accountList[ 0 ];
		Account aStore = accountList[ 1 ];

		List<Licenses__c> licenseList = new List<Licenses__c>();
		Licenses__c installerLicense = SG_FSLTestDataSetup.getNewLicense(
						SG_FSLTestDataSetup.installerLicenseRTId, anInstaller.Id );
		licenseList.add( installerLicense );

		Licenses__c storeRequiredLicense = SG_FSLTestDataSetup.getNewLicense(
						SG_FSLTestDataSetup.requiredLicenseRTId, aStore.Id );
		licenseList.add( storeRequiredLicense );

		insert licenseList;
	}

	@isTest
	public static void successfullyInsertInstallerAvailableTest() {
		Test.startTest();

		// create/query objects to test
		// installer first, then store
		List<Account> accountList = SG_FSLTestDataSetup.getAccounts();

		Installers_Available__c instAvail =
				SG_FSLTestDataSetup.getNewInstallerAvailable(
						accountList[ 0 ].Id, accountList[ 1 ].Id );

		String error = '';
		try {
			insert instAvail;
		} catch( Exception e ) {
			error = e.getMessage();
		}

		Test.stopTest();

		system.assertEquals( '', error, 'Installer_Available__c record should be inserted with no errors' );
	}

	@isTest
	public static void installerAvailableValidationTest() {
		Test.startTest();

		// create/query objects to test
		// installer first, then store
		List<Account> accountList = SG_FSLTestDataSetup.getAccounts();

		// add required license to store, this is a license that the installer doesn't have
		Licenses__c storeRequiredLicense = SG_FSLTestDataSetup.getNewLicense(
				SG_FSLTestDataSetup.requiredLicenseRTId, accountList[ 1 ].Id );
		storeRequiredLicense.Type__c = 'Certified Firm';
		storeRequiredLicense.Certified_Firm__c = 'FEDERAL';
		insert storeRequiredLicense;

		Installers_Available__c instAvail = new Installers_Available__c();
		instAvail.Installer_Account__c = accountList[ 0 ].Id;
		instAvail.Store_Account__c = accountList[ 1 ].Id;
		instAvail.Status__c = 'Primary';

		String error = '';
		try {
			insert instAvail;
		} catch( Exception e ) {
			error = e.getMessage();
		}

		Test.stopTest();

		system.assertEquals( null, instAvail.Id, 'Installer_Available__c record should NOT be inserted' );
		system.assert( error.containsIgnoreCase( 'Installer doesn\'t have enough active licenses for store' )
				, 'Installer_Available__c insert should result in error' );
	}

	@isTest
	public static void primaryInstallerValidationTest() {
		Test.startTest();

		// create/query objects to test
		// installer first, then store
		List<Account> accountList = SG_FSLTestDataSetup.getAccounts();

		Installers_Available__c instAvail = SG_FSLTestDataSetup.getNewInstallerAvailable(
				accountList[ 0 ].Id, accountList[ 1 ].Id );
		// satisfy validation rule
		instAvail.Percent__c = .5;
		system.debug( 'inserting instAvail= ' + instAvail );
		insert instAvail;

		// second installer expected to fail validation
		Installers_Available__c instAvail2 = instAvail.clone( false );

		String error = '';
		try {
			system.debug( 'inserting instAvail2= ' + instAvail2 );
			insert instAvail2;
		} catch( Exception e ) {
			error = e.getMessage();
		}

		Test.stopTest();

		system.assertEquals( null, instAvail2.Id
					, 'Second primary Installer_Available__c record should NOT be inserted' );
		system.assert( error.containsIgnoreCase( 'already has a primary installer for' )
				, 'Second primary Installer_Available__c insert should result in error' );
	}

	@isTest
	public static void installerAvailableNoLicenseTest() {
		Test.startTest();

		// create/query objects to test
		// installer first, then store
		List<Account> accountList = SG_FSLTestDataSetup.getAccounts();

		// remove licenses from installer
		delete [
				SELECT Id
				FROM Licenses__c
				WHERE Account__c = :accountList[ 0 ].Id
		];

		Installers_Available__c instAvail = SG_FSLTestDataSetup.getNewInstAvailWithoutDependencies(
						accountList[ 0 ].Id, accountList[ 1 ].Id );

		String error = '';
		try {
			insert instAvail;
		} catch( Exception e ) {
			error = e.getMessage();
		}

		Test.stopTest();

		system.assertEquals( null, instAvail.Id, 'Installer_Available__c record should NOT be inserted' );
		system.assert( error.containsIgnoreCase( 'Installer doesn\'t have any required active licenses for store' )
				, 'Installer_Available__c insert should result in error' );
	}

	@IsTest
	public static void testDisabledTrigger() {
		Test.startTest();

		Apex_Activation_Settings__c settings = Apex_Activation_Settings__c.getInstance();
		settings = (Apex_Activation_Settings__c) ( settings == null ? settings : new Apex_Activation_Settings__c() );
		settings.Disable_Installers_Available_Triggers__c = true;
		if( settings.Id != null ) {
			update settings;
		} else {
			insert settings;
		}

		// create/query objects to test
		List<Account> accountList = SG_FSLTestDataSetup.getAccounts();

		Installers_Available__c instAvail = SG_FSLTestDataSetup.getNewInstAvailWithoutDependencies(
				accountList[ 0 ].Id, accountList[ 1 ].Id );
		insert instAvail;

		Test.stopTest();
	}
}