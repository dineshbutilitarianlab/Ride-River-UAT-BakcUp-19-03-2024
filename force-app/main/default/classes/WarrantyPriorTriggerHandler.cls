public class WarrantyPriorTriggerHandler {

    // Method to handle warranty approval
    public static void handleWarrantyApproval(List<Warranty_Prior__c> newRecords, Map<Id, Warranty_Prior__c> oldMap) {
        List<Claim> claimsToInsert = new List<Claim>();

        // Step 1: Collect all Warranty IDs
        Set<Id> warrantyIds = new Set<Id>();
        for (Warranty_Prior__c warranty : newRecords) {
            Warranty_Prior__c oldWarranty = oldMap.get(warranty.Id);
            if (warranty.Status__c == 'Approved' && oldWarranty.Status__c != 'Approved') {
                warrantyIds.add(warranty.Id);
            }
        }

        if (warrantyIds.isEmpty()) {
            return; // Exit if there are no warranties to process
        }

        // Step 2: Query related WorkOrders and their Accounts
        Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
            [SELECT Id, AccountId,Vehicle__c
             FROM WorkOrder
             WHERE Id IN (SELECT Job_Card__c FROM Warranty_Prior__c WHERE Id IN :warrantyIds)]
        );

        // Step 3: Process each Warranty and create Claims
        for (Warranty_Prior__c warranty : newRecords) {
            Warranty_Prior__c oldWarranty = oldMap.get(warranty.Id);

            if (warranty.Status__c == 'Approved' && oldWarranty.Status__c != 'Approved') {
                // Find the related WorkOrder
                WorkOrder relatedWorkOrder = workOrderMap.get(warranty.Job_Card__c);

                if (relatedWorkOrder != null && relatedWorkOrder.AccountId != null) {
                    // Create a Claim
                    Claim newClaim = new Claim(
                        Name              = 'Claim_' + warranty.Name,
                        Warranty_Prior__c = warranty.Id,
                        AccountId         = relatedWorkOrder.AccountId, // Assign the Account from the WorkOrder
                        //Status            = 'Submitted',
                        Status = 'Draft', // Set an appropriate initial status//Code added by Aniket on 20/01/2025 as per requirement
                        Vehicle__c        = relatedWorkOrder.Vehicle__c,      
                        Job_Card__c       = relatedWorkOrder.Id // Assign the WorkOrder so we can track the Claim
                    );
                    claimsToInsert.add(newClaim);
                } else {
                    System.debug('Related WorkOrder or Account not found for Warranty: ' + warranty.Id);
                }
            }
        }

        // Step 4: Insert Claims
        if (!claimsToInsert.isEmpty()) {
            insert claimsToInsert;
            System.debug('Inserted Claims: ' + claimsToInsert);
        }
    } // Ensure this method is properly closed here

}