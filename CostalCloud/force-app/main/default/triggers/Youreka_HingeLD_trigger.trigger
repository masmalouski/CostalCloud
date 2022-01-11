/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_HingeLD_trigger on Hinge__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Hinge__c');
}