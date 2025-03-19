global class EmailToLead2 implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){

        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';

        // Add the email plain text into the local variable  
        myPlainText = email.plainTextBody;

        // Check for existing leads with this email address   
        Lead[] leads = [SELECT Id, Name,firstname,lastname,title,description, Email
                        FROM Lead
                        WHERE Email = :email.fromAddress AND title =:email.subject];

        if (leads.isEmpty()) {
            
            Lead newLead = new Lead();
            newLead.Email = email.fromAddress; 
            newLead.LastName = email.fromName;
            newLead.Company = email.fromName;
            newLead.LeadSource = 'Email-To-Lead';
            newLead.Description = email.plainTextBody;
            newLead.Title = email.subject;
            
            // Insert a new lead
            try{
                insert newLead;
            }catch(exception e){
                
            }
                

            System.debug('New Lead record: ' + newLead );   
        } else {
            System.debug('Incoming email duplicates existing Lead record(s): ' + leads );    
        }

            
        // with an error message   
        result.success = true;

        // Return the result for the Apex Email Service 
        return result;
    }
}