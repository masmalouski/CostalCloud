/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_ElectricalLD_trigger on Electrical__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Electrical__c');
}