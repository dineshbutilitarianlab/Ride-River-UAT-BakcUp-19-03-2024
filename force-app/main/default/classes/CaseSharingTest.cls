@isTest
private class CaseSharingTest {
 
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
        List<contact> conList = [SELECT Id, Name , Email 
                                 FROM contact 
                                 WHERE AccountId=:acc1.Id 
                                 AND Primary_Contact__c = true];
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
    static void testShareCasesWithAccountUsers() {
        List<account> accList = [SELECT Id, Type, Name 
                                 FROM Account 
                                 WHERE Type = 'Customer' 
                                 OR Type = 'Dealer'];
        Vehicle vehicle = [SELECT Id, VehicleRegistrationNumber, CurrentOwnerId 
                           FROM Vehicle LIMIT 1];
        Account customerAcc = new Account();
        Account dealerAcc = new Account();
        For(Account acc:accList ){
            If(acc.type == 'Customer'){
                customerAcc = acc;
            }else if(acc.type == 'Dealer'){
                dealerAcc = acc;
            }
        }
        Account acc = [SELECT Id, Name 
                       FROM Account 
                       WHERE Name = 'Partner' LIMIT 1];
        contact testContact = [SELECT Id, Name , Email 
                               FROM contact 
                               WHERE AccountId=:acc.Id AND Primary_Contact__c = true];
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
        Test.startTest();
        insertCase();
        
        
        Test.stopTest();
    }
    @future
    public static void insertCase( ) {
        Account dealerAcc = [SELECT Id, Type, Name 
                             FROM Account 
                             WHERE Type = 'Dealer' LIMIT 1];
        Vehicle vehicle = [SELECT Id, VehicleRegistrationNumber, CurrentOwnerId 
                           FROM Vehicle LIMIT 1];
        // Create a test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            Assign_to_Dealer__c = dealerAcc.Id, 
            AccountId = vehicle.CurrentOwnerId,
            Case_Type__c = 'Complaint',
            Case_Category__c = 'Price',
            Vehicle_Registration_Number__c = vehicle.VehicleRegistrationNumber,
            Status = 'New',
            Case_Concern__c = 'Belt',
            Origin = 'Email',
            Description = 'Test'
        );
        insert testCase;
        
        CaseSharing.shareCasesWithAccountUsers(new List<Id>{testCase.Id});
    }
}