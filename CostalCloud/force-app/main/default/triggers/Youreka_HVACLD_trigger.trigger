/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_HVACLD_trigger on HVAC__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'HVAC__c');
}