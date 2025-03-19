global class ScheduleServiceReminderEmailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext context) {
        // Get All Service Appointments where Duedaste should be prior 1 day.
		String milestoneSoql = 'SELECT id, Vehicle__r.name, Vehicle__r.CurrentOwner.Name, Vehicle__r.CurrentOwner.Email__c, DueDate, Appointment_Date__c, Vehicle__r.Dealer__r.Phone from ServiceAppointment where Appointment_Date__c = TOMORROW  and Status = \'Scheduled\' AND Vehicle__r.Dealer__r.Phone != NULL AND Vehicle__r.CurrentOwner.Email__c != NULL';
        return Database.getQueryLocator(milestoneSoql);
    }
    
    global void execute(Database.BatchableContext context, List<ServiceAppointment> scope) {
        
        if(!scope.isEmpty()) {
            List<Messaging.SingleEmailMessage> bulkEmails = new List<Messaging.SingleEmailMessage>();
            
            for(ServiceAppointment appo : scope) {
                Messaging.SingleEmailMessage serviceEmail = new Messaging.SingleEmailMessage();
                List<String> sendToAddressesList = new List<String>();
                sendToAddressesList.add(appo.Vehicle__r.CurrentOwner.Email__c); 
                serviceEmail.setToAddresses(sendToAddressesList);
            	
                serviceEmail.setSubject('Reminder: Your Vehicle Service is Due Soon!');
                String body = 'Dear '+appo.Vehicle__r.CurrentOwner.Name+',<br/><br/>';
                body += 'We hope this message finds you well. This is a gentle reminder that your vehicle is due for its scheduled service on '+appo.Appointment_Date__c.toString().split(' ')[0]+'. Regular maintenance ensures the optimal performance and longevity of your vehicle, and we’re here to assist you in keeping it in top condition. Ensuring that your vehicle receives regular maintenance not only helps prevent unexpected issues but also preserves the warranty coverage provided by the manufacturer.<br/><br/>';
                body += 'To schedule your service appointment, please contact our service department at '+'<span style="background-color:yellow;">+91 '+appo.Vehicle__r.Dealer__r.Phone+'</span>'+'. Our team will be happy to assist you in selecting a convenient time for your service.<br/><br/>';
                body += 'Thank you for choosing '+appo.Vehicle__r.Name+'. We look forward to serving you soon.<br/><br/>';
                body += 'Warm regards,<br/><br/>';
                body += '<img src="https://rivermobilityprivatelimited2--riverdev.sandbox.file.force.com/sfc/dist/version/renditionDownload?rendition=ORIGINAL_Png&versionId=0680T0000025U2m&operationContext=DELIVERY&contentId=05T0T000006rUxr&page=0&d=/a/0T0000009wp9/yFYNT7wN42ZGE4fO2AjOkbtkiLPcKxiFQXYbUBybZR8&oid=00D0T0000000eGD&dpt=null&viewId=" alt="logo">';
                body += '<br/><br/>River Mobility Pvt Ltd';
     
                serviceEmail.setHtmlBody(body);
                bulkEmails.add(serviceEmail);   
        	}
            
        	Messaging.sendEmail(bulkEmails);
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
    }
}