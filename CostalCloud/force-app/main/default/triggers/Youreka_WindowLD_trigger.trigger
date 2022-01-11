/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_WindowLD_trigger on Window__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Window__c');
}