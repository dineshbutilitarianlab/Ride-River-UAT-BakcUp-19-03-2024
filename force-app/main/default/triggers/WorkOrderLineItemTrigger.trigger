trigger WorkOrderLineItemTrigger on WorkOrderLineItem (before insert, after insert, after update, after delete) {
   // Handle "before insert" logic (if needed in the future)
   // if (Trigger.isBefore) {
        //if (Trigger.isInsert) {
            // Add any future logic for "before insert" here if required
       // } /*else if (Trigger.isUpdate) {
            // Add any future logic for "before update" here if required
        //}
    //} 

    // Handle "after insert" logic
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            WorkOrderLineItemTriggerHandler.handleInsert(Trigger.new);
            WorkOrderLineItemTriggerHandler.createProductConsumed(Trigger.new);
        } else if (Trigger.isUpdate) {
           WorkOrderLineItemTriggerHandler.handleUpdate(Trigger.new, Trigger.oldMap);
        }else if (Trigger.isDelete) {
           WorkOrderLineItemTriggerHandler.handleDelete(Trigger.old);
            
      }
    } 
}