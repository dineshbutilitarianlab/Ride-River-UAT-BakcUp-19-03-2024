@isTest
public class LeadTransferHistoryHandlerTest {
    @TestSetup
    static void setupTestData() {
        // Create test user profiles
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        // Create test users
        User requestingUser = new User(
            Alias = 'requsr', Email = 'requestinguser@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Requestor', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'requestinguser@test.com'
        );
        
        User dealerUser = new User(
            Alias = 'derusr', Email = 'dealeruser@test.com',
            EmailEncodingKey = 'UTF-8', LastName = 'Dealer', LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = 'dealeruser@test.com'
        );
        
        insert new List<User>{ requestingUser, dealerUser };
        
        // Create test lead
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Dealer_Code__c = 'D001',
            OwnerId = dealerUser.Id
        );
        insert testLead;
        
        // Create test Lead Transfer History record
        Lead_Transfer_History__c testHistory = new Lead_Transfer_History__c(
            Lead__c = testLead.Id,
            Requested_By__c = requestingUser.Id,
            Old_Owner__c = dealerUser.Id,
            Status__c = 'Pending'
        );
        insert testHistory;
    }
    
    @isTest
    static void testUpdateLeadOwner() {
        // Fetch test data
        Lead_Transfer_History__c testHistory = [SELECT Id, Lead__c, Requested_By__c, Status__c, Dealer_Code__c FROM Lead_Transfer_History__c LIMIT 1];
        Lead testLead = [SELECT Id, Dealer_Code__c FROM Lead WHERE Id = :testHistory.Lead__c LIMIT 1];
        
        // Simulate status update to 'Approved'
        testHistory.Status__c = 'Approved';
        update testHistory;
        
        // Prepare input parameters for the handler method
        List<Lead_Transfer_History__c> newRecords = [SELECT Id, Lead__c, Requested_By__c, Status__c, Dealer_Code__c FROM Lead_Transfer_History__c];
        Map<Id, Lead_Transfer_History__c> oldMap = new Map<Id, Lead_Transfer_History__c>{ testHistory.Id => testHistory };
        
        Test.startTest();
        LeadTransferHistoryHandler.updateLeadOwner(newRecords, oldMap);
        Test.stopTest();
        

    }
}