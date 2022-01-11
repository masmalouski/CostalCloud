/**********************************************************************
* Name:     triggers
* Author:   Strategic Growth, Inc. (www.strategicgrowthinc.com)
*
* ======================================================
* ======================================================
* Purpose:  
*
* ======================================================
* ======================================================
* History:
* VERSION   DATE            INITIALS      	DESCRIPTION/FEATURES ADDED
* 1.0       10/25/21 	    SWM           	Initial Development - Create Visibilty for new files uploaded
*
**********************************************************************/


trigger SG_ContentVersion on ContentVersion (after insert, after update) {

    if( SG_ApexActivator.isDisabled('Disable ContentVersion Triggers') ) {
        System.debug( 'Trigger disabled by Apex Activation Settings Custom Setting.' );
        return;
    }


    Apex_Activation_Settings__c aacs = Apex_Activation_Settings__c.getOrgDefaults();
    Id sfIntId = (Id) aacs.SF_Integration_User_Id__c;

    Set<Id> cvIds = new Set<Id>();

    for (ContentVersion cvr:trigger.new)
    {
        if(cvr.LastModifiedById == sfIntId)
        {
            cvIds.add(cvr.Id);
        }
    }

//            deletePreviousLink( contentDoc.Id, recordID );


    // Go and pickup the document links to delete for All users
    Set<Id> doclinkTempIds = new Set<Id>();
    List<ContentVersion> contentList = new List<ContentVersion>();
    if(cvIds.size()>0)
    {
        for(ContentVersion pcvr:[SELECT ID, Title, FirstPublishLocationId, ContentDocument.Title , ContentDocument.ID, Integration_Key_Content_Version__c
        FROM ContentVersion WHERE Integration_Key_Content_Version__c !='' and FirstPublishLocationId !=''  and ID IN :cvIds])
        {
            doclinkTempIds.add(pcvr.FirstPublishLocationId);
            contentList.add(pcvr);
        }
    }

    List<ContentDocumentLink> updcdlList = new List<ContentDocumentLink>();
    ContentDocumentLink updRec = new ContentDocumentLink();
    //Delete one of the documentlinks for sharing with everyone
    if(doclinkTempIds.size() > 0)
    {
        for (ContentDocumentLink delcdl:[SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE ShareType ='I' and Visibility='AllUsers' and LinkedEntityId =:doclinkTempIds])
        //for (ContentDocumentLink rec1:[SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :doclinkTempIds])
        {
            //updRec = new ContentDocumentLink();
            //updRec.Id = rec1.Id;
            //updRec.ShareType = 'V';
            //updRec.Visibility = 'AllUsers';
            //updcdlList.add(updRec);

            updcdlList.add(delcdl);
        }
    }

    // If there are any records to delete then delete this
    if(updcdlList.size()>0)
    {
        //update updcdlList;
         //delete updcdlList;
    }



    List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
    ContentDocumentLink cdlrec = new ContentDocumentLink();
    if(cvIds.size()>0)
    {
        // Go through the list and then add the record for sharing.
        for(ContentVersion pcvr:contentList)
        {
            cdlrec = new ContentDocumentLink();
            cdlrec.LinkedEntityId = pcvr.FirstPublishLocationId;
            cdlrec.ContentDocumentId = pcvr.ContentDocument.ID;
            cdlrec.ShareType = 'I';
            cdlrec.Visibility = 'AllUsers';

            cdlist.add(cdlrec);
            //insert cdl;

            system.debug('***** cdlist :'+cdlist);
        }
    }

    if(cdlist.size() > 0)
    {
     //   insert cdlist;
    }



}