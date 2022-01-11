/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_Walls_trigger on Walls__c (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'Walls__c');
}