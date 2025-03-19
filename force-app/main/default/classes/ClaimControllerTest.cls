@isTest
public with sharing class ClaimControllerTest {
    @testSetup
    static void setupTestData() {
        // Create test batch
        Create_Batch__c testBatch = new Create_Batch__c(Is_Credit_Note_Created__c = false);
        insert testBatch;
        
        // Create test claims
        Account testAccount = new Account(Name = 'Test Account',Type='Customer');
        insert testAccount;
        // Create test claims
        List<Claim> testClaims = new List<Claim>();
        for (Integer i = 0; i < 5; i++) {
            testClaims.add(new Claim(
                Name = 'Test Claim ' + i,
                 AccountId = testAccount.Id,
                Approved_Amount__c = 0,
                Create_Batch__c = testBatch.Id,
                Credit_Note_Number__c = null
            ));
        }
        insert testClaims;
    }
    
    @isTest
    static void testGetClaims() {
        // Fetch the test batch
        Create_Batch__c testBatch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        
        // Call the getClaims method
        Test.startTest();
        List<Claim> claims = ClaimController.getClaims(testBatch.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateClaims() {
        // Fetch test claims and batch
        List<Claim> testClaims = [SELECT Id, Create_Batch__c FROM Claim LIMIT 3];
        Id batchId = testClaims[0].Create_Batch__c;
        
        // Create wrapper objects
        List<ClaimController.ClaimItemWrapper> claimItemWrappers = new List<ClaimController.ClaimItemWrapper>();
        for (Claim claim : testClaims) {
            ClaimController.ClaimItemWrapper wrapper = new ClaimController.ClaimItemWrapper(
                claim.Id,
                500,
                'Rejection Reason Example',
                batchId
            );
            claimItemWrappers.add(wrapper);
        }
        
        // Serialize wrapper data
        String claimItemWrappersJson = JSON.serialize(claimItemWrappers);
        
        // Call updateClaims method
        Test.startTest();
        ClaimController.updateClaims(claimItemWrappersJson);
        Test.stopTest();
    }
}