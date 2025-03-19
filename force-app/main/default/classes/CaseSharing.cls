public class CaseSharing {
    @InvocableMethod
    public static void shareCasesWithAccountUsers(List<Id> caseIds) {
        List<CaseShare> caseShares = new List<CaseShare>();

        // Query for the Cases using the passed-in IDs
        List<Case> cases = [SELECT Id, Assign_to_Dealer__c FROM Case WHERE Id IN :caseIds];
        
        for (Case c : cases) {
            // Fetch users associated with the Case's Account
            List<User> accountUsers = [SELECT Id FROM User WHERE AccountId = :c.Assign_to_Dealer__c];
            
            for (User u : accountUsers) {
                // Create a CaseShare record for each user
                CaseShare cs = new CaseShare();
                cs.CaseId = c.Id;
                cs.UserOrGroupId = u.Id;
                cs.CaseAccessLevel = 'Edit'; // Set to 'Edit' explicitly
                cs.RowCause = Schema.CaseShare.RowCause.Manual; // Use 'Manual' or a custom reason
                caseShares.add(cs);
            }
        }

        if (!caseShares.isEmpty()) {
            // Insert all CaseShare records in bulk
            insert caseShares;
        }
    }
}