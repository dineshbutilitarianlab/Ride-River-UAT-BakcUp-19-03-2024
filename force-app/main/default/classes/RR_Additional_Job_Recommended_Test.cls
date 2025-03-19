@isTest
public class RR_Additional_Job_Recommended_Test {
      @testSetup
    static void setupTestData() {
        // Set up the standard pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        // Create test work order
        WorkOrder testWorkOrder = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            Pricebook2Id = standardPricebook.Id  // Associate the standard pricebook with the WorkOrder
        );
        insert testWorkOrder;

        // Create test products
        Product2 testProduct1 = new Product2(
            Name = 'Test Product 1',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct1;

        Product2 testProduct2 = new Product2(
            Name = 'Test Product 2',
            ProductCode = 'TP-002',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct2;

        // Create pricebook entries for the test products
        PricebookEntry pbe1 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe1;

        PricebookEntry pbe2 = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct2.Id,
            UnitPrice = 200,
            IsActive = true
        );
        insert pbe2;

        // Create RR_Additional_Job_Recommended__c records with RR_Work_Order__c field populated
        RR_Additional_Job_Recommended__c job1 = new RR_Additional_Job_Recommended__c(
            RR_Product__c = testProduct1.Id,
            RR_Work_Order__c = testWorkOrder.Id // Populate the required field
        );
        RR_Additional_Job_Recommended__c job2 = new RR_Additional_Job_Recommended__c(
            RR_Product__c = testProduct2.Id,
            RR_Work_Order__c = testWorkOrder.Id // Populate the required field
        );
        RR_Additional_Job_Recommended__c job3 = new RR_Additional_Job_Recommended__c(
            RR_Work_Order__c = testWorkOrder.Id // Populate the required field, no product
        );

        insert new List<RR_Additional_Job_Recommended__c>{job1, job2, job3};
    }

    @isTest
    static void testHandleUnitPriceUpdate() {
        // Retrieve test products
        Product2 testProduct1 = [SELECT Id FROM Product2 WHERE ProductCode = 'TP-001' LIMIT 1];
        Product2 testProduct2 = [SELECT Id FROM Product2 WHERE ProductCode = 'TP-002' LIMIT 1];

        // Retrieve the test work order
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];

        // Retrieve the inserted RR_Additional_Job_Recommended__c records
        List<RR_Additional_Job_Recommended__c> jobs = [SELECT Id, RR_Product__c, RR_Unit_Price__c, RR_Work_Order__c FROM RR_Additional_Job_Recommended__c WHERE RR_Work_Order__c = :testWorkOrder.Id];

        // Call the handler
        Test.startTest();
        RR_Additional_Job_Recommended_Handler.handleUnitPriceUpdate(jobs);
        Test.stopTest();

        // Verify the results
        jobs = [SELECT Id, RR_Product__c, RR_Unit_Price__c FROM RR_Additional_Job_Recommended__c WHERE RR_Work_Order__c = :testWorkOrder.Id];

        for (RR_Additional_Job_Recommended__c job : jobs) {
            if (job.RR_Product__c == testProduct1.Id) {
                System.assertEquals(100, job.RR_Unit_Price__c, 'Unit price should be 100 for Test Product 1');
            } else if (job.RR_Product__c == testProduct2.Id) {
                System.assertEquals(200, job.RR_Unit_Price__c, 'Unit price should be 200 for Test Product 2');
            } 
        }
    }
}