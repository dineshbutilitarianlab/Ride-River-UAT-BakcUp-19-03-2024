global class PeriodicServiceReminderEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Get All Milestones where MilestoneDate should be prior 10 day.
        Date tenDays = Date.Today().addDays(10);
        Set<String> milestoneTypes = new Set<String>{'1st Service','2nd Service','3rd Service','4th Service','5th Service','6th Service','7th Service','8th Service','9th Service','10th Serviec','11th Service','12th Service','13th Service','14th Service','15th Service','16th Service','17th Service','18th Service'};
		String milestoneSoql = 'SELECT Id, Name, MilestoneDate, Vehicle.CurrentOwnerId, Vehicle.CurrentOwner.Email__c, MilestoneType, Vehicle.CurrentOwner.Name, Vehicle.Name, Vehicle.Dealer__r.Phone FROM AssetMilestone WHERE MilestoneDate =: tenDays AND Stage = \'Tentative\' AND MilestoneType IN :milestoneTypes AND Service_Appointment_Booked__c = false AND Vehicle.Dealer__r.Phone != null AND Vehicle.CurrentOwner.Email__c != NULL';
        return Database.getQueryLocator(milestoneSoql);
    }
    
    global void execute(Database.BatchableContext context, List<AssetMilestone> scope) {
        
        if(!scope.isEmpty()) {
            List<Messaging.SingleEmailMessage> bulkEmails = new List<Messaging.SingleEmailMessage>();
            
            for(AssetMilestone mile : scope) {
                Messaging.SingleEmailMessage milestoneEmail = new Messaging.SingleEmailMessage();
                List<String> sendToAddressesList = new List<String>();
                sendToAddressesList.add(mile.Vehicle.CurrentOwner.Email__c); 
                milestoneEmail.setToAddresses(sendToAddressesList);
            	
                milestoneEmail.setSubject('Reminder: Your Vehicle Service is Due Soon!');
                String body = 'Dear '+mile.Vehicle.CurrentOwner.Name+',<br/><br/>';
                //+91 8277460050
                body += 'We hope this message finds you well. This is a gentle reminder that your vehicle is due for its '+mile.MilestoneType+' on '+mile.MilestoneDate.toString().split(' ')[0]+'. Regular maintenance ensures the optimal performance and longevity of your vehicle, and we’re here to assist you in keeping it in top condition. Ensuring that your vehicle receives regular maintenance not only helps prevent unexpected issues but also preserves the warranty coverage provided by the manufacturer.<br/><br/>';
                body += 'To schedule your service appointment, please contact our service department at '+'<span style="background-color:yellow;">+91 '+mile.Vehicle.Dealer__r.Phone+'</span>'+'. Our team will be happy to assist you in selecting a convenient time for your service.<br/><br/>';
                body += 'Thank you for choosing '+mile.Vehicle.Name+'. We look forward to serving you soon.<br/><br/>';
                body += 'Warm regards,<br/><br/>';
                body += '<img src="https://rivermobilityprivatelimited2--riverdev.sandbox.file.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0680T0000025U2m&operationContext=DELIVERY&contentId=05T0T000006rUxr&page=0&d=/a/0T0000009wp9/yFYNT7wN42ZGE4fO2AjOkbtkiLPcKxiFQXYbUBybZR8&oid=00D0T0000000eGD&dpt=null&viewId=" alt="logo">';
                body += '<br/><br/>River Mobility Pvt Ltd';
     
                milestoneEmail.setHtmlBody(body);
                bulkEmails.add(milestoneEmail);  
                mile.Status__c = 'Reminder Sent'; 
        	}
            
        	Messaging.sendEmail(bulkEmails);
            Update scope;
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}