public without sharing class Check_PDI_Item_Screen_Controller {
    @AuraEnabled(cacheable=false)
    public static List<Pre_Delivery_Inspection_Item__c> fetchPDIItems(Id recordId){
        return [Select Id, Name, Check__c, Pre_Delivery_Inspection__c, Pre_Delivery_Inspection__r.Parameter__c, Pre_Delivery_Inspection__r.Description__c, Pre_Delivery_Inspection__r.Attribute__c, Asset_Milestone__c from Pre_Delivery_Inspection_Item__c Where Asset_Milestone__r.VehicleId = :recordId ORDER BY Pre_Delivery_Inspection__r.Attribute__c];
    }

    @AuraEnabled
    public static List<Pre_Delivery_Inspection_Item__c> updatePDIItmes(Id recordId){
        List<Pre_Delivery_Inspection_Item__c> updatedItems = new List<Pre_Delivery_Inspection_Item__c>();
        List<Pre_Delivery_Inspection_Item__c> pdIItems = [Select Id, Name, Check__c, Asset_Milestone__c from Pre_Delivery_Inspection_Item__c Where Asset_Milestone__r.VehicleId = :recordId];
        if(pdIItems != null && pdIItems.size() > 0){
            for(Pre_Delivery_Inspection_Item__c item : pdIItems){
                Pre_Delivery_Inspection_Item__c newItem = new Pre_Delivery_Inspection_Item__c();
                newItem.Id = item.Id;
                newItem.Check__c = true;
                updatedItems.add(newItem);
            }
        }
        if(updatedItems != null && updatedItems.size() > 0){
            update updatedItems;

            // Update Vehicle PDI Status
            Vehicle vac = new Vehicle();
            vac.Id = recordId;
            vac.PDI_Status_Pass__c = true;

            update vac;
        }
        return updatedItems;
    }

    @AuraEnabled 
    public static String getPdfFileAsBase64String(String vehicleId) {
        PageReference pdfPage = Page.Check_pdi_item_screen_pdf;
        pdfPage.getParameters().put('id',vehicleId);
        // Blob pdfBlob = pdfPage.getContent();
        // String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return pdfPage.getUrl();
    }

    // @AuraEnabled(cacheable=false)
    // public static List<Vehicle_Recall__c> fetchVehicleRecall(Id recordId){
    //     return [Select Id, Name, Labor_Code__c, Part_Number__c, Recall_Bypass__c, Vehicle__c from Vehicle_Recall__c Where Vehicle__c = :recordId];
    // }

    // @AuraEnabled(cacheable=false)
    // public static Boolean sendRecallRequest(Id recordId){
    //     List<Vehicle> vehicleList = [Select Id, Name from Vehicle Where ID =:recordId];
    //     if(vehicleList != null && vehicleList.size() > 0){
    //         Vehicle vehicleRecord = vehicleList[0];
    //         // Define the email service address
    //         String toAddress = System.Label.Service_Team_Email;
    
    //         // Create a new SingleEmailMessage object
    //         Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    
    //         // Set the recipients
    //         email.setToAddresses(new String[] {toAddress});
    
    //         // Set the email subject
    //         email.setSubject('Vehicle Recall Request for '+vehicleRecord.Name);
    
    //         // Set the email body
    //         String body = '<p>Dear Service Team,</p><br/><br/>';
    //         body += '<p>We would like to inform you that a recall request has been raised for a vehicle <strong>'+vehicleRecord.Name+'</strong>.</p>'+
    //                 +'<p>Please take immediate action to address this recall request and ensure that all necessary steps are taken to resolve the issue promptly.</p>'+
    //                 +'<p>Thank you for your attention to this matter.</p>';       
    //         email.setHtmlBody(body);
    
    //         // Send the email
    //         Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    
    //         // Check if the email was sent successfully
    //         if (result[0].success) {
    //             System.debug('Email sent successfully.');
    //             return true;
    //         }
    //         System.debug('Failed to send email: ' + result[0].errors[0].message);
    //         return false;
    //     }
    //     return false;

    // }
}