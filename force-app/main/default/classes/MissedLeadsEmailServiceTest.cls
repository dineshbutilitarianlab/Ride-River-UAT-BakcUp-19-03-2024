@isTest
public class MissedLeadsEmailServiceTest {

    @testSetup
    static void setupTestData() {
        // Create Users: Store Owner and ASM Manager
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

        // Insert Missed Leads (Status = "New", Created Yesterday)
        List<Lead> missedLeads = new List<Lead>();
        Date yesterday = Date.today().addDays(-1);
        DateTime yesterdayStart = DateTime.newInstance(yesterday, Time.newInstance(10, 0, 0, 0)); // Simulate a morning timestamp

        for (Integer i = 0; i < 3; i++) {
            Lead newLead = new Lead(
                LastName = 'Missed Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'missedlead' + i + '@example.com',
                Phone = '894257328'+i,
                Status = 'New',
                OwnerId = storeOwner.Id
            );
            insert newLead;

            // Set CreatedDate to yesterday
            Test.setCreatedDate(newLead.Id, yesterdayStart);
        }
    }

    @isTest
    static void testSendMissedLeadsEmails() {
        Test.startTest();
        MissedLeadsEmailService.sendMissedLeadsEmails();
        Test.stopTest();

    }

    @isTest
    static void testExecuteMethod() {
        Test.startTest();

        MissedLeadsEmailService job = new MissedLeadsEmailService();
        job.execute(null);
        
        Test.stopTest();
    }
}