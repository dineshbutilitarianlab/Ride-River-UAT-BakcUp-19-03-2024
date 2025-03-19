@isTest
public class WorkOrderLineHandlerTest {
    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        WorkOrder testWorkOrder = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            Odometer_Reading__c= 120,
            Pricebook2Id = standardPricebook.Id
        );
        insert testWorkOrder;

        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pricebookEntry;
        
        
        Schema.Location l1 = new Schema.Location(); 
        l1.Name = 'Warehouse 1';
        l1.LocationType = 'Secondary';
        l1.IsInventoryLocation = true;
        insert l1;
        
        ProductItem pItem = new ProductItem(
            Product2Id= testProduct.Id,
            LocationId = l1.Id,
            Transfer_Quantity__c = 10, 
            Inward_Quantity__c = 9,
            QuantityOnHand = 30
        );
        insert pItem;
        
        
        // Create Work Order Line Item
        WorkOrderLineItem woli = new WorkOrderLineItem(
            WorkOrderId = testWorkOrder.Id,
            Warranty_Prior__c = null,
            PricebookEntryId = pricebookEntry.Id
        );
        insert woli;
        
         ProductConsumed pConsumed1 = new ProductConsumed(
            WorkOrderLineItemId = woli.Id,
            ProductItemId = pItem.Id,
             QuantityConsumed = 1,
            Quantity_Consumed__c = 1,
            WorkOrderId = testWorkOrder.Id
        );

        ProductConsumed pConsumed2 = new ProductConsumed( // Second ProductConsumed for the same ProductItem
            WorkOrderLineItemId = woli.Id,
            ProductItemId = pItem.Id,
            QuantityConsumed = 1,
            Quantity_Consumed__c = 1,
            WorkOrderId = testWorkOrder.Id
        );

        insert new List<ProductConsumed>{ pConsumed1, pConsumed2 };
        
        // Create Warranty Prior
        List<Warranty_Prior__c> warPriorList = new List<Warranty_Prior__c>();
        Warranty_Prior__c warrantyPrior = new Warranty_Prior__c();
        warPriorList.add(warrantyPrior);
        insert warPriorList;
        //insert warrantyPrior;
        
        // Create Work Order Line Item with Warranty Prior
        List<WorkOrderLineItem> workitemlList = new List<WorkOrderLineItem>();
        WorkOrderLineItem woliWithWarranty = new WorkOrderLineItem(
            WorkOrderId = testWorkOrder.Id,
            Warranty_Prior__c = warPriorList[0].Id, 
             PricebookEntryId = pricebookEntry.Id
        );
       workitemlList.add(woliWithWarranty);
        insert workitemlList;
        
        // Create WorkPlan associated with Warranty Prior
        WorkPlan workPlan = new WorkPlan(Warranty_Prior__c = warrantyPrior.Id, Name = 'test', ParentRecordId =testWorkOrder.Id );
        insert workPlan;
         List<WorkOrderLineItem> workOrderLines = [SELECT Id, Warranty_Prior__c FROM WorkOrderLineItem LIMIT 1];
        Test.startTest();
        WorkOrderLineHandler.handleAfterDelete(workitemlList);
        Test.stopTest();
    }
    
    @isTest
    static void testHandleDelete() {
        // Fetch test data
        List<WorkOrderLineItem> workOrderLines = [SELECT Id, Warranty_Prior__c FROM WorkOrderLineItem LIMIT 1];
        
        Test.startTest();
        delete workOrderLines;
        Test.stopTest();
       
    }
}