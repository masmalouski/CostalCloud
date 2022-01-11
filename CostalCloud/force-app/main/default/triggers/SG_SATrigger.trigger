/**********************************************************************
* Name:     SG_SATrigger
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
*  
* ======================================================
* ======================================================
* Purpose:                                                      
* 
* ======================================================
* ======================================================
* History:                                                            
* VERSION   DATE            INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0       06-Aug-2021     rwd           Initial Development           
*   
***********************************************************************/


trigger SG_SATrigger on ServiceAppointment ( before insert, before update
											, after insert, after update ) {

    if ( SG_ApexActivator.isDisabled( 'Disable_SA_Triggers__c' ) ) {
		System.debug( '---> SG_SATrigger; this trigger has been disabled via Custom Setting' );
		return;
	}

	SG_SAHeper.syncWorkOrderDates( Trigger.operationType, Trigger.new, Trigger.oldMap );

	SG_SAHeper.doMatchInstaller( Trigger.operationType, Trigger.new, Trigger.oldMap );


}