public class DiscrepancyController {

    @AuraEnabled
    public static String getUserProfile() {
        return [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;
    }

    @AuraEnabled(cacheable=true)
    public static List<Discrepancy_Line_Item__c> getLineItems(Id discrepancyId) {
        return [SELECT Id, Name, Supporting_Media__c,Spare_Approval__c,Warehouse_Approval__c,Feedback_From_Spare__c, Feedback_From_Warehosue__c FROM Discrepancy_Line_Item__c WHERE Discrepancy__c = :discrepancyId];
    }

    @AuraEnabled
public static String updateSupportingMedia(Map<Id, Map<String, String>> mediaUpdates, String profileName) {
    try {
        System.debug('mediaUpdates======>' + mediaUpdates);
        System.debug('profileName======>' + profileName);

        List<Discrepancy_Line_Item__c> updates = new List<Discrepancy_Line_Item__c>();

        for (Id itemId : mediaUpdates.keySet()) {
            Discrepancy_Line_Item__c item = new Discrepancy_Line_Item__c(Id = itemId);
            Map<String, String> itemUpdates = mediaUpdates.get(itemId);

            if (itemUpdates.containsKey('media') && String.isNotBlank(itemUpdates.get('media'))) {
                item.Supporting_Media__c = itemUpdates.get('media');
            }

            // If user is System Administrator, Parts Manager, or Warehouse Profile
            if (profileName == 'System Administrator' || profileName == 'Parts Manager') {
                if (itemUpdates.containsKey('status')) {
                    item.Spare_Approval__c = itemUpdates.get('status');
                }
                if (itemUpdates.containsKey('feedback')) {
                    item.Feedback_From_Spare__c = itemUpdates.get('feedback');
                }
            } 
            
            if (profileName == 'Warehouse Profile') {
                if (itemUpdates.containsKey('status')) {
                    item.Warehouse_Approval__c = itemUpdates.get('status');
                    System.debug('where hose ==>' + item.Warehouse_Approval__c);
                
                }
                if (itemUpdates.containsKey('feedback')) {
                    item.Feedback_From_Warehosue__c = itemUpdates.get('feedback');
                }
            }

            updates.add(item);
        }

        if (!updates.isEmpty()) {
            update updates;
            return 'Success';
        } else {
            return 'No updates performed';
        }
    } catch (Exception e) {
        return e.getMessage();
    }
}



    @AuraEnabled
    public static List<Claim> getClaimsAndItsLineItems(String recordId){
        try {
            return [Select Id, Name, AccountId, Status, ClaimType, FinalizedDate, Summary, ClaimReason, IsClosed, 
            Severity, ClaimReasonType, FnolChannel, TotalClaimedAmount, TotalAdjustedAmount, RelatedClaimId, 
            UsageType, StatusCode, ClaimTypeCode, Create_Batch__c, Total_Claimed_Amount__c, Total_Approved_Amount__c, 
            Warranty_Prior__c, Total_Claim_Amount__c, Credit_Note__c, Job_Card__c, Vehicle__c, Unit_Price__c, 
            Credit_Note_Number__c, Shipped_Quantity__c, Received_Quantity__c, Total_Claimable_Amount__c, Total_NDP__c, 
            Approved_Amount__c,(SELECT Id,Name, ClaimId, ClaimParticipantId, Category,AssetUsageValue, 
            AssetUsageUnitOfMeasure, VehicleId, Amount__c, Status__c, Approved_Quantity__c, Approved_Amount__c, 
            Part__c, Warranty_Tag__c, Failure_Quantity__c, Part_Description__c, Quantity__c, Hours__c, 
            Claim_Item_Number__c, Received_Quantity__c,Unit_Price__c, CGST_Percentage__c, IGST_Percentage__c, 
            SGST_Percentage__c, Dealer_List_Price__c,Claim_Amount__c, Single_Labour_Charge__c, Total_Labour_Charges__c, 
            Approved_Total_NDP__c, Approved_Sub_Total__c, Tax_Amount__c, Approved_Grand_Total__c, Approved_Tax_Amount__c, 
             Claim_Amount_manual__c, Rejection_Reason__c, Quantity_Rejected__c, Electrical_Value_Formula__c, 
             Consequential_Part_Formula__c, Hours_Formula__c, UnitPrice_Formula__c, IGST_Percentage_Formula__c, 
             Part_Description_Formula__c, Quantity_Formula__c, CGST_Percentage_Formula__c, SGST_Percentage_Formula__c,
            Dealer_List_Price_NDP_Formula__c, Claim_Type__c, Labour_Code__c, Labour_Duration_Hours__c, 
            Labour_Duration_Min__c, Labour_Charge__c, HSN_Code__c, Discount__c, Amount_per_Hour__c, 
            Labour_Tax__c, Labour_Total_Amount__c, Global_labour_Charges__c, Execution_Order__c, 
            Labour_Status__c, Labour_Category__c FROM ClaimItems) 
            FROM Claim Where Create_Batch__c =: recordId AND Create_Batch__r.Status__c = 'Dispatched' 
            ];
        } catch(Exception e){
            System.debug('Exception====>'+e.getMessage() + ' at line Number ======>' + e.getLineNumber());
            return null;
        }
    }
}