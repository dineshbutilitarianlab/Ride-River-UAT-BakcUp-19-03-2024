public class DiscrepancyLineItemTriggerHandler {
    public static void validateBeforeUpdate(List<Discrepancy_Line_Item__c> newList, Map<Id, Discrepancy_Line_Item__c> oldMap) {
        for (Discrepancy_Line_Item__c dli : newList) {
            Discrepancy_Line_Item__c oldRecord = oldMap.get(dli.Id);

            
            if (dli.Status__c == 'Under SPM Review' && oldRecord.Status__c != 'Under SPM Review') {
                
                
                if (String.isEmpty(dli.Supporting_Media__c)) {
                    dli.addError('Supporting Media is required before changing status to Under SPM Review.');
                }
            }
        }
    }

    public static void processAfterUpdate(List<Discrepancy_Line_Item__c> newList, Map<Id, Discrepancy_Line_Item__c> oldMap) {
        Set<Id> recordIdsToEmail = new Set<Id>();

        for (Discrepancy_Line_Item__c dli : newList) {
            Discrepancy_Line_Item__c oldRecord = oldMap.get(dli.Id);

            
            if (dli.Status__c == 'Under SPM Review' && oldRecord.Status__c != 'Under SPM Review' && !String.isEmpty(dli.Supporting_Media__c)) {
                recordIdsToEmail.add(dli.Id);
            }
        }

        if (!recordIdsToEmail.isEmpty()) {
           // DiscrepancyLineItemEmailService.sendApprovalEmail(recordIdsToEmail);
        }
    }
}