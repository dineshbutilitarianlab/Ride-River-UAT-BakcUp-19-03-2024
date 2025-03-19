public class PartController {
    public static void checkAndDeleteWorkOrderLineItem(Id workOrderLineItemId) {
        // Query the WorkOrderLineItem and its related WorkOrder
        WorkOrderLineItem woli = [SELECT Id, WorkOrderId, WorkOrder.Status 
                                  FROM WorkOrderLineItem 
                                  WHERE Id = :workOrderLineItemId 
                                  LIMIT 1];
          system.debug('query  executed'+ woli);
        // Check if the related WorkOrder status is 'Completed'
        if (woli.WorkOrder.Status == 'Completed') {
            throw new AuraHandledException('You cannot delete this WorkOrderLineItem because the related WorkOrder is completed.');
        } else {
            // If the status is not 'Completed', proceed with deletion
            delete woli;
        }
    }
}