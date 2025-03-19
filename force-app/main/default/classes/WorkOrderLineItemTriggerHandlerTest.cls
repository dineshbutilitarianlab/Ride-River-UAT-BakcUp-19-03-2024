@isTest
public class WorkOrderLineItemTriggerHandlerTest {
    
    @isTest
    static void testInsertWorkOrderLineItem() {
        // Create Account
        Account acc = new Account(Name = 'Test data');
        insert acc;
        
        // Create Standard Pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            State__c = 'Karnataka',
            IsActive = true
        );
        update standardPricebook;
        
        // Create Product2
        Product2 product1 = new Product2(Name = 'Test Product 1', IsActive = true, ProductCode = 'SDFGH3456', HSN_Code__c = 'FGHJK367', Type__c = 'Parts');
        insert product1;
        
        // Create PricebookEntry
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pricebookEntry1;
        
        // Create WorkOrder
        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id, Status = 'New', Subject = 'Test Work Order');
        insert workOrder;
        
        // Create WorkOrderLineItem
        WorkOrderLineItem workOrderLineItem1 = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,  // Link to the created WorkOrder
            Quantity = 2,  // Example Quantity
            UnitPrice = 120,  // Example Price
            PricebookEntryId = pricebookEntry1.Id // Link to the PricebookEntry
        );
        
        insert workOrderLineItem1;
        
        // Verify WorkOrderLineItem
        WorkOrderLineItem insertedItem = [SELECT Id, Product2Id, PricebookEntryId FROM WorkOrderLineItem WHERE Id = :workOrderLineItem1.Id LIMIT 1];
        System.assertEquals(product1.Id, insertedItem.Product2Id);
        System.assertEquals(pricebookEntry1.Id, insertedItem.PricebookEntryId);
    }
    //method added by Aniket on 17/02/2025
    @IsTest
    static void afterDelete(){
        Account acc = new Account(Name = 'Test data');
        insert acc;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            State__c = 'Karnataka',
            IsActive = true
        );
        update standardPricebook;
        
       
        Product2 product1 = new Product2(Name = 'Test Product 1', IsActive = true, ProductCode = 'SDFGH3456', HSN_Code__c = 'FGHJK367', Type__c = 'Parts');
        insert product1;
        
        
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pricebookEntry1;
        
        
        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id, Status = 'New', Subject = 'Test Work Order');
        insert workOrder;
        
        
        WorkOrderLineItem workOrderLineItem1 = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,  
            Quantity = 2, 
            UnitPrice = 120,  
            PricebookEntryId = pricebookEntry1.Id 
        );
        
        insert workOrderLineItem1;
        Test.startTest();
        delete workOrderLineItem1;
        Test.stopTest();
    }
    
}