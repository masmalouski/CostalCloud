/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_LaborLD_trigger on Labor__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Labor__c');
}