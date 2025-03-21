/**
 * @description       :
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             :
 * @last modified on  : 03-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
Trigger OrderTrigger on Order (before insert, after update, after insert, before update) {

    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        System.debug('Inside Order Insert or Updadte Trigger');
            OrderTriggerHandler.maintainOrderCounter(Trigger.new);
    }
    
    if (Trigger.isAfter && Trigger.isUpdate) {
        System.debug('Inside Orderrrrrrrrr Updadte Trigger');
        OrderTriggerHandler.handleOrderUpdate(Trigger.new, Trigger.oldMap);
        OrderTriggerHandler.createProductTransferForBackOrder(Trigger.oldMap, Trigger.newMap);
        OrderTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        OrderTriggerHandler.sendWhatsAppAfterOrderCreation(Trigger.new,Trigger.oldMap);
        form22Controller.handleOrderUpdate(Trigger.new, Trigger.oldMap);
       // OrderTriggerHandler.sendPDFAfterRTO(Trigger.new,Trigger.oldMap);
       // OrderTriggerHandler.processOrderMilestones(Trigger.new, Trigger.oldMap);
        //OrderTriggerHandler.sendWhatsAppAfterOrderCreation(Trigger.new);
        //added by Aniket on 05/03/2025 for Ew Integration
        //OrderTriggerHandler.afterUpdateForEWIntegration(Trigger.new, Trigger.oldMap);
         for (Order o : Trigger.new) {
        if (o.Status == 'RTO Registration' && Trigger.oldMap.get(o.Id).Status != 'RTO Registration') {
            OrderTriggerHandler.sendPDFAfterRTO(Trigger.new,Trigger.oldMap);
            OrderTriggerHandler.afterUpdateForEWIntegration(Trigger.new, Trigger.oldMap);
            OrderTriggerHandler.processOrderMilestones(Trigger.new, Trigger.oldMap);
           // OrderTriggerHandler.afterUpdateForEWIntegration(Trigger.new, Trigger.oldMap);
            break; 
        }
    }
    }

    if(Trigger.isAfter && Trigger.isInsert){
        //OrderTriggerHandler.sendWhatsAppAfterOrderCreation(Trigger.new);
    }
}