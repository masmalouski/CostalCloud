/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_PlumbingLD_trigger on Plumbing__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Plumbing__c');
}