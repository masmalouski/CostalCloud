/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_WorkOrder_trigger on WorkOrder (after update){
    disco.Util.updateObjectsFieldLinkAnswers(trigger.new,'WorkOrder');
}