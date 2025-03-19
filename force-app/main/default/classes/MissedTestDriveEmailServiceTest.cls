@isTest
public class MissedTestDriveEmailServiceTest {

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

        // Create a Lead assigned to Store Owner
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Email = 'testlead@example.com',
            Phone = '1234567890',
            Status = 'Test Ride',
            OwnerId = storeOwner.Id
        );
        insert testLead;

        // Create Test Drive Records (Missed Rides)
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>();
        Date yesterday = Date.today().addDays(-1);

        for (Integer i = 0; i < 3; i++) {
            testDrives.add(new Test_Drive__c(
                Name = 'Missed Test Drive ' + i,
                Lead__c = testLead.Id,
                Test_Ride_Date__c = yesterday,
                Ride_Type__c = 'Home Ride',
                Test_Drive_Status__c = 'Scheduled'
            ));
        }
        insert testDrives;

    }

    @isTest
    static void testSendMissedTestDriveEmails() {
        Test.startTest();
        
        // Call the method
        MissedTestDriveEmailService.sendMissedTestDriveEmails();
        
        Test.stopTest();
    }


    @isTest
    static void testExecuteMethod() {
        Test.startTest();
        
        // Execute the Schedulable job
        MissedTestDriveEmailService job = new MissedTestDriveEmailService();
        job.execute(null);
        
        Test.stopTest();
    }
}