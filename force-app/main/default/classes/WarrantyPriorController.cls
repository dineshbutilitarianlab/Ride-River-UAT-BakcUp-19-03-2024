/*****************************************************************************
 * CLASS NAME: WarrantyPriorController
 * 
 * PURPOSE:
 *   This class handles the operations related to the Warranty Prior object.
 *   It provides methods to:
 *     - Fetch Warranty Prior details and related records (Work Order Line Items and Work Plans).
 *     - Update Warranty Prior fields, Work Order Line Items (Parts), and Work Plans (Labours).
 *     - Serve as the backend controller for the LWC interacting with Warranty Prior records.
 * 
 * AUTHOR: ROHIT SINGH BISHT
 * DATE CREATED: [29/11/2024]
 * 
 * USAGE NOTES:
 *   - Ensure that the required fields (e.g., Id, Tax__c, Amount_per_Hour__c) are present
 *     in the input from the frontend to avoid runtime errors.
 *   - Follow proper sharing rules and security practices.
 * 
 * DEPENDENCIES:
 *   - Related LWC or Aura Components calling these methods.
 * 
 *****************************************************************************/

public with sharing class WarrantyPriorController {

    // ----------------------------- //
    //        FETCH METHODS          //
    // ----------------------------- //

    /**
     * Fetch Warranty Prior details based on the Work Order ID.
     * 
     * @param workOrderId - ID of the related Work Order
     * @return Warranty_Prior__c - The Warranty Prior record
     */
    @AuraEnabled
    public static Warranty_Prior__c getWarrantyPrior(Id workOrderId) {
        System.debug('Fetching Warranty Prior for Job Card ID: ' + workOrderId);
        return [
            SELECT Id, Name, VIN__c, Registration_Number__c, Motor_Number__c, Odometer_Reading__c, Warranty_Prior_Date__c,
                   Type_of_Warranty__c, Job_Card__c, ASM_Feedback__c, FFIR_Number__c, Dealer_Observation__c, Media__c,Total_Claim_Amount__c,Standard_Values__c,FFIR_Link__c	
            FROM Warranty_Prior__c
            WHERE Job_Card__c = :workOrderId
            LIMIT 1
        ];
    }

    /**
     * Fetch related Work Order Line Items for a Warranty Prior.
     * 
     * @param warrantyId - ID of the related Warranty Prior
     * @return List<WorkOrderLineItem> - List of related Work Order Line Items
     * lastModifiedBy - Sagar Kumar
     */
    @AuraEnabled(cacheable=true)
    public static List<WorkOrderLineItem> getRelatedWorkOrderLineItems(Id warrantyId) {
        System.debug('Fetching related WorkOrderLineItems for Warranty ID: ' + warrantyId);
        return [
            SELECT Id, LineItemNumber, PricebookEntryId, Warranty_Prior__c, PricebookEntry.Product2.Name,
                   PricebookEntry.Product2.ProductCode, Quantity, RR_Parts_Category__c, Status, Tax__c,
                   Amount_per_Hour__c, CreatedDate, WorkOrder.WorkOrderNumber, PricebookEntry.Product2Id,Total_Labour_Charges__c,Total_NDP__c,Grand_Total__c,IGST_Percentage_formula__c,
                   TotalAmount__c,Labour_Code__r.Name,Labour_Code__r.RR_Labour_Charge__c ,Replacement_Type__c,Labour_Code__r.RR_Efforts_Hours__c,Hours__c,Part_Description__c,Consequential_Part__c,Electrical_Value__c,
                    FFIR_Number__c, FFIR_Links__c
            FROM WorkOrderLineItem
            WHERE Warranty_Prior__c = :warrantyId
            ORDER BY CreatedDate ASC
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<WorkOrderLineItem> getRelatedWorkOrderLineItemsOnlyCausal(Id warrantyId) {
        System.debug('Fetching related WorkOrderLineItems for Warranty ID: causal ' + warrantyId);
        return [
            SELECT Id, LineItemNumber, PricebookEntryId, Warranty_Prior__c, PricebookEntry.Product2.Name,
                   PricebookEntry.Product2.ProductCode, Quantity, RR_Parts_Category__c, Status, Tax__c,
                   Amount_per_Hour__c, CreatedDate, WorkOrder.WorkOrderNumber, PricebookEntry.Product2Id,Total_Labour_Charges__c,Total_NDP__c,Grand_Total__c,IGST_Percentage_formula__c,
                   TotalAmount__c,Labour_Code__r.Name,Labour_Code__r.RR_Labour_Charge__c ,Replacement_Type__c,Labour_Code__r.RR_Efforts_Hours__c,Hours__c,Part_Description__c,Consequential_Part__c,Electrical_Value__c,
                    FFIR_Number__c, FFIR_Links__c
            FROM WorkOrderLineItem
            WHERE Warranty_Prior__c = :warrantyId AND Replacement_Type__c = 'Causal'
            ORDER BY CreatedDate ASC
        ];
    }

    

     @AuraEnabled
        public static void updateAdditionalParts(List<WorkOrderLineItem> partsDraftValues) {
            System.debug('Updating Parts:::==> ' + partsDraftValues);
            try {
                if (partsDraftValues != null && !partsDraftValues.isEmpty()) {
                    update partsDraftValues;
                }
            } catch (Exception e) {
                throw new AuraHandledException('Error updating parts: ' + e.getMessage());
            }
        }
    /**
     * Fetch related Work Plans (Labours) for a Warranty Prior.
     * 
     * @param warrantyId - ID of the related Warranty Prior
     * @return List<WorkPlan> - List of related Work Plans
     */

    @AuraEnabled(cacheable=true)
    public static String getUserProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WorkPlan> getRelatedWorkPlans(Id warrantyId) {
        System.debug('Fetching related Work Plans for Warranty ID: ' + warrantyId);
        return [
            SELECT Id, Name, Warranty_Prior__c, RR_Labour_Code__r.Code, Status__c, Duration_Hour__c, Labour_Charge__c,
                   CreatedDate, RR_Labour_Code__c, Amount_per_Hour__c, Tax__c,TotalAmount__c, Labour_Charge_CodeSet__c,
                   Code_Set_Tax__c, Total_Labour_Cost__c
            FROM WorkPlan
            WHERE Warranty_Prior__c = :warrantyId
            ORDER BY CreatedDate ASC
        ];
    }

    // ----------------------------- //
    //        UPDATE METHODS         //
    // ----------------------------- //

    /**
     * Update multiple Work Order Line Items (Parts).
     * 
     * @param partsDraftValues - List of draft values from the UI for updating parts
     */
    @AuraEnabled
    public static void updateParts(List<Map<String, Object>> partsDraftValues) {
        System.debug('partsDraftValues:::::=>' + partsDraftValues);
        try {
            List<WorkOrderLineItem> workOrderLineItemsToUpdate = new List<WorkOrderLineItem>();

            for (Map<String, Object> part : partsDraftValues) {
                if (part.containsKey('Id') && part.get('Id') != null) {
                    WorkOrderLineItem item = new WorkOrderLineItem(
                        Id = (Id) part.get('Id'),
                        Tax__c = part.containsKey('Tax__c') && part.get('Tax__c') != null 
                        ? (part.get('Tax__c') instanceof Decimal 
                           ? (Decimal) part.get('Tax__c') 
                           : Decimal.valueOf((String) part.get('Tax__c')))
                           : null,
                        Amount_per_Hour__c = part.containsKey('Amount_per_Hour__c') && part.get('Amount_per_Hour__c') != null 
                                    ? (part.get('Amount_per_Hour__c') instanceof Decimal 
                                       ? (Decimal) part.get('Amount_per_Hour__c') 
                                       : Decimal.valueOf((String) part.get('Amount_per_Hour__c')))
                                       : null
                    );
                    workOrderLineItemsToUpdate.add(item);
                }
            }

            if (!workOrderLineItemsToUpdate.isEmpty()) {
                update workOrderLineItemsToUpdate;
                System.debug('Updated WorkOrderLineItems:::=> ' + workOrderLineItemsToUpdate);
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating Parts (WorkOrderLineItems): ' + ex.getMessage());
        }
    }

    /**
     * Update multiple Work Plans (Labours).
     * 
     * @param labourDraftValues - List of draft values from the UI for updating labours
     */
    @AuraEnabled
    public static void updateLabours(List<Map<String, Object>> labourDraftValues) {
        try {
            List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();

            for (Map<String, Object> labour : labourDraftValues) {
                if (labour.containsKey('Id') && labour.get('Id') != null) {
                    WorkPlan plan = new WorkPlan(
                        Id = (Id) labour.get('Id'),
                        Tax__c = labour.containsKey('Tax__c') && labour.get('Tax__c') != null 
                        ? (labour.get('Tax__c') instanceof Decimal 
                           ? (Decimal) labour.get('Tax__c') 
                           : Decimal.valueOf((String) labour.get('Tax__c')))
                           : null,
                        Amount_per_Hour__c = labour.containsKey('Amount_per_Hour__c') && labour.get('Amount_per_Hour__c') != null 
                                    ? (labour.get('Amount_per_Hour__c') instanceof Decimal 
                                       ? (Decimal) labour.get('Amount_per_Hour__c') 
                                       : Decimal.valueOf((String) labour.get('Amount_per_Hour__c')))
                                       : null
                    );
                    workPlansToUpdate.add(plan);
                }
            }

            if (!workPlansToUpdate.isEmpty()) {
                update workPlansToUpdate;
                System.debug('Updated WorkPlans: ' + workPlansToUpdate);
            }
        } catch (Exception ex) {
            throw new AuraHandledException('Error updating Labours (WorkPlans): ' + ex.getMessage());
        }
    }

    /**
     * Update a single Warranty Prior record.
     * 
     * @param warrantyId - ID of the Warranty Prior
     * @param typeOfWarranty - Updated Type of Warranty
     * @param asmFeedback - Updated ASM Feedback
     * @param ffirNumber - Updated FFIR Number
     * @param dealerObservation - Updated Dealer Observation
     * @param media - Updated Media field
     */
    @AuraEnabled
    public static void updateWarrantyPrior(Id warrantyId, String asmFeedback) {
        try {
            System.debug('asmFeedback'+asmFeedback);
            Warranty_Prior__c warrantyToUpdate = [
                SELECT Id, Type_of_Warranty__c, ASM_Feedback__c, FFIR_Number__c, Dealer_Observation__c, Media__c FROM Warranty_Prior__c
                WHERE Id = :warrantyId
                LIMIT 1
            ];

            //warrantyToUpdate.Type_of_Warranty__c = typeOfWarranty;
            warrantyToUpdate.ASM_Feedback__c = asmFeedback;
            // warrantyToUpdate.FFIR_Number__c = ffirNumber;
            // warrantyToUpdate.Dealer_Observation__c = dealerObservation;
            // warrantyToUpdate.Media__c = media;

            update warrantyToUpdate;
            System.debug('Updated Warranty Prior: ' + warrantyToUpdate);
        } catch (Exception ex) {
           System.debug('Error fetching custom metadata: ' + ex.getMessage());
        }
    }
}