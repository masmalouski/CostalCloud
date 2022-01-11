/***************************************************
* Name:         SG_FileHelper
* Author:       Strategic Growth, Inc. (www.strategicgrowthinc.com)
* Date:         Nov 2021
* ==================================================
* ==================================================
* Purpose:      ...
*
* ==================================================
* ==================================================
* History:
* VERSION   DATE            INITIALS    DESCRIPTION/FEATURES ADDED
* 1.0       Nov 2021        GO          Initial Development
*
****************************************************/
public with sharing class SG_FileHelper
{
    public static Boolean processFile_Ran = false;

    public static void processFile(TriggerOperation operation, List<ContentDocumentLink> links)
    {
        System.debug(LoggingLevel.WARN, '==> START SG_FileHelper.processFile()');

        if(operation != TriggerOperation.AFTER_INSERT)
        {
            System.debug(LoggingLevel.WARN, '==> ABORT: operation != TriggerOperation.AFTER_INSERT');
            return;
        }

        if(processFile_Ran == true)
        {
            System.debug(LoggingLevel.WARN, '==> ABORT: processFile_Ran == true');
            return;
        }

        processFile_Ran = true;

        // These are Ids of records File Attachment is associated to
        Set<Id> recordIds = new Set<Id>();
        for(ContentDocumentLink l:links)
        {
            recordIds.add(l.LinkedEntityId);
        }

        // Get Attachment/File Records
        List<Attachment_Files__c> attachmentFiles = [SELECT Id, Type__c FROM Attachment_Files__c WHERE Id IN :recordIds];

        // nothing to process, so return
        if(attachmentFiles.isEmpty()) return;

        for(Attachment_Files__c af:attachmentFiles)
        {
            af.Has_File__c = true;
        }

        update attachmentFiles;

    }

}