public class MaterialsMDL implements Schedulable {
    public void execute(SchedulableContext SC) {
        PriceBookEntry[] pbeList = [SELECT Id,Pricebook2Id,Product2Id,UnitPrice FROM PriceBookEntry WHERE SystemModstamp >:Datetime.now().addMinutes(-15)];

Set<String> myIds = new Set<String>();                                                      
      for (PriceBookEntry pbe: pbeList) {
               myIds.add(pbe.Id); 
     }
      
Materials__c[] msList = [SELECT Id,Product__c,Price_Book__c,PBEId__c,Unit_Price__c FROM Materials__c WHERE PBEId__c in :myIds];

    for (PriceBookEntry p : pbeList) {
        boolean itemExists = false;
        for (Materials__c m : msList) {
            if (p.Id == m.PBEId__c) {
             itemExists = true;
             m.Product__c = p.Product2Id;
             m.Price_Book__c = p.Pricebook2Id;
             m.Unit_Price__c = p.UnitPrice;
             break;
            }
        }
        if (itemExists == false)
        {Materials__c newM = new Materials__c(PBEId__c = p.Id,Product__c = p.Product2Id,Price_Book__c = p.Pricebook2Id,Unit_Price__c = p.UnitPrice);
         msList.add(newM);}
    }

    upsert msList;
        }
}