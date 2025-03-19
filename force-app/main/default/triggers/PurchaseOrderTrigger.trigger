trigger PurchaseOrderTrigger on ProductRequest (after insert, after update) {
    try {
        if (Trigger.isAfter) {
            // Notify Store Manager for high-value Purchase Orders
            PurchaseOrderTriggerHandler.sendHighValueNotification(Trigger.new);

            // Notify Warehouse for new Purchase Orders requiring allotment
            if (Trigger.isInsert) {
             //   PurchaseOrderTriggerHandler.notifyWarehouseForAllotment(Trigger.new);
            }
        }
    } catch (Exception ex) {
        // Log the exception to debug logs for troubleshooting
        System.debug('Error in PurchaseOrderTrigger: ' + ex.getMessage());
    }
}