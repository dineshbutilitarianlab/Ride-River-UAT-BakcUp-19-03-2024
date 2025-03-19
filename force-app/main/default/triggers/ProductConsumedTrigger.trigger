trigger ProductConsumedTrigger on ProductConsumed (before insert,after insert,after update,after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        ProductConsumedTriggerHandler.rollUpOfQuantityConsumed(Trigger.new,null);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        ProductConsumedTriggerHandler.rollUpOfQuantityConsumed(Trigger.new,Trigger.oldMap);
    }
    if(Trigger.isAfter && Trigger.isDelete){
        
        ProductConsumedTriggerHandler.rollUpOfQuantityConsumed(Trigger.old,null);
    }
    

}