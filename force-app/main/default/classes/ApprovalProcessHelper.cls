public with sharing class ApprovalProcessHelper {
    @AuraEnabled
    public static void handleApproval(String recordId, String action) {
        System.debug('Entering handleApproval with recordId: ' + recordId + ', action: ' + action);

        if (recordId == null || action == null) {
            System.debug('Validation failed: Record ID or action is null.');
            throw new AuraHandledException('Record ID or action cannot be null.');
        }

        if (action == 'approve' || action == 'reject') {
            System.debug('Handling action: ' + action);
            Approval.ProcessWorkitemRequest workItemRequest = new Approval.ProcessWorkitemRequest();
            System.debug('Setting comments for action: ' + workItemRequest.getComments());
            workItemRequest.setAction(action.capitalize());
            System.debug('Capitalized action set: ' + workItemRequest.getAction());
            String workItemId = getWorkItemId(recordId);
            System.debug('Retrieved WorkItem ID: ' + workItemId);
            workItemRequest.setWorkItemId(workItemId);
            Approval.process(workItemRequest);
        } else if (action == 'recall') {
            System.debug('Handling recall action.');
            recallApproval(recordId);
        } else {
            System.debug('Invalid action specified: ' + action);
            throw new AuraHandledException('Invalid action specified.');
        }

        System.debug('Exiting handleApproval.');
    }

    private static String getWorkItemId(String recordId) {
        System.debug('Entering getWorkItemId with recordId: ' + recordId);

        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId
            LIMIT 1
        ];
        System.debug('WorkItems retrieved: ' + workItems);

        if (!workItems.isEmpty()) {
            System.debug('WorkItem ID found: ' + workItems[0].Id);
            return workItems[0].Id;
        } else {
            System.debug('No WorkItem found for recordId: ' + recordId);
            throw new AuraHandledException('No WorkItem found for the specified record.');
        }
    }

    Public static void recallApproval(String recordId) {
        System.debug('Entering recallApproval with recordId: ' + recordId);

        List<ProcessInstance> instances = [
            SELECT Id, Status 
            FROM ProcessInstance 
            WHERE TargetObjectId = :recordId AND Status = 'Pending'
            LIMIT 1
        ];
        System.debug('ProcessInstances retrieved: ' + instances);

        if (!instances.isEmpty()) {
            System.debug('Pending ProcessInstance found, deleting: ' + instances[0].Id);
            delete instances[0]; // Deleting the instance recalls the approval
        } else {
            System.debug('No pending approval process found for recordId: ' + recordId);
            throw new AuraHandledException('No pending approval process found for the specified record.');
        }

        System.debug('Exiting recallApproval.');
    }

    @AuraEnabled(cacheable=true)
    public static Boolean canViewApprovalActions() {
        System.debug('Entering canViewApprovalActions');
        
        // Get the current user's profile name
        String userProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
    
        // Check if the profile is "ASM Profile"
        if (userProfileName != System.Label.CanViewApprovalActions) {
            System.debug('Current user does not have the Area Service Manager. Access denied.');
            return false; // Deny access if the user is not in the ASM Profile
        }
    
        // // Query the ProcessInstanceWorkitem for the current user's approval task
        // List<ProcessInstanceWorkitem> workItems = [
        //     SELECT Id, ActorId, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName
        //     FROM ProcessInstanceWorkitem 
        //     WHERE ProcessInstance.ProcessDefinition.DeveloperName = 'Warranty_Approval_Process'
        //     AND ActorId = :UserInfo.getUserId() 
        //     LIMIT 1
        // ];
        
        // // Check if work items exist and if the current user is assigned
        // if (!workItems.isEmpty()) {
        //     System.debug('WorkItem retrieved: ' + workItems[0].Id);
        //     System.debug('Current user is assigned to the approval action.');
        //     return true; // The current user is assigned to the approval action
        // } else {
        //     System.debug('No WorkItem found for the current user in the Warranty_Approval_Process.');
        //     return false; // The current user is not assigned to this approval
        // }
        return true;
    }
    
    
    
    
}