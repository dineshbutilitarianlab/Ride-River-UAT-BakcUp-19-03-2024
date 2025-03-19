public class ClaimItemTriggerHandler {
    
    public static void processClaimUpdates(List<ClaimItem> updatedItems) {
        Set<Id> claimIds = new Set<Id>();

        // Collect Claim IDs for processing
        for (ClaimItem item : updatedItems) {
            if (item.Status__c == 'Approved' || item.Status__c == 'Rejected' /*|| item.Status__c == 'Pending'*/) {
                claimIds.add(item.ClaimId);
            }
        }
        
        if (!claimIds.isEmpty()) {
            // Query all Claim Items related to the Claims
            Map<Id, List<ClaimItem>> claimItemsMap = new Map<Id, List<ClaimItem>>();
            for (ClaimItem ci : [
                SELECT Id, Status__c, ClaimId
                FROM ClaimItem 
                WHERE ClaimId IN :claimIds
            ]) {
                if (!claimItemsMap.containsKey(ci.ClaimId)) {
                    claimItemsMap.put(ci.ClaimId, new List<ClaimItem>());
                }
                claimItemsMap.get(ci.ClaimId).add(ci);
            }
            
            // Evaluate Claims for status updates
            List<Claim> claimsToUpdate = evaluateAndUpdateClaims(claimItemsMap);
            
            // Update Claims
            if (!claimsToUpdate.isEmpty()) {
                update claimsToUpdate;

                // Notify System Admin if Claims are sent to Finance
                sendNotificationToSystemAdmin(claimsToUpdate, 'Sent to Finance');
            }
        }
    }

    private static List<Claim> evaluateAndUpdateClaims(Map<Id, List<ClaimItem>> claimItemsMap) {
        List<Claim> claimsToUpdate = new List<Claim>();
        
        for (Id claimId : claimItemsMap.keySet()) {
            Boolean hasPendingItems = false;
            Boolean allApprovedOrRejected = true;

            // Check all Claim Items for the Claim
            for (ClaimItem ci : claimItemsMap.get(claimId)) {
                if (ci.Status__c == 'Pending') {
                    hasPendingItems = true;
                } 
                if (ci.Status__c != 'Approved' && ci.Status__c != 'Rejected') {
                    allApprovedOrRejected = false;
                }
            }

            // Update Claim status based on ClaimItem statuses
            if (hasPendingItems) {
                claimsToUpdate.add(new Claim(
                    Id = claimId,
                    Status = 'Under Review'
                ));
            } else if (allApprovedOrRejected) {
                claimsToUpdate.add(new Claim(
                    Id = claimId,
                    Status = 'Sent to Finance'
                ));
            }
        }
        
        return claimsToUpdate;
    }

    

   private static void sendNotificationToSystemAdmin(List<Claim> updatedClaims, String status) {
    
    String emailBody = '<p>Dear Finance Team,</p>';
    emailBody += '<p>The following claims have been updated to "<b>' + status + '</b>":</p>';

    String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();

    for (Claim claim : updatedClaims) {
        if (claim.Status == status) {
            String claimLink = baseUrl + '/' + claim.Id;
            emailBody += 'Claim ID: <a href="' + claimLink + '">' + claim.Id + '</a></p>';
        }
    }

    emailBody += '<p>Best regards,<br>Your Salesforce System</p>';

    List<User> financeUsers = [
        SELECT Email
        FROM User
        WHERE Profile.Name = 'Finance'
        AND IsActive = true
    ];

    List<String> financeEmails = new List<String>();
    for (User user : financeUsers) {
        financeEmails.add(user.Email);
    }

    if (!financeEmails.isEmpty()) {
        OrgWideEmailAddress owea = [SELECT Id, DisplayName 
                                    FROM OrgWideEmailAddress 
                                    WHERE DisplayName = :System.Label.OrgWideEmail 
                                    LIMIT 1];

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(financeEmails);
        email.setSubject('Claims Updated to "' + status + '"');
        email.setHtmlBody(emailBody); 
        if (owea != null) {
            email.setOrgWideEmailAddressId(owea.Id);
        }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }
}


}