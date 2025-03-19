@isTest
private class ScheduleServiceReminderEmailBatchTest {
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
        
        ServiceAppointment ser = new ServiceAppointment(
        	ContactId = con.Id,
            ParentRecordId = acc.Id,
            Vehicle__c = vehicle.id,
            Status = 'Scheduled',
            Appointment_Date__c = Date.today().addDays(1),
            DueDate = DateTime.now().addDays(2),
            EarliestStartTime = DateTime.now()
        );
        insert ser;
        
        Test.startTest();
        
        // Execute the batch
        ScheduleServiceReminderEmailBatch batch = new ScheduleServiceReminderEmailBatch();
        Database.executeBatch(batch);
        Test.stopTest();
        
        // Verify that Email is sent or not 
        List<EmailMessage> sentEmails = [SELECT Id, Subject, TextBody FROM EmailMessage];
        
        // Assert that the number of emails
        System.assertEquals(sentEmails.size(), 1);
    }
    
    @isTest
    static void scheduleSchedulableClass(){
        test.starttest();
        ScheduleServiceReminderScheduleClass myClass = new ScheduleServiceReminderScheduleClass();   
        String chron = '0 0 23 * * ?';        
        system.schedule('Test Sched', chron, myClass);
        test.stoptest();
    }
}