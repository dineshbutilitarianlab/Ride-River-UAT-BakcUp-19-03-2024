public class ClaimTriggerHandler {
    public static void handleAfterInsert(List<Claim> newClaims) {
        // Collect related Warranty IDs from the Claims
        Set<Id> warrantyIds = new Set<Id>();
        for (Claim claim : newClaims) {
            if (claim.Warranty_Prior__c != null) { // Assuming there's a Warranty lookup on Claim
                warrantyIds.add(claim.Warranty_Prior__c);
            }
        }

        if (warrantyIds.isEmpty()) {
            return; // Exit if there are no related warranties
        }

        // Step 1: Query related Warranty_Prior__c records to get Job Cards (WorkOrders) and Owners
        Map<Id, Warranty_Prior__c> warrantyMap = new Map<Id, Warranty_Prior__c>();
        Set<Id> jobCardIds = new Set<Id>(); // To store Job_Card__c IDs

        for (Warranty_Prior__c warranty : [
            SELECT Id, Job_Card__c, OwnerId FROM Warranty_Prior__c WHERE Id IN :warrantyIds
        ]) {
            warrantyMap.put(warranty.Id, warranty);
            if (warranty.Job_Card__c != null) {
                jobCardIds.add(warranty.Job_Card__c);
            }
        }

        // Step 2: Query related Job Cards (WorkOrders) to get Vehicle__c
        Map<Id, Id> jobCardToVehicleMap = new Map<Id, Id>();
        if (!jobCardIds.isEmpty()) { 
            for (WorkOrder jobCard : [
                SELECT Id, Vehicle__c FROM WorkOrder WHERE Id IN :jobCardIds
            ]) {
                if (jobCard.Vehicle__c != null) {
                    jobCardToVehicleMap.put(jobCard.Id, jobCard.Vehicle__c);
                }
            }
        }

        // Step 3: Create a combined map of Warranty ID to Vehicle ID
        Map<Id, Id> warrantyToVehicleMap = new Map<Id, Id>();
        for (Id warrantyId : warrantyMap.keySet()) {
            Id jobCardId = warrantyMap.get(warrantyId).Job_Card__c;
            if (jobCardToVehicleMap.containsKey(jobCardId)) {
                warrantyToVehicleMap.put(warrantyId, jobCardToVehicleMap.get(jobCardId));
            }
        }

        // Step 4: Query WorkOrderLineItems related to the Warranty Prior
        Map<Id, List<WorkOrderLineItem>> warrantyToLineItemsMap = new Map<Id, List<WorkOrderLineItem>>();
        for (WorkOrderLineItem lineItem : [
            SELECT Id, Amount__c, Warranty_Prior__c, Description, Quantity, Hours__c, TotalAmount__c 
            FROM WorkOrderLineItem WHERE Warranty_Prior__c IN :warrantyIds
        ]) {
            if (!warrantyToLineItemsMap.containsKey(lineItem.Warranty_Prior__c)) {
                warrantyToLineItemsMap.put(lineItem.Warranty_Prior__c, new List<WorkOrderLineItem>());
            }
            warrantyToLineItemsMap.get(lineItem.Warranty_Prior__c).add(lineItem);
        }

        // Step 5: Query WorkPlans related to Warranty Prior
        Map<Id, List<WorkPlan>> warrantyToWorkPlanMap = new Map<Id, List<WorkPlan>>();
        for (WorkPlan plan : [
            SELECT Id, Warranty_Prior__c, TotalAmount__c FROM WorkPlan WHERE Warranty_Prior__c IN :warrantyIds
        ]) {
            if (!warrantyToWorkPlanMap.containsKey(plan.Warranty_Prior__c)) {
                warrantyToWorkPlanMap.put(plan.Warranty_Prior__c, new List<WorkPlan>());
            }
            warrantyToWorkPlanMap.get(plan.Warranty_Prior__c).add(plan);
        }

        // Step 6: Create Claim Items & Store Claims that need updates
        List<ClaimItem> claimItemsToInsert = new List<ClaimItem>();
        List<Claim> claimsToUpdate = new List<Claim>();

        for (Claim claim : newClaims) {
            Id warrantyOwnerId = warrantyMap.containsKey(claim.Warranty_Prior__c) ? warrantyMap.get(claim.Warranty_Prior__c).OwnerId : null;

            // Store Claim for update (cannot modify inside after trigger)
            if (warrantyOwnerId != null && claim.OwnerId != warrantyOwnerId) {
                claimsToUpdate.add(new Claim(Id = claim.Id, OwnerId = warrantyOwnerId));
            }

            // Create Claim Items for WorkOrderLineItems (Parts)
            if (warrantyToLineItemsMap.containsKey(claim.Warranty_Prior__c)) {
                List<WorkOrderLineItem> relatedLineItems = warrantyToLineItemsMap.get(claim.Warranty_Prior__c);
                Integer i = 1;
                for (WorkOrderLineItem lineItem : relatedLineItems) {
                    Id vehicleId = warrantyToVehicleMap.get(claim.Warranty_Prior__c);

                    ClaimItem newClaimItem = new ClaimItem(
                        Name      = 'Claim_Item_' + claim.Name +' ' + i,
                        ClaimId   = claim.Id,
                        Part__c   = lineItem.Id,
                        Amount__c = lineItem.TotalAmount__c,
                        FaultDate = Date.today(),
                        Status__c = 'Pending',
                        Claim_Type__c = 'Part'
                    );
                    claimItemsToInsert.add(newClaimItem);
                    i++;
                }
            }

            // Create Claim Items for WorkPlans (Labour)
            if (warrantyToWorkPlanMap.containsKey(claim.Warranty_Prior__c)) {
                List<WorkPlan> relatedWorkPlans = warrantyToWorkPlanMap.get(claim.Warranty_Prior__c);
                Integer i = 1;
                for (WorkPlan plan : relatedWorkPlans) {
                    ClaimItem newClaimItem = new ClaimItem(
                        Name = 'Claim_Item_' + claim.Name + '_Labour_' + i,
                        ClaimId = claim.Id,
                        Claim_Type__c = 'Labour',
                        Status__c = 'Pending',
                        FaultDate = Date.today(),
                        Labour_Code__c = plan.Id
                    );
                    claimItemsToInsert.add(newClaimItem);
                    i++;
                }
            }
        }

        // Step 7: Perform Updates **Outside** of the Loop
        if (!claimsToUpdate.isEmpty()) {
            update claimsToUpdate; // Separate DML statement to update Claim owners
        }

        // Step 8: Insert all Claim Items
        if (!claimItemsToInsert.isEmpty()) {
            insert claimItemsToInsert;
        }

        System.debug('Claim Items Inserted: ' + claimItemsToInsert);
    }
    public static void handleAfterUpdate(List<Claim> newClaims, Map<Id, Claim> oldClaimsMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        // Email template IDs (Get these from Salesforce)
        Id approvedTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Claim_Approved1' LIMIT 1].Id;
        Id rejectedTemplateId = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Claim_Rejection' LIMIT 1].Id;
        
        for (Claim claim : newClaims) {
            Claim oldClaim = oldClaimsMap.get(claim.Id);
            
            // Check if status changed
            if (oldClaim.Status != claim.Status) {
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(claim.OwnerId); // Sends to the Claim Owner
                email.setSaveAsActivity(false); // No need to log an activity
                
                if (claim.Status == 'Approved') {
                    email.setTemplateId(approvedTemplateId);
                } else if (claim.Status == 'Rejected') {
                    email.setTemplateId(rejectedTemplateId);
                } else {
                    continue; // Skip if status is not Approved or Rejected
                }

                emails.add(email);
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}