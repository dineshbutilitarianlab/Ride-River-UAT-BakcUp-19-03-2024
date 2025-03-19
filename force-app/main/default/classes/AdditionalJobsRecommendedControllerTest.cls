@isTest
public class AdditionalJobsRecommendedControllerTest {
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
            Odometer_Reading__c= 120,
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

        // Create CodeSet records with unique Codes
        CodeSet ct1 = new CodeSet();
        ct1.Name = 'LabourCode1';
        ct1.Code = 'Code1';
        ct1.RR_Efforts_Hours__c = 2;
        ct1.RR_Labour_Charge__c = 1000;
        insert ct1;

        CodeSet ct2 = new CodeSet();
        ct2.Name = 'LabourCode2';
        ct2.Code = 'Code2';
        ct2.RR_Efforts_Hours__c = 1;
        ct2.RR_Labour_Charge__c = 2000;
        insert ct2;

        // Create RR_Additional_Job_Recommended__c records
        RR_Additional_Job_Recommended__c job1 = new RR_Additional_Job_Recommended__c(
            RR_Product__c = testProduct1.Id,
            RR_Work_Order__c = testWorkOrder.Id,
            RR_Quantity__c = 1,
            RR_Description__c = 'Job 1 description',
            RR_Labour_Code__c = ct1.Id
        );
        RR_Additional_Job_Recommended__c job2 = new RR_Additional_Job_Recommended__c(
            RR_Product__c = testProduct2.Id,
            RR_Work_Order__c = testWorkOrder.Id,
            RR_Quantity__c = 2,
            RR_Description__c = 'Job 2 description',
            RR_Labour_Code__c = ct2.Id
        );
        insert new List<RR_Additional_Job_Recommended__c>{job1, job2};
    }

    @isTest
    static void testGetAdditionalJobs() {
        // Retrieve the test work order
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];

        // Call the method to test
        Test.startTest();
        List<RR_Additional_Job_Recommended__c> result = AdditionalJobsRecommendedController.getAdditionalJobs(testWorkOrder.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(2, result.size(), 'Result size should be 2');

        Map<String, RR_Additional_Job_Recommended__c> jobMap = new Map<String, RR_Additional_Job_Recommended__c>();
        for (RR_Additional_Job_Recommended__c job : result) {
            jobMap.put(job.RR_Product__r.ProductCode, job);
        }

        // Check details of each job
        System.assert(jobMap.containsKey('TP-001'), 'Job for TP-001 should be present');
        System.assert(jobMap.containsKey('TP-002'), 'Job for TP-002 should be present');

        RR_Additional_Job_Recommended__c job1 = jobMap.get('TP-001');
        System.assertEquals('Test Product 1', job1.RR_Product__r.Name, 'Product name should be "Test Product 1"');
        System.assertEquals(1, job1.RR_Quantity__c, 'Quantity should be 1');
        System.assertEquals('Job 1 description', job1.RR_Description__c, 'Description should be "Job 1 description"');
        System.assertEquals('Code1', job1.RR_Labour_Code__r.Code, 'Labour Code should be "Code1"');
        System.assertEquals(1000, job1.RR_Labour_Code__r.RR_Labour_Charge__c, 'Labour Charge should be 1000');
        System.assertEquals(2, job1.RR_Labour_Code__r.RR_Efforts_Hours__c, 'Efforts Hours should be 2');

        RR_Additional_Job_Recommended__c job2 = jobMap.get('TP-002');
        System.assertEquals('Test Product 2', job2.RR_Product__r.Name, 'Product name should be "Test Product 2"');
        System.assertEquals(2, job2.RR_Quantity__c, 'Quantity should be 2');
        System.assertEquals('Job 2 description', job2.RR_Description__c, 'Description should be "Job 2 description"');
        System.assertEquals('Code2', job2.RR_Labour_Code__r.Code, 'Labour Code should be "Code2"');
        System.assertEquals(2000, job2.RR_Labour_Code__r.RR_Labour_Charge__c, 'Labour Charge should be 2000');
        System.assertEquals(1, job2.RR_Labour_Code__r.RR_Efforts_Hours__c, 'Efforts Hours should be 1');
    }
    @isTest
    static void setupTestData2() {
        // Set up the standard pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        // Create test product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;

        // Create pricebook entry for the test product
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
    }

    @isTest
    static void testGetDynamicValues() {
        // Retrieve the test product
        Product2 testProduct = [SELECT Id FROM Product2 WHERE ProductCode = 'TP-001' LIMIT 1];

        // Call the method to test
        Test.startTest();
        Map<String, Object> result = AdditionalJobsRecommendedController.getDynamicValues(testProduct.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(100, result.get('price'), 'Price should be 100');
        System.assertEquals('TP-001', result.get('productCode'), 'Product code should be "TP-001"');
    }
      @isTest
    static void testGetLabourCode() {
        // Set up test data
        CodeSet testCodeSet = new CodeSet(
            Name='LabourCode1',
            Code = 'TESTCODE123',
            CodeDescription = 'Test Code Description'
        );
        insert testCodeSet;

        // Call the method to test
        Test.startTest();
        Map<String, String> result = AdditionalJobsRecommendedController.getLabourCode(testCodeSet.Id);
        Test.stopTest();

        // Verify the results
        System.assertEquals(testCodeSet.Id, result.get('labourCodeId'), 'Labour Code Id should match');
        System.assertEquals('TESTCODE123', result.get('labourCode'), 'Labour Code should match');
        //System.assertEquals('Test Code Description', result.get('CodeDescription'), 'Code Description should match');
    }

    @isTest
    static void testGetLabourCode_Null() {
        // Call the method with a null Id
        Test.startTest();
        Map<String, String> result = AdditionalJobsRecommendedController.getLabourCode(null);
        Test.stopTest();

        // Verify that the result is null
        System.assertEquals(null, result.get('labourCodeId'), 'Labour Code Id should be null');
        System.assertEquals(null, result.get('labourCode'), 'Labour Code should be null');
        System.assertEquals(null, result.get('CodeDescription'), 'Code Description should be null');
    }

   /* @isTest
    static void testGetLabourCode_Exception() {
        // Call the method with an invalid Id to simulate an exception
        Test.startTest();
        Map<String, String> result = AdditionalJobsRecommendedController.getLabourCode('invalidId');
        Test.stopTest();

        // Verify that the result is null due to the exception handling in the method
        System.assertEquals(null, result.get('labourCodeId'), 'Labour Code Id should be null');
        System.assertEquals(null, result.get('labourCode'), 'Labour Code should be null');
        System.assertEquals(null, result.get('CodeDescription'), 'Code Description should be null');
    }*/
      @isTest
    static void testGetProductPrice() {
        // Set up test data
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;

        // Get the Id of the standard pricebook
        Id standardPricebookId = Test.getStandardPricebookId();

        PricebookEntry testEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry;

        // Call the method to test
        Test.startTest();
        Decimal result = AdditionalJobsRecommendedController.getProductPrice(testProduct.Id);
        Test.stopTest();

        // Verify the result
        System.assertEquals(100, result, 'Product price should be 100');
    }

    @isTest
    static void testGetProductPrice_NoPricebookEntry() {
        // Set up test data without a corresponding PricebookEntry
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;

        // Call the method to test
        Test.startTest();
        Decimal result = AdditionalJobsRecommendedController.getProductPrice(testProduct.Id);
        Test.stopTest();

        // Verify the result should be 0 when no PricebookEntry is found
        System.assertEquals(0, result, 'Product price should be 0 when no PricebookEntry is found');
    }
     @isTest 
    public static void testSubmitAndSendEmail() {
        // Create test data
        WorkOrder testWorkOrder = new WorkOrder(Subject = 'Test Work Order',Odometer_Reading__c=122);
        insert testWorkOrder;
        
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = '001',
            Type__c = 'Parts'
        );
        insert testProduct;
        
        Id standardPricebookId = Test.getStandardPricebookId();

        PricebookEntry testEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert testEntry;

        RR_Additional_Job_Recommended__c additionalJob = new RR_Additional_Job_Recommended__c(
            RR_Work_Order__c = testWorkOrder.Id,
            RR_Product__c= testProduct.Id
            // Add other required fields
        );
        insert additionalJob;

        // Set up email mock
        Test.startTest();
        

        // Call the method to test
        String result = AdditionalJobsRecommendedController.submitAndSendEmail(testWorkOrder.Id);

        // Verify the result

        Test.stopTest();
    }

   
}