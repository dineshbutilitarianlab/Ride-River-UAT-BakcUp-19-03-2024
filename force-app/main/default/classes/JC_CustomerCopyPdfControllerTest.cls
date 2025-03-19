@isTest
public class JC_CustomerCopyPdfControllerTest {
    
    @testSetup
    static void setupTestData() {
        /*List<Term_Condition_JC__mdt> terms = new List<Term_Condition_JC__mdt>();
        for (Integer i = 1; i <= 3; i++) {
            Term_Condition_JC__mdt term = new Term_Condition_JC__mdt(
                SI_No__c = i,
                Term_Condition__c = 'Term ' + i
            );
            terms.add(term);
        }
        insert terms;*/
        
        // Create WorkOrder, Contact, and related records

        Account acc = new Account(Name = 'Test Account', Email__c = 'test@gmail.com',type = 'Customer');
        insert acc;
        
        Account acc1 = new Account(Name = 'Test Account', Email__c = 'test@gmail.com', type = 'Dealer', phone = '1212121212');
        insert acc1;
        
        Contact primaryContact = new Contact(
            LastName = 'Primary',
            Email = 'primary@example.com',
            Phone = '1111111111',
            MailingState = 'Karnataka',
            MailingStreet = '123 Primary St',
            MailingCountry = 'India',
            MailingPostalCode = '90001',
            MailingCity = 'Los Angeles',
            AccountId = acc.Id,
            Primary_Contact__c = true
        );
        insert primaryContact;
        
        Contact secondaryContact = new Contact(
            LastName = 'Secondary',
            Email = 'secondary@example.com',
            Phone = '2222222222',
            MailingState = 'karnataka',
            MailingStreet = '456 Secondary St',
            MailingCountry = 'India',
            MailingPostalCode = '90002',
            MailingCity = 'Los Angeles',
            AccountId = acc.Id,
            Primary_Contact__c = false
        );
        insert secondaryContact;

        Contact con = new Contact(Lastname = 'Test Contact', AccountId = acc.id, Phone = '1234567890', Email='test@gmail.com');
        insert con;

        Asset asset = new Asset(Name = 'Test Asset', AccountId = acc.id, ContactId = con.id);
        insert asset;

        Product2 product = new Product2(Name = 'Test Product', Type__c = 'Parts', HSN_Code__c = 'TESTHSN', productcode='123qwe');
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
        
        WorkOrder jobCard = new WorkOrder(
            Vehicle__c = vehicle.Id,
            ContactId = primaryContact.Id,
            accountId = acc.Id
        );
        insert jobCard;
        
        // Create WorkPlan records
        for (Integer i = 1; i <= 2; i++) {
            WorkPlan plan = new WorkPlan(
                WorkOrderId = jobCard.Id,
                Duration_Hour__c = i,
                Duration_Min__c = i * 10,
                Labour_Charge__c = i * 100.0,
                name = 'Test work plan'
                //RR_Labour_Code__r = new CodeSet(Code = 'LC' + i, CodeDescription = 'Labour Code ' + i)
            );
            insert plan;
        }
        
        // Create RR_Customer_Voice__c records
        for (Integer i = 1; i <= 3; i++) {
            RR_Customer_Voice__c voice = new RR_Customer_Voice__c(
                RR_Concern_Category__c = 'Range',
                RR_Description__c = 'Description ' + i,
                RR_Observation_Action_Taken__c = 'Action ' + i,
                RR_Related_Images__c = 'Image ' + i,
                RR_Work_Order__c = jobCard.Id
            );
            insert voice;
        }

    }
    
    @isTest
    static void testJC_CustomerCopyPdfController() {
        // Retrieve the test JobCard record
        WorkOrder jobCard = [SELECT Id FROM WorkOrder LIMIT 1];
        
        // Instantiate the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(jobCard);
        JC_CustomerCopyPdfController controller = new JC_CustomerCopyPdfController(sc);
        
        // Assert the controller properties
        System.assertNotEquals(controller.currentdate, null, 'Current date should be set');
        System.assertNotEquals(controller.compDetails, null, 'Company details should be retrieved');
        System.assert(controller.terms.size() > 0, 'Terms should be retrieved');
        System.assertNotEquals(controller.Jobcard, null, 'Job card should be retrieved');
        System.assert(controller.plans.size() > 0, 'Plans should be retrieved');
        System.assert(controller.voices.size() >= 3, 'Voices should be retrieved');
        System.assertNotEquals(controller.conDetails, null, 'Contact details should be set');
        System.assert(controller.totalDurationHours > 0, 'Total duration hours should be calculated');
    }
}