@isTest
public class DailyNewLeadsEmailServiceTest {

    @testSetup
    static void setupTestData() {
        // Create test users
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        Profile managerProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User asmUser = new User(
            FirstName = 'ASM',
            LastName = 'Manager',
            Email = 'asm.manager@example.com',
            Username = 'asm.manager@example.com.salesforce',
            Alias = 'asmman',
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = managerProfile.Id,
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
        
        storeOwner.ManagerId = asmUser.Id;
        update storeOwner;

        // Insert test leads and modify CreatedDate
        List<Lead> testLeads = new List<Lead>();
        DateTime todayMorning = DateTime.newInstance(Date.today(), Time.newInstance(8, 0, 0, 0)); // Simulating 8 AM today

        for (Integer i = 0; i < 5; i++) {
            Lead newLead = new Lead(
                LastName = 'Test Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'test' + i + '@example.com',
                Phone = '888887678'+i,
                Status = 'New',
                OwnerId = storeOwner.Id
            );
            insert newLead;

            // Set CreatedDate to today at 8 AM
            Test.setCreatedDate(newLead.Id, todayMorning);
        }

    }

    @isTest
    static void testSendNewLeadsEmails() {
        Test.startTest();
        
        // Call the email sending method
        DailyNewLeadsEmailService.sendNewLeadsEmails();
        
        Test.stopTest();
    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        
        // Execute the Schedulable job
        DailyNewLeadsEmailService job = new DailyNewLeadsEmailService();
        job.execute(null);
        
        Test.stopTest();
    }
}