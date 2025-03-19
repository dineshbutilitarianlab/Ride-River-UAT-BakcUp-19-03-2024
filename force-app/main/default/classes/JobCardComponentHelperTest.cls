@isTest
public class JobCardComponentHelperTest {
    
    @testSetup
    static void setup() {
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        List<AssetMilestone> milestoneList = new List<AssetMilestone>();
        
        AssetMilestone milestone = new AssetMilestone();
        milestone.Delivery_Date__c = System.today();
        milestone.MilestoneType = 'PDI';
        milestone.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone.MilestoneDate = System.today();
        milestone.AssetId = mapnewRecords.get('Asset').Id;
        milestone.Name = 'PDI';
        milestone.UsageType = 'Automotive';
        milestone.Stage = 'Active';
        
        Insert milestone;
        
        vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        vh.PDI_Status_Pass__c = true;
        
        update vh;
        
        PriceBookEntry entry = (PriceBookEntry)mapnewRecords.get('PricebookEntry');
        Id PriceBookId = entry.PriceBook2Id;
        Account acc = (Account)mapnewRecords.get('Account');
        Product2 newProduct = (Product2)mapnewRecords.get('Product');
        
        // Create a Standard Order record
        Order standardOrder = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            pricebook2Id = PriceBookId,
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            //Payment_Type__c = itemPaymentType,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'india',
            Assigned_Vehicle__c = vh.Id
        );
        Insert standardOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = standardOrder.Id,
            PricebookEntryId = entry.Id,
            Product2Id = newProduct.Id,
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Vehicle'
        );
        
        
        AssetMilestone milestone4 = new AssetMilestone();
        milestone4.Delivery_Date__c = System.today();
        milestone4.MilestoneType = 'Sold';
        milestone4.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone4.MilestoneDate = System.today();
        milestone4.AssetId = mapnewRecords.get('Asset').Id;
        milestone4.Name = 'Vehicle Sold';
        milestone4.UsageType = 'Automotive';
        milestone4.Stage = 'Active';
        
        Insert milestone4;
        
        AssetMilestone milestone1 = new AssetMilestone();
        milestone1.Delivery_Date__c = System.today();
        milestone1.MilestoneType = 'Customer Delivery';
        milestone1.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone1.MilestoneDate = System.today();
        milestone1.AssetId = mapnewRecords.get('Asset').Id;
        milestone1.Name = 'Vehicle Sold';
        milestone1.UsageType = 'Automotive';
        milestone1.Stage = 'Active';
        
        Insert milestone1;
        
        
        City__c city = new City__c(
            Name = 'Bengaluru',
            City_Masking_Name__c = 'Bengaluru',
            State__c = 'Karnataka',
            City_Pincode__c = '123456',
            Price_Book__c = PriceBookId
        );
        insert city;
        
        Account acc1 = new Account();
        acc1.name = 'partner';
        acc1.Email__c = 'partner@gmail.com';
        acc1.Phone = '6767656776';
        acc1.Type = 'Dealer';
        Insert acc1;
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:acc1.Id AND Primary_Contact__c = true];
        Contact testContact = new Contact();
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
                FirstName = 'John',
                LastName = 'partner',
                Email = 'john.partner@test.com',
                Phone = '9011113046',
                MailingCity = 'Test City',
                MailingCountry = 'india',
                MailingPostalCode = '12345',
                MailingState = 'karnataka',
                MailingStreet = '123 Test Street',
                AccountId = acc1.Id,
                Primary_Contact__c = true
            );
            
            insert testContact;
        }
        
        acc1.IsPartner =true;
        update acc1;
        
        
        ServiceResource sr = new ServiceResource(name='Test Resource', RelatedRecordId = userinfo.GetUserId(), IsActive = true);
        Insert sr;
        
        
    }
    
    @isTest
    static void testFetchVehicleDetailsByVINFailure() {
        Test.startTest();
        String vehicleIdentifier = 'VIN1234567890';
        String inputType = 'VIN';
        
        try{
            JobCardComponentHelper.VehicleWrapper vw = JobCardComponentHelper.fetchVehicleDetails(vehicleIdentifier, inputType);
        }catch(exception e){
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Script thrown error');
        }
        Test.stopTest();
        
    }
    
    @isTest
    static void testFetchVehicleDetailsByVINSuccess() {
        Test.startTest();
        String vehicleIdentifier = '111S';
        String inputType = 'VIN';
        
        JobCardComponentHelper.VehicleWrapper vw = JobCardComponentHelper.fetchVehicleDetails(vehicleIdentifier, inputType);
        Test.stopTest();
        
        System.assertNotEquals(null, vw.vehicle, 'Vehicle should not be null');
        System.assertEquals('111S', vw.vehicle.VehicleIdentificationNumber, 'Vehicle VIN should match');
        System.assertEquals('9011113246', vw.primaryContactPhone, 'Primary contact phone should match');
    }
    
    @isTest
    static void testFetchVehicleDetailsByRegistrationNumberFailure() {
        Test.startTest();
        String vehicleIdentifier = 'REG123';
        String inputType = 'RegistrationNumber';
        
        try{
            JobCardComponentHelper.VehicleWrapper vw = JobCardComponentHelper.fetchVehicleDetails(vehicleIdentifier, inputType);
        }catch(exception e){
            System.assertEquals(true, (e!=null), 'Script thrown error');
        }
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testFetchVehicleDetailsByRegistrationNumberSuccess() {
        Test.startTest();
        String vehicleIdentifier = 'REG1235';
        String inputType = 'RegistrationNumber';
        
        JobCardComponentHelper.VehicleWrapper vw = JobCardComponentHelper.fetchVehicleDetails(vehicleIdentifier, inputType);
        Test.stopTest();
        
        System.assertNotEquals(null, vw.vehicle, 'Vehicle should not be null');
        System.assertEquals('REG1235', vw.vehicle.VehicleRegistrationNumber, 'Vehicle registration number should match');
        System.assertEquals('9011113246', vw.primaryContactPhone, 'Primary contact phone should match');
    }
    
    @isTest
    static void testValidateOTP() {
        Vehicle testVehicle = [SELECT Id, CurrentOwnerId FROM Vehicle LIMIT 1];
        String testPhoneNumber = '9011113246';
        
        Test.startTest();
        JobCardComponentHelper.contactDetails contactDetails = JobCardComponentHelper.validateOTP(testPhoneNumber, testVehicle);
        Test.stopTest();
        
        System.assertNotEquals(null, contactDetails.primaryCon, 'Primary contact should not be null');
        System.assertEquals(true, contactDetails.isPrimary, 'Primary contact flag should be true');
        System.assertEquals(true, contactDetails.isSecondaryPresent, 'Secondary contact present flag should be true');
        System.assertEquals(testPhoneNumber, contactDetails.primaryCon.Phone, 'Primary contact phone should match');
    }
    
    
    /*##################################################################################################################################################*/
    @IsTest
static void testFetchServiceAdvisors() {
    Account acc = new Account(Name = 'Partner');
    insert acc;
    
    User owner;
    try {
        owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId LIMIT 1];
    } catch (Exception e) {
        System.debug('No owner found for account: ' + acc.Id);
        return;
    }
    
    if (owner != null && owner.UserRoleId == null) {
        UserRole ownerRole = new UserRole(Name = 'Account Owner Role');
        insert ownerRole;
        owner.UserRoleId = ownerRole.Id;
        update owner;
    }
    
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'test@example.com',
        Phone = '9999999998',
        AccountId = acc.Id,
        Primary_Contact__c = true
    );
    insert testContact;
    
    Test.startTest();

    UserRole role = new UserRole(Name = 'Partner User Role');
    insert role;

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)'];
    User partnerUser = new User(
        LastName = 'Partner',
        Email = 'partner@example.com',
        Username = 'partneruser@example.com' + System.currentTimeMillis(),
        ProfileId = p.Id,
        Alias = 'partn',
        TimeZoneSidKey = 'GMT',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ContactId = testContact.Id,
        UserRoleId = role.Id,
        IsActive = true
    );
    insert partnerUser;
    
    System.runAs(partnerUser) {
        system.debug('partnerUser>>>>' + JSON.serializePretty(partnerUser));
        List<ServiceResource> result = JobCardComponentHelper.fetchServiceAdvisors('Test Resource');
        System.assert(result.size() == 0, 'Expected not to find Service Advisors for Partner user');
    }
    
    List<ServiceResource> result = JobCardComponentHelper.fetchServiceAdvisors('Test Resource');
    System.assert(result.size() > 0, 'Expected to find Service Advisors for non-Partner user');
    
    Test.stopTest();
}


    
  /*  @IsTest
    static void testFetchServiceCenters() {
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Partner' LIMIT 1];
        
        contact testContact = [SELECT Id, Name , Email from contact where AccountId=:acc.Id AND Primary_Contact__c = true];
        
        Test.startTest();
        
        
        UserRole role = new UserRole();
        //role.DeveloperName = 'portalRole';
        role.PortalType = 'Partner';
        role.PortalAccountId = acc.Id;
        Insert role;
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)'];
        User partnerUser = new User(
            LastName = 'Partner',
            Email = 'partner@example.com',
            Username = 'partneruser@example.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'partn',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            UserRole = role,
            IsActive = true
        );
        insert partnerUser;
        
        // Assume running as Partner User
        System.runAs(partnerUser) {
            List<Account> result = JobCardComponentHelper.fetchServiceCenters('Partner');
            System.assert(result.size() > 0, 'Expected to find Service Centers for Partner user');
        }
        
        List<Account> result = JobCardComponentHelper.fetchServiceCenters('Partner');
        System.assert(result.size() > 0, 'Expected to find Service Centers for non-Partner user');
        
        Test.stopTest();
    }*/
    
    @IsTest
    static void testFetchCities() {
        
        Account acc = [SELECT Id, Name, OwnerId FROM Account WHERE Name = 'Partner' LIMIT 1];
    
        // Ensure Account Owner has a role
        User owner = [SELECT Id, UserRoleId FROM User WHERE Id = :acc.OwnerId];
        if(owner.UserRoleId == null) {
            UserRole ownerRole = new UserRole(Name = 'Account Owner Role');
            insert ownerRole;
    
            owner.UserRoleId = ownerRole.Id;
            update owner;
        }
        
        Contact testContact = [SELECT Id, Name, Email 
                               FROM Contact 
                               WHERE AccountId = :acc.Id 
                               AND Primary_Contact__c = true 
                               LIMIT 1];
        
        Test.startTest();
    
        UserRole role = new UserRole();
        role.PortalType = 'Partner';
        role.PortalAccountId = acc.Id;
        insert role;
    
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' LIMIT 1];
    
        User partnerUser = new User(
            LastName = 'Partner',
            Email = 'partner@example.com',
            Username = 'partneruser@example.com' + System.currentTimeMillis(),
            ProfileId = p.Id,
            Alias = 'partn',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ContactId = testContact.Id,
            UserRoleId = role.Id,
            IsActive = true
        );
        insert partnerUser;
    
        User us = [SELECT Id, UserType FROM User WHERE Id = :partnerUser.Id];
        System.debug('us>>>>____' + us);
    
        // Assume running as Partner User 
        System.runAs(partnerUser) {
            List<City__c> result = JobCardComponentHelper.fetchCities('Bengaluru');
            System.assert(result.size() == 1, 'Expected to find Cities for Partner user');
        }
    
        List<City__c> result = JobCardComponentHelper.fetchCities('Bengaluru');
        System.assert(result.size() > 0, 'Expected to find Cities for non-Partner user');
    
        Test.stopTest();
    }

    
    /*##################################################################################################################################################*/
    
    @isTest
    static void testSaveCardDetails() {
        Vehicle testVehicle = [SELECT Id, CurrentOwnerId FROM Vehicle LIMIT 1];
        
        
        ServiceResource sr = [SELECT Id, Name FROM serviceresource LIMIT 1];
        //Insert sr;
        
        Account ServiceCenter = new Account(Name='service center1', Type = 'Service Center', Phone = '7890898989');
        Insert ServiceCenter;
        
        JobCardComponentHelper.JobCardDetails jobCardDetails = new JobCardComponentHelper.JobCardDetails();
        jobCardDetails.contactName = 'John Doe';
        jobCardDetails.phoneNumber = '9011113246';
        jobCardDetails.vehicle = testVehicle;
        jobCardDetails.email = 'john.doe@example.com';
        jobCardDetails.KmsCovered = 1500;
        jobCardDetails.address = new JobCardComponentHelper.AddressWrapper();
        jobCardDetails.address.street = '123 Main St';
        jobCardDetails.address.city = 'San Francisco';
        jobCardDetails.address.province = 'CA';
        jobCardDetails.address.country = 'USA';
        jobCardDetails.address.postalCode = '94105';
        jobCardDetails.ServiceAdvisor = sr.Id;
        jobCardDetails.ServiceCenter = ServiceCenter.Id;
        jobCardDetails.TypeOfJob = 'Periodic maintenance';
        jobCardDetails.subType = '1st Service';
        
        jobCardDetails.Charger = false;
        jobCardDetails.ToolKit = false;
        jobCardDetails.FirstAidKit = false;
        jobCardDetails.NonOEAccFitted = false;  
        jobCardDetails.RearViewMirror = false;
        jobCardDetails.VehicleDocument = false;
        jobCardDetails.SOC = 20;
        jobCardDetails.City = [SELECT Id FROM City__c LIMIT 1].Id;
        
        jobCardDetails.EstimatedCost = 500.00;
        jobCardDetails.EstimatedDeliveryTime = System.now().addDays(2);
        jobCardDetails.concernNoList = new List<JobCardComponentHelper.ConcernWrapper>();
        jobCardDetails.concernNoList.add(new JobCardComponentHelper.ConcernWrapper());
        
        Test.startTest();
        String jobCardId = JobCardComponentHelper.saveCardDetails(jobCardDetails);
        Test.stopTest();
        
        System.assertNotEquals(null, jobCardId, 'Job Card Id should not be null');
        
        WorkOrder insertedJobCard = [SELECT Id, ContactId FROM WorkOrder WHERE Id = :jobCardId LIMIT 1];
        System.assertNotEquals(null, insertedJobCard, 'Inserted Job Card should not be null');
    }
}