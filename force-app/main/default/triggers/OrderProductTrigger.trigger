trigger OrderProductTrigger on OrderItem (before insert,before update, after insert,after update,after delete, after undelete) {
    
    If(Trigger.isbefore){
        if(trigger.isInsert){
            OrderProductTriggerController.beforeHandler(Trigger.new, null);
        }else if(trigger.isupdate){
            OrderProductTriggerController.beforeHandler(Trigger.new, Trigger.oldMap);
        }
    }
    
   /* If(Trigger.isafter && Trigger.isdelete){
        If(OrderProductTriggerController.triggerRan != true)
       OrderProductTriggerController.Deletehandler(Trigger.old);
    } */
    
    If(Trigger.isafter && Trigger.isUpdate){
        If(OrderProductTriggerController.triggerRan != true)
        OrderProductTriggerController.Updatehandler(Trigger.new,Trigger.oldMap);
    }

}