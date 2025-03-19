public class LeadTransferHistoryHandler {
    public static void updateLeadOwner(List<Lead_Transfer_History__c> newRecords, Map<Id, Lead_Transfer_History__c> oldMap) {
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Lead_Transfer_History__c> leadTransfersToUpdate = new List<Lead_Transfer_History__c>();

        for (Lead_Transfer_History__c history : newRecords) {
            //Lead_Transfer_History__c oldHistory = oldMap.get(history.Id);

            // Check if Status changed to 'Approved'
            if (history.Status__c == 'Approved' ) {
                if (history.Lead__c != null && history.Requested_By__c != null) {
                    leadsToUpdate.add(new Lead(
                        Id = history.Lead__c,
                        Dealer_Code__c	 = history.Dealer_Code__c
                    ));
                    
                    leadTransfersToUpdate.add(new Lead_Transfer_History__c(
                        Id = history.Id,
                        New_Owner__c = history.Requested_By__c ,// Assuming there's a field to mark transfer update
                        Approval_Date__c = Datetime.now()
                    ));
                }
            }
        }

        // Perform bulk update
        if (!leadsToUpdate.isEmpty()) {
            try {
                update leadsToUpdate;
                System.debug('### Lead ownership updated successfully! '+leadsToUpdate);
            } catch (Exception e) {
                System.debug('### Error updating Lead owner: ' + e.getMessage());
            }
        }
        
        if (!leadTransfersToUpdate.isEmpty()) {
            try {
                update leadTransfersToUpdate;
                System.debug('### Lead Transfer History updated successfully!');
            } catch (Exception e) {
                System.debug('### Error updating Lead Transfer History: ' + e.getMessage());
            }
        }
    }
}