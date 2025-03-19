public class AssetMilestoneTriggerWorker {
	 public static void createPDIItems(List<AssetMilestone> newList, Map<Id, AssetMilestone> newMap, Map<Id, AssetMilestone> oldMap){

        // Specify the object and field API name
        String objectApiName = 'AssetMilestone';
        String fieldApiName = 'MilestoneType';
        // Set<String> milestoneTypesToBeSkip = new Set<String>{'1st Service','2nd Service','3rd Service','4th Service','5th Service','6th Service','7th Service','8th Service','9th Service','10th Service','11th Service','12th Service','13th Service','14th Service','15th Service','16th Service','17th Service','18th Service'};
        
        Set<String> MilestoneTypesToBeSkipped = new Set<String>();
        String milestoneTypesToBeSkipCustomLabel = System.Label.milestoneTypesToBeSkip;
        for(String milestoneType : milestoneTypesToBeSkipCustomLabel.split(',')){
            MilestoneTypesToBeSkipped.add(milestoneType);
        }

        Map<String, Integer> milestoneseqs = getPicklistValuesWithSeq(objectApiName, fieldApiName, MilestoneTypesToBeSkipped);      

        Set<Id> vehicleID = new Set<Id>();
        List<Vehicle> allVehicles = new List<Vehicle>();
        Map<Id,Boolean> vehicleStatus = new Map<Id,Boolean>();
        for (AssetMilestone asset : newList) {
            vehicleID.add(asset.vehicleID);
        }
        if(vehicleID != null && vehicleID.size() > 0){
            allVehicles = [Select Id,Name,PDI_Status_Pass__c From Vehicle Where Id IN:vehicleID];
        }
        
        if(allVehicles != null && allVehicles.size() > 0){
            for(Vehicle vac : allVehicles){
                vehicleStatus.put(vac.Id, vac.PDI_Status_Pass__c);
            }
        }
        
        // List to hold new Child records to be inserted
        List<Pre_Delivery_Inspection_Item__c> newChildRecords = new List<Pre_Delivery_Inspection_Item__c>();
    
        // Map to store existing Child records related to Parent objects
        Map<Id, List<Pre_Delivery_Inspection_Item__c>> existingChildRecordsMap = new Map<Id, List<Pre_Delivery_Inspection_Item__c>>();
    
        // Query for existing Child records related to Parent objects
        for (Pre_Delivery_Inspection_Item__c existingChildRecord : [SELECT Id, Asset_Milestone__c, Pre_Delivery_Inspection__c, Check__c FROM Pre_Delivery_Inspection_Item__c WHERE Asset_Milestone__c IN :newMap.keySet()]) {
            if (!existingChildRecordsMap.containsKey(existingChildRecord.Asset_Milestone__c)) {
                existingChildRecordsMap.put(existingChildRecord.Asset_Milestone__c, new List<Pre_Delivery_Inspection_Item__c>{existingChildRecord});
            } else {
                existingChildRecordsMap.get(existingChildRecord.Asset_Milestone__c).add(existingChildRecord);
            }
        }
        
        // Query PDI for new Child records to be inserted
        List<Pre_Delivery_Inspection__c> pdiListRecords = [Select Id from Pre_Delivery_Inspection__c ORDER BY Attribute__c];
        
        // Iterate over updated Parent objects
        for (AssetMilestone updatedParent : newList) {
            if(vehicleStatus != null && vehicleStatus.containsKey(updatedParent.vehicleID) && vehicleStatus.get(updatedParent.vehicleID) == false && (milestoneseqs.get(updatedParent.MilestoneType) <= milestoneseqs.get('PDI'))){
                // Check if Parent status is updated to 'PDI Check' and there are no existing Child records with the same status
                if (updatedParent.MilestoneType == 'PDI' && !existingChildRecordsMap.containsKey(updatedParent.Id)) {
                    for(Pre_Delivery_Inspection__c pdi : pdiListRecords){
                        // Create a new Child record
                        Pre_Delivery_Inspection_Item__c newChildRecord = new Pre_Delivery_Inspection_Item__c(
                            Asset_Milestone__c 					= updatedParent.Id,
                            Pre_Delivery_Inspection__c 			= pdi.Id,
                            Check__c 						    = false
                            // Add other field values as needed
                        );
                        newChildRecords.add(newChildRecord);
                    }
                }
            }
            else if(vehicleStatus != null && vehicleStatus.containsKey(updatedParent.vehicleID) && vehicleStatus.get(updatedParent.vehicleID) == false) {
                updatedParent.addError('Please make sure all PDI is checked of vehicle before moving to the next milestone.');
            }
            
        }
    
        // Insert new Child records
        if (!newChildRecords.isEmpty()) {
            insert newChildRecords;
        }
    }
    
    public static void checkMilestoneRecord(List<AssetMilestone> milestones) {
        Set<String> existingVehicleMilestoneTypes = new Set<String>();
        //Set<String> milestoneTypes = new Set<String>{'1st Service','2nd Service','3rd Service','4th Service','5th Service','6th Service','7th Service','8th Service','9th Service','10th Service','11th Service','12th Service','13th Service','14th Service','15th Service','16th Service','17th Service','18th Service'};
		
        Set<String> milestoneTypes = new Set<String>();
        String milestoneTypesToBeSkipCustomLabel = System.Label.milestoneTypesToBeSkip;
        for(String milestoneType : milestoneTypesToBeSkipCustomLabel.split(',')){
            milestoneTypes.add(milestoneType);
        } 
            
        // Jitendra : Where clause added in query to optimize the query
        Set<Id> vehicleID = new Set<Id>();
        for (AssetMilestone asset : milestones) {
            vehicleID.add(asset.vehicleID);
        }

        // Query existing AssetMilestone records
        for (AssetMilestone existingMilestone : [SELECT VehicleId, MileStonetype FROM AssetMilestone where MilestoneType IN :milestoneTypes AND vehicleID IN :vehicleID]) {
            // Construct a unique identifier for the combination of vehicle and milestone type
            String vehicleMilestoneKey = existingMilestone.VehicleId + '-' + existingMilestone.MilestoneType;
    
            // Add the combination to the set
            existingVehicleMilestoneTypes.add(vehicleMilestoneKey);
        }
    
        // Iterate through the AssetMilestones being inserted
        for (AssetMilestone newMilestone : milestones) {
            //Jitendra : Date Validation Added as per UAT feedback
            if(newMilestone.MilestoneType != 'Order Received' && newMilestone.MilestoneDate < System.today()){
                newMilestone.addError('The milestone date must be today or a future date.');
            }
            
            
            // Construct a unique identifier for the combination of vehicle and milestone type
            String newVehicleMilestoneKey = newMilestone.VehicleId + '-' + newMilestone.MilestoneType;
    
            // Check if the combination already exists in the set
            if (existingVehicleMilestoneTypes.contains(newVehicleMilestoneKey)) {
                // If it does, prevent the insertion of the new AssetMilestone
                newMilestone.addError('Milestone with the same vehicle and service type are already exists.');
            }
        }
    }
    
    public static void deletePDIMilestone(List<AssetMilestone> milestones){
        Set<Id> vehicleID = new Set<Id>();
        List<Vehicle> allVehicles = new List<Vehicle>();
        for (AssetMilestone asset : milestones) {
            if (asset.MilestoneType == 'PDI'){
                vehicleID.add(asset.vehicleID);
            }
        }
        if(vehicleID != null && vehicleID.size() > 0){
            List<Vehicle> fetchAllVehicles = [Select Id,Name,PDI_Status_Pass__c From Vehicle Where Id IN:vehicleID];
            
            if(fetchAllVehicles != null && fetchAllVehicles.size() > 0){
            	for(Vehicle vac : fetchAllVehicles){
                    Vehicle vc = new Vehicle();
                    vc.Id = vac.Id;
               		vc.PDI_Status_Pass__c = false;
                    allVehicles.add(vc);
            	}
        	}
            
            if(allVehicles != null && allVehicles.size() > 0){
                update allVehicles;
            }
        }
    }

    public static Map<String, Integer> getPicklistValuesWithSeq(String objectApiName, String fieldApiName, Set<String> MilestoneTypesToBeSkipped){
        Map<String, Integer> milestoneseqs = new Map<String, Integer>(); 
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldApiName).getDescribe();
        if (fieldDescribe.getType() == Schema.DisplayType.PICKLIST) {
            List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
            Integer count = 1;
            for (Schema.PicklistEntry picklistEntry : picklistValues) {
                // Access picklist value and label
                String value = picklistEntry.getValue();
                String label = picklistEntry.getLabel();
                if(!MilestoneTypesToBeSkipped.contains(value)){
                    milestoneseqs.put(value, count++);
                }
            }
        } else {
            // Handle if the field is not a picklist
            System.debug('The specified field is not a picklist.');
        }
        return milestoneseqs;
    }

    public static void checkMilestoneSequenceRecord(List<AssetMilestone> milestones){
        // Specify the object and field API name
        String objectApiName = 'AssetMilestone';
        String fieldApiName = 'MilestoneType';
        Set<String> MilestoneTypesToBeSkipped = new Set<String>();
        String milestoneTypesToBeSkipCustomLabel = System.Label.milestoneTypesToBeSkip;
        for(String milestoneType : milestoneTypesToBeSkipCustomLabel.split(',')){
            MilestoneTypesToBeSkipped.add(milestoneType);
        }
        
        Map<String, Integer> milestoneseqs = getPicklistValuesWithSeq(objectApiName, fieldApiName, MilestoneTypesToBeSkipped);       
        System.debug('milestoneseqs : '+milestoneseqs);
        
        Set<Id> vehicleIDs = new Set<Id>();
        Set<Id> cureentMilestones = new Set<Id>();
        List<Vehicle> allVehicles = new List<Vehicle>();
        Map<String,String> vehicleStatus = new Map<String,String>();
        for (AssetMilestone asset : milestones) {
            vehicleIDs.add(asset.VehicleId);
            cureentMilestones.add(asset.Id);
            // System.debug('asset Id '+asset.Id);
        }

        allVehicles = [Select Id, (SELECT Id, MilestoneType, Name, CreatedDate FROM AssetMilestones Where ID Not IN :cureentMilestones AND MilestoneType Not IN :MilestoneTypesToBeSkipped ORDER BY MilestoneType DESC limit 1) from Vehicle Where Id IN :vehicleIDs];
        Boolean isFirstMileStone = true;
       
        if(allVehicles != null && allVehicles.size() > 0){
            for(Vehicle vc : allVehicles){
                if(vc.AssetMilestones != null && vc.AssetMilestones.size() > 0){
                    System.debug('vc.AssetMilestones'+vc.AssetMilestones);
                    isFirstMileStone = false;
                    // Latest created Asset Miletsotone of a vehicle
                    vehicleStatus.put(vc.Id, vc.AssetMilestones[0].MilestoneType);
                }
            }
        }        
        System.debug('vehicleStatus'+vehicleStatus);

        for (AssetMilestone asset : milestones) {
            if(asset.VehicleId != null){
                String key = asset.VehicleId;
                if(!MilestoneTypesToBeSkipped.contains(asset.MilestoneType) && vehicleStatus.containsKey(key) && milestoneseqs.containsKey(vehicleStatus.get(key))){
                    Integer lastStatusSeq = milestoneseqs.get(vehicleStatus.get(key));
                    Integer nextStatusSeq = milestoneseqs.get(asset.MilestoneType);
                    System.debug('lastStatusSeq :'+lastStatusSeq);
                    System.debug('nextStatusSeq :'+nextStatusSeq);
                    System.debug('vehicleStatus.get(key) :'+vehicleStatus.get(key));
                    System.debug('asset.MilestoneType :'+asset.MilestoneType);
                    if(lastStatusSeq + 1 != nextStatusSeq){
                       //  asset.addError('You cannot create a '+asset.MilestoneType+' milestone before completing the prior milestones.');
                    }
                } 
                else if(isFirstMileStone && milestoneseqs.get(asset.MilestoneType) != 1){
                    System.debug('milestoneseqs.get(asset.MilestoneType) : '+milestoneseqs.get(asset.MilestoneType));
                   // asset.addError('You cannot create a '+asset.MilestoneType+' milestone before completing the prior milestones.');
                }
            }
        }

    }
}