global class CancelServiceAppointmentsBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Status, DueDate, Asset_Milestone__r.Status__c  FROM ServiceAppointment WHERE DueDate < TODAY AND Asset_Milestone__c != NULL AND Status IN (\'Scheduled\', \'In Progress\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ServiceAppointment> scope) {
        List<ServiceAppointment> appointmentsToUpdate = new List<ServiceAppointment>();
        List<AssetMilestone> milestonesToUpdate = new List<AssetMilestone>();
        
        for (ServiceAppointment sa : scope) {
            // Update the status to 'Canceled'
            sa.Status = 'Lapsed';
            appointmentsToUpdate.add(sa);
            
            if (sa.Asset_Milestone__c != null) {
                AssetMilestone milestone = new AssetMilestone(Id = sa.Asset_Milestone__c, Status__c = 'Service Not Done & Close');
                milestonesToUpdate.add(milestone);
            }
        }

        // Update the records
        update appointmentsToUpdate;
        
        // Update related Asset Milestones
        if (!milestonesToUpdate.isEmpty()) {
            update milestonesToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {
        // Any post-processing logic can be added here if needed
    }
}