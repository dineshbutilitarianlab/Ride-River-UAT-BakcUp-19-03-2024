trigger InventoryLotType on Inventory_Lot__c (before delete) {
    for (Inventory_Lot__c record : Trigger.old) {
        if (record.Type__c == 'Spare vehicle') {
            record.addError('Records with Type "Spare Vehicle" cannot be deleted.');
        }
    }
}