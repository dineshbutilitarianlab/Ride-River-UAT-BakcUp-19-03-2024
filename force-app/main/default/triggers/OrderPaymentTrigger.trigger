/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-12-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger OrderPaymentTrigger on Order_Payment__c (before insert, before update, after update, after insert) {
     
    If(trigger.isBefore){ 
        If(trigger.isInsert){            
            OrderPaymentTriggerHandler.checkDuplicateOnInsert(trigger.new, false);            
            OrderPaymentTriggerHandler.insertHandler(trigger.new);
        }    
        if(trigger.isUpdate){
            OrderPaymentTriggerHandler.checkDuplicateOnInsert(trigger.new, true);
        }
    }
    
    if(trigger.isAfter){
        If(trigger.isInsert){
            OrderPaymentTriggerHandler.updateOrderOnInsert(trigger.new);
            OrderStatusHandler.sendPreOrderReceipt01(trigger.new); 
            //new on 12/02/2025
        }
        
        If(trigger.isUpdate){
            OrderPaymentTriggerHandler.updateOrderOnUpdate(trigger.new, trigger.oldMap);
            OrderPaymentTriggerHandler.populatePDFInOrder(trigger.new,Trigger.oldMap);
        }
    }
}