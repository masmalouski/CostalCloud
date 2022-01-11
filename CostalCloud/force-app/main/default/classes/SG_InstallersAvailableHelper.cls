/***************************************************
* Name:         SG_InstallersAvailableHelper
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         12 May 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       12 May 2021     FMF     Initial Development
* 
****************************************************/

public with sharing class SG_InstallersAvailableHelper {
	public static Set<ID> recordIdsAlreadyProcessedSet = new Set<ID>();

	public static void validateInstaller( TriggerOperation operationType, List<Installers_Available__c> newList
			, Map<ID, Installers_Available__c> oldMap ) {

		// When an Installer is "assigned" to a client such as Home Depot we need something that compares
		// the required licenses identified on client account to all active licenses on the installer
		// account and only allow the relationship if they have a correct match. Exception is if the installer
		// have more licenses than what the customer require. Suggest by start comparing the total number of
		// active licenses at installer. If installer has 3 and client require 4 then it is already rejected.
		// If the installer has 4 or more and client require 4 then compare data elements between the two.
		//
		// There is an expiration date on the license that the installer has. When the license is expired we
		// need the related list between the client and the installer to reflect that the license has "expired".
		// Installer_Account__c, Job_Type_Category__c, Status__c, Store_Account__c
		//
		// prevent more than one primary installer per category, job type and store

		if( operationType != TriggerOperation.BEFORE_INSERT
				&& operationType != TriggerOperation.BEFORE_UPDATE ) {
			return;
		}

		// collect store and installer Ids
		Set<ID> accountIDset = getAccountIds( newList, oldMap );
		if( accountIDset.isEmpty() ) {
			return;
		}

		// get existing primary installers
		Map<String, Installers_Available__c> primaryInstallerMap = getPrimaryInstallersMap( accountIDset );

		// collect and separate license Ids per parent account
		// Matching_Key__c is a concatenation of fields to match licenses
		List<Licenses__c> licenseList = getStoreLicenseList( accountIDset );
		Map<Id, Set<String>> licensesPerAccountMap = getLicensesPerAccount( licenseList );

		// check installer licenses against store required licenses
		for( Installers_Available__c anInstallerAvailable : newList ) {
			Installers_Available__c oldInstaller = ( oldMap != null ?
							oldMap.get( anInstallerAvailable.Id ) : null );

			// check if there already is a primary installer available
			// when updating:  check if status has been changed to Primary
			if( anInstallerAvailable.Status__c == 'Primary'
					&& ( oldInstaller == null || oldInstaller.Status__c != anInstallerAvailable.Status__c ) ) {
				String theKey = anInstallerAvailable.Store_Account__c
								+ '^' + anInstallerAvailable.Category__c
								+ '^' + anInstallerAvailable.Job_Type__c
								+ '^' + anInstallerAvailable.SvcTypeCode__c;
				system.debug( 'checking key= ' + theKey );
				if( primaryInstallerMap.containsKey( theKey ) ) {
					anInstallerAvailable.addError( 'Store '
							+ anInstallerAvailable.Store_Name__c + ' already has a primary installer for '
							+ anInstallerAvailable.Category__c + ' / ' + anInstallerAvailable.Job_Type__c
							+ ' / svc type code ' + anInstallerAvailable.SvcTypeCode__c );
					continue;
				}
			}

			Set<String> requiredLicenseSet = licensesPerAccountMap.get( anInstallerAvailable.Store_Account__c );
			if( requiredLicenseSet == null ) {
				// store doesn't require any licenses
				continue;
			}

			Set<String> installerLicenseSet = licensesPerAccountMap.get( anInstallerAvailable.Installer_Account__c );
			if( installerLicenseSet == null ) {
				// report installer without licenses
				String missingLicenseList = getMissingLicenseList( requiredLicenseSet, new Set<String>() );
				anInstallerAvailable.addError( 'Installer doesn\'t have any required active licenses for store '
											+ anInstallerAvailable.Store_Name__c + '.'
											+ ' Missing licenses:  ' + missingLicenseList );
				continue;
			}

			if( installerLicenseSet.containsAll( requiredLicenseSet ) ) {
				// installer has all required licenses
				continue;
			}

			// installer is missing licenses
			// identify which licenses are missing
			String missingLicenseList = getMissingLicenseList( requiredLicenseSet, installerLicenseSet );

			anInstallerAvailable.addError( 'Installer doesn\'t have enough active licenses for store '
					+ anInstallerAvailable.Store_Name__c + '.'
					+ ' Missing licenses:  ' + missingLicenseList );
		}
	}

	public static String getMissingLicenseList( Set<String> requiredLicenseSet, Set<String> installerLicenseSet ) {
		Set<String> missingLicenseSet = requiredLicenseSet.clone();
		missingLicenseSet.removeAll( installerLicenseSet );

		String missingLicenseList = '';
		for( String aLicenseMatchingKey : missingLicenseSet ) {
			// type is the first field in the concatenated formula
			String licenseType = aLicenseMatchingKey.substringBefore( '^' );
			//system.debug( 'aLicenseMatchingKey= ' + aLicenseMatchingKey );
			//system.debug( 'licenseType= ' + licenseType );
			missingLicenseList = missingLicenseList + ', ' + licenseType;
		}
		if( missingLicenseList.length() > 2 ) {
			missingLicenseList = missingLicenseList.substring( 2 );
		}
		system.debug( 'missingLicenseList= ' + missingLicenseList );
		return missingLicenseList;
	}

	public static Set<ID> getAccountIds( List<Installers_Available__c> newList
								, Map<ID, Installers_Available__c> oldMap ) {
		Set<ID> accountIDset = new Set<ID>();
		for( Installers_Available__c anInstallerAvailable : newList ) {
			if( recordIdsAlreadyProcessedSet.contains( anInstallerAvailable.ID ) ) {
				continue;
			}
			if( anInstallerAvailable.ID != null ) {
				recordIdsAlreadyProcessedSet.add( anInstallerAvailable.ID );
			}

			// skip if no relevant field has changed
			Installers_Available__c oldInstaller = ( oldMap != null ?
							oldMap.get( anInstallerAvailable.Id ) : null );
			if( oldInstaller != null && oldInstaller.Status__c != anInstallerAvailable.Status__c
					&& oldInstaller.Store_Account__c != anInstallerAvailable.Store_Account__c
					&& oldInstaller.Category__c != anInstallerAvailable.Category__c
					&& oldInstaller.Job_Type__c != anInstallerAvailable.Job_Type__c
					&& oldInstaller.SvcTypeCode__c != anInstallerAvailable.SvcTypeCode__c ) {
				continue;
			}

			// collect account Ids in the same set - will run a single query for both
			accountIDset.add( anInstallerAvailable.Store_Account__c );
			accountIDset.add( anInstallerAvailable.Installer_Account__c );
		}
		system.debug( 'accountIDset= ' + accountIDset );
		return accountIDset;
	}

	public static Map<String, Installers_Available__c> getPrimaryInstallersMap( Set<Id> storeIDset ) {
		List<Installers_Available__c> primaryInstallerList = [
				SELECT Id, Name, Store_Account__c, Category__c, Job_Type__c, SvcTypeCode__c, Percent__c
				FROM Installers_Available__c
				WHERE Store_Account__c IN :storeIDset
					AND Status__c = 'Primary'
		];
		system.debug( 'primaryInstallerList= ' + primaryInstallerList );

		Map<String, Installers_Available__c> primaryInstallerMap = new Map<String, Installers_Available__c>();
		for( Installers_Available__c anInstaller : primaryInstallerList ) {
			String theKey = anInstaller.Store_Account__c
					+ '^' + anInstaller.Category__c + '^' + anInstaller.Job_Type__c
					+ '^' + anInstaller.SvcTypeCode__c;
			primaryInstallerMap.put( theKey, anInstaller );
		}
		system.debug( 'primaryInstallerMap= ' + primaryInstallerMap );

		return primaryInstallerMap;
	}

	public static List<Licenses__c> getStoreLicenseList( Set<Id> storeIDset ) {
		// store required doesn't need status Active
		List<Licenses__c> licenseList = [
				SELECT Id, Name, Account__c, Account__r.Name
						, RecordType.Name, City__c
						, Expiration_Date__c, Type__c, Status__c
						, Matching_Key__c
				FROM Licenses__c
				WHERE Account__c IN :storeIDset
					AND ( RecordType.Name = 'Store Required License'
						OR Status__c = 'Active' )
		];
		// 20210916 - removed , State__c as per Eva
		system.debug( 'licenseList= ' + licenseList );
		return licenseList;
	}

	public static Map<Id, Set<String>> getLicensesPerAccount( List<Licenses__c> licenseList ) {
		Map<Id, Set<String>> licensesPerAccountMap = new Map<Id, Set<String>>();
		for( Licenses__c aLicense : licenseList ) {
			Set<String> licenseMatchingKeySet = licensesPerAccountMap.get( aLicense.Account__c );
			if( licenseMatchingKeySet == null ) {
				licenseMatchingKeySet = new Set<String>();
			}
			licenseMatchingKeySet.add( aLicense.Matching_Key__c );
			licensesPerAccountMap.put( aLicense.Account__c, licenseMatchingKeySet );
		}
		system.debug( 'licensesPerAccountMap= ' + licensesPerAccountMap );
		return licensesPerAccountMap;
	}

}