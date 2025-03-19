public with sharing class BatchRecordController {
   
    @AuraEnabled(cacheable=true)
    public static Contact getCurrentUserContact() {
        try {
           
            String currentUserId = UserInfo.getUserId();
            System.debug('Current User ID: ' + currentUserId);
 
            User currentUser = [SELECT ContactId FROM User WHERE Id = :currentUserId LIMIT 1];
            System.debug('ContactId from User: ' + currentUser.ContactId);
 
            if (currentUser.ContactId == null) {
                System.debug('No associated contact found for the current user.');
                throw new AuraHandledException('No associated contact found for the current user.');
            }
            Contact userContact = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];
 
            System.debug('Contact Retrieved: ' + userContact);
            return userContact;
            } catch (QueryException e) {
                System.debug('QueryException occurred: ' + e.getMessage());
                throw new AuraHandledException('No associated contact found for the current user.');
            } catch (Exception ex) {
                System.debug('Unexpected Exception: ' + ex.getMessage());
                throw new AuraHandledException('An unexpected error occurred.');
            }
    }
 
    @AuraEnabled(cacheable=true)
    public static List<Claim> fetchClaims() {
        try {
            List<Claim> claims = [SELECT Id, Name, Total_Claim_Amount__c FROM Claim WHERE Create_Batch__c = NULL AND Status = 'Submitted'];
            System.debug('Fetched claims:::' + claims);
            return claims;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching claims: ' + e.getMessage());
        }
    }
 
    @AuraEnabled
    public static Id createBatchAndTagClaims(
        List<Id> claimIds, Date batchDispatchDate, String lrNumber, String lrAttachment, String TOD,
        String AOC, String RN, String VN, String HPS, String Phone,
        String POS, String TN, String TID, String Eway, String MOT, String purpose) {
        System.debug('Entering createBatchAndTagClaims method.');
 
        if (claimIds == null || claimIds.isEmpty()) {
            throw new AuraHandledException('No claims selected.');
        }
        // if (batchDispatchDate == null) {
        //     throw new AuraHandledException('Batch dispatch date is required.');
        // }
 
        try {
            System.debug('Validations passed. Proceeding with batch creation.');
           
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
 
            String profileName = System.Label.CQA_Profile;
            User usr = [SELECT Id, Email FROM User WHERE Profile.Name = :profileName AND IsActive = TRUE LIMIT 1];
            System.debug('Queried CQA Profile User: ' + usr);
 
            if (usr == null) {
                throw new AuraHandledException('No active user found with the CQA Profile.');
            }
 
            List<CustomNotificationType> customNotiList = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Notification_To_Record_Owner'];
            System.debug('Queried CustomNotificationType list size: ' + customNotiList.size());
 
            if (customNotiList.isEmpty()) {
                throw new AuraHandledException('Custom Notification Type not found.');
            }
 
            List<Claim> selectedClaims = [
                SELECT Id, Total_Claim_Amount__c FROM Claim WHERE Id IN :claimIds];
            System.debug('Queried selected claims: ' + selectedClaims);
 
            Decimal batchAmount = 0;
            for (Claim claim : selectedClaims) {
                batchAmount += claim.Total_Claim_Amount__c;
            }
            System.debug('Calculated total batch amount: ' + batchAmount);
 
            Create_Batch__c newBatch = new Create_Batch__c(
                Batch_Amount__c = batchAmount,
                Batch_Created_Date__c = Date.today(),
                Batch_Dispatch_Date__c = batchDispatchDate,
                LR_Number__c = lrNumber,
                Status__c = 'New',
                LR_Attachment__c = lrAttachment,
                Terms_of_Delivery__c = TOD,
                Address_of_Consignee__c = AOC,
                Requestor_Name__c = RN,
                Vehicle_No__c = VN,
                Handover_Person_Store__c = HPS,
                Phone__c = Phone,
                Purpose_of_Sending__c = POS,
                Transport_Name__c = TN,
                Transporter_ID__c = TID,
                E_Way_Bill_No__c = Eway,
                Mode_of_Transport__c = MOT,
                Purpose__c = purpose
            );
            insert newBatch;
            System.debug('Inserted new batch record with ID: ' + newBatch.Id);
             String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
 
             String claimDetails = '';
            for (Claim claim : selectedClaims) {
                claimDetails += 'Claim Id: ' + claim.Id + '\n';
            }
 
          /*  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject('New Batch Came to Claim');
            email.setPlainTextBody( 'Hi,\n\n' +
            'The following claims have been assigned to you for review. Please approve or reject them:\n\n' +
            claimDetails +
            '\nRegards,\nYour System') ;
            email.setToAddresses(new List<String>{usr.Email});
            email.setSaveAsActivity(true);
            email.setWhatId(newBatch.Id);
            mailList.add(email);
 
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
                System.debug('Email sent successfully to: ' + usr.Email);
            } */
 
           
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Batch Processed!');
            notification.setBody('Batch Processed for Claim Coverage.');
            notification.setNotificationTypeId(customNotiList[0].Id);
            notification.setTargetId(newBatch.Id);
            notification.send(new Set<String>{usr.Id});
            System.debug('Custom notification sent successfully to user ID: ' + usr.Id);
 
            for (Claim claim : selectedClaims) {
                claim.Create_Batch__c = newBatch.Id;
                claim.Status = 'Under Review';
            }
            update selectedClaims;
            System.debug('Claims updated successfully with new batch ID.');
 
            return newBatch.Id;
 
        } catch (Exception e) {
            System.debug('Error occurred: ' + e.getMessage());
            throw new AuraHandledException('Error creating batch: ' + e.getMessage());
        }
    }
}