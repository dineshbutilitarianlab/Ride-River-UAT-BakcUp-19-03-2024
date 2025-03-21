@isTest
public class DailyReportEmailServiceTest {

    @testSetup
    static void setupTestData() {
        // Retrieve necessary profiles
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        // Create test users
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
            LanguageLocaleKey = 'en_US',
            ManagerId = asmUser.Id
        );
        insert storeOwner;

        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 10; i++) {
            testLeads.add(new Lead(
                LastName = 'Test Lead ' + i,
                Phone = '1234567890',
                Company = 'Test Company ' + i,
                Status = 'New',
                OwnerId = storeOwner.Id
            ));
        }
        insert testLeads;

        // Create test test drives
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        for (Lead lead : testLeads) {
            testDrives.add(new Test_Drive__c(
                Test_Ride_Date__c = Date.today(),
                Lead__c = lead.Id,
                Ride_Type__c = 'Home Ride',
                Test_Drive_Status__c = 'Completed',
                OwnerId = storeOwner.Id
            ));
        }
        insert testDrives;

        // Create test follow-ups
        List<Follow_Up__c> testFollowUps = new List<Follow_Up__c>();
        for (Lead lead : testLeads) {
            testFollowUps.add(new Follow_Up__c(
                Follow_Up_Date__c = Date.today(),
                Lead__c = lead.Id,
                Status__c = 'Completed',
                OwnerId = storeOwner.Id
            ));
        }
        insert testFollowUps;
    }

    @isTest
    static void testSendDailyReportEmails() {
        Test.startTest();
        
        // Call the method
        DailyReportEmailService.sendDailyReportEmails();
        
        Test.stopTest();
    }

}