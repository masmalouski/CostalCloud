/***************************************************
* Name:         SG_InstallersAvailableTrigger
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

trigger SG_InstallersAvailableTrigger on Installers_Available__c ( before insert, before update ) {
	if( SG_ApexActivator.isDisabled('Disable Installers Available Triggers') ) {
		System.debug( 'Trigger disabled by Apex Activation Settings Custom Setting.' );
		return;
	}

	SG_InstallersAvailableHelper.validateInstaller( Trigger.operationType, Trigger.new, Trigger.oldMap );
}