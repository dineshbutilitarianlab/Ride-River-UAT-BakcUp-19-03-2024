/******************************************************************************
* Class Name: PaymentTriggerHandler
* Created by : Sudarshan N B - 1/10/23
* Last Modified By : Sudarshan N B - 10/07/2024
* Description : Handler for payment trigger
*****************************************************************************/
public class PaymentTriggerHandler {
    
    public static void insertHandler(List<Payment__c> newRecords){
        
        Set<Id> recordIds = new Set<Id>();
        List<Order_Payment__c> paymentsToUpdate = new List<Order_Payment__c>();
        
        For(Payment__c p : newRecords){
            If(p.Payment_Status__c == 'Success')
            recordIds.add(p.Id);
        }
        
        List<Order_Payment__c> orderPayments = [SELECT Id, Amount1__c, Payments__r.Amount__c  from Order_Payment__c WHERE Payments__c IN :recordIds];
        
        For(Order_Payment__c op: orderPayments){
            Order_Payment__c opRecord = op;
            opRecord.Amount1__c = op.Payments__r.Amount__c;
            paymentsToUpdate.add(opRecord);
            
        }
        
        
        If(paymentsToUpdate != null){
            database.update(paymentsToUpdate,false);
        }
    }
    
    Public static void updateHandler(List<Payment__c> newRecords, Map<id,Payment__c> oldMap){
        
        Set<Id> recordIds = new Set<Id>();
        List<Order_Payment__c> paymentsToUpdate = new List<Order_Payment__c>();
        
        For(Payment__c p : newRecords){
            If(p.Payment_Status__c == 'Success')
            recordIds.add(p.Id);
        }
        
        List<Order_Payment__c> orderPayments = [SELECT Id, Amount1__c, Payments__r.Amount__c  from Order_Payment__c WHERE Payments__c IN :recordIds];
        List<Order_Payment__c> opList = new List<Order_Payment__c>();
        
        Map<Id,Order_Payment__c> mappaymentIdtoOp = new Map<Id,Order_Payment__c>();
        
        For(Order_Payment__c op: orderPayments){
            IF(!mappaymentIdtoOp.containsKey(op.Payments__c)){
                mappaymentIdtoOp.put(op.Payments__c,op);
            }
        }  
        
        For(Payment__c p : newRecords){
            If(p.Payment_Status__c == 'Success' && p.Payment_Status__c != oldMap.get(p.Id).Payment_Status__c){
                opList.add(mappaymentIdtoOp.get(p.Id));
            }
            
        }
        
        If(opList != null){
            
            OrderStatusHandler.sendPreOrderReceipt01(opList);
        }
        
    }
}