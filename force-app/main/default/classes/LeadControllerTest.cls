@isTest
public class LeadControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test user profiles
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create test users
        User sysAdmin = new User(
            Alias = 'sysadm', Email = 'sysadmin@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Admin', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = sysAdminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'sysadminwdfhk@wdfhktest.com'
        );

        User standardUser = new User(
            Alias = 'stdusr', Email = 'standarduser@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'User', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standarduserwdfhk@test.com'
        );

        insert new List<User>{ sysAdmin, standardUser };

        // Create test leads
        List<Lead> testLeads = new List<Lead>{
            new Lead(LastName = 'Lead One', Phone = '9560687654', Company = 'Company 1', Status = 'New', OwnerId = sysAdmin.Id),
            new Lead(LastName = 'Lead Two', Phone = '0987654321', Company = 'Company 12', Status = 'New', OwnerId = standardUser.Id)
        };
        insert testLeads;
    }

    @isTest
    static void testGetLeadByPhone() {
        Test.startTest();
        String testPhone = '0987654321';

        // Call method
        Lead lead = LeadController.getLeadByPhone(testPhone);
        
        // Assertions
        System.assertNotEquals(null, lead, 'Lead should be returned');
        System.assertEquals(testPhone, lead.Phone, 'Phone number should match');
        Test.stopTest();
    }

    @isTest
    static void testSubmitLeadForApproval_NewRecord() {
        Lead testLead = [SELECT Id FROM Lead WHERE Phone = '9560687654' LIMIT 1];

        Test.startTest();
        String result = LeadController.submitLeadForApproval(testLead.Id);
        Test.stopTest();
    }

    @isTest
    static void testSubmitLeadForApproval_RejectedRecord() {
        Lead testLead = [SELECT Id,OwnerId FROM Lead WHERE Phone = '0987654321' LIMIT 1];

        // Create a rejected Lead Transfer History record
        Lead_Transfer_History__c rejectedTransfer = new Lead_Transfer_History__c(
            Lead__c = testLead.Id,
            Requested_By__c = UserInfo.getUserId(),
            Old_Owner__c = testLead.OwnerId,
            Status__c = 'Rejected'
        );
        insert rejectedTransfer;

        Test.startTest();
        String result = LeadController.submitLeadForApproval(testLead.Id);
        Test.stopTest();

    }

    @isTest
    static void testSubmitLeadForApproval_ExistingPending() {
        Lead testLead = [SELECT Id ,OwnerId FROM Lead WHERE Phone = '9560687654' LIMIT 1];

        // Create a pending Lead Transfer History record
        Lead_Transfer_History__c pendingTransfer = new Lead_Transfer_History__c(
            Lead__c = testLead.Id,
            Requested_By__c = UserInfo.getUserId(),
            Old_Owner__c = testLead.OwnerId,
            Status__c = 'Pending'
        );
        insert pendingTransfer;

        Test.startTest();
        String result = LeadController.submitLeadForApproval(testLead.Id);
        String result1 = LeadController.submitLeadForApproval(null);
        Test.stopTest();

    }
}