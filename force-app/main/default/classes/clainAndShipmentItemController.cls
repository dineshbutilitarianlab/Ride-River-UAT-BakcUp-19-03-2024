public with sharing class clainAndShipmentItemController {
    
    @AuraEnabled(cacheable=true)
    public static List<Claim> getBatchClaims(Id batchId) {
        return [SELECT Id, Name FROM Claim WHERE Create_Batch__c = :batchId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<WorkPlan> getBatchLabour(){
        return [SELECT Id, Name FROM WorkPlan ];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ShipmentItem> getShipmentItemList(String recordId){
        return [Select id,ShipmentItemNumber,Quantity,Quantity_Received__c,Missing_Damaged_Quantity__c,ShipmentId,Shipment.Status,Product2Id,Product2.Name from ShipmentItem where ShipmentId=:recordId];
    }
    @AuraEnabled
    public static string updateShipmentItemList(List<ShipmentItem> shipmentItemList,String recordId){
        Shipment s = [SELECT Id, Status FROM Shipment WHERE id=:recordId];
        s.Status='Delivered';
        update s;
        update shipmentItemList;
        return 'SUCCESS';
    }
    
    //!check wheteher it is used or not 
    @AuraEnabled(cacheable = true)
    public static List<Claim> getAllClaims(String recordId){
        return [SELECT Id,Name,ClaimType,Status,Total_Claimed_Amount__c,Create_Batch__c,Create_Batch__r.Name,Create_Batch__r.Is_GRN_Received__c,Shipped_Quantity__c FROM Claim where Create_Batch__c=:recordId ];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ClaimItem> getPartItems(Id recordId) {
        System.debug('Method getPartItems invoked with recordId: ' + recordId);
        
        try {
            List<ClaimItem> claimItems = [
                SELECT Id, Name, Claim.Name, Claim_Item_Number__c, 
                Part__r.LineItemNumber, Part__r.Product_Code__c, Status__c, 
                Amount__c, Quantity_Formula__c, Received_Quantity__c, Rejection_Reason__c, 
                Claim.Create_Batch__c, Claim.Create_Batch__r.Name, Approved_Quantity__c,
                Quantity_Rejected__c,Claim.Create_Batch__r.Send_to_Finance__c ,
                Claim.Shipped_Quantity__c
                FROM ClaimItem 
                WHERE Claim.Create_Batch__c = :recordId 
                 
                AND Claim_Type__c = 'Part'
            ];
            
            System.debug('Fetched Claim Items: ' + claimItems);
            return claimItems;
        } catch (Exception e) {
            System.debug('Exception occurred in getPartItems: ' + e.getMessage());
            throw new AuraHandledException('Error fetching claim items: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable = true)
    public static List<ClaimItem> getLabourItems(String recordId) {
        System.debug('Method getAllClaimItems invoked with recordId: ' + recordId);
        
        try {
            // Query to fetch claim items
            List<ClaimItem> claimItems = [
                SELECT Id, Name, 
                Claim.ClaimType, 
                Claim.Name, 
                Claim_Item_Number__c,
                Status__c, 
                Amount__c, 
                Quantity__c, 
                Received_Quantity__c,
                Rejection_Reason__c,
                Claim.Create_Batch__c, 
                Claim.Create_Batch__r.Name, 
                Labour_Code__r.Name,
                Labour_Total_Amount__c,
                Labour_Category__c,
                Approved_Quantity__c,
                Claim.Create_Batch__r.Is_GRN_Received__c, Quantity_Rejected__c,
                Claim.Shipped_Quantity__c,Claim.Create_Batch__r.Send_to_Finance__c 
                FROM ClaimItem 
                WHERE Claim.Create_Batch__c = :recordId and Claim_Type__c = 'Labour'
            ];
            
            // Debugging the retrieved claim items
            System.debug('Fetched Claim Items: ' + claimItems);
            
            return claimItems;
        } catch (Exception e) {
            // Debugging and handling exceptions
            System.debug('Exception occurred in getAllClaimItems: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching claim items: ' + e.getMessage());
        }
    }
    
    
    
    @AuraEnabled(cacheable = true)
    public static List<ClaimItem> getAllClaimItems(String recordId) {
        System.debug('Method getAllClaimItems invoked with recordId: ' + recordId);
        
        try {
            // Query to fetch claim items
            List<ClaimItem> claimItems = [
                SELECT Id, Name, 
                Claim.ClaimType, 
                Claim.Name, 
                Claim_Item_Number__c,
                Status__c, 
                Amount__c, 
                Quantity__c, 
                Received_Quantity__c,
                Rejection_Reason__c,
                Claim.Create_Batch__c, 
                Claim.Create_Batch__r.Name, 
                Approved_Quantity__c,
                Claim.Create_Batch__r.Is_GRN_Received__c, Quantity_Rejected__c,
                Claim.Shipped_Quantity__c
                FROM ClaimItem 
                WHERE Claim.Create_Batch__c = :recordId
            ];
            
            // Debugging the retrieved claim items
            System.debug('Fetched Claim Items: ' + claimItems);
            
            return claimItems;
        } catch (Exception e) {
            // Debugging and handling exceptions
            System.debug('Exception occurred in getAllClaimItems: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching claim items: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ClaimItem> getAllClaimItemsApproved(String recordId) {
        System.debug('Method getAllClaimItems invoked with recordId: ' + recordId);
        
        try {
            // Query to fetch claim items
            List<ClaimItem> claimItems = [
                SELECT Id, Name, 
                Claim.ClaimType, 
                Claim.Name, 
                Claim_Item_Number__c,
                Status__c, 
                Amount__c, 
                Quantity__c, 
                Received_Quantity__c,
                Claim_Amount__c,
                Quantity_Formula__c,
                Rejection_Reason__c,
                Claim.Create_Batch__c, 
                Claim.Create_Batch__r.Name, 
                Approved_Quantity__c,
                Part__r.HSN_Code__c,
                Part__r.LineItemNumber,
                Claim.Create_Batch__r.Is_GRN_Received__c, Quantity_Rejected__c,
                Claim.Shipped_Quantity__c
                FROM ClaimItem 
                WHERE Claim.Create_Batch__c = :recordId  and Claim_Type__c = 'Part'
            ]; //and Status__c = 'Approved'
            
            // Debugging the retrieved claim items
            System.debug('Fetched Claim Items: ' + claimItems);
            
            return claimItems;
        } catch (Exception e) {
            // Debugging and handling exceptions
            System.debug('Exception occurred in getAllClaimItems: ' + e.getMessage());
            throw new AuraHandledException('With An error occurred while fetching claim items: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateClaims(List<Claim> claimList){
        try {
            Set<Id> batchIds = new Set<Id>();
            for(Claim c : claimList){
                batchIds.add(c.Create_Batch__c);
            }
            Create_Batch__c c = [Select id,Is_GRN_Received__c from Create_Batch__c where id=:batchIds LIMIT 1];
            if(c.Is_GRN_Received__c == false){
                c.Is_GRN_Received__c = true;
            }
            
            update c;
            update claimList;
            return 'SUCCESS';
            
        } catch (Exception e) {
            System.debug('Custom Error: Something went wrong - ' + e.getMessage());
             return 'ERROR: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static string updateClaimItems(List<ClaimItem> claimList) {
        System.debug('Entering updateClaimItems method...');
        try {
            System.debug('Received claimList: ' + claimList);
            
            Set<Id> batchIds = new Set<Id>();
            for (ClaimItem c : claimList) {
                System.debug('Processing ClaimItem: ' + c);
                batchIds.add(c.Claim.Create_Batch__c);
            }
            
            System.debug('Collected batchIds: ' + batchIds);
            
            Create_Batch__c c = [SELECT Id, Status__c,Is_GRN_Received__c FROM Create_Batch__c WHERE Id = :batchIds LIMIT 1];
            System.debug('Queried Create_Batch__c record: ' + c);
            
            if (c.Is_GRN_Received__c == false) {
                System.debug('Updating Is_GRN_Received__c to true for batchId: ' + c.Id);
                c.Is_GRN_Received__c = true;
            }
            
            c.Status__c = 'Received';
            update c;
            System.debug('Updated Create_Batch__c record: ' + c);
            
            update claimList;
            System.debug('Updated ClaimItem records: ' + claimList);
            
            System.debug('Exiting updateClaimItems method with SUCCESS');
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception Occurred - ' + e.getMessage());
             return 'ERROR: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static Id createClaimItem(String name, String claimId, String labourCode) {
        
        System.debug('createClaimItem method....' + name+'------' + claimId + '-----------'+ labourCode);
        try {
            ClaimItem nCli = new ClaimItem();
            nCli.Name = name;
            nCli.Claim_Type__c = 'Labour';
            nCli.Labour_Code__c = labourCode;
            nCli.ClaimId = claimId;
            nCli.FaultDate = System.now();
            
            if (nCli!= null) {
                
                insert nCli;   
            }
            return nCli.Id;
        } catch (Exception e) {
            System.debug('Error while creating Claim Item: ' + e.getMessage());
             return null;
        }
    }
    
    @AuraEnabled
    public static String updateClaimItemsApprovedQuantityAndReason(String claimItemWrappersJson) {
        System.debug('Entering updateClaimItems method...');
        System.debug('claimItemWrappers...'+ claimItemWrappersJson);
        try {
            List<ClaimItemWrapper> claimItemWrappers = (List<ClaimItemWrapper>) JSON.deserialize(
                claimItemWrappersJson, 
                List<ClaimItemWrapper>.class
            );
            // Collect ClaimItem Ids
            Set<Id> claimItemIds = new Set<Id>();
            Set<Id> laborItemIds = new Set<Id>();
            set<Id> batchIds = new Set<Id>();
            for (ClaimItemWrapper wrapper : claimItemWrappers) {
                claimItemIds.add(wrapper.claimItemId);
                laborItemIds.add(wrapper.labourCodeId);
                batchIds.add(wrapper.batchId);
            }
            System.debug('Claim Item IDs: ' + claimItemIds);

            // Query ClaimItem records where Type__c = 'Labour' and filter their IDs
            for (ClaimItem ci : [SELECT Id ,Claim_Type__c FROM ClaimItem WHERE Id IN :claimItemIds AND Claim_Type__c = 'Labour']) {
                laborItemIds.add(ci.Id);
            }

            System.debug('Labour code Item IDs: ' + laborItemIds);

            
            // Query only necessary fields
            Map<Id, ClaimItem> existingClaimItems = new Map<Id, ClaimItem>(
                [SELECT Id, Approved_Quantity__c, Rejection_Reason__c ,Dealer_List_Price_NDP_Formula__c,Labour_Total_Amount__c
                 FROM ClaimItem 
                 WHERE Id IN :claimItemIds]
            );
            System.debug('Existing ClaimItems fetched: ' + existingClaimItems);
            
            List<ClaimItem> claimItemsToUpdate = new List<ClaimItem>();
            
            // Update the queried records with new values
            for (ClaimItemWrapper wrapper : claimItemWrappers) {
                if (existingClaimItems.containsKey(wrapper.claimItemId)) {
                    ClaimItem existing = existingClaimItems.get(wrapper.claimItemId);
                    existing.Approved_Quantity__c = wrapper.approvedQuantity;
                    existing.Rejection_Reason__c = wrapper.rejectionReason;
                    existing.Status__c = wrapper.approvalStatus;
                    Decimal listPrice = (existing.Dealer_List_Price_NDP_Formula__c != null) ? existing.Dealer_List_Price_NDP_Formula__c : 0;
                    existing.Approved_Amount__c = wrapper.approvedQuantity*listPrice;
                    if (wrapper.approvedQuantity > 0) {
                        System.debug('Status set to Approved');
                        existing.Status__c = 'Approved';
                    } else {
                        System.debug('Status set to Rejected');
                        existing.Status__c = 'Rejected';
                    }
                    claimItemsToUpdate.add(existing);
                    System.debug('Updating ClaimItem: ' + existing.Id + ' with Approved Quantity: ' 
                                 + wrapper.approvedQuantity + ' and Rejection Reason: ' + wrapper.rejectionReason);
                } else {
                    System.debug('ClaimItem with Id ' + wrapper.claimItemId + ' not found in database.');
                }
            }

            List<ClaimItem> laborItemsToUpdate = new List<ClaimItem>();
            
            Map<Id, ClaimItem> existingLaborItems = new Map<Id, ClaimItem>(
                [SELECT Id, Approved_Quantity__c, Rejection_Reason__c ,Labour_Total_Amount__c
                 FROM ClaimItem 
                 WHERE Id IN :laborItemIds]
            );

                for(ClaimItemWrapper wrapper : claimItemWrappers) {
                    if (existingClaimItems.containsKey(wrapper.claimItemId) && laborItemIds.contains(wrapper.claimItemId)) {
                        ClaimItem existing = existingClaimItems.get(wrapper.claimItemId);
                        existing.Status__c = wrapper.approvalStatus;
                        System.debug('Processing ClaimItem ID: ' + existing.Id);
                        System.debug('Existing Labour Total Amount: ' + existing.Labour_Total_Amount__c);
                        System.debug('Approval Status: ' + wrapper.approvalStatus);
                        existing.Approved_Amount__c = (wrapper.approvalStatus == 'Approved') ? existing.Labour_Total_Amount__c : 0;

                        laborItemsToUpdate.add(existing);
                    }else{
                        System.debug('ClaimItem with ID ' + wrapper.claimItemId + ' is not in laborItemIds or not found.');
                    }

                }
                if (!laborItemsToUpdate.isEmpty()) {
                    update laborItemsToUpdate;
                    System.debug('ClaimItem records updated successfully.');
                } else {
                    System.debug('No ClaimItem records to update.');
                }
                list<Create_Batch__c > batchList = [SELECT Id, Status__c FROM Create_Batch__c WHERE Id IN :batchIds];
                for(Create_Batch__c b : batchList){
                    b.Send_to_Finance__c = true;
                }
                update batchList;
            if (!claimItemsToUpdate.isEmpty()) {
                update claimItemsToUpdate;
                 

                System.debug('Updated ClaimItem records: ' + claimItemsToUpdate);
            } else {
                System.debug('No ClaimItems to update.');
            }
            
            System.debug('Exiting updateClaimItems method with SUCCESS');
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            throw new AuraHandledException('Error: ' + e.getMessage());
        }
    }
    
    
    public class ClaimItemWrapper {
        @AuraEnabled public Id claimItemId;
        @AuraEnabled public Id labourCodeId;
        @AuraEnabled public Id batchId;
        @AuraEnabled public Integer approvedQuantity;
        @AuraEnabled public String rejectionReason;
        @AuraEnabled public String approvalStatus;
        
        public ClaimItemWrapper() {
        }
        public ClaimItemWrapper(Id claimItemId,Id labourCodeId, Integer approvedQuantity, String rejectionReason,string approvalStatus) {
            this.claimItemId = claimItemId;
            this.labourCodeId = labourCodeId;
            this.batchId = batchId;
            this.approvedQuantity = approvedQuantity;
            this.rejectionReason = rejectionReason;
            this.approvalStatus = approvalStatus;
           
        }
    }
    
    
}