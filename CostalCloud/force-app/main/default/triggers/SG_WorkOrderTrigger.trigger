/***************************************************
* Name:         SG_WorkOrderTrigger
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

trigger SG_WorkOrderTrigger on WorkOrder ( before insert, before update
										, after insert, after update, after delete, after undelete ) {
	if( SG_ApexActivator.isDisabled('Disable WorkOrder Triggers') ) {
		System.debug( 'Trigger disabled by Apex Activation Settings Custom Setting.' );
		return;
	}

	// before
	SG_WorkOrderHelper.populateLookups( Trigger.operationType, Trigger.new, Trigger.oldMap );
	SG_WorkOrderHelper.flagPermitOrRRPRequired( Trigger.operationType, Trigger.new, Trigger.oldMap );
	SG_WorkOrderHelper.startGenericApprovalProcesses( Trigger.operationType, Trigger.new, Trigger.oldMap );


	// before
	if(Trigger.operationType == TriggerOperation.BEFORE_UPDATE && SG_PONotesHelper.processPONOtes_Ran == false)
	{
		SG_PONotesHelper.processPONOtes(Trigger.operationType, Trigger.new);
	}

	SG_WorkOrderHelper.WorkOrderCollections theCollections = SG_WorkOrderHelper.collectDataFromWorkOrder(
													Trigger.operationType, Trigger.new, Trigger.oldMap );
	if( theCollections != null ) {

		SG_WorkOrderHelper.trackStatusChanges( theCollections.newWorkOrderHistoryMap );
	}

	// 11/16/2021 - fire the sharing portion whenever installer changes, regardless of any other criteria
	SG_WorkOrderHelper.createAndDeleteShares( Trigger.operationType, Trigger.new, Trigger.oldMap );

	// 11/17/2021 -- update the SA Territory if changed
	SG_WorkOrderHelper.syncSATerritories( Trigger.operationType, Trigger.new, Trigger.oldMap );

	//SG_WorkOrderHelper.createAndDeleteShares( Trigger.operationType, Trigger.new, Trigger.oldMap );
	//SG_WorkOrderHelper.trackStatusChanges( Trigger.operationType, Trigger.new, Trigger.oldMap );

	// do rollups...
	SG_WorkOrderHelper.doRollups( Trigger.operationType, Trigger.new, Trigger.oldMap );
}