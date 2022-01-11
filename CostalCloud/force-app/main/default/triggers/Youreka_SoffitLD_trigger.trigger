/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_SoffitLD_trigger on Soffit__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'Soffit__c');
}