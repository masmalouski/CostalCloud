/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_RRP_Test_KitsLD_trigger on RRP_Test_Kits__c (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'RRP_Test_Kits__c');
}