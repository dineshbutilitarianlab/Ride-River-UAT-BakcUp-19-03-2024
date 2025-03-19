trigger LeadTransferHistoryTrigger on Lead_Transfer_History__c (after insert,after update) {
   LeadTransferHistoryHandler.updateLeadOwner(Trigger.new, Trigger.oldMap);
}