@isTest
private class Customer_Invoice_PDF_Controller_Test {
    @isTest static void testNull() {
        // Create test data
        
        Account acc = new Account();
        acc.Name = 'testing Account';
        acc.Type = 'Customer';
        acc.Phone = '9807654321';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'testing Contact';
        con.AccountId = acc.Id;
        con.Phone = '9123456789';
        con.Email = 'test@test.com';
        con.Primary_Contact__c = true;
        insert con;
        
        Asset asst = new Asset();
        asst.Name = 'test Asset';
        asst.AccountId = acc.Id;
        asst.ContactId = con.Id;
        insert asst;
        
        Software_Version__c sv = new Software_Version__c();
        sv.Name = 'test version';
        sv.Latest_Software_Version__c = true;
        insert sv;
        
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.HSN_Code__c = '123';
        prod.Type__c = 'Vehicle';
        prod.ProductCode = '2132132';
        insert prod;
        
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'test VehicleDefinition';
        vd.ProductId = prod.Id;
        insert vd;
        
        Vehicle vac = new Vehicle();
        vac.Name = 'test vehicle';
        vac.CurrentOwnerId = acc.Id;
        vac.Charger_PC_Number__c = '123CC';
        vac.VehicleRegistrationNumber = '123';
        vac.VehicleIdentificationNumber = 'NeoCity2022ZXi';
        vac.VehicleDefinitionId = vd.Id;
        vac.Software_Version__c = sv.Id;
        vac.AssetId = asst.Id;
        vac.Spare_Vehicle__c = false;
        insert vac;
        
        // Create a test Warehouse
        Warehouse__c testWarehouse = new Warehouse__c();
        testWarehouse.Name = 'Test Warehouse';
        
        
        
        insert testWarehouse;
        
        // Create a test WorkOrder with the required fields, including Warehouse__c
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Warehouse__c = testWarehouse.Id; // Set the Warehouse reference
        testWorkOrder.Vehicle__c = vac.Id;
        testWorkOrder.AccountId = acc.Id;
        insert testWorkOrder;
        
        // Create a test Work Type record (related to Work_Type__c lookup field)
        WorkType testWorkType = new WorkType();
        testWorkType.Name = 'Test Work Type';
        testWorkType.Amount__c = 100.0;
        testWorkType.EstimatedDuration = 2; // Correct the field name
        testWorkType.DurationType = 'Hours'; // Correct the field name
        insert testWorkType;
        
        
        // Create a test WorkPlan associated with the test WorkOrder
        WorkPlan testWorkPlan = new WorkPlan();
        testWorkPlan.Name = 'Test Workplan';
        testWorkPlan.Labour_Charge__c = 100.0; // Set values as needed
        testWorkPlan.Work_Type__c = testWorkType.Id; // Use the ID of the created WorkType record
        testWorkPlan.WorkOrderId = testWorkOrder.Id;
        testWorkPlan.RR_Labour_Category__c = 'Paid';
        testWorkPlan.Duration_Hour__c = 1;
        testWorkPlan.Labour_Charge__c = 100;
        // testWorkPlan.Discount__c = 2;
        insert testWorkPlan;
        
        WorkPlan testWorkPlan1 = new WorkPlan();
        testWorkPlan1.Name = 'Test Workplan1';
        testWorkPlan1.Labour_Charge__c = 100.0; // Set values as needed
        testWorkPlan1.Work_Type__c = testWorkType.Id; // Use the ID of the created WorkType record
        testWorkPlan1.WorkOrderId = testWorkOrder.Id;
        testWorkPlan1.RR_Labour_Category__c = 'Insurance';
        testWorkPlan1.Duration_Hour__c = 1;
        testWorkPlan1.Labour_Charge__c = 100;
        // testWorkPlan1.Discount__c = 2;
        insert testWorkPlan1;
        
        // Call the method being tested
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(testWorkOrder);
            PageReference pageRef = Page.Customer_Invoice_PDF; // Add your VF page Name here
            pageRef.getParameters().put('id', String.valueOf(testWorkOrder.Id));
            Test.setCurrentPage(pageRef);
            Customer_Invoice_PDF_Controller obj = new Customer_Invoice_PDF_Controller(sc);
        Test.stopTest();
    }
}