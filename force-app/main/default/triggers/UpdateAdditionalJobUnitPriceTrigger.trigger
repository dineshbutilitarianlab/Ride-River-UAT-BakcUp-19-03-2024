trigger UpdateAdditionalJobUnitPriceTrigger on RR_Additional_Job_Recommended__c (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            RR_Additional_Job_Recommended_Handler.handleUnitPriceUpdate(Trigger.new);
        }
    }
}