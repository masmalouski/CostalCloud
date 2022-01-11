/* This trigger was created by the Youreka package and is integral to it. 
Please do not delete */
trigger Youreka_WorkOrderLineItemLD_trigger on WorkOrderLineItem (after update){
    disco.Util.updateAnswersInLinkedSections(trigger.new,'WorkOrderLineItem');
}