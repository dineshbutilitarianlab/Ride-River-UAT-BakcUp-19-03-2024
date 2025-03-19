public with sharing class WorkOrderLineItemController {
    
    @AuraEnabled(cacheable=true)
    public static List<WorkOrderLineItem> getRelatedWorkOrderLineItems(Id workOrderId){
        try{
            System.debug('Fetching related Products for Work Order Id: ' + workOrderId);
            List<WorkOrderLineItem> WorkOrderLineItems = [SELECT WorkOrderId, Id, LineItemNumber, PricebookEntryId, PricebookEntry.Product2.Name, Quantity, RR_Parts_Category__c, Status,WorkOrder.Status,
                                                          PricebookEntry.Product2.ProductCode,CreatedDate,WorkOrder.WorkOrderNumber, PricebookEntry.Product2Id,Labour_Code__c,Labour_Code__r.Name, Product2.ProductCode
                                                          FROM WorkOrderLineItem
                                                          WHERE WorkOrderId=: workOrderId
                                                          ORDER BY CreatedDate ASC];
            System.debug('Retrieved related WorkOrderLineItems: ' + WorkOrderLineItems);
            
            RETURN WorkOrderLineItems;
        }catch(exception e){
            system.debug('Error Message'+e.getMessage()+ ' at Line Number'+ e.getLineNumber());
            return null;
        }
    }

    @AuraEnabled
    public static Id getWarrantyForJobCard(Id workOrderId) {
        system.debug('workOrderId'+workOrderId);
        // check here wgich workorderid is coming
        try{
            Warranty_Prior__c warranty = [
                SELECT Id
                FROM Warranty_Prior__c
                WHERE Job_Card__c = :workOrderId
                LIMIT 1
            ];
            return warranty != null ? warranty.Id : null;
        }catch(exception e){
            system.debug('Error Message'+e.getMessage()+ ' at Line Number'+ e.getLineNumber());
            return null;
        }
    }
    //additional code by Aniket on 20/01/2025 for Deleting added Parts added code by Astitva for deletion of the jobcard 
    @AuraEnabled
    public static void deleteWorkOrderLineItemApex(String rowId , Id workOrderId){
        system.debug('JobCard'+ workOrderId);
          WorkOrder JobCard = [Select Id ,Status from WorkOrder WHERE Id = :workOrderId LIMIT 1];
          If( JobCard.Status == 'Completed'|| JobCard.Status == 'Cancellation Requested' || JobCard.Status == 'Canceled' ){
             system.debug('you cannot delete this record as it is already in Final Stage');
          }else{
            system.debug('ProductConsumed'+ [Select Id, WorkOrderLineItemId  from ProductConsumed where WorkOrderLineItemId =:rowId]);
             delete [Select Id, WorkOrderLineItemId from ProductConsumed where WorkOrderLineItemId =:rowId];
             
             delete [Select Id from WorkOrderLineItem WHERE Id=:rowId];
          }
           
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getAvailableQuantity(Id productId, Id workOrderId) {
    try {
        System.debug('Fetching available quantity of Product ' + productId + ' in WorkOrder ' + workOrderId);

        
        WorkOrder wo = [SELECT Dealer_Contact__r.Location__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
        System.debug('Fetched WorkOrder: ' + wo);
        
        if (wo.Dealer_Contact__r.Location__c == null) {
            System.debug('No Location found for the WorkOrder: ' + workOrderId);
            throw new AuraHandledException('No Location found for this Work Order.');
        }

        Id locationId = wo.Dealer_Contact__r.Location__c;
       // Id locationId = wo.Contact.Location__c;
        System.debug('Location ID for WorkOrder ' + workOrderId + ': ' + locationId);

        ProductItem productInventory = [SELECT Quantity_In_Hand__c FROM ProductItem WHERE Product2Id = :productId AND LocationId = :locationId LIMIT 1];
        System.debug('Fetched ProductItem: ' + productInventory);

        if (productInventory != null) {
            System.debug('Available Quantity of Product ' + productId + ' at Location ' + locationId + ': ' + productInventory.Quantity_In_Hand__c);
            return productInventory.Quantity_In_Hand__c;
        } else {
            System.debug('No ProductInventory found for Product ' + productId + ' at Location ' + locationId);
            return 0;
        }
    } catch (Exception e) {
        System.debug('Error fetching available quantity: ' + e.getMessage());
        return -1;
    }
}

/*
    @AuraEnabled(cacheable=true)
    public static Decimal getAvailableQuantity(Id productId, Id workOrderId) {
        try {
            System.debug('Fetching available quantity of Product ' + productId + ' in WorkOrder ' + workOrderId);

            WorkOrder wo = [SELECT Contact.Location__c FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];

            if (wo.Contact.Location__c == null) {
                throw new AuraHandledException('No Location found for this Work Order.');
            }

            Id locationId = wo.Contact.Location__c;
            System.debug('Location ID: ' + locationId);

            ProductItem productInventory = [SELECT Quantity_In_Hand__c 
                                            FROM ProductItem 
                                            WHERE Product2Id = :productId 
                                            AND LocationId = :locationId 
                                            LIMIT 1];

            Decimal availableStock = productInventory != null ? productInventory.Quantity_In_Hand__c : 0;
            System.debug('Current Stock: ' + availableStock);

            Decimal allocatedQuantity = 0;
            List<WorkOrderLineItem> existingLines = [SELECT Quantity 
                                                    FROM WorkOrderLineItem 
                                                    WHERE WorkOrderId = :workOrderId 
                                                    AND Product2Id = :productId];

            for (WorkOrderLineItem line : existingLines) {
                allocatedQuantity += line.Quantity;
            }

            System.debug('Allocated Quantity: ' + allocatedQuantity);

            Decimal remainingStock = availableStock - allocatedQuantity;
            System.debug('Final Available Stock: ' + remainingStock);

            return remainingStock > 0 ? remainingStock : 0; 
        } catch (Exception e) {
            System.debug('Error fetching available quantity: ' + e.getMessage());
            return -1; 
        }
    }
*/

}