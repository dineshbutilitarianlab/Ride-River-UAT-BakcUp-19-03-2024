@isTest
public class HomeTestDriveEmailServiceTest {

    @testSetup
    static void setupTestData() {
        // Create test users
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User storeOwner = new User(
            FirstName = 'Store',
            LastName = 'Owner',
            Email = 'store.owner@example.com',
            Username = 'store.owner@example.com.salesforce',
            Alias = 'stowner',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert storeOwner;

        User asmUser = new User(
            FirstName = 'ASM',
            LastName = 'Manager',
            Email = 'asm.manager@example.com',
            Username = 'asm.manager@example.com.salesforce',
            Alias = 'asmman',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = adminProfile.Id,
            LanguageLocaleKey = 'en_US'
        );
        insert asmUser;
        
        // Assign Manager to Store Owner
        storeOwner.ManagerId = asmUser.Id;
        update storeOwner;

        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 5; i++) {
            testLeads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'test' + i + '@example.com',
                Phone = '1234567890',
                Status = 'Test Ride',
                OwnerId = storeOwner.Id
            ));
        }
        insert testLeads;

        // Create test test drives
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        for (Integer i = 0; i < 5; i++) {
            testDrives.add(new Test_Drive__c(
                Name = 'Test Drive ' + i,
                Lead__c = testLeads[i].Id,
                Test_Ride_Date__c = Date.today(),
                Ride_Type__c = 'Home Ride',
                Test_Drive_Status__c = 'Scheduled'
            ));
        }
        insert testDrives;
    }

    @isTest
    static void testSendTestDriveEmails() {
        Test.startTest();
        
        // Call the method
        HomeTestDriveEmailService.sendTestDriveEmails();
        
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        
        // Create an instance and execute
        HomeTestDriveEmailService job = new HomeTestDriveEmailService();
        job.execute(null);
        
        Test.stopTest();
    }
}