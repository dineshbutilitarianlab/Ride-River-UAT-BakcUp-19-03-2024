trigger ProductTransferTrigger on ProductTransfer (after insert, before update, after delete, after update, before insert, before delete ) {
    
    if (Trigger.isAfter && Trigger.isInsert) {
        ProductTransferHandler.onInsertProductTransferUpdateInventory(Trigger.new);
        ProductTransferHandler.handleDailyLedgerCreationOrUpdate(Trigger.new);  
    }
    
    if (Trigger.isBefore && Trigger.isUpdate) {
        ProductTransferHandler.onUpdateProductTransferUpdateInventory(Trigger.newMap, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && Trigger.isDelete) {
        ProductTransferHandler.onDeleteProductTransferUpdateInventory(Trigger.old);
    }
    
}