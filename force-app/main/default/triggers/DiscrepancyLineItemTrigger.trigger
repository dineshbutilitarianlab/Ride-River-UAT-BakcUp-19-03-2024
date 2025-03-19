trigger DiscrepancyLineItemTrigger on Discrepancy_Line_Item__c (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        DiscrepancyLineItemTriggerHandler.validateBeforeUpdate(Trigger.new, Trigger.oldMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        DiscrepancyLineItemTriggerHandler.processAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}