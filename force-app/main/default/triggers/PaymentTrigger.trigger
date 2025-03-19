trigger PaymentTrigger on Payment__c (after insert, after update, after delete, after unDelete) {
    
    If(trigger.isInsert || trigger.isUpdate || trigger.isUndelete){
        PaymentTriggerHandler.insertHandler(trigger.new); 
    }
    
    If(trigger.isUpdate){
        PaymentTriggerHandler.updateHandler(trigger.new, trigger.oldMap);
    }
}