/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_DoorLD_trigger on Door__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Door__c');
}