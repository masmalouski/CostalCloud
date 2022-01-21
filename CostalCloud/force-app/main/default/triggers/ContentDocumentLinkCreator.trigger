trigger ContentDocumentLinkCreator on ContentDocumentLink(before insert) {
  //This trigger is a quick add-on to Youreka that ensures the photos captured with Youreka are also
  //displayed on the records that the Forms are related to. Initially the trigger was designed for Work Orders,
  //but it can be adapted to fit other needs.
  List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
  List<Attachment_Files__c> attList = new List<Attachment_Files__c>();
  // map to maintain relationship between the answer and its content document id
  Map<Id, Id> relatedAnswerIds2ContentDocumentIds = new Map<Id, Id>();

  for (ContentDocumentLink cdl : Trigger.new) {
    // get the prefix from describe info in case its diff in diff orgs
    String answerPrefix = disco__Answer__c.sObjectType.getDescribe()
      .getKeyPrefix();

    if (String.valueOf(cdl.linkedEntityId).startsWithIgnoreCase(answerPrefix)) {
      relatedAnswerIds2ContentDocumentIds.put(
        cdl.linkedEntityId,
        cdl.contentDocumentId
      );
    }
  }
  // go get the related answers and related record IDs for field link and linked sections for our answer IDs
  List<disco__Answer__c> relatedAnswers = [
    SELECT Id, disco__Form__r.Work_Order__c
    FROM disco__Answer__c
    WHERE Id IN :relatedAnswerIds2ContentDocumentIds.keyset()
  ];

  // iterate though our related answers and build our content document links
  for (disco__Answer__c thisAnswer : relatedAnswers) {
    String workOrderId = thisAnswer.disco__Form__r.Work_Order__c;

    if (workOrderId != null) {
      String contentDocumentId = relatedAnswerIds2ContentDocumentIds.get(
        thisAnswer.id
      );
      Attachment_Files__c attFileObj = new Attachment_Files__c(
        Type__c = 'Photo',
        Work_Order__c = workOrderId
      );
      attList.add(attFileObj);
      insert attList;
      cdlList.add(
        new ContentDocumentLink(
          ContentDocumentId = contentDocumentId,
          ShareType = 'V',
          Visibility = 'AllUsers',
          LinkedEntityId = attFileObj.Id
        )
      );
    }
  }
  try {
    // insert, if its empty it doesnt count as DML so you dont need to check size first
    insert cdlList;
  } catch (Exception e) {
  }
}
