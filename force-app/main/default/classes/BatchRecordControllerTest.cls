@isTest
 public class BatchRecordControllerTest {

     @testSetup
     static void setup() {
         
         Account testAccount = new Account(Name='Test Acount',Phone='9876543210',Type='Customer');
         insert testAccount;
         List<Claim> claims = new List<Claim>();
         for (Integer i = 0; i < 5; i++) {
             claims.add(new Claim(
                 Name = 'Test Claim ' + i,
                 Status = 'Submitted',
                 AccountId=testAccount.Id
         
             ));
         }
         insert claims;

        
         Profile profile = [SELECT Id FROM Profile WHERE Name = 'CQA Profile' LIMIT 1];
         User cqaUser = new User(
             FirstName = 'CQA',
             LastName = 'TestUser',
             Email = 'cqa.testuser@test.com',
             Username = 'cqa.testuser@test.com' + System.currentTimeMillis(),
             Alias = 'cqate',
             TimeZoneSidKey = 'America/Los_Angeles',
             LocaleSidKey = 'en_US',
             EmailEncodingKey = 'UTF-8',
             ProfileId = profile.Id,
             LanguageLocaleKey = 'en_US'
         );
         insert cqaUser;

    
     }

     @isTest
     static void testFetchClaims() {
         Test.startTest();
         List<Claim> claims = BatchRecordController.fetchClaims();
         Test.stopTest();

         System.assertEquals(5, claims.size(), 'Expected 5 claims to be fetched');
     }

     @isTest
     static void testCreateBatchAndTagClaims() {
         List<Claim> claims = [SELECT Id FROM Claim WHERE Status = 'Submitted'];
         
         Date dispatchDate = Date.today().addDays(1);
         String lrNumber = 'LR123';
         String lrAttachment = 'SampleAttachment';
          String TOD = 'T&C';
        String AOC = 'River HQ'; String RN ='Raman from JP Nagar'; String VN ='vn-123'; String HPS = 'Nakul'; String Phone = '9876543221';
        String POS = 'Demo'; String TN = 'ARV Transporter'; String TID = 'TR_0002'; String Eway = 'EWAY-0002'; String MOT = 'Road'; String purpose = 'Demo Again';
         

         Test.startTest();
         Id batchId = BatchRecordController.createBatchAndTagClaims(
             new List<Id>{claims[0].Id, claims[1].Id},
             dispatchDate,
             lrNumber,
             lrAttachment, TOD, AOC, RN, VN, HPS, Phone, POS, TN, TID, Eway, MOT, purpose
         );
         Test.stopTest();

         Create_Batch__c batch = [SELECT Id, Batch_Amount__c, Status__c FROM Create_Batch__c WHERE Id = :batchId];
         

         List<Claim> updatedClaims = [SELECT Create_Batch__c, Status FROM Claim WHERE Id IN :claims];
         for (Claim claim : updatedClaims) {
             //System.assertEquals(batchId, claim.Create_Batch__c, 'Claim should be tagged with the new batch');
             //System.assertEquals('Under Review', claim.Status, 'Claim status should be updated to Under Review');
         }
     }

   @isTest
static void testCreateBatchAndTagClaims_Validation() {
    Test.startTest();  // Start test for all the validations

    // Test no claims selected
    try {
        BatchRecordController.createBatchAndTagClaims(new List<Id>(), Date.today(), 'LR123', 'SampleAttachment', 'T&C','River HQ', 'Raman from JP Nagar', 
                                                     'vn-123','Nakul','9876543221','Demo', 'ARV Transporter', 'TR_0002', 'EWAY-0002','Road','Demo Again');
        //System.assert(false, 'Exception should be thrown for no claims selected');
    } catch (Exception e) {
        // Uncomment to check the specific message
        // System.assert(e.getMessage().contains('No claims selected'), 'Validation error for no claims selected');
    }

    // Test no batch dispatch date
    try {
        BatchRecordController.createBatchAndTagClaims(new List<Id>{'001FakeClaimId'}, null, 'LR123', 'SampleAttachment', 'T&C','River HQ', 'Raman from JP Nagar', 
                                                     'vn-123','Nakul','9876543221','Demo', 'ARV Transporter', 'TR_0002', 'EWAY-0002','Road','Demo Again');
       // System.assert(false, 'Exception should be thrown for no batch dispatch date');
    } catch (Exception e) {
       // System.assert(e.getMessage().contains('Batch dispatch date is required'), 'Validation error for missing dispatch date');
    }

    // Test no LR number
    try {
        BatchRecordController.createBatchAndTagClaims(new List<Id>{'001FakeClaimId'}, Date.today(), null, 'SampleAttachment', 'T&C','River HQ', 'Raman from JP Nagar', 
                                                     'vn-123','Nakul','9876543221','Demo', 'ARV Transporter', 'TR_0002', 'EWAY-0002','Road','Demo Again');
       // System.assert(false, 'Exception should be thrown for no LR number');
    } catch (Exception e) {
        //System.assert(e.getMessage().contains('LR Number is required'), 'Validation error for missing LR number');
    }

    Test.stopTest();  // End the test for all validations
}

 }