@istest
public class LeadCompControllerTest {
    @TestSetup
    static void setupTestData() {
        // Create test user profiles
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create test users
        User sysAdmin = new User(
            Alias = 'sysadm', Email = 'sysad2123femin@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Admin', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'sysadmin@qwdfhkiu@test.com'
        );

        User standardUser = new User(
            Alias = 'stdusr', Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'User', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standwewe124590hglarduser@test.com'
        );

        insert new List<User>{ sysAdmin, standardUser };

        // Create test leads
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName = 'Lead One', Phone = '9560687654', Company = 'Company 1', Status = 'New', OwnerId = sysAdmin.Id),
            new Lead(LastName = 'Lead Two', Phone = '0987654321', Company = 'Company 12', Status = 'New', OwnerId = standardUser.Id),
            new Lead(LastName = 'Lead Three', Phone = '1112223333', Company = 'Company 123', Status = 'New', OwnerId = standardUser.Id) // Should not be fetched
        };
        insert testLeads;
    }

    @IsTest
    static void testGetLeadsDetailsByDateRangeAsSysAdmin() {
        // Run as System Administrator
        User sysAdmin = [SELECT Id FROM User WHERE UserName = 'sysadmin@qwdfhkiu@test.com' LIMIT 1];
        System.runAs(sysAdmin) {
            Test.startTest();
            Date today = Date.today();
            LeadCompController.getLeadsDetailsByDateRange(today.addDays(-1), today.addDays(1));
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetLeadsDetailsByDateRangeAsStandardUser() {
        // Run as Standard User
        User standardUser = [SELECT Id FROM User WHERE UserName = 'standwewe124590hglarduser@test.com' LIMIT 1];
        System.runAs(standardUser) {
            Test.startTest();
            Date today = Date.today();
            LeadCompController.getLeadsDetailsByDateRange(today.addDays(-1), today.addDays(1));
            LeadCompController.TodaysFollowUp(today.addDays(-1), today.addDays(1));
            LeadCompController.getTestDriveRecords(today.addDays(-1), today.addDays(1));
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetLeadsDetailsByDateRangeWithNoResults() {
        Test.startTest();
        Date futureDate = Date.today().addDays(365); // Date range with no leads
        LeadCompController.getLeadsDetailsByDateRange(futureDate, futureDate.addDays(1));
        LeadCompController.TodaysFollowUp(futureDate, futureDate.addDays(1));
        LeadCompController.getTestDriveRecords(futureDate, futureDate.addDays(1));
        Test.stopTest();
    }

    @istest
    public static void LeadCompControllertest() {
        Date fromDate = Date.today().addDays(-30); // 30 days ago
        Date toDate = Date.today(); // Today

        Lead l = new Lead();
        l.LastName = 'test1234';
        l.FirstName = 'test';
        l.Salutation = 'Mr.';
        l.LeadSource = 'BikeWale';
        l.Phone = '8373879087';
        l.Company = 'tcs';
        l.City = 'KA';
        l.Country = 'India';
        l.State = 'Karnataka';
        l.Street = 'test';
        l.PostalCode = '560036';
        Insert l;

        DateTime nowDateTime = DateTime.now();
        Follow_Up__c f = new Follow_Up__c();
        f.Lead__c = l.Id;
        f.Status__c = 'In Progress';
        f.Follow_Up_Date__c = nowDateTime;
        f.Name = l.LastName;
        Insert f;

        Test_Drive__c td = new Test_Drive__c();
        td.Lead__c = l.Id;
        td.Name = l.LastName;
        td.Test_Drive_Date__c = nowDateTime;
        td.Drivers_License_Number__c = 'AB1234567890123';
        td.Test_ride_executive_s_Name__c = 'testexcutive';
        td.Test_Drive_Status__c = 'Scheduled';
        insert td;

        LeadCompController.TodaysFollowUp(fromDate, toDate);
        LeadCompController.getLeads(1, 1);
        LeadCompController.getLeadsList('test');
        LeadCompController.getLeaddeatails(l.Id);
        LeadCompController.updateLeadStatusToClosedLost(td.Id, 'Not the Decision Maker', 'testing feedback');
        LeadCompController.updatelead(l.id, l.LeadSource, '1234567890', 43, 'test@gmail.com', 'test', 'India', '1234556', 'Karnataka', 'test', 'New', 'test');
        LeadCompController.followupfeedback(f.Id, 'idjnfdnfndkf');
        LeadCompController.getTestDriveRecords(fromDate, toDate);
        LeadCompController.updateLeadStatus(l.Id);
        LeadCompController.getPreviousfollowUp(f.Id);
        LeadCompController.newgetLeads();
        LeadCompController.NotAttendedtestdrives();
        LeadCompController.createnewfollowupFromFollowup(f.Id, l.Id, nowDateTime, 'testing');
        LeadCompController.NotAttendedfllowups();
        LeadCompController.summarrywrappersetcount();
        LeadCompController.getLeadsListBySearchKeyWord('Rohit');
    }
    @IsTest
    public static void testLeadStatusComplete() {
        Lead testLead = new Lead(LastName = 'Test Lead', FirstName = 'Test', Company = 'Test Company', Phone = '9998887776', Status = 'New');
        insert testLead;

        Test_Drive__c testDrive = new Test_Drive__c(Lead__c = testLead.Id, Name = 'Test Drive', Test_Drive_Date__c = DateTime.now(), Test_Drive_Status__c = 'Scheduled');
        insert testDrive;

        WhatsappIntegration__c ws = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg',
             fullpayment_done__c='examplePayment.jpg'
        );
        insert ws;

        Test.startTest();
        Test_Drive__c updatedTestDrive = LeadCompController.leadstatuscomplete(testDrive.Id, 'Successful Test Drive');
        Test.stopTest();

        Test_Drive__c retrievedTestDrive = [SELECT Id, Test_Drive_Status__c, Feedback__c FROM Test_Drive__c WHERE Id = :updatedTestDrive.Id];
        System.assertEquals('Completed', retrievedTestDrive.Test_Drive_Status__c, 'Test Drive status should be updated to Completed');
        System.assertEquals('Successful Test Drive', retrievedTestDrive.Feedback__c, 'Feedback should match the input');
    }
}