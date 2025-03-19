@isTest
private class JobCardEstimatationControllerTest {
    static testMethod void testControllerInitialization() {
        
        Account ac = new Account(Name = 'Test Service center', Email__c = 'testdealer@gmail.com',Phone = '1234567891', type='Service Center',Center_Code__c = '2803', ShippingCountry='India', ShippingState='Karnataka', ShippingPostalCode='123456',ShippingCity='testcity',ShippingStreet='teststreet');
        insert ac;
        
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com',Phone = '1234567890', Service_Center__c = ac.id, type='Customer', ShippingCountry='India',ShippingState='Karnataka', ShippingPostalCode='123456',ShippingCity='testcity',ShippingStreet='teststreet');
        insert acc;
        
        Account acDealer = new Account(Name = 'Test Dealer', Email__c = 'testdealer@gmail.com',Phone = '1237567891', type='Dealer', Center_Code__c = '2003', ShippingCountry='India', ShippingState='Karnataka', ShippingPostalCode='121456',ShippingCity='testcity',ShippingStreet='teststreet');
        insert acDealer;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567898', Primary_Contact__c= true, Email ='test@gmail.com');
        insert con;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asset;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', ProductCode='2803');
        insert product;

        VehicleDefinition vehiDefi = new VehicleDefinition(Name = 'Test Definition', ProductId = product.id);
        insert vehiDefi;

        Software_Version__c softwareVersion = new Software_Version__c(Name = 'Test Version 1');
        insert softwareVersion;

        Vehicle vehicle = new Vehicle(
            Name = 'Test Vehicle',
            assetId = asset.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleDefinitionId = vehiDefi.id,
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            Charger_PC_Number__c = 'TEST123',
            PDI_Status_Pass__c = true,
            VehicleRegistrationNumber = 'RIVER-GUJ-8A2-C'
        );
        insert vehicle;
        
        Case testCase = new Case(
            contactId = con.id,
            accountId = acc.id,
            vehicle__c = vehicle.id,
            case_type__c = 'Urgent Complaint',
            status = 'New',
            origin = 'Phone',
            Description = 'Test',
            Subject__c = 'Parts Concern',
            Case_Category__c = 'Parts',
            Vehicle_Registration_Number__c = 'RIVER-GUJ-8A2-C',
            Assign_to_Dealer__c = acDealer.id
            //Case_Concern__c = 'Throttle'
        );
        insert testCase;

        Customer_Feedback__c testFeedback = new Customer_Feedback__c(
            Case__c = testCase.Id,
            name = 'Test Customer Feedback',
            issue_type__c = 'Parts',
           	Resolution_provided__C = 'Test Solution'
        );
        insert testFeedback;

        /*AssetMilestone testMilestone = new AssetMilestone(
            Name = 'Test Milestone ',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Customer Delivery',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert testMilestone;*/

        WorkOrder testWorkOrder = new WorkOrder(
            Vehicle__c = vehicle.Id,
            AccountId = acc.Id,
            ContactId = con.Id
            // Add other required fields here
        );
        insert testWorkOrder;

        Pricebook2 pb = new Pricebook2(Name='Standard Pricebook', IsActive=true);
        insert pb;

        // Create Product
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            IsActive = true,
            Description = 'Test Product Description',
            HSN_Code__c = 'HSN002',
            Type__c = 'Parts',
            ProductCode = '9999'

        );
        insert testProduct;

        // Add Pricebook Entry
        /*PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbe;*/

        /*WorkOrderLineItem testLineItem = new WorkOrderLineItem(
            WorkOrderId = testWorkOrder.Id,
            UnitPrice = 100.00,
            product2Id = testProduct.id
        );
        insert testLineItem;*/

        // Start test
        Test.startTest();

        // Set page parameters
        PageReference pageRef = Page.JobCardEstimate; // Replace YourPageName with the actual page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', testWorkOrder.Id);

        // Instantiate the controller
        JobCardEstimatationController controller = new JobCardEstimatationController();

        Test.stopTest();
    }
    
  /*  @isTest
    static void testGetOL() {
        // Instantiate the controller
        JobCardEstimatationController controller = new JobCardEstimatationController();
        
        // Call the getOL() method
        List<String> result = controller.getOL();
    }*/
}