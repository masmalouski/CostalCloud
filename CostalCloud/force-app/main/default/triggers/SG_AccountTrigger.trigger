/***************************************************
* Name:         SG_AccountTrigger
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

trigger SG_AccountTrigger on Account (before insert, before update) {
	if( SG_ApexActivator.isDisabled('Disable Account Triggers') ) {
		System.debug( 'Trigger disabled by Apex Activation Settings Custom Setting.' );
		return;
	}

	SG_AccountHelper.validateInstaller( Trigger.operationType, Trigger.new, Trigger.oldMap );
}