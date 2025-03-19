@isTest
private class PeriodicServiceReminderEmailBatchTest {
    @isTest
    static void testBatchExecution() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type = 'Dealer', phone = '1212121212');
        insert acc1;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
        insert con;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asset;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN');
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
            PDI_Status_Pass__c = true,
            Charger_PC_Number__c = 'ABC123',
            Dealer__c = acc1.Id
        );
        insert vehicle;
        
        AssetMilestone milestone1 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Order Received',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone1;
        
        AssetMilestone milestone2 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Manufactured',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone2;
        
        AssetMilestone milestone3 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Delivered',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone3;
        
        AssetMilestone milestone4 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'PDI',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone4;
        
        AssetMilestone milestone5 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Sold',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone5;
        
        AssetMilestone milestone6 = new AssetMilestone(
            Name = 'Test Milestone1',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = 'Customer Delivery',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone6;

        AssetMilestone milestone = new AssetMilestone(
            Name = 'Test Milestone ',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = '1st Service',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone;
        
        Test.startTest();
        
        // Execute the batch
        PeriodicServiceReminderEmailBatch batch = new PeriodicServiceReminderEmailBatch();
        Database.executeBatch(batch);
		
        Test.stopTest();
        
        // Assert that emails were sent
        List<AssetMilestone> assetMilestones = [SELECT id, status__C from AssetMilestone]; 
        //System.assertEquals(assetMilestones.get(0).status__c, 'Reminder Sent');
        
        // Verify that Email is sent or not 
        List<EmailMessage> sentEmails = [SELECT Id, Subject, TextBody FROM EmailMessage];
        
        // Assert that the number of emails
        System.assertEquals(sentEmails.size(), 1);
    }
    
    @isTest
    static void periodicSchedulableClass(){
        test.starttest();
        PeriodicServiceReminderScheduleClass myClass = new PeriodicServiceReminderScheduleClass();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stoptest();
    }
        
}