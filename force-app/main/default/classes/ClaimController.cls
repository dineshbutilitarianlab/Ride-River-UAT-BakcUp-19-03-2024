public with sharing class ClaimController {
    // Fetch claims from the database
    @AuraEnabled(cacheable=true)
    public static List<Claim> getClaims(String  recordId) {
        try {
            // Query claims with the required fields
			return [SELECT Id,Name,Total_Claim_Amount__c,Approved_Amount__c	,Create_Batch__r.Is_Credit_Note_Created__c
			,Create_Batch__c,Credit_Note_Number__c FROM Claim where Create_Batch__c=:recordId ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching claims: ' + e.getMessage());
        }
    }

    // Update claims in the database
    @AuraEnabled
    public static void updateClaims(String claimItemWrappersJson) {
        try {
            System.debug('wrapper'+claimItemWrappersJson);
            List<ClaimItemWrapper> claimItemWrappers = (List<ClaimItemWrapper>) JSON.deserialize(
                claimItemWrappersJson, 
                List<ClaimItemWrapper>.class
            );

            List<Claim> claimsToUpdate = new List<Claim>();
            List<Create_Batch__c> batchesToUpdate = new List<Create_Batch__c>();
            Set<Id> batchIds = new Set<Id>();
   
            for (ClaimItemWrapper wrapper : claimItemWrappers) {
                claimsToUpdate.add(new Claim(
                    Id = wrapper.claimId,
                    Approved_Amount__c = wrapper.approvedAmount,
                    Credit_Note_Number__c = wrapper.creditNoteNumber,
                    Status = 'Settled'
                ));

                if (wrapper.batchId != null) {
                    batchIds.add(wrapper.batchId);
                }
            }
    
            // Perform bulk update operation
            if (!claimsToUpdate.isEmpty()) {
                update claimsToUpdate;
            }

            if (!batchIds.isEmpty()) {
                List<Create_Batch__c> relatedBatches = [SELECT Id, Is_Credit_Note_Created__c FROM Create_Batch__c WHERE Id IN :batchIds];
                for (Create_Batch__c batch : relatedBatches) {
                    batch.Is_Credit_Note_Created__c = true;
                    batchesToUpdate.add(batch);
                }

                if (!batchesToUpdate.isEmpty()) {
                    update batchesToUpdate;
                    System.debug('Successfully updated Batches: ' + batchesToUpdate);
                }


            }

            System.debug('Successfully updated claims: ' + claimsToUpdate);
        } catch (Exception e) {
            System.debug('Coing in catch: ' + e.getMessage() + ' ' + e.getLineNumber() + ' ' + e.getStackTraceString() + ' ' );
            throw new AuraHandledException('Error updating claims: ' + e.getMessage());
        }
    }

    public class ClaimItemWrapper {
        @AuraEnabled public Id claimId;
        @AuraEnabled public Integer approvedAmount;
        @AuraEnabled public String creditNoteNumber;
        @AuraEnabled public Id batchId;
    
        public ClaimItemWrapper() {
        }
        public ClaimItemWrapper(Id claimId, Integer approvedAmount, String rejectionReason,Id batchId) {
            this.claimId = claimId;
            this.approvedAmount = approvedAmount;
            this.creditNoteNumber = creditNoteNumber;
            this.batchId = batchId;
        }
    }
}