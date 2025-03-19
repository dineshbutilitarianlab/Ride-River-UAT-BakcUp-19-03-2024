@isTest
private class CancelServiceAppointmentsBatchTest {
    @isTest
    static void testBatchExecution() {
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type = 'Customer');
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
        
        ServiceAppointment ser = new ServiceAppointment(
        	ContactId = con.Id,
            ParentRecordId = acc.Id,
            Vehicle__c = vehicle.id,
            Status = 'Scheduled',
            DueDate = DateTime.now().addDays(-1),
            EarliestStartTime = DateTime.now().addDays(-10),
            Asset_Milestone__c = milestone1.id
        );
        insert ser;
        
        Test.startTest();
        
        // Execute the batch
        CancelServiceAppointmentsBatch batch = new CancelServiceAppointmentsBatch();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    
    @isTest
    static void CancelServiceAppointmentsBatchMethod(){
        test.starttest();
        CancelServiceAppointmentsScheduleClass myClass = new CancelServiceAppointmentsScheduleClass();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stoptest();
    }
        
}