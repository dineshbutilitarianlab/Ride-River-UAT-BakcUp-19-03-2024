trigger ServiceAppointmentTrigger on ServiceAppointment (before insert, before update) {
    if(Trigger.isBefore) {
        Set<Id> milestoneIds = new Set<Id>();
        List<ServiceAppointment> newAppointments = new List<ServiceAppointment>();
        Set<Id> newUpdatedAppointments = new Set<Id>();
        
        // Collect Milestone Ids from new Service Appointments
        if(Trigger.isInsert){
            for(ServiceAppointment appointment : Trigger.new) {
                if(appointment.Asset_Milestone__c != null) {
                    milestoneIds.add(appointment.Asset_Milestone__c);
                    newAppointments.add(appointment);
                }
                
                if(appointment.status == 'Completed'){
                    newUpdatedAppointments.add(appointment.id);
                }
            }
        }
        
        if(Trigger.isUpdate){
            for(ServiceAppointment appointment : Trigger.new) {
                if(appointment.Asset_Milestone__c != null && appointment.Asset_Milestone__c != Trigger.oldMap.get(appointment.Id).Asset_Milestone__c) {
                    milestoneIds.add(appointment.Asset_Milestone__c);
                    newAppointments.add(appointment);
                }
                
                if(appointment.status == 'Completed' && Trigger.oldMap.get(appointment.Id).Status != 'Completed'){
                    newUpdatedAppointments.add(appointment.id);
                }
            }
        }
        
    
        // Query existing Service Appointments related to the same Milestones
        Map<Id, Integer> milestoneAppointmentCount = new Map<Id, Integer>();
        for(ServiceAppointment appointment : [SELECT Id, Asset_Milestone__c FROM ServiceAppointment WHERE Asset_Milestone__c IN :milestoneIds]) {
            milestoneAppointmentCount.put(appointment.Asset_Milestone__c, 1);
        }
        
        // Query existing all SA which status marked as complete
        if (!newUpdatedAppointments.isEmpty()) {
            // Query the related WorkOrders
            List<WorkOrder> workOrders = [
                SELECT Id, Status, Service_Appointment__c 
                FROM WorkOrder 
                WHERE Service_Appointment__c IN :newUpdatedAppointments AND Status != 'Completed'
            ];
            

            // Map to keep track of incomplete WorkOrders by ServiceAppointmentId
            Map<Id, List<WorkOrder>> incompleteWorkOrdersMap = new Map<Id, List<WorkOrder>>();

            for (WorkOrder wo : workOrders) {
                //if (wo.Status != 'Completed') {
                    if (!incompleteWorkOrdersMap.containsKey(wo.Service_Appointment__c)) {
                        incompleteWorkOrdersMap.put(wo.Service_Appointment__c, new List<WorkOrder>());
                    }
                    incompleteWorkOrdersMap.get(wo.Service_Appointment__c).add(wo);
                //}
            }

            // Add error to ServiceAppointments with incomplete WorkOrders
            for (ServiceAppointment sa : Trigger.new) {
                if (newUpdatedAppointments.contains(sa.Id) && incompleteWorkOrdersMap.containsKey(sa.Id)) {
                    sa.addError('There are related Work Orders that are not yet Completed.');
                }
            }
        }
    
        // Check if any Milestone already has a related Service Appointment
        for(ServiceAppointment appointment : newAppointments) {
            if(milestoneAppointmentCount.containsKey(appointment.Asset_Milestone__c) && milestoneAppointmentCount.get(appointment.Asset_Milestone__c) > 0) {
                appointment.addError('Only one Service Appointment is allowed per Milestone.');
            }
        }
    }
    
    
}