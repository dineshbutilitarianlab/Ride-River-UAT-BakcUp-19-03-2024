trigger Discrepancy on Discrepancy__c (before insert,After Insert) {
    if(trigger.isInsert && trigger.isAfter){
       // DiscrepancyTriggerHandler.updateShipment(trigger.new);
    }
}