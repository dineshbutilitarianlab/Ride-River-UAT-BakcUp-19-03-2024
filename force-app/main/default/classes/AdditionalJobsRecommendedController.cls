public with sharing class AdditionalJobsRecommendedController {
    private static Boolean emailSent = false;
    
    @AuraEnabled(cacheable=true)
    public static List<RR_Additional_Job_Recommended__c> getAdditionalJobs(Id workOrderId){
        List<RR_Additional_Job_Recommended__c> AddJobs = [SELECT Id,Name,RR_Product__r.Name,RR_Product__r.ProductCode,RR_Work_Order__c,RR_Work_Order__r.WorkOrderNumber,RR_Quantity__c,RR_Description__c,
                                                          RR_Labour_Code__r.Code,RR_Labour_Code__r.RR_Labour_Charge__c,RR_Labour_Code__r.RR_Efforts_Hours__c,CreatedDate, RR_Product__c
                                                          FROM RR_Additional_Job_Recommended__c 
                                                          WHERE RR_Work_Order__c =: workOrderId
                                                          ORDER BY CreatedDate ASC];
        
        return AddJobs;
        
    }
    
    //Fetching the PriceBook entry records dynamically
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDynamicValues(Id productId) {
        Map<String, Object> dynamicValues = new Map<String, Object>();
        
        // Query PricebookEntry to get the price of the product
        List<PricebookEntry> entryList = [SELECT UnitPrice, Product2.Name,Product2.ProductCode
                                          FROM PricebookEntry
                                          WHERE Product2Id = :productId
                                          AND Pricebook2.IsStandard = true
                                          LIMIT 1];
        
        if (entryList.size() > 0) {
            dynamicValues.put('price', entryList[0].UnitPrice);
            dynamicValues.put('productCode', entryList[0].Product2.ProductCode);
        }else{
            throw new auraHandledException('The selected product does not have a price set. Please choose another product.');
        }
        
        return dynamicValues;
    }
    
    //Fetching the labor code details
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getLabourCode(Id codeId) {
        Map<String, String> labourCodeMap = new Map<String, String>();
        
        
        try {
            CodeSet codesetRecord = [SELECT Id, Code,CodeDescription, Name
                                     FROM CodeSet
                                     WHERE Id = :codeId
                                     LIMIT 1];
            
            System.debug('CodeSet Record: ' + codesetRecord);
            
            if (codesetRecord != null) {
                labourCodeMap.put('labourCodeId', codesetRecord.Id);
                labourCodeMap.put('labourCode', codesetRecord.Code);
                labourCodeMap.put('labourCodeDescription', codesetRecord.CodeDescription);
                labourCodeMap.put('Name', codesetRecord.Name);
                
            } else {
                labourCodeMap.put('labourCodeId', null);
                labourCodeMap.put('labourCode', null); // Return null if no record found
                labourCodeMap.put('labourCodeDescription', null); // Return null if no record found
                
            }
        } catch (Exception e) {
            System.debug('Error fetching CodeSet record: ' + e.getMessage());
            labourCodeMap.put('labourCodeId', null);
            labourCodeMap.put('labourCode', null); // Handle exception by returning null
            labourCodeMap.put('labourCodeDescription', null); // Handle exception by returning null
            
        }
        
        System.debug('Labour Code Map: ' + labourCodeMap);
        return labourCodeMap;
    }
    @AuraEnabled
    public static String submitAndSendEmail(Id jobId) {
        if (emailSent) {
            return 'Email already sent';
        }
        system.debug('Method called');
        try{
            // Fetch Work Order related contact email and contact's full name
            WorkOrder relatedWorkOrder = [SELECT ContactId, Contact.Name, Contact.Email, WorkOrderNumber, Vehicle__r.VehicleRegistrationNumber, AccountId
                                          FROM WorkOrder
                                          WHERE Id = :jobId];
            
            // Fetch related additional jobs
            List<RR_Additional_Job_Recommended__c> additionalJobs = [SELECT Id, RR_Labour_Code__c, RR_Product__r.Name, 
                                                                     RR_Quantity__c, RR_Labour_Code__r.Code, 
                                                                     RR_Labour_Code__r.RR_Labour_Charge__c, 
                                                                     RR_Labour_Code__r.RR_Efforts_Hours__c,RR_Labour_Code__r.RR_Efforts_Minutes__c,
                                                                     RR_Work_Order__c, RR_Work_Order__r.WorkOrderNumber
                                                                     FROM RR_Additional_Job_Recommended__c
                                                                     WHERE RR_Work_Order__c = :jobId];
            
            //Fetch Primary Contact
            List<Contact> primaryCon = [SELECT Email, Name FROM contact WHERE AccountId = :relatedWorkOrder.AccountId AND Primary_Contact__c = true LIMIT 1];
            
            String contactFullName = '';
            String contactEmail = '';
            
            // Compose email content
            If(primaryCon.size()>0 && primaryCon[0].Email !=null && primaryCOn[0].Email != ''){
                contactFullName = primaryCon[0].Name;
                contactEmail = primaryCon[0].Email;
            }else{
                contactFullName = relatedWorkOrder.Contact.Name;
                contactEmail = relatedWorkOrder.Contact.Email;
            }
            
            
            
            String emailBody = '<style>table {border-collapse: collapse;} th, td {border: 1px solid black; padding: 8px;border-collapse: collapse;}</style>';
            emailBody += 'Dear ' + contactFullName + ',<br/><p>I hope this email finds you well. We want to bring it to your notice that based on our thorough inspection we would like to update you that in addition to the requested services for your vehicle (' + relatedWorkOrder.Vehicle__r.VehicleRegistrationNumber + '), we have identified some recommended maintenance tasks that we believe are essential to ensure optimal performance and longevity of your vehicle.</p>';
            emailBody += '<p>Before proceeding with any additional services, we wanted to seek your approval. We have outlined the recommended additional jobs below for your reference. Please take a moment to review the recommendations and share your approval to proceed further.</p><br/><table style="border: 1px solid black; border-collapse: collapse;">';
            emailBody += '<tr><th style="border: 1px solid black; border-collapse: collapse;">Work Order</th><th style="border: 1px solid black;border-collapse: collapse;">Product</th><th style="border: 1px solid black;border-collapse: collapse;">Price.(RS)</th><th style="border: 1px solid black;border-collapse: collapse;">Quantity</th><th style="border: 1px solid black;border-collapse: collapse;">Labour Code</th><th style="border: 1px solid black;border-collapse: collapse;">Labour Charge.(RS)</th><th style="border: 1px solid black;border-collapse: collapse;">Efforts Hours</th><th style="border: 1px solid black; border-collapse: collapse;">Efforts Minutes</th><th style="border: 1px solid black;border-collapse: collapse;">Total.(RS)</th></tr>';
            
            Decimal grandTotal = 0;
            
            for (RR_Additional_Job_Recommended__c job : additionalJobs) {
                Decimal productPrice = getProductPrice(job.RR_Product__c);
                String workOrderNumber = job.RR_Work_Order__c != null ? job.RR_Work_Order__r.WorkOrderNumber : 'N/A';
                String productName = job.RR_Product__c != null ? job.RR_Product__r.Name : 'N/A';
                String quantity = job.RR_Quantity__c != null ? String.valueOf(job.RR_Quantity__c) : 'N/A';
                String labourCode = job.RR_Labour_Code__c != null ? job.RR_Labour_Code__r.Code : 'N/A';
                String labourCharge = job.RR_Labour_Code__c != null && job.RR_Labour_Code__r.RR_Labour_Charge__c != null ? String.valueOf(job.RR_Labour_Code__r.RR_Labour_Charge__c) : 'N/A';
                Decimal effortHours = job.RR_Labour_Code__r.RR_Efforts_Hours__c != null ? job.RR_Labour_Code__r.RR_Efforts_Hours__c : 0;
                Decimal effortMinutes = job.RR_Labour_Code__r.RR_Efforts_Minutes__c != null ? job.RR_Labour_Code__r.RR_Efforts_Minutes__c : 0;
                String effortsHours = job.RR_Labour_Code__c != null ? String.valueOf(job.RR_Labour_Code__r.RR_Efforts_Hours__c) : 'N/A';
                String effortsMinutes = job.RR_Labour_Code__c != null ? String.valueOf(job.RR_Labour_Code__r.RR_Efforts_Minutes__c) : 'N/A';
                Decimal totalEffortHours = effortHours + (effortMinutes / 60);
                
                
                Decimal totalAmount = ((productPrice * job.RR_Quantity__c) + 
                                       ((job.RR_Labour_Code__r.RR_Labour_Charge__c != null && job.RR_Labour_Code__r.RR_Efforts_Hours__c != null) 
                                        ? job.RR_Labour_Code__r.RR_Labour_Charge__c * totalEffortHours
                                        : 0)).setScale(2, RoundingMode.HALF_UP);			
                grandTotal+=totalAmount;
                
                emailBody += '<tr><td style="border: 1px solid black;border-collapse:collapse;">' + workOrderNumber + '</td><td style="border: 1px solid black; border-collapse: collapse;">' + productName + '</td><td style="border: 1px solid black; border-collapse: collapse;">' + productPrice + '</td><td style="border: 1px solid black;border-collapse: collapse;">' + quantity + '</td><td style="border: 1px solid black;">' + labourCode + '</td><td style="border: 1px solid black;">' + labourCharge + '</td><td style="border: 1px solid black;">' + effortsHours + '</td><td style="border: 1px solid black;">' +effortsMinutes+ '</td><td style="border: 1px solid black;">'+ totalAmount +'</td> </tr>';
                
            }
            emailBody += '<tr><td colspan="8" style="border: 1px solid black; text-align: right; font-weight: bold;">Total Estimation</td><td style="border: 1px solid black; font-weight: bold;">' + grandTotal + '</td></tr>';
            emailBody += '</table><br/><br/> Once we receive your approval, we will proceed with the repairs. <br/><br/> Best regards,<br/><img src="{!URLFOR($Resource.RideRiverLogo)}"/>  <br/> <i>River Mobility Pvt Ltd<i>';
            
            // Send email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {contactEmail});
            mail.setSubject('Additional Jobs Recommended');
            mail.setHtmlBody(emailBody);
            
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            emailSent = true;
            return 'Email sent successfully';
        } catch (Exception e) {
            // Handle any exceptions
            
            return 'Error sending email: ' + e.getMessage();
        }
    }
    
    
    // Method to fetch product price
    @TestVisible
    private static Decimal getProductPrice(Id productId) {
        Decimal productPrice = 0;
        
        // Query PricebookEntry to get the price of the product
        List<PricebookEntry> entry = [SELECT UnitPrice
                                      FROM PricebookEntry
                                      WHERE Product2Id = :productId
                                      AND Pricebook2.IsStandard = true
                                      LIMIT 1];
        
        if (entry.size()>0) {
            productPrice = entry[0].UnitPrice;
        }
        
        return productPrice;
    }
    
}