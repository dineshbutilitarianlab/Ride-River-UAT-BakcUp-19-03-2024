trigger WorkPlanTrigger on WorkPlan (after insert,after delete) {
    // if (Trigger.isAfter && Trigger.isInsert) {
    //     WorkPlanTriggerHandler.handleInsert(Trigger.new);
    // }
    if(Trigger.isAfter && Trigger.isDelete){
         WorkPlanTriggerHandler.handleAfterDelete(Trigger.Old);
    }
}