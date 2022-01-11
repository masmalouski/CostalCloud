/***************************************************
* Name:         SG_AccountHelper
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

public with sharing class SG_AccountHelper {
	public static Set<ID> recordIdsAlreadyProcessedSet = new Set<ID>();

    // We will need a validation rule to ensure that no 2 installer accounts
    // can be created with the exact same name (installer account type only).

	public static void validateInstaller( TriggerOperation operationType
            , List<Account> newList, Map<ID, Account> oldMap ) {

		if( operationType != TriggerOperation.BEFORE_INSERT
				&& operationType != TriggerOperation.BEFORE_UPDATE ) {
			return;
		}

		Set<String> installerNameSet = new Set<String>();
        Set<Id> installerIdSet = new Set<Id>();
		for( Account anAccount : newList ) {
			if( recordIdsAlreadyProcessedSet.contains( anAccount.ID ) ) {
				continue;
			}
            if( anAccount.Id != null ) {
                recordIdsAlreadyProcessedSet.add( anAccount.ID );
            }

            // validate only installers
            if( anAccount.RecordTypeId == SG_FSLTestDataSetup.installerRTId ) {
                installerNameSet.add( anAccount.Name );
                installerIdSet.add( anAccount.Id );
            }
		}
        system.debug( 'installerNameSet= ' + installerNameSet );
        system.debug( 'installerIdSet= ' + installerIdSet );

        if( installerNameSet.isEmpty() ) {
            return;
        }

        // get other installers with same name
        Map<String, Account> accountMap = getInstallerMap( installerIdSet, installerNameSet );

        reportDuplicates( newList, accountMap );
	}

    public static void reportDuplicates( List<Account> newList, Map<String, Account> accountMap ) {
        for( Account anAccount : newList ) {
            // skip non-installers
            if( anAccount.RecordTypeId != SG_FSLTestDataSetup.installerRTId ) {
                continue;
            }

            Account existingInstaller = accountMap.get( anAccount.Name );
            if( existingInstaller != null ) {
                system.debug( 'There is already an installer with the name ' + anAccount.Name );
                anAccount.addError( 'There is already an installer with the name ' + anAccount.Name );
                continue;
            }
        }
    }

    public static Map<String, Account> getInstallerMap( Set<Id> installerIdSet, Set<String> installerNameSet ) {
        List<Account> installerList = [
                SELECT Id, Name, RecordTypeId
                FROM Account
                WHERE Id NOT IN :installerIdSet
                    AND Name IN :installerNameSet
                    AND RecordTypeId = :SG_FSLTestDataSetup.installerRTId
        ];
        system.debug( 'installerList= ' + installerList );

        Map<String, Account> accountMap = new Map<String, Account>();
        for( Account anAccount : installerList ) {
            accountMap.put( anAccount.Name, anAccount );
        }

        return accountMap;
    }

}