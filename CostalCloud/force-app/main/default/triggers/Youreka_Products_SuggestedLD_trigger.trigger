/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Products_SuggestedLD_trigger on Products_Suggested__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Products_Suggested__c');
}