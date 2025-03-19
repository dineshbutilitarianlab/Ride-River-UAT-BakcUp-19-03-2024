trigger WorkOrderLine on WorkOrderLineItem (before delete,after Delete){
    if(trigger.isBefore && trigger.isDelete){
        WorkOrderLineHandler.handleActivitiesBeforeDelete(trigger.old);
    }
  if(trigger.isafter && trigger.isDelete){
        WorkOrderLineHandler.handleAfterDelete(trigger.old);
    }
}