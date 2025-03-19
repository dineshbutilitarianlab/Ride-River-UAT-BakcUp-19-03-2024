public class WorkOrderLineItemTriggerHandler {

    public static void handleInsert(List<WorkOrderLineItem> workOrderLineItems) {
        // Step 1: Collect WorkOrder IDs from WorkOrderLineItems
          Set<String> restrictedPartsCategories = new Set<String>();
          for (Parts_Category_Restricted__mdt meta : [SELECT Parts_Category__c FROM Parts_Category_Restricted__mdt]) {
               restrictedPartsCategories.add(meta.Parts_Category__c);
           }
        
        Set<Id> workOrderIds = new Set<Id>();
        Set<Id> warrantyPriorIds = new Set<Id>();
        for (WorkOrderLineItem item : workOrderLineItems) {
            if (item.WorkOrderId != null && !restrictedPartsCategories.contains(item.RR_Parts_Category__c)) {
                workOrderIds.add(item.WorkOrderId);
            }
            if (item.Warranty_Prior__c != null) {
                warrantyPriorIds.add(item.Warranty_Prior__c);
            }
        }
        System.debug('WorkOrder IDs: ' + workOrderIds);
    
        // Step 2: Query existing Warranty Priors related to WorkOrder IDs
        Map<Id, Warranty_Prior__c> existingWarrantyMap = new Map<Id, Warranty_Prior__c>(
            [SELECT Id, Job_Card__c, Total_Claim_Amount__c 
             FROM Warranty_Prior__c 
             WHERE Job_Card__c IN :workOrderIds]
        );
        System.debug('Existing Warranties: ' + existingWarrantyMap);
    
        // Step 3: Create new warranties for WorkOrders without an existing warranty
        List<Warranty_Prior__c> newWarranties = new List<Warranty_Prior__c>();
        Map<Id, Id> workOrderToWarrantyMap = new Map<Id, Id>();
    
        // Map existing warranties
        for (Warranty_Prior__c warranty : existingWarrantyMap.values()) {
            workOrderToWarrantyMap.put(warranty.Job_Card__c, warranty.Id);
        }

        // Prepare new warranties for missing WorkOrders
        if (!workOrderIds.isEmpty()) {
            Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
                [SELECT Id,
                        Vehicle__c,
                        Odometer_Reading__c,
                        Vehicle_Registration_Number__c,
                        Vehicle__r.EngineNumber,
                        Vehicle__r.VehicleIdentificationNumber
                 FROM WorkOrder
                 WHERE Id IN :workOrderIds]
            );

            for (WorkOrderLineItem item : workOrderLineItems) {
                if (item.WorkOrderId != null && !workOrderToWarrantyMap.containsKey(item.WorkOrderId)) {
                    WorkOrder relatedWorkOrder = workOrderMap.get(item.WorkOrderId);
                    if (relatedWorkOrder != null) {
                        Warranty_Prior__c newWarranty = new Warranty_Prior__c(
                            Job_Card__c = item.WorkOrderId,
                            Motor_Number__c = relatedWorkOrder.Vehicle__r.EngineNumber,
                            Odometer_Reading__c = relatedWorkOrder.Odometer_Reading__c,
                            Registration_Number__c = relatedWorkOrder.Vehicle_Registration_Number__c,
                            VIN__c = relatedWorkOrder.Vehicle__r.VehicleIdentificationNumber,
                            Warranty_Prior_Date__c = Date.today(),
                            Status__c = 'Pending',
                            Total_Claim_Amount__c = 0 // Initialize Total Claimed Amount
                        );
                        newWarranties.add(newWarranty);
                    }
                }
            }
        }

        if (!newWarranties.isEmpty()) {
            insert newWarranties;
            for (Warranty_Prior__c warranty : newWarranties) {
                workOrderToWarrantyMap.put(warranty.Job_Card__c, warranty.Id);
                warrantyPriorIds.add(warranty.Id);
            }
        }

        System.debug('WorkOrder to Warranty Map: ' + workOrderToWarrantyMap);

        // Step 4: Update WorkOrderLineItems with the associated warranties
        List<WorkOrderLineItem> workOrderLineItemsToUpdate = new List<WorkOrderLineItem>();
        for (WorkOrderLineItem item : workOrderLineItems) {
            if (item.WorkOrderId != null && workOrderToWarrantyMap.containsKey(item.WorkOrderId)) {
                WorkOrderLineItem updatedItem = new WorkOrderLineItem(
                    Id = item.Id,
                    Warranty_Prior__c = workOrderToWarrantyMap.get(item.WorkOrderId)
                );
                workOrderLineItemsToUpdate.add(updatedItem);
            }
        }

        if (!workOrderLineItemsToUpdate.isEmpty()) {
            update workOrderLineItemsToUpdate;
        }

        System.debug('Updated WorkOrderLineItems: ' + workOrderLineItemsToUpdate);

        // Step 5: Update Total Claimed Amount on Warranty Priors
        if (!warrantyPriorIds.isEmpty()) {
            updateWarrantyTotalClaimedAmount(warrantyPriorIds);
        }
    }

    public static void handleUpdate(List<WorkOrderLineItem> workOrderLineItems, Map<Id, WorkOrderLineItem> oldMap) {
        // Step 1: Collect Warranty Prior IDs for updated items
        Set<Id> warrantyPriorIds = new Set<Id>();
        for (WorkOrderLineItem item : workOrderLineItems) {
            if (item.Warranty_Prior__c != null) {
                warrantyPriorIds.add(item.Warranty_Prior__c);
            }
            WorkOrderLineItem oldItem = oldMap.get(item.Id);
            if (oldItem != null && oldItem.Warranty_Prior__c != item.Warranty_Prior__c) {
                warrantyPriorIds.add(oldItem.Warranty_Prior__c);
            }
        }

        // Step 2: Update Total Claimed Amount on Warranty Priors
        if (!warrantyPriorIds.isEmpty()) {
            updateWarrantyTotalClaimedAmount(warrantyPriorIds);
        }
    }
    public static void handleDelete(List<WorkOrderLineItem> deletedWorkOrderLineItems) {
        try {
            // Step 1: Collect Warranty Prior IDs from deleted items
            Set<Id> warrantyPriorIds = new Set<Id>();
            for (WorkOrderLineItem item : deletedWorkOrderLineItems) {
                if (item.Warranty_Prior__c != null) {
                    warrantyPriorIds.add(item.Warranty_Prior__c);
                }
            }
    
            // Step 2: Filter Warranty Priors that still have related WorkOrderLineItems
            if (!warrantyPriorIds.isEmpty()) {
                Set<Id> warrantyIdsToUpdate = new Set<Id>();
    
                // Query to check remaining WorkOrderLineItems
                List<AggregateResult> remainingItems = [
                    SELECT Warranty_Prior__c, COUNT(Id) recordCount
                    FROM WorkOrderLineItem
                    WHERE Warranty_Prior__c IN :warrantyPriorIds
                    GROUP BY Warranty_Prior__c
                ];
    
                // Add to update set only if there are remaining items
                for (AggregateResult result : remainingItems) {
                    Id warrantyId = (Id) result.get('Warranty_Prior__c');
                    Long recordCount = (Long) result.get('recordCount');
                    if (recordCount > 0) {
                        warrantyIdsToUpdate.add(warrantyId);
                    }
                }
    
                // Step 3: Update Total Claimed Amount on valid Warranty Priors
                if (!warrantyIdsToUpdate.isEmpty()) {
                    updateWarrantyTotalClaimedAmount(warrantyIdsToUpdate);
                } else {
                    System.debug('No Warranty Prior records to update.');
                }
            }
        } catch (Exception e) {
            System.debug('Error in handleDelete: ' + e.getMessage());
            throw e;
        }
    }
    

    private static void updateWarrantyTotalClaimedAmount(Set<Id> warrantyPriorIds) {
        try {
            System.debug('Warranty Prior IDs for Total Claimed Amount Update: ' + warrantyPriorIds);
        
            // Step 1: Aggregate TotalAmount__c from WorkOrderLineItems
            Map<Id, Decimal> warrantyToTotalAmountMap = new Map<Id, Decimal>();
            List<AggregateResult> aggregateResults = [
                SELECT Warranty_Prior__c, SUM(TotalAmount__c) totalAmount
                FROM WorkOrderLineItem
                WHERE Warranty_Prior__c IN :warrantyPriorIds
                GROUP BY Warranty_Prior__c
            ];
        
            System.debug('Aggregate Results for TotalAmount__c: ' + aggregateResults);
        
            for (AggregateResult result : aggregateResults) {
                warrantyToTotalAmountMap.put(
                    (Id) result.get('Warranty_Prior__c'),
                    (Decimal) result.get('totalAmount')
                );
            }
        
            System.debug('Map of Warranty Prior to Total Amount: ' + warrantyToTotalAmountMap);
        
            // Step 2: Update Warranty Prior records
            List<Warranty_Prior__c> warrantiesToUpdate = new List<Warranty_Prior__c>();
            for (Id warrantyId : warrantyPriorIds) {
                if (warrantyId != null) { // Ensure warrantyId is not null
                    Decimal totalAmount = warrantyToTotalAmountMap.get(warrantyId) != null ? warrantyToTotalAmountMap.get(warrantyId) : 0;
                    System.debug('Warranty ID: ' + warrantyId + ', Total Amount: ' + totalAmount);
        
                    warrantiesToUpdate.add(new Warranty_Prior__c(
                        Id = warrantyId,
                        Total_Claim_Amount__c = totalAmount
                    ));
                } else {
                    System.debug('Skipping update for null Warranty ID.');
                }
            }
        
            if (!warrantiesToUpdate.isEmpty()) {
                System.debug('Warranties to Update: ' + warrantiesToUpdate);
                update warrantiesToUpdate;
            } else {
                System.debug('No Warranties to Update.');
            }
        } catch (Exception e) {
            System.debug('Error in updateWarrantyTotalClaimedAmount: ' + e.getMessage());
            throw e;
        }
    }
    
    



// public static void handleUpdate(List<WorkOrderLineItem> workOrderLineItems, Map<Id, WorkOrderLineItem> oldMap) {
//     // Step 1: Identify WorkOrderLineItems where WorkOrderId has changed
//     Set<Id> changedWorkOrderIds = new Set<Id>();
//     for (WorkOrderLineItem item : workOrderLineItems) {
//         WorkOrderLineItem oldItem = oldMap.get(item.Id);
//         if (item.WorkOrderId != oldItem.WorkOrderId) {
//             changedWorkOrderIds.add(item.WorkOrderId);
//             changedWorkOrderIds.add(oldItem.WorkOrderId);
//         }
//     }
//     System.debug('Changed WorkOrder IDs: ' + changedWorkOrderIds);

//     // Step 2: Query existing Warranty Priors for the changed WorkOrders
//     Map<Id, Warranty_Prior__c> warrantyMap = new Map<Id, Warranty_Prior__c>(
//         [SELECT Id, Job_Card__c FROM Warranty_Prior__c WHERE Job_Card__c IN :changedWorkOrderIds]
//     );
//     System.debug('Queried Warranty Priors: ' + warrantyMap);

//     // Step 3: Update WorkOrderLineItems with the correct Warranty Prior
//     List<WorkOrderLineItem> itemsToUpdate = new List<WorkOrderLineItem>();

//     for (WorkOrderLineItem item : workOrderLineItems) {
//         if (item.WorkOrderId == null) continue;

//         // Get the correct Warranty Prior for the new WorkOrder
//         Warranty_Prior__c warranty = warrantyMap.get(item.WorkOrderId);

//         if (warranty != null) {
//             item.Warranty_Prior__c = warranty.Id;
//             itemsToUpdate.add(item);
//         }
//     }
//     System.debug('Items to Update on Update: ' + itemsToUpdate);

//     // Step 4: Update WorkOrderLineItems
//     if (!itemsToUpdate.isEmpty()) {
//         update itemsToUpdate;
//     }
// }

    public static void createProductConsumed(List<WorkOrderLineItem> newPartList){
        
        workOrderLineItemWrapper woli = new workOrderLineItemWrapper();
        
        
        
        List<ProductConsumed> pcToInsert = new List<ProductConsumed>();
        try{
            for(WorkOrderLineItem w : newPartList){
                woli.partId.add(w.Id);
                if(w.WorkOrderId != null){
                    woli.workOrderId.add(w.WorkOrderId);
                }
            }
            
            System.debug('partId==>'+woli.partId);
            System.debug('workOrderId==>'+woli.workOrderId);
            List<WorkOrder> workOrderList = [SELECT Id,ContactId from WorkOrder where Id IN:woli.workOrderId];
            for(WorkOrder wo : workOrderList){
                woli.ContactIds.add(wo.ContactId);
            }
            System.debug('ContactIds===>'+woli.ContactIds);
            
            List<Contact> contactList = [SELECT Id, Location__c  FROM Contact WHERE Id IN :woli.ContactIds];
            for(Contact c : contactList){
                woli.locationIds.add(c.Location__c);
            }
            System.debug('locationIds==>'+woli.locationIds);
            
            List<ProductItem> productInventoryList = [SELECT Id, LocationId, Product2Id FROM ProductItem WHERE LocationId IN :woli.locationIds];
            
            for (ProductItem p : productInventoryList) {
                woli.productInventoryMap.put(p.Product2Id, p.Id);
            }
            System.debug('productInventoryMap===>'+woli.productInventoryMap);
            
            List<WorkOrderLineItem> insertedPartList = [SELECT Id, WorkOrderId, Product_Code__c, Product2Id, Product_Consumed__c, 
                                                        PricebookEntry.Product2Id, WorkOrder.Pricebook2.Id, Warranty_Prior__c, PricebookEntryId, Quantity 
                                                        FROM WorkOrderLineItem
                                                        WHERE Id IN:woli.partId];
            
            System.debug('insertedPartList==>'+insertedPartList);
            
            for (WorkOrderLineItem ww : insertedPartList) {
                
                ProductConsumed p = new ProductConsumed();
                p.WorkOrderId = ww.WorkOrderId;
                p.WorkOrderLineItemId = ww.Id;
                p.QuantityConsumed =ww.Quantity;
                p.Quantity_Consumed__c = ww.Quantity;
                p.PricebookEntryId = ww.PricebookEntryId;
                p.Product__c=ww.Product2Id;
                p.ProductItemId = woli.productInventoryMap.get(ww.PricebookEntry.Product2Id);
                pcToInsert.add(p);
                
            }
            
            
            if (!pcToInsert.isEmpty()) {
            insert pcToInsert;
        }

        
        
    } catch (Exception e) {
        System.debug('Error Occured==>'+e.getMessage()+'Error Occured in Line Number==>'+e.getLineNumber());
        System.debug('Type: ' + e.getTypeName());
        System.debug('Stack Trace: ' + e.getStackTraceString());
        System.debug('Cause: ' + e.getCause());
        
    }
    }
    public class workOrderLineItemWrapper{
        Set<Id> partId = new Set<Id>();
        Set<Id> workOrderId = new Set<Id>();
        Set<Id> ContactIds = new Set<Id>();
        Set<Id> locationIds = new Set<Id>();
        Map<Id,Id> productInventoryMap = new Map<Id,Id>();
    }
  /*  public static void deleteProductConsumedRecord(List<WorkOrderLineItem> deletedRecords){
        Set<Id> partIds = new Set<Id>();
        try{
            for(WorkOrderLineItem w : deletedRecords){
                partIds.add(w.Id);
            }
            System.debug('partIds===>'+partIds);
            
            List<ProductConsumed> pcList = [Select Id,WorkOrderLineItemId from ProductConsumed Where WorkOrderLineItemId IN:partIds];
           
            System.debug('pcList===>'+pcList);
            
            
        }catch(Exception e){
            System.debug('Error Occured===>'+e.getMessage()+'Error Occured In Line Number===>'+e.getLineNumber());
        }
        
        
    }*/
}