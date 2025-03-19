public with sharing class WorkOrderController {
    @AuraEnabled(cacheable=true)
    public static String getWorkOrderStatus(Id workOrderId) {
        WorkOrder wo = [SELECT Status FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
        return wo.Status;
    }
}