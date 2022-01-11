/**********************************************************************
* Name:     SG_SAHeper
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
* 1.1       09-Sep-2021     fmf             Adding code to sync StartDate/EndDate in Work Order
*   
***********************************************************************/


public class SG_SAHeper {
	public static final String APPT_STATUS_SCHEDULED = 'Scheduled';
	public static final String APPT_STATUS_DISPATCHED = 'Dispatched';
	public static final String APPT_STATUS_CANCELED = 'Canceled';
	public static final String WO_SUBSTATUS_SCHEDULED = 'Scheduled';
	public static final String WO_SUBSTATUS_CANCELED = 'Customer Cancelled';

	public static Boolean hasMatchedInstaller = false;


	/*
		•	When SA is created and has value in TCS_Assigned_Resource__c
	o	Find matching value in Xref table
	o	When match found – populate the Installer Account
		Search on the Unique Name of the TCS Cross Reference object
	 */
    public static void doMatchInstaller(System.TriggerOperation triggerEvent, List<ServiceAppointment> newObjs, Map<Id, ServiceAppointment> oldObjs)
	{
		System.debug(LoggingLevel.WARN, '---> start doMatchInstaller');

		// set the enum of allowed trigger operations (before insert, after update, etc)
		List<TriggerOperation> triggerTypes = new List<TriggerOperation>{
				TriggerOperation.AFTER_INSERT
				, TriggerOperation.AFTER_UPDATE
		};
		if ( !SG_DisplayUtils.canFireTrigger( triggerEvent, triggerTypes, hasMatchedInstaller) )
		{
			System.debug(LoggingLevel.WARN, '---> already hasMatchedInstaller: ' + hasMatchedInstaller + ' or wrong trigger type; skip');
			return;
		}

		// prevents recursive triggers
		hasMatchedInstaller = true;
		
		if ( newObjs != null && newObjs.size() > 0 )
		{
			Map<String, List<ServiceAppointment>> installerMap = new Map<String, List<ServiceAppointment>>();
			List<ServiceAppointment> updateList = new List<ServiceAppointment>();

			for ( ServiceAppointment newObj : newObjs )
			{
				ServiceAppointment oldObj;
				if ( oldObjs != null && oldObjs.keySet().size() > 0 )
				{
					oldObj = oldObjs.get( newObj.Id );
				}
				if ( String.isNotBlank( newObj.TCS_Assigned_Resource__c) && SG_DisplayUtils.hasChanged( oldObj, newObj, 'TCS_Assigned_Resource__c'))
				{
					List<ServiceAppointment> tmpList = installerMap.get( newObj.TCS_Assigned_Resource__c );
					if ( tmpList == null ) tmpList = new List<ServiceAppointment>();
					tmpList.add( newObj );
					installerMap.put( newObj.TCS_Assigned_Resource__c, tmpList );

				}
			}

			System.debug(LoggingLevel.WARN, '---> installers to match: ' + installerMap );
			// find matching installers in the XREF
			if ( installerMap != null && installerMap.keySet().size() > 0 )
			{
				for ( TCS_Resource_Cross_Reference__c xref : [SELECT Id, Name, Installer_Account__c, Unique_Name__c FROM TCS_Resource_Cross_Reference__c WHERE Unique_Name__c IN :installerMap.keySet() ])
				{
					// was this causing null reference?
					List<ServiceAppointment> innerSvcApptList = installerMap.get( xref.Unique_Name__c );
					if( innerSvcApptList == null ) {
						continue;
					}

					for ( ServiceAppointment sa : innerSvcApptList )
					{
						// create a new reference for update...
						ServiceAppointment tmpSa = new ServiceAppointment(id=sa.Id);
						tmpSa.Installer__c = xref.Installer_Account__c;
						updateList.add( tmpSa );
					}
				}

				System.debug(LoggingLevel.WARN, '---> SAs to update: ' + updateList );
				if ( updateList != null && !updateList.isEmpty() )
				{
					System.debug(LoggingLevel.WARN, '---> updating Service Appointments with installers...');
					String errMsg = SG_DB.updateRecords( updateList );
					System.debug(LoggingLevel.WARN, '---> errMsg: ' + errMsg );

				}
			}

		}
	}

	public static Set<Id> svcApptIdsAlreadyProcessedSet = new Set<Id>();
	public static void syncWorkOrderDates( TriggerOperation operationType
			, List<ServiceAppointment> newList, Map<Id, ServiceAppointment> oldMap ) {

		//if( operationType != TriggerOperation.BEFORE_INSERT
		//		&& operationType != TriggerOperation.BEFORE_UPDATE ) {
		//	return;
		//}
		if( operationType != TriggerOperation.AFTER_INSERT
				&& operationType != TriggerOperation.AFTER_UPDATE ) {
			return;
		}
		system.debug( '*** starting syncWorkOrderDates ***' );

		// 1) A work order may have multiple Service Appointments.
		// The first time a work order has a related Service Appointment and the
		// Service Appointment Status is changed to either Scheduled or Dispatched
		// and has a value in SchedStartTime and SchedEndTime (standard date/time
		// svc appointment fields)
		//
		// Populate these 2 standard fields on the work order: StartDate, EndDate
		// Update the Work Order "Sub_Status__c" field value to "Scheduled"
		//
		// If the related service appointment status is changed to "Canceled"
		// remove the start/end date values on the work order and revert the
		// work order sub status to Customer Cancelled

		// 11/9/2021 - we want to maintain the dates, regardless of status

		SObjectType workOrderType = Schema.WorkOrder.SObjectType;

		//List<WorkOrder> workOrderList = new List<WorkOrder>();
		Map<Id, WorkOrder> updateWoMap = new Map<Id, WorkOrder>();
		for( ServiceAppointment anAppointment : newList ) {
			if( recordIsAlreadyProcessed( svcApptIdsAlreadyProcessedSet, anAppointment.Id ) ) {
				continue;
			}

			// skip if unchanged or irrelevant changes or missing dates
			//ServiceAppointment oldAppointment = ( oldMap != null ? oldMap.get( anAppointment.Id ) : null );
			/*Boolean statusHasNotChanged = (
							oldAppointment != null
							&& oldAppointment.Status == anAppointment.Status
			);*/
			Boolean currentStatusScheduledDispatched = (
							anAppointment.Status == APPT_STATUS_SCHEDULED
							|| anAppointment.Status == APPT_STATUS_DISPATCHED
			);
			/*Boolean currentStatusIsIrrelevant = (
							! currentStatusScheduledDispatched
							&& anAppointment.Status != APPT_STATUS_CANCELED
			);*/
			/*Boolean datesAreEmpty = (
							anAppointment.SchedStartTime == null
							&& anAppointment.SchedEndTime == null
			);*/
			Boolean parentNotWorkOrder = (
					anAppointment.ParentRecordId == null
					|| anAppointment.ParentRecordId.getSobjectType() != workOrderType
			);
			if(  parentNotWorkOrder ) {
				continue;
			}

			/*
			if( statusHasNotChanged || currentStatusIsIrrelevant
					|| datesAreEmpty || parentNotWorkOrder ) {
				continue;
			}
			 */

			// instantiate work order to update it with the right substatus/dates
			String subStatus = ( currentStatusScheduledDispatched ?
								WO_SUBSTATUS_SCHEDULED : WO_SUBSTATUS_CANCELED );
			// see if we already have updated this...
			WorkOrder aWorkOrder = updateWoMap.get( anAppointment.ParentRecordId );
			if ( aWorkOrder == null ) aWorkOrder = new WorkOrder(Id=anAppointment.ParentRecordId);
			//WorkOrder aWorkOrder = getWorkOrderForUpdate( anAppointment, subStatus );
			aWorkOrder = getWorkOrderForUpdate( anAppointment, subStatus, aWorkOrder );

			//workOrderList.add( aWorkOrder );
			updateWoMap.put( aWorkOrder.Id, aWorkOrder );
		}

		if( updateWoMap == null || updateWoMap.keySet().size() == 0 ) {
			return;
		}

		// disable work order trigger temporarily while updating the dates/substatus
		SG_WorkOrderHelper.triggerDisabledDuringTransaction = true;
		update updateWoMap.values();
		SG_WorkOrderHelper.triggerDisabledDuringTransaction = false;
	}

	public static Boolean recordIsAlreadyProcessed(
						Set<Id> recordIdsAlreadyProcessedSet, Id anId ) {
		if( recordIdsAlreadyProcessedSet.contains( anId ) ) {
			return true;
		}
		if( anId != null ) {
			recordIdsAlreadyProcessedSet.add( anId );
		}
		return false;
	}

	public static WorkOrder getWorkOrderForUpdate( ServiceAppointment anAppointment, String subStatus, WorkOrder aWorkOrder ) {
		// if scheduled, copy the dates, otherwise null

		aWorkOrder.StartDate =  anAppointment.SchedStartTime;
		aWorkOrder.EndDate = anAppointment.SchedEndTime;

		/*aWorkOrder.StartDate = ( subStatus == WO_SUBSTATUS_SCHEDULED ? anAppointment.SchedStartTime : null );
		aWorkOrder.EndDate = ( subStatus == WO_SUBSTATUS_SCHEDULED ? anAppointment.SchedEndTime : null );*/
	//	aWorkOrder.Sub_Status__c = subStatus;
		aWorkOrder.HDC_User__c = anAppointment.HDC_User__c;

		return aWorkOrder;
	}





}