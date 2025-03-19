@isTest
public class FollowUpEmailServiceTest {

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
                Phone = '1234567890',
                Status = 'Follow Up',
                OwnerId = storeOwner.Id
            ));
        }
        insert testLeads;

        // Create test follow-ups
        List<Follow_Up__c> testFollowUps = new List<Follow_Up__c>();
        for (Integer i = 0; i < 5; i++) {
            testFollowUps.add(new Follow_Up__c(
                Lead__c = testLeads[i].Id,
                Follow_Up_Date__c = Date.today().addDays(-1),
                Status__c = 'Not Started',
                Previous_Followup_date__c = Date.today().addDays(-2),
                Previous_Feedback__c = 'No Response',
                Feedback__c = 'Need Follow-up'
            ));
        }
        insert testFollowUps;
    }

    @isTest
    static void testSendFollowUpEmails() {
        Test.startTest();
        
        // Call the method
        FollowUpEmailService.sendFollowUpEmails();
        
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        
        // Create an instance and execute
        FollowUpEmailService job = new FollowUpEmailService();
        job.execute(null);
        
        Test.stopTest();
    }
}