/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_ApplianceLD_trigger on Appliance__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Appliance__c');
}