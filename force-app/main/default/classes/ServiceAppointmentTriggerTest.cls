@isTest
private class ServiceAppointmentTriggerTest {
    @isTest
    static void testBatchExecution() { 
        Test.startTest();
        
        // Create test data
        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', Type = 'Customer');
        insert acc;

        Contact con = new Contact(LastName = 'Test Contact', AccountId = acc.id, Phone = '1234567890');
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
            AssetId = asset.id,
            VehicleIdentificationNumber = 'TEST123',
            VehicleDefinitionId = vehiDefi.id,
            Software_Version__c = softwareVersion.id,
            CurrentOwnerId = acc.id,
            Charger_PC_Number__c = 'true',
            PDI_Status_Pass__c = true
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
            Name = 'Test Milestone',
            MilestoneDate = Date.today().addDays(10),
            VehicleId = vehicle.id,
            MilestoneType = '1st Service',
            Stage = 'Tentative',
            UsageType = 'Automotive',
            AssetId = asset.id
        );
        insert milestone;

        // Test inserting ServiceAppointment with milestone
        ServiceAppointment ser = new ServiceAppointment(
            ContactId = con.Id,
            ParentRecordId = acc.Id,
            Vehicle__c = vehicle.id,
            Status = 'Scheduled',
            DueDate = DateTime.now().addDays(1),
            EarliestStartTime = DateTime.now(),
            Asset_Milestone__c = milestone.id
        );
        insert ser;

        // Test inserting another ServiceAppointment with the same milestone to trigger an error
        ServiceAppointment serDup = new ServiceAppointment(
            ContactId = con.Id,
            ParentRecordId = acc.Id,
            Vehicle__c = vehicle.id,
            Status = 'Scheduled',
            DueDate = DateTime.now().addDays(1),
            EarliestStartTime = DateTime.now(),
            Asset_Milestone__c = milestone.id
        );
        Boolean duplicateMilestoneException = false;
        try {
            insert serDup;
        } catch (DmlException e) {
            duplicateMilestoneException = true;
            System.assert(e.getMessage().contains('Only one Service Appointment is allowed per Milestone.'));
        }
        System.assert(duplicateMilestoneException, 'Expected an exception to be thrown for duplicate milestone.');

        // Test updating ServiceAppointment to Completed without related WorkOrders
        /*ServiceAppointment serUpdate = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :ser.Id];
        serUpdate.Status = 'Completed';
        update serUpdate;*/

        // Create related WorkOrder records
        WorkOrder woIncomplete = new WorkOrder(
            ContactId = con.id,
            AccountId = acc.Id,
            Vehicle__c = vehicle.Id,
            Status = 'In Progress',
            Service_Appointment__c = ser.Id
        );
        insert woIncomplete;

        WorkOrder woComplete = new WorkOrder(
            ContactId = con.id,
            AccountId = acc.Id,
            Vehicle__c = vehicle.Id,
            Status = 'Completed',
            Service_Appointment__c = ser.Id
        );
        insert woComplete;

        // Test updating ServiceAppointment to Completed with related incomplete WorkOrders
        ServiceAppointment serUpdate = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :ser.Id];
        serUpdate.Status = 'Completed';
        Boolean incompleteWorkOrderException = false;
        try {
            update serUpdate;
        } catch (DmlException e) {
            incompleteWorkOrderException = true;
            System.assert(e.getMessage().contains('There are related Work Orders that are not yet Completed.'));
        }
        System.assert(incompleteWorkOrderException, 'Expected an exception to be thrown for incomplete WorkOrders.');

        // Update all WorkOrders to Completed
        woIncomplete.Status = 'Completed';
        update woIncomplete;

        // Test updating ServiceAppointment to Completed now that all WorkOrders are completed
        serUpdate = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :ser.Id];
        serUpdate.Status = 'Completed';
        update serUpdate;

        // Verify the update succeeded
        ServiceAppointment updatedSA = [SELECT Id, Status FROM ServiceAppointment WHERE Id = :ser.Id];
        System.assertEquals('Completed', updatedSA.Status);

        Test.stopTest();
    }
}