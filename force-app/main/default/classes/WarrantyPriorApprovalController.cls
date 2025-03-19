public with sharing class WarrantyPriorApprovalController {
    @AuraEnabled
    public static String submitApprovalProcess(Id warrantyId, String typeOfWarranty, String asmFeedback, String ffirNumber, String dealerObservation, String media,String standardValue,String ffirLink) {
        try{
            
        // // check is there any approval process
        // List<ProcessInstance> instances = [
        //     SELECT Id, Status
        //     FROM ProcessInstance
        //     WHERE TargetObjectId = :warrantyId
        //     AND Status IN ('Sumbit for Approval')
        //     LIMIT 1
        // ];
        
        // if (!instances.isEmpty()) {
        //     return 'An approval process is already initiated for this record.';
        // }

            Warranty_Prior__c warrantyToUpdate = [
                SELECT Id, Type_of_Warranty__c, ASM_Feedback__c, FFIR_Number__c, Dealer_Observation__c, Media__c,Status__c,Standard_Values__c
                FROM Warranty_Prior__c
                WHERE Id = :warrantyId
                LIMIT 1
            ];
            
            warrantyToUpdate.Type_of_Warranty__c = typeOfWarranty;
            warrantyToUpdate.ASM_Feedback__c = asmFeedback;
            warrantyToUpdate.FFIR_Number__c = ffirNumber;
            warrantyToUpdate.Dealer_Observation__c = dealerObservation;
            warrantyToUpdate.Media__c = media;
            warrantyToUpdate.Standard_Values__c = standardValue;
            warrantyToUpdate.FFIR_Link__c = ffirLink;
            
            update warrantyToUpdate;
            
        // // Allow submission only if the status is 'Pending' or 'Rejected'
        // if (warrantyToUpdate.Status__c != 'Pending' && warrantyToUpdate.Status__c != 'Rejected') {
        //     return 'Approval process cannot be initiated. Only records with Status "Pending" or "Rejected" can be submitted for approval.';
        // }

        // Check for existing approval process instances
        // List<ProcessInstance> instances = [
        //     SELECT Id, Status
        //     FROM ProcessInstance
        //     WHERE TargetObjectId = :warrantyId
        //     AND Status IN ('Pending', 'Rejected')
        //     LIMIT 1
        // ];

        // if (!instances.isEmpty()) {
        //     ProcessInstance instance = instances[0];
        //     if (instance.Status == 'Pending') {
        //         return 'An approval process is already in progress for this record.';
        //     }
        //     if (instance.Status == 'Rejected') {
        //         System.debug('Approval process previously rejected. Resubmitting for approval.');
        //     }
        // }
            
            // if (warrantyToUpdate == null) {
            //     throw new AuraHandledException('No related Warranty Prior record found.');
            // }
            
            // if (warrantyToUpdate.Status__c != 'Sumbit for Approval') {
            //     return 'Only records with Status "Sumbit for Approval" can be submitted for approval.';
            // }
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
           // if(warrantyToUpdate.Approval_Fired__c == false){
                req.setComments('Submitting related Warranty Prior for approval.');
                req.setObjectId(warrantyToUpdate.Id);
            //}
            Approval.ProcessResult result = Approval.process(req);
            
            // if(result.isSuccess()){
            //     return 'Success';
            // }else {
            //     return null;
            // }
            
            // System.debug('resdsd======'+result);
            // // Check if the submission was successful
            // if (!result.isSuccess()) {
            //     String errorMessage = 'Failed to submit approval process.';
            //     if (result.getErrors() != null && !result.getErrors().isEmpty()) {
            //         errorMessage += ' Errors: ';
            //         for (Database.Error error : result.getErrors()) {
            //             errorMessage += error.getMessage() + ' ';
            //         }
            //     }
            // }
            return 'Success';
            
        }catch(exception e){
            system.debug('Error Message'+e.getMessage()+ ' at Line Number'+ e.getLineNumber());
            return null;
        }
    }
    
    // checking warranty is already initiated
    @AuraEnabled(cacheable=true)
    public static Boolean checkApprovalStatus(Id warrantyId) {
        Warranty_Prior__c warrantyRecord = [
            SELECT Id, Name, Status__c 
            FROM Warranty_Prior__c 
            WHERE Id = :warrantyId
            LIMIT 1
        ];
        
        System.debug('status====> '+warrantyRecord.Status__c);
        if (warrantyRecord.Status__c == 'Sumbit for Approval' ||  warrantyRecord.Status__c == 'Approved') {
            System.debug('status====> '+warrantyRecord.Status__c);
            return true;
        }
        // Assuming 'Submit for Approval' or 'Approved' means approval process has started
       // return (warrantyRecord.Status__c == 'Submit for Approval' || warrantyRecord.Status__c == 'Approved');
       return false;
    }
    

    @AuraEnabled(cacheable=true)
    public static Boolean isWarrantySubmittedForApproval(Id warrantyId) {
        // try {
            // Query the Warranty_Prior__c record based on the provided Warranty ID
            Warranty_Prior__c warrantyRecord = [
                SELECT Id, Name, Status__c 
                FROM Warranty_Prior__c 
                WHERE Id = :warrantyId
                LIMIT 1
            ];

            // Check if the warranty record status is 'Submit for Approval'
            if (warrantyRecord.Status__c == 'Sumbit for Approval') {
                return true; // Return true if the status is 'Submit for Approval'
            }
            return false; // Return false if no record found or status is different

        // } catch (Exception e) {
        //    // throw new AuraHandledException('Error checking warranty status: ' + e.getMessage());
        // }
    }
    
    @AuraEnabled
    public static Warranty_Prior__c getRelatedWarrantyPrior(Id workOrderId) {
        try{
            // Fetch related Warranty Prior record
            List<Warranty_Prior__c> records = [
                SELECT Id, Name, Status__c 
                FROM Warranty_Prior__c 
                WHERE Job_Card__c = :workOrderId 
                LIMIT 1
            ];
            return records.isEmpty() ? null : records[0]; 
        }catch(exception e){
            system.debug('Error Message'+e.getMessage()+ ' at Line Number'+ e.getLineNumber());
            return null;
        }
        
    }
}