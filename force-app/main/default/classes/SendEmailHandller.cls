public class SendEmailHandller {        
    
    public static void SendEmailHandller(list<order> lstOrder, map<id,List<Attachment>> mapOrderIdToAttachments) {
        
        Set<Id> setAccount = new Set<Id>();
        for (Order objOrder : lstOrder) {
            if (objOrder.AccountId != null) {
                setAccount.add(objOrder.AccountId);                
            }
        }
        OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='support@rideriver.com'];
        string senderEmail = orgWideEmailAddresses.Address; 
        
        // Query the necessary fields including AccountId
        List<Order> ordersWithAccountIds = [SELECT Id, AccountId FROM Order WHERE Id IN :setAccount];
        
        Map<string, List<Contact>> mapAccIdToConEmails = New Map<string,List<contact>>();
        List<Contact> lstContact = [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN :setAccount];
        for(Contact con : lstContact) {
            if(con.Email != null && con.Email != '') {
                if(!mapAccIdToConEmails.containsKey(con.AccountId)) {
                    mapAccIdToConEmails.put(con.AccountId, new List<contact>{con});
                } else {
                    mapAccIdToConEmails.get(con.AccountId).add(con);
                }
            }
        }

        system.debug('lstContact==>'+lstContact);
        
        List<Messaging.SingleEmailMessage> Emails = new List<Messaging.SingleEmailMessage>();
        For(order order:lstOrder){
            
            if (mapAccIdToConEmails.get(order.AccountId) != null && mapAccIdToConEmails.get(order.AccountId).size()>0) {
                For(Contact objContact : mapAccIdToConEmails.get(order.AccountId)){
                    
                    // Create a list to store the attachments
                    List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                    
                    // Add the attachments to the list
                    for (Attachment attachment : mapOrderIdToAttachments.get(order.Id)) {
                        Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                        emailAttachment.setFileName(attachment.Name.replace(' ', '_').replace('-', '_'));
                        emailAttachment.setBody(attachment.Body);
                        emailAttachments.add(emailAttachment);
                    }
                    
                    // Create and send the email
                    Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[] {objContact.Email}; // Use the appropriate email field
                        
                    sEmail.setToAddresses(toAddresses);
                    sEmail.setSubject('Exciting News! Your Order is Ready for Registration');
                    String body = 'Hi ' + objContact.Name + ',<br/><br/>';
                    body += 'We are excited to inform you that your Indie with order number ' ;
                    
                    If(order.Website_Order_Id__c != null && order.Website_Order_Id__c != ''){
                        body += order.Website_Order_Id__c;
                    }else{
                        body += order.OrderNumber;
                    }
                        
                    body +=  ' is now ready for registration!<br/>' ;  
                    body += 'Please find your Invoices/Receipts attached with this email.<br/><br/>' ;
                    body += 'Welcome to the River family!<br/><br/>' ;
                    
                    body += 'Warm Regards,<br/>';
                    body += 'Team River';
                    sEmail.setHtmlBody(body);
                    sEmail.setReplyTo(senderEmail);  
                    sEmail.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                    
                    // Attach the list of attachments to the email
                    sEmail.setFileAttachments(emailAttachments);
                    
                    // Send the email  
                    Emails.add(sEmail);
                }
            }
            
        }
        
        try {
            Messaging.sendEmail(Emails);
        } catch(Exception e) {
            System.debug('Exception>>' + e);
        }
    }
    //====================================================================================================================================================================
    
    public static void SendEmailHandller2(list<order>lstOrder, List<Attachment> attachmentsToInsert) {
        //list<order>lstOrder=[select id,OrderNumber,AccountId from Order where Id=:orderId];
        Set<Id> setAccount = new Set<Id>();
        for (Order objOrder : lstOrder) {
            if (objOrder.AccountId != null) {
                setAccount.add(objOrder.AccountId);                
            }
        }
        
        //fetch Org wide email address
        OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='support@rideriver.com'];
        string senderEmail = orgWideEmailAddresses.Address; 
        
        // Query the necessary fields including AccountId
        List<Order> ordersWithAccountIds = [SELECT Id, AccountId FROM Order WHERE Id IN :setAccount];
        
        List<Contact> lstContact = [SELECT Id, Name, Email, AccountId FROM Contact WHERE AccountId IN :setAccount];
        system.debug('lstContact==>'+lstContact);
        
        List<Messaging.SingleEmailMessage> Emails = new List<Messaging.SingleEmailMessage>();
        
        for (Contact objContact : lstContact) {
            if (objContact.Email != null) {
                // Create a list to store the attachments
                List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
                
                // Add the attachments to the list
                for (Attachment attachment : attachmentsToInsert) {
                    Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                    emailAttachment.setFileName(attachment.Name);
                    emailAttachment.setBody(attachment.Body);
                    emailAttachments.add(emailAttachment);
                }
                
                // Create and send the email
                Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {objContact.Email}; // Use the appropriate email field
                    sEmail.setToAddresses(toAddresses);
                sEmail.setSubject('Pre-Order Receipt');
                String body = 'Hi ' + objContact.Name + ',<br/><br/>' ;
                body += '  <strong>We are glad to confirm your River Indie is booking.</strong><br/><br/>';  
                body += ' Your order booking number is  <strong>' + lstOrder[0].Booking_Payment_Id__c + '</strong>.<br/><br/>';  
                body += ' We will notify you on the progress of your order and keep you updated via the mode of communication chosen by you.(We send all our communication via Email, SMS, and Whatsapp).<br/><br/>' ;
                body += 'For any queries you can contact us at - 9731158443 <br/><br/>';
                body += 'Welcome to the River community!<br/><br/>';    
                body += 'Warm Regards,<br/>';
                body += 'Team River';
                sEmail.setHtmlBody(body);
                sEmail.setReplyTo(senderEmail);  
                sEmail.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                
                // Attach the list of attachments to the email
                sEmail.setFileAttachments(emailAttachments);
                
                Emails.add(sEmail);
                // Send the email  
                
            }
            
        }
        try {
            Messaging.sendEmail(Emails);
        } catch(Exception e) {
            System.debug('Exception>>' + e);
        }
    }
    
    // ==============================================================================================================================================================================   
    // Send the Pre_payments Attchamnetnts.
    public static void sendPreAttchamnets(string OrderpaymentId, List<Attachment> attachmentsToInsert){
        set<Id>setAccountId=new set<Id>();
        list<Order_Payment__c>lstOrderPayment=[SELECT Id,name,Order__c,order__r.AccountId,Order__r.OrderNumber,Amount__c,Order__r.Website_Order_Id__c FROM Order_Payment__c  WHERE Id=:OrderpaymentId];
        system.debug('lstOrderPayment==>'+lstOrderPayment);
        system.debug('OrderPayment==>'+lstOrderPayment);
        
        //fetch Org wide email address
        OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='support@rideriver.com'];
        string senderEmail = orgWideEmailAddresses.Address; 
        
        for(Order_Payment__c objOrderPayment :lstOrderPayment){
            if(objOrderPayment.order__r.AccountId!=null){
                setAccountId.add(objOrderPayment.order__r.AccountId); 
            }
        } 
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        list<Contact>lstContact=[select Id, Name,Email,AccountId from contact where AccountId In:setAccountId];
        system.debug('lstContact==>'+lstContact);
        
        //Add attchaments.
        List<Messaging.EmailFileAttachment> emailAttachments = new List<Messaging.EmailFileAttachment>();
        
        // Add the attachments to the list
        for (Attachment attachment : attachmentsToInsert) {
            Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
            emailAttachment.setFileName(attachment.Name);
            emailAttachment.setBody(attachment.Body);
            emailAttachments.add(emailAttachment);
        }
        
        //Send the Email.
        for(contact ObjContact:lstContact){
            if(ObjContact.Email!=null){
                // Create and send the email
                Messaging.SingleEmailMessage sEmail = new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] {objContact.Email}; // Use the appropriate email field
                    sEmail.setToAddresses(toAddresses);
                sEmail.setSubject('Payment Receipt');
                String body = 'Hi ' + objContact.Name + ',<br/><br/>' ;
                body += 'Thank you for making the payment of ' + lstOrderPayment[0].Amount__c + ' for Order ' + lstOrderPayment[0].Order__r.Website_Order_Id__c + '.<br/><br/>' ;
                body += 'Please find your receipts attached with this email.<br/><br/>' ;
                body += 'Warm Regards,<br/>';
                body += 'Team River';
                sEmail.setHtmlBody(body);  
                sEmail.setReplyTo(senderEmail);  
                sEmail.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
                
                // Attach the list of attachments to the email
                sEmail.setFileAttachments(emailAttachments);
                emailMessages.add(sEmail);
            }
        }
        
        if (!emailMessages.isEmpty()){
            try {
                Messaging.sendEmail(emailMessages);
            } catch(Exception e) {
                System.debug('Exception>>' + e);
            }
        }
    }  
}