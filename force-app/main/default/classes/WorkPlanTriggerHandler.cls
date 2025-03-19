public class WorkPlanTriggerHandler {
    /*
    public static void handleInsert(List<WorkPlan> workPlans) {    
        Set<Id> workOrderIds = new Set<Id>(); 
        for (WorkPlan workPlan : workPlans) {
            if (workPlan.WorkOrderId != null && workPlan.RR_Labour_Category__c != 'Paid') {
                workOrderIds.add(workPlan.WorkOrderId);
            }
        }
        System.debug('WorkOrder IDs: ' + workOrderIds); 
        Map<Id, Warranty_Prior__c> warrantyMap = new Map<Id, Warranty_Prior__c>([SELECT Id, Job_Card__c FROM Warranty_Prior__c WHERE Job_Card__c IN :workOrderIds]);
        System.debug('Existing Warranty Priors == > ' + warrantyMap);
        
        List<WorkPlan> workPlansToUpdate = new List<WorkPlan>();
        
        for (WorkPlan workPlan : [SELECT Id,WorkOrderId FROM WorkPlan WHERE Id IN:workOrderIds]) {
            System.debug('workPlan === > ' + workPlan);
            if (workPlan.WorkOrderId != null && warrantyMap.containsKey(workPlan.WorkOrderId)) { 
                WorkPlan updatedWorkPlan = new WorkPlan(
                    Id = workPlan.Id,
                    Warranty_Prior__c = warrantyMap.get(workPlan.WorkOrderId).Id
                );
                workPlansToUpdate.add(updatedWorkPlan);
            }else{
                System.debug('Conditon False');       
            }
        }
        
        if (!workPlansToUpdate.isEmpty()) {
            update workPlansToUpdate;
        }
    }
*/
    
    public static void handleAfterDelete(List<WorkPlan> deletedWorkPlans) {
        Set<Id> warrantyPriorIds = new Set<Id>();

        // Collect all related Warranty Prior IDs
        for (WorkPlan wp : deletedWorkPlans) {
            if (wp.Warranty_Prior__c != null) {
                warrantyPriorIds.add(wp.Warranty_Prior__c);
            }
        }

        if (!warrantyPriorIds.isEmpty()) {
            // Check if there are any WorkOrderLineItem records linked to these Warranty Prior IDs
            Set<Id> warrantyWithWorkOrders = new Set<Id>();
            for (AggregateResult ar : [
                SELECT Warranty_Prior__c FROM WorkOrderLineItem 
                WHERE Warranty_Prior__c IN :warrantyPriorIds 
                GROUP BY Warranty_Prior__c
            ]) {
                warrantyWithWorkOrders.add((Id) ar.get('Warranty_Prior__c'));
            }

            // Identify Warranty_Prior__c records that have no WorkOrderLineItem records
            Set<Id> warrantiesToDelete = new Set<Id>(warrantyPriorIds);
            warrantiesToDelete.removeAll(warrantyWithWorkOrders);

            if (!warrantiesToDelete.isEmpty()) {
                List<Warranty_Prior__c> warrantiesToDeleteList = [
                    SELECT Id FROM Warranty_Prior__c WHERE Id IN :warrantiesToDelete
                ];
                delete warrantiesToDeleteList;
            }
        }
    }
}