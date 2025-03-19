public class WorkOrderLineHandler {
    public static void handleActivitiesBeforeDelete(List<WorkOrderLineItem> workOrderLineItems){
        if (workOrderLineItems == null || workOrderLineItems.isEmpty()) {
        return;
    }
        
        Set<Id> workOrderLineItemIds = new Set<Id>();
        for(WorkOrderLineItem woli : workOrderLineItems){
            workOrderLineItemIds.add(woli.Id);
        }
        
         if (workOrderLineItemIds.isEmpty()) {
        return;
    }
        
        List<ProductConsumed> productConsumedList = [
            SELECT Id, ProductItemId, Quantity_Consumed__c
            FROM ProductConsumed
            WHERE WorkOrderLineItemId IN :workOrderLineItemIds
        ]; 
        
        Map<Id, Decimal> productItemQuantityMap = new Map<Id, Decimal>();
        
        for (ProductConsumed pc : productConsumedList){
            if (pc.ProductItemId != null){
                if (productItemQuantityMap.containsKey(pc.ProductItemId)){
                    
                    Decimal currentQuantity = productItemQuantityMap.get(pc.ProductItemId);
                    
                    productItemQuantityMap.put(pc.ProductItemId, currentQuantity - pc.Quantity_Consumed__c);
                } else {
                    productItemQuantityMap.put(pc.ProductItemId, -pc.Quantity_Consumed__c);
                }
            }
        }
        
         if (productItemQuantityMap.isEmpty()) {
            return; // No product items to update
        }
        
        
        List<ProductItem> productItemsToUpdate = [
            SELECT Id, 	Quantity_In_Hand__c,QuantityOnHand
            FROM ProductItem
            WHERE Id IN :productItemQuantityMap.keySet()
        ];
        
        
       // for (ProductItem pi : productItemsToUpdate) {
       //     Decimal quantityChange = productItemQuantityMap.get(pi.Id);
       //     pi.QuantityOnHand += quantityChange; 
       // }
       for (ProductItem pi : productItemsToUpdate) {
        if (productItemQuantityMap.containsKey(pi.Id)) {
            Decimal quantityChange = productItemQuantityMap.get(pi.Id);
            if (quantityChange != null) {
                pi.QuantityOnHand += quantityChange;
            }
        }
    }
        
        
        if (!productItemsToUpdate.isEmpty()) {
            update productItemsToUpdate;
        }
    }
    
    
    public static void handleAfterDelete(List<WorkOrderLineItem> deletedWorkOrders) {
        Set<Id> warrantyPriorIds = new Set<Id>();
        
        // Collect all related Warranty Prior IDs
        for (WorkOrderLineItem woli : deletedWorkOrders) {
            if (woli.Warranty_Prior__c != null) {
                warrantyPriorIds.add(woli.Warranty_Prior__c);
            }
        }
        
        if (!warrantyPriorIds.isEmpty()) {
            // Check if there are any WorkPlan records linked to these Warranty Prior IDs
            Set<Id> warrantyWithWorkPlans = new Set<Id>();
            for (AggregateResult ar : [
                SELECT Warranty_Prior__c FROM WorkPlan 
                WHERE Warranty_Prior__c IN :warrantyPriorIds 
                GROUP BY Warranty_Prior__c
            ]) {
                warrantyWithWorkPlans.add((Id) ar.get('Warranty_Prior__c'));
            }
            
            // Identify Warranty_Prior__c records that have no WorkPlan records
            Set<Id> warrantiesToDelete = new Set<Id>(warrantyPriorIds);
            warrantiesToDelete.removeAll(warrantyWithWorkPlans);
            
            if (!warrantiesToDelete.isEmpty()) {
                List<Warranty_Prior__c> warrantiesToDeleteList = [
                    SELECT Id FROM Warranty_Prior__c WHERE Id IN :warrantiesToDelete
                ];
                
                // Use Database.delete() with allOrNone = false to handle any permission-related issues
                Database.DeleteResult[] deleteResults = Database.delete(warrantiesToDeleteList, false);
                
                for (Database.DeleteResult dr : deleteResults) {
                    if (!dr.isSuccess()) {
                        for (Database.Error err : dr.getErrors()) {
                            System.debug('Delete error: ' + err.getMessage());
                        }
                    }
                }
            }
        }
    }
}