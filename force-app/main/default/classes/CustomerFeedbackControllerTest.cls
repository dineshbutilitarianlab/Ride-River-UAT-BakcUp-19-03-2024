@isTest
private class CustomerFeedbackControllerTest {

    static testMethod void testControllerInitialization() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type='Customer');
        insert acc;
        
        Account accDealer = new Account(Name = 'Test Delaer', Email__c = 'testdelaer@gmail.com', Phone = '8767868687', type='Dealer');
        insert accDealer;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
        insert con;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asset;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', ProductCode = '12312');
        insert product;

        VehicleDefinition vehiDefi = new VehicleDefinition(Name = 'Test Definition', ProductId = product.id);
        insert vehiDefi;

        Software_Version__c softwareVersion = new Software_Version__c(Name = 'Test Version 1');
        insert softwareVersion;

        Vehicle vehicle = new Vehicle(
            Name = 'Test Vehicle',
            assetId = asset.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleRegistrationNumber = 'RIVER-GUJ-8A2-C',
            VehicleDefinitionId = vehiDefi.id,
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            PDI_Status_Pass__c = true,
            Charger_PC_Number__c = 'ABC123'
        );
        insert vehicle;
        
        Case testCase = new Case(
            contactId = con.id,
            accountId = acc.id,
            Vehicle_Registration_Number__c = 'RIVER-GUJ-8A2-C',
         // vehicle__c = vehicle.id,
            case_type__c = 'Urgent Complaint',
            status = 'New',
            Case_Category__c = 'Parts',
            Assign_to_Dealer__c = accDealer.id,
            origin = 'Phone',
            Category__c = 'Minor',
            Case_Concern__c = 'None',
            Subject__c = 'Parts concern',
            Description = 'Test'
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

        // Start test
        Test.startTest();

        // Set page parameters
        PageReference pageRef = Page.CustomerFeedbackForm; // Replace YourPageName with the actual page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', testCase.Id);

        // Create a StandardController instance with the Case record
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);
        
        // Instantiate the controller
        CustomerFeedbackController controller = new CustomerFeedbackController(sc);

        // Verify controller properties
        System.assertEquals(testCase.Id, controller.currentCase.Id);
        System.assertEquals(vehicle.Id, controller.caseVehicle.Id);
        System.assertEquals(1, controller.customerFeedbacks.size());
       

        Test.stopTest();
    }
    
    static testMethod void testControllerInitialization3() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type='Customer');
        insert acc;
        
        Account accDealer = new Account(Name = 'Test Delaer', Email__c = 'testdelaer@gmail.com', Phone = '8767868687', type='Dealer');
        insert accDealer;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
        insert con;

        Asset asst = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asst;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', ProductCode = '12312');
        insert product;

        VehicleDefinition vehiDefi = new VehicleDefinition(Name = 'Test Definition', ProductId = product.id);
        insert vehiDefi;

        Software_Version__c softwareVersion = new Software_Version__c(Name = 'Test Version 1');
        insert softwareVersion;
        
        Vehicle vac = new Vehicle(
            Name = 'Test Vehicle',
            assetId = asst.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleDefinitionId = vehiDefi.id,
            VehicleRegistrationNumber = 'RIVER-GUJ-8A2-C',
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            Charger_PC_Number__c = 'ABCD1234',
            PDI_Status_Pass__c = true
        );
        insert vac;

        Order Ord = new Order(
            accountId = acc.id,
            EffectiveDate = System.today(),
            Dealer__c = accDealer.id,
            Status = 'Draft',
            Assigned_Vehicle__c = vac.id           
        );
        insert Ord;
        
        Case testCase = new Case(
            contactId = con.id,
            accountId = acc.id,
            Vehicle_Registration_Number__c = 'RIVER-GUJ-8A2-C',
           // vehicle__c = vehicle.id,
            case_type__c = 'Urgent Complaint',
            status = 'New',
            Case_Category__c = 'Parts',
            Assign_to_Dealer__c = accDealer.id,
            origin = 'Phone',
            Category__c = 'Minor',
            Case_Concern__c = 'None',
            Subject__c = 'Parts concern',
            Description = 'Test'
        );
        insert testCase;

        Customer_Feedback__c testFeedback = new Customer_Feedback__c(
            Case__c = testCase.Id,
            name = 'Test Customer Feedback',
            issue_type__c = 'Parts',
           	Resolution_provided__C = 'Test Solution'
        );
        insert testFeedback;
        
 /*     AssetMilestone milestone1 = new AssetMilestone();
        milestone1.Name = 'Test Milestone';
        milestone1.AssetId = asst.Id;
        milestone1.UsageType = 'Automotive';
        milestone1.MilestoneDate = System.today();
        milestone1.MilestoneType = 'Order Received';
        milestone1.Stage = 'Active';
        milestone1.VehicleId = vac.Id;
        insert milestone1;
        
        AssetMilestone milestone2 = new AssetMilestone();
        milestone2.Name = 'Test Milestone';
        milestone2.AssetId = asst.Id;
        milestone2.UsageType = 'Automotive';
        milestone2.MilestoneDate = System.today();
        milestone2.MilestoneType = 'Manufactured';
        milestone2.Stage = 'Active';
        milestone2.VehicleId = vac.Id;
        insert milestone2;
        
        AssetMilestone milestone3 = new AssetMilestone();
        milestone3.Name = 'Test Milestone';
        milestone3.AssetId = asst.Id;
        milestone3.UsageType = 'Automotive';
        milestone3.MilestoneDate = System.today();
        milestone3.MilestoneType = 'Delivered';
        milestone3.Stage = 'Active';
        milestone3.VehicleId = vac.Id;
        insert milestone3;       */
        
        AssetMilestone milestone4 = new AssetMilestone();
        milestone4.Name = 'Test Milestone';
        milestone4.AssetId = asst.Id;
        milestone4.UsageType = 'Automotive';
        milestone4.MilestoneDate = System.today();
        milestone4.MilestoneType = 'PDI';
        milestone4.Stage = 'Active';
        milestone4.VehicleId = vac.Id;
        insert milestone4;
        
        Vehicle vac1 = new Vehicle(
            Id = vac.Id,
            PDI_Status_Pass__c = true
        );
        
        update vac1;
        
        AssetMilestone milestone5 = new AssetMilestone();
        milestone5.Name = 'Test Milestone';
        milestone5.AssetId = asst.Id;
        milestone5.UsageType = 'Automotive';
        milestone5.MilestoneDate = System.today();
        milestone5.MilestoneType = 'Sold';
        milestone5.Stage = 'Active';
        milestone5.VehicleId = vac.Id; 
        insert milestone5;
        
        /*AssetMilestone testMilestone = new AssetMilestone(
            Name = 'Test Milestone ',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Sold',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert testMilestone;*/

        // Start test
        Test.startTest();

        // Set page parameters
        PageReference pageRef = Page.CustomerFeedbackForm; // Replace YourPageName with the actual page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', testCase.Id);
        
        // Create a StandardController instance with the Case record
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);

        // Instantiate the controller
        CustomerFeedbackController controller = new CustomerFeedbackController(sc);

        // Verify controller properties
        System.assertEquals(testCase.Id, controller.currentCase.Id);
        System.assertEquals(vac.Id, controller.caseVehicle.Id);
        System.assertEquals(1, controller.customerFeedbacks.size());
       

        Test.stopTest();
    }
    
    static testMethod void testControllerInitialization1() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type='Customer');
        insert acc;
        
        Account accDealer = new Account(Name = 'Test Delaer', Email__c = 'testdelaer@gmail.com', Phone = '8767868687', type='Dealer');
        insert accDealer;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
        insert con;

        Asset asst = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asst;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', ProductCode = '12312');
        insert product;

        VehicleDefinition vehiDefi = new VehicleDefinition(Name = 'Test Definition', ProductId = product.id);
        insert vehiDefi;

        Software_Version__c softwareVersion = new Software_Version__c(Name = 'Test Version 1');
        insert softwareVersion;

        Vehicle vac = new Vehicle(
            Name = 'Test Vehicle',
            assetId = asst.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleDefinitionId = vehiDefi.id,
            VehicleRegistrationNumber = 'RIVER-GUJ-8A2-C',
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            Charger_PC_Number__c = 'ABCD1234',
            PDI_Status_Pass__c = true
        );
        insert vac;
        
        Order Ord = new Order(
            accountId = acc.id,
            EffectiveDate = System.today(),
            Dealer__c = accDealer.id,
            Status = 'Draft',
            Assigned_Vehicle__c = vac.id           
        );
        insert Ord;
        
        Case testCase = new Case(
            contactId = con.id,
            accountId = acc.id,
            Vehicle_Registration_Number__c = 'RIVER-GUJ-8A2-C',
           // vehicle__c = vehicle.id,
            case_type__c = 'General Query',
            status = 'New',
            origin = 'Phone',
            Category__c = 'Minor',
            Case_Concern__c = 'None',
            Subject__c = 'Parts concern',
            Description = 'Test'
        );
        insert testCase;

        Customer_Feedback__c testFeedback = new Customer_Feedback__c(
            Case__c = testCase.Id,
            name = 'Test Customer Feedback',
            issue_type__c = 'Parts',
           	Resolution_provided__C = 'Test Solution'
        );
        insert testFeedback;
        
     /*   AssetMilestone milestone1 = new AssetMilestone();
        milestone1.Name = 'Test Milestone';
        milestone1.AssetId = asst.Id;
        milestone1.UsageType = 'Automotive';
        milestone1.MilestoneDate = System.today();
        milestone1.MilestoneType = 'Order Received';
        milestone1.Stage = 'Active';
        milestone1.VehicleId = vac.Id;
        insert milestone1;
        
        AssetMilestone milestone2 = new AssetMilestone();
        milestone2.Name = 'Test Milestone';
        milestone2.AssetId = asst.Id;
        milestone2.UsageType = 'Automotive';
        milestone2.MilestoneDate = System.today();
        milestone2.MilestoneType = 'Manufactured';
        milestone2.Stage = 'Active';
        milestone2.VehicleId = vac.Id;
        insert milestone2;
        
        AssetMilestone milestone3 = new AssetMilestone();
        milestone3.Name = 'Test Milestone';
        milestone3.AssetId = asst.Id;
        milestone3.UsageType = 'Automotive';
        milestone3.MilestoneDate = System.today();
        milestone3.MilestoneType = 'Delivered';
        milestone3.Stage = 'Active';
        milestone3.VehicleId = vac.Id;
        insert milestone3;  */
        
        AssetMilestone milestone4 = new AssetMilestone();
        milestone4.Name = 'Test Milestone';
        milestone4.AssetId = asst.Id;
        milestone4.UsageType = 'Automotive';
        milestone4.MilestoneDate = System.today();
        milestone4.MilestoneType = 'PDI';
        milestone4.Stage = 'Active';
        milestone4.VehicleId = vac.Id;
        insert milestone4;
        
        Vehicle vac1 = new Vehicle(
            Id = vac.Id,
            PDI_Status_Pass__c = true
        );
        
        update vac1;
        
        AssetMilestone milestone5 = new AssetMilestone();
        milestone5.Name = 'Test Milestone';
        milestone5.AssetId = asst.Id;
        milestone5.UsageType = 'Automotive';
        milestone5.MilestoneDate = System.today();
        milestone5.MilestoneType = 'Sold';
        milestone5.Stage = 'Active';
        milestone5.VehicleId = vac.Id;
        insert milestone5;
        
        AssetMilestone milestone6 = new AssetMilestone();
        milestone6.Name = 'Test Milestone';
        milestone6.AssetId = asst.Id;
        milestone6.UsageType = 'Automotive';
        milestone6.MilestoneDate = System.today();
        milestone6.MilestoneType = 'Customer Delivery';
        milestone6.Stage = 'Active';
        milestone6.VehicleId = vac.Id;
        milestone6.Delivery_Date__c = Date.today().addDays(10);
        milestone6.Vehicle_Received_By__c = 'TEST123';
        insert milestone6;

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

        // Start test
        Test.startTest();

        // Set page parameters
        PageReference pageRef = Page.CustomerFeedbackForm; // Replace YourPageName with the actual page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', testCase.Id);
        
        // Create a StandardController instance with the Case record
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);

        // Instantiate the controller
        CustomerFeedbackController controller = new CustomerFeedbackController(sc);

        // Verify controller properties
        System.assertEquals(testCase.Id, controller.currentCase.Id);

        Test.stopTest();
    }
    
    static testMethod void testControllerInitialization2() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type='Customer');
        insert acc;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
        insert con;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asset;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', ProductCode = '12312');
        insert product;

        VehicleDefinition vehiDefi = new VehicleDefinition(Name = 'Test Definition', ProductId = product.id);
        insert vehiDefi;

        Software_Version__c softwareVersion = new Software_Version__c(Name = 'Test Version 1');
        insert softwareVersion;
        
        Vehicle vac = new Vehicle(
            Name = 'Test Vehicle',
            assetId = asset.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleDefinitionId = vehiDefi.id,
            VehicleRegistrationNumber = 'RIVERGUJ8A2C',
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            Charger_PC_Number__c = 'ABCD1234',
            PDI_Status_Pass__c = true
        );
        insert vac;

        Case testCase = new Case(
            contactId = con.id,
            accountId = acc.id,
            Vehicle_Registration_Number__c = 'RIVERGUJ8A2C',
           // vehicle__c = vehicle.id,
            case_type__c = 'General Query',
            status = 'New',
            origin = 'Phone',
            Category__c = 'Minor',
            Case_Concern__c = 'None',
            Subject__c = 'Parts concern',
            Description = 'Test'
        );
        insert testCase;

        Customer_Feedback__c testFeedback = new Customer_Feedback__c(
            Case__c = testCase.Id,
            name = 'Test Customer Feedback',
            issue_type__c = 'Parts',
           	Resolution_provided__C = 'Test Solution'
        );
        insert testFeedback;

        // Start test
        Test.startTest();

        // Set page parameters
        PageReference pageRef = Page.CustomerFeedbackForm; // Replace YourPageName with the actual page name
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', testCase.Id);
        
        // Create a StandardController instance with the Case record
        ApexPages.StandardController sc = new ApexPages.StandardController(testCase);

        // Instantiate the controller
        CustomerFeedbackController controller = new CustomerFeedbackController(sc);

        // Verify controller properties
        System.assertEquals(testCase.Id, controller.currentCase.Id);

        Test.stopTest();
    }
}