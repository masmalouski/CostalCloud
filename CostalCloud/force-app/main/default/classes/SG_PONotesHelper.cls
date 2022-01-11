/***************************************************
* Name:         SG_PONotesHelper
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         Nov 2021
* ==================================================
* ==================================================
* Purpose:      Auto create PO Notes when WorkOrder.PO_Note_AutoCreated__c
*               is populated
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       Nov 2021        GO          Initial Development
*
****************************************************/

public with sharing class SG_PONotesHelper
{

    public static Boolean processPONOtes_Ran = false;

    public static void processPONOtes(TriggerOperation operationType, List<WorkOrder> workOrders)
    {
        System.debug(LoggingLevel.WARN, '==> SG_processPONotes()');

        if(operationType != TriggerOperation.BEFORE_UPDATE)
        {
            System.debug(LoggingLevel.WARN, '==> ABORT: operationType != TriggerOperation.BEFORE_UPDATE');
            return;
        }

        if(System.isFuture() || System.isQueueable())
        {
            // do not run this code if it's @future or @queueable
            System.debug(LoggingLevel.WARN, '==> ABORT: System.isFuture() || System.isQueueable()');
            return;
        }

        if(processPONOtes_Ran == true)
        {
            System.debug(LoggingLevel.WARN, '==> ABORT: processPONOtes_Ran == true');
            return;
        }

        processPONOtes_Ran = true;

        // Get Installer Manual Note Record Type
        Id manualRTId;
        try
        {
            manualRTId = Schema.SObjectType.PO_Notes__c.getRecordTypeInfosByName().get('Installer Manual Note').getRecordTypeId();
        }
        catch(Exception e)
        {
            System.debug('Invalid Record Type: Installer Manual Note');
        }

        Id autoRTId;
        try
        {
            autoRTId = Schema.SObjectType.PO_Notes__c.getRecordTypeInfosByName().get('Auto Generated Note').getRecordTypeId();
        }
        catch(Exception e)
        {
            System.debug('Invalid Record Type: Auto Generated Note');
        }

        List<PO_Notes__c> poNotesToCreate = new List<PO_Notes__c>();
        for(WorkOrder wo:workOrders)
        {
            if(wo.PO_Note_AutoCreated__c != null)
            {
                String theNote = wo.PO_Note_AutoCreated__c;

                PO_Notes__c poNote = new PO_Notes__c();
                if(wo.PO_Note_Auto_Generated__c == true)
                {
                    if(autoRTId != null) poNote.RecordTypeId = autoRTId;
                }
                else
                {
                    if(manualRTId != null) poNote.RecordTypeId = manualRTId;
                }

                poNote.Work_Order__c = wo.Id;
                poNote.Name = wo.Installer_Action__c;  // SUBJECT
                if(poNote.Name == null)
                {
                    if(wo.Unscheduled_Reason__c != null)
                    {
                        poNote.Name = wo.Unscheduled_Reason__c;
                    }
                    else
                    {
                        poNote.Name = wo.PO_Note_Subject_AutoCreate__c;
                    }
                }


                poNote.Description__c = theNote;
                if(theNote.length() > 80)
                {
                    poNote.Name = theNote.mid(0, 80);
                }
                poNote.Private_Note__c = wo.Private_Note_AutoCreate__c;
                poNote.Auto_Push__c = wo.Auto_Push_Note_AutoCreate__c;

                poNotesToCreate.add(poNote);
            }
        }

        System.debug(LoggingLevel.WARN, '==>poNOtesToCreate: ' + poNotesToCreate);

        // nothing to process so return
        if(poNotesToCreate.isEmpty()) return;

        try
        {
            System.debug(LoggingLevel.WARN, '==>inserting poNOtesToCreate');
            String poNotes_JSON = JSON.serialize(poNotesToCreate);
            createPONotes(poNotes_JSON);
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.WARN, '==>inserting poNOtesToCreate ERROR' + e.getStackTraceString() + '; ' + e.getMessage());
        }


    }

    @Future
    public static void createPONotes(String poNotes_JSON)
    {
        // create the manual note
        List<PO_Notes__c> poNotes = (List<PO_Notes__c>)JSON.deserialize(poNotes_JSON, List<PO_Notes__c>.class);
        insert poNotes;

        Set<Id> workOrderIds = new Set<Id>();
        for(PO_Notes__c p:poNotes)
        {
            workOrderIds.add(p.Work_Order__c);
        }

        // reset note fields on the work order record
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder WHERE Id IN :workOrderIds];
        for(WorkOrder wo:workOrders)
        {
            wo.Do_PO_Note_Validation__c = false;
            wo.PO_Note_AutoCreated__c = null;
            wo.Private_Note_AutoCreate__c = false;
            wo.Auto_Push_Note_AutoCreate__c = true;
            wo.PO_Note_Subject_AutoCreate__c = null;
            wo.PO_Note_Auto_Generated__c = false;
        }
        update workOrders;
    }

}