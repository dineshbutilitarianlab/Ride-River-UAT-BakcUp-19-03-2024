@isTest
public class WorkOrderLineItemControllerTest {
    // Common test data setup
    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        // Create test data
       

        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;

        PricebookEntry standardPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100, // Set your desired unit price
            IsActive = true
        );
        insert standardPricebookEntry;


        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113248', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
         
        Schema.Location l2 = new Schema.Location(); 
        l2.Name = 'Warehouse 1';
        l2.LocationType = 'Secondary';
        l2.IsInventoryLocation = true;
        insert l2;
        
        Contact contacts = new Contact(lastName='test Contact', Primary_contact__c=true, FirstName='Test name', Phone='6767676767', email='testemail@gmail.com', AccountId=dealerAccount.Id,Location__c =l2.Id    );
        insert contacts; 
      
        
         WorkOrder testWorkOrder = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            Odometer_Reading__c= 120,
            Pricebook2Id = standardPricebook.Id , // Associate the standard pricebook with the WorkOrder
                Dealer_Contact__c = contacts.id
        );
        insert testWorkOrder;
                WorkOrderLineItem testWorkOrderLineItem = new WorkOrderLineItem(
            WorkOrderId = testWorkOrder.Id,
            PricebookEntryId = standardPricebookEntry.Id, // Use the Pricebook Entry ID here
            Quantity = 1,
            Status = 'New'
        );
        insert testWorkOrderLineItem;
        
      

        // Assert that at least one WorkOrder exists
         

       
        System.debug('Using testWorkOrder: ' + testWorkOrder.Id);
        Test.startTest();
         WorkOrderLineItemController.getAvailableQuantity(testProduct.id,testWorkOrder.id);
        Test.stopTest();
    }

    // Test method for getting related work order line items
    @isTest
    static void testGetRelatedWorkOrderLineItems() {
        // Retrieve the test work order
        List<WorkOrder> workOrders = [SELECT Id FROM WorkOrder LIMIT 1];
        System.debug('Retrieved workOrders: ' + workOrders);

        // Assert that at least one WorkOrder exists
        System.assertNotEquals(0, workOrders.size(), 'No WorkOrders found');

        WorkOrder testWorkOrder = workOrders[0];
        System.debug('Using testWorkOrder: ' + testWorkOrder.Id);
         
        list<WorkOrderLineItem> workitemRecv = [SELECT Id FROM WorkOrderLineItem LIMIT 1];
        System.assertNotEquals(0, workitemRecv.size(),'No WorkOrders found');
        WorkOrderLineItem testWorkOrderLineItem = workitemRecv[0];                   
        // Call the method to test
        Test.startTest();
        List<WorkOrderLineItem> result = WorkOrderLineItemController.getRelatedWorkOrderLineItems(testWorkOrder.Id);
        WorkOrderLineItemController.getWarrantyForJobCard(testWorkOrder.id);
        WorkOrderLineItemController.deleteWorkOrderLineItemApex(testWorkOrderLineItem.id, testWorkOrder.id);
        Test.stopTest();
        System.debug('Retrieved WorkOrderLineItems: ' + result);

        // Verify the results
        System.assertEquals(1, result.size(), 'Result size should be 1');
        System.assertEquals(testWorkOrder.Id, result[0].WorkOrderId, 'WorkOrderId should match the test Work Order Id');
        System.assertEquals(1, result[0].Quantity, 'Quantity should be 1');
        System.assertEquals('New', result[0].Status, 'Status should be "New"');
    }
}