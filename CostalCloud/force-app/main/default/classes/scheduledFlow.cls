global class scheduledFlow implements Schedulable {
  global void execute(SchedulableContext sc) {
    WorkOrder[] woList = [
      SELECT Id
      FROM WorkOrder
      WHERE SystemModstamp > :Datetime.now().addMinutes(-30)
    ];

    Set<Id> myIds = new Set<Id>();
    for (WorkOrder wo : woList) {
      myIds.add(wo.Id);
    }
    if (woList != null && woList.size() > 0) {
      ContentDocumentLink[] CDLList = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :myIds
      ];
      if (CDLList != null && CDLList.size() > 0) {
        Map<String, Object> params = new Map<String, Object>();
        params.put('ContentDocumentLink', CDLList);
        Flow.Interview.Move_doc_from_Files_to_Attachment_Files flow = new Flow.Interview.Move_doc_from_Files_to_Attachment_Files(
          params
        );
        flow.start();
      }
    }
  }
}
