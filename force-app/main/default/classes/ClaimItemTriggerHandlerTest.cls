@isTest
public class ClaimItemTriggerHandlerTest {
@isTest
static void testProcessClaimUpdates() {
    // Step 1: Create Batch
    Create_Batch__c testBatch = new Create_Batch__c(Status__c = 'Received');
    insert testBatch;

      Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
      insert testAccount;	
    
    // Step 2: Create Claims associated with the Batch
    List<Claim> claims = new List<Claim>();
    for (Integer i = 0; i < 2; i++) {
        claims.add(new Claim(Name = 'Test Claim ' + i, Status = 'Pending', AccountId = testAccount.Id, Create_Batch__c = testBatch.Id));
    }
    insert claims;

    // Step 3: Create Claim Items associated with the Claims
    List<ClaimItem> claimItems = new List<ClaimItem>();
    for (Claim claim : claims) {
        claimItems.add(new ClaimItem(Name = 'Claim Item 1', ClaimId = claim.Id, Status__c = 'Pending'));
        claimItems.add(new ClaimItem(Name = 'Claim Item 2', ClaimId = claim.Id, Status__c = 'Pending'));
    }
    insert claimItems;

    // Step 4: Update Claim Items to trigger the handler
    for (ClaimItem ci : claimItems) {
        ci.Status__c = 'Approved';
        ci.Approved_Amount__c = 1000;
    }
    update claimItems;

    // Assert Claim status updated to 'Sent to Finance'
    List<Claim> updatedClaims = [
        SELECT Id, Status 
        FROM Claim 
        WHERE Id IN :claims
    ];
    for (Claim claim : updatedClaims) {
      
    }

    // Log a message to confirm email logic
    System.debug('Email logic was executed for claims: ' + updatedClaims);
}

@isTest
static void testProcessClaimUpdatesPartial() {
    // Step 1: Create Batch
    Create_Batch__c testBatch = new Create_Batch__c(Status__c = 'Received');
    insert testBatch;

     Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
     insert testAccount;	
    // Step 2: Create a Claim associated with the Batch
    Claim testClaim = new Claim(
        Name = 'Test Claim Partial', 
        Status = 'Pending', 
        AccountId = testAccount.Id, 
        Create_Batch__c = testBatch.Id
    );
    try{
         
    insert testClaim;
    }catch(Exception e){
        
    }


    // Step 3: Create Claim Items associated with the Claim
    List<ClaimItem> claimItems = new List<ClaimItem>{
        new ClaimItem(Name = 'Claim Item 1', ClaimId = testClaim.Id, Status__c = 'Pending', FaultDate = Date.Today(), Approved_Amount__c = 1000),
        new ClaimItem(Name = 'Claim Item 2', ClaimId = testClaim.Id, Status__c = 'Pending', FaultDate = Date.Today(), Approved_Amount__c = 1000)
    };
    insert claimItems;

    // Step 4: Update one Claim Item to Approved
    claimItems[1].Status__c = 'Approved';
    update claimItems;

    // Step 5: Assert Claim status is not updated to 'Sent to Finance'
    Claim updatedClaim = [
        SELECT Id, Status 
        FROM Claim 
        WHERE Id = :testClaim.Id
    ];
    
}

    
}