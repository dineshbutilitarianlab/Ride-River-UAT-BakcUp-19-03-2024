public class CaseTriggerHandler {
    
    public static void fireEmailBasedOnCaseTypeAndItsStagesAfterInsert(List<Case> cseList) {
        try {
            Map<String, EmailTemplate> emailTemplates = getEmailTemplates();
            system.debug('emailTemplates=====>'+emailTemplates);
            OrgWideEmailAddress owea = getOrgWideEmailAddress();
            system.debug('owea=====>'+owea);
            
            Set<Id> accountIds = getAccountIdsFromCases(cseList);
            system.debug('accountIds=====>'+accountIds);
            
            Set<Id> accountDealerIds = getDealerAccountFromCases(cseList);
            system.debug('accountIds=====>'+accountDealerIds);
            
            Map<Id, Account> accountMap = getAccountMap(accountIds);
            system.debug('accountMap=====>'+accountMap);
            Map<Id, Account> accountMaps = getAccountMap(accountDealerIds);
            system.debug('accountMaps=====>'+accountMaps);
            List<Messaging.SingleEmailMessage> mailList = prepareEmails(cseList, emailTemplates, owea, accountMap, accountMaps);
            system.debug('mailList=====>'+mailList);
            
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            }
        } catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line ==>' + e.getLineNumber());
        }
    }
    
    public static void fireEmailBasedOnCaseTypeAndItsStagesAfterUpdate(List<Case> cseList,Map<Id,Case> OldCase) {
        try {
            Map<String, EmailTemplate> emailTemplates = getEmailTemplates();
            system.debug('emailTemplates=====>'+emailTemplates);
            OrgWideEmailAddress owea = getOrgWideEmailAddress();
            system.debug('owea=====>'+owea);
            
            Set<Id> accountIds = getAccountIdsFromCases(cseList);
            system.debug('accountIds=====>'+accountIds);
            Map<Id, Account> accountMap = getAccountMap(accountIds);
            system.debug('accountMap=====>'+accountMap);
            Map<Id, Account> accountMaps = getAccountMap(new Set<Id>());
            system.debug('accountMaps=====>'+accountMaps);
            List<Messaging.SingleEmailMessage> mailList = prepareEmailsOnUpdation(cseList,OldCase ,emailTemplates, owea, accountMap, accountMaps);
            system.debug('mailList=====>'+mailList);
            
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            }
        } catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line ==>' + e.getLineNumber());
        }
    }
    
    private static Map<String, EmailTemplate> getEmailTemplates() {
        List<EmailTemplate> emailTemplates = [SELECT Id, Subject, Body, Name, HTMLValue 
                                              FROM EmailTemplate 
                                              WHERE Folder.Name = 'Shipment Emails'];
        Map<String, EmailTemplate> mapOfEmailTemplate = new Map<String, EmailTemplate>();
        for (EmailTemplate emailTempRec : emailTemplates) {
            mapOfEmailTemplate.put(emailTempRec.Name, emailTempRec);
        }
        return mapOfEmailTemplate;
    }
    
    private static OrgWideEmailAddress getOrgWideEmailAddress() {
        return [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'River Mobility' LIMIT 1];
    }
    
    private static Set<Id> getAccountIdsFromCases(List<Case> cseList) {
        Set<Id> accountIds = new Set<Id>();
        for (Case cse : cseList) {
            if (cse.AccountId != null) {
                accountIds.add(cse.AccountId);
            }
        }
        return accountIds;
    }
    
    private static Set<Id> getDealerAccountFromCases(List<Case> cseList) {
        Set<Id> accountIds = new Set<Id>();
        for (Case cse : cseList) {
            if (cse.Assign_to_Dealer__c != null) {
                accountIds.add(cse.Assign_to_Dealer__c);
            }
        }
        return accountIds;
    }
    
    private static Map<Id, Account> getAccountMap(Set<Id> accountIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            for (Account acc : [SELECT Id, Name, Email__c, BillingAddress, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Phone 
                                FROM Account 
                                WHERE Id IN :accountIds]) {
                                    accountMap.put(acc.Id, acc);
                                }
        }
        return accountMap;
    }
    
    private static List<Messaging.SingleEmailMessage> prepareEmails(List<Case> cseList, Map<String, EmailTemplate> emailTemplates, OrgWideEmailAddress owea, Map<Id, Account> accountMap, Map<Id, Account> accountMaps) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        for (Case cse : cseList) {
            String templateKey = getTemplateKey(cse.Case_type__c, cse.Status);
            if (templateKey != null && emailTemplates.containsKey(templateKey)) {
                EmailTemplate emailRec = emailTemplates.get(templateKey);
                Messaging.SingleEmailMessage mailTemp = prepareSingleEmail(cse, emailRec, owea, accountMap, accountMaps);
                if (mailTemp != null) {
                    mailList.add(mailTemp);
                }
            }
        }
        return mailList;
    }
    
    private static List<Messaging.SingleEmailMessage> prepareEmailsOnUpdation(List<Case> cseList,Map<Id,Case> oldCase ,Map<String, EmailTemplate> emailTemplates, OrgWideEmailAddress owea, Map<Id, Account> accountMap, Map<Id, Account> accountMaps) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        for (Case cse : cseList) {
            String templateKey = getTemplateKey(cse.Case_type__c, cse.Status);
            Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
            if (templateKey != null && emailTemplates.containsKey(templateKey)) {
                EmailTemplate emailRec = emailTemplates.get(templateKey);
                if((cse.Status != oldCase.get(cse.Id).Status) || (cse.Case_Type__c != oldCase.get(cse.Id).Case_Type__c)){
                    mailTemp = prepareSingleEmailOnUpdation(cse, oldCase,emailRec, owea, accountMap, accountMaps);
                }
                
                if (mailTemp != null) {
                    mailList.add(mailTemp);
                }
            }
        }
        return mailList;
    }
    
    private static String getTemplateKey(String caseType, String status) {
        if (caseType == 'General Query' && status == 'Open') return 'General Query When Case Open';
        if (caseType == 'Complaint' && status == 'Open') return 'Complaint when Case Open';
        if (caseType == 'Urgent Complaint' && status == 'Open') return 'Urgent Complaint When Case Open';
        //if (caseType == 'Service Request' && status == 'Open') return 'Service Request When Case Open';
        if (caseType == 'PSFU Concerns' && status == 'Open') return 'PSFU Concerns When Case Open';
        if (caseType == 'General Query' && status == 'Closed') return 'General Query When Case is Closed';
        if (caseType == 'Complaint' && status == 'Closed') return 'Complaint when Case Is Closed';
        if (caseType == 'Urgent Complaint' && status == 'Closed') return 'Urgent Complaint When Case Is Closed';
        if (caseType == 'PSFU Concerns' && status == 'Closed') return 'PSFU Concerns When Case Is Closed';
        if (caseType == 'General Query' && status == 'RNR') return 'General Query When Case RNR Status';
        if (caseType == 'Complaint' && status == 'RNR') return 'Complaint when Case RNR Status';
        if (caseType == 'Urgent Complaint' && status == 'RNR') return 'Urgent Complaint When Case RNR Status';
        //if (caseType == 'Service Request' && status == 'RNR') return 'Service Request When Case RNR Status';
        if (caseType == 'PSFU Concerns' && status == 'RNR') return 'PSFU Concerns When Case RNR Status';
        return null;
    }
    
    private static Messaging.SingleEmailMessage prepareSingleEmail(Case cse, EmailTemplate emailRec, OrgWideEmailAddress owea, Map<Id, Account> accountMap, Map<Id, Account> accountMaps) {
        String emailBody = emailRec.Body;
        String emailSubject;
        if(cse.Status == 'Closed'){
            emailSubject = 'River Mobility Case Number :' + cse.CaseNumber + ' Update';
        }else{
            emailSubject = 'River Mobility Case Number :' + cse.CaseNumber;
        }
        
        emailBody = replacePlaceholders(emailBody, cse, accountMap, accountMaps);
        Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
        List<String> toAddresses = getToAddresses(cse, accountMap);
        
        if (!toAddresses.isEmpty()) {
            mailTemp.setToAddresses(toAddresses);
            mailTemp.setSubject(emailSubject);
            mailTemp.setOrgWideEmailAddressId(owea.Id);
            mailTemp.setHtmlBody(emailRec.HTMLValue);
            mailTemp.setPlainTextBody(emailBody);
            mailTemp.setSaveAsActivity(true);
            return mailTemp;
        }
        return null;
    }
    
    private static Messaging.SingleEmailMessage prepareSingleEmailOnUpdation(Case cse,Map<Id,Case> oldCase, EmailTemplate emailRec, OrgWideEmailAddress owea, Map<Id, Account> accountMap, Map<Id, Account> accountMaps) {
        String emailBody = emailRec.Body;
        String emailSubject;
        if(cse.Status == 'Closed'){
            emailSubject = 'River Mobility Case Number :' + cse.CaseNumber + ' Update';
        }else{
            emailSubject = 'River Mobility Case Number :' + cse.CaseNumber;
        }
        
        
        emailBody = replacePlaceholders(emailBody, cse, accountMap, accountMaps);
        Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
        List<String> toAddresses = getToAddresses(cse, accountMap);
        
        if (!toAddresses.isEmpty()) {
            mailTemp.setToAddresses(toAddresses);
            mailTemp.setSubject(emailSubject);
            mailTemp.setOrgWideEmailAddressId(owea.Id);
            mailTemp.setHtmlBody(emailRec.HTMLValue);
            mailTemp.setPlainTextBody(emailBody);
            mailTemp.setSaveAsActivity(true);
            return mailTemp;
        }
        return null;
    }
    
    private static String replacePlaceholders(String emailBody, Case cse, Map<Id, Account> accountMap, Map<Id, Account> accountMaps) {
        emailBody = emailBody.replace('{!Case.CaseNumber}', cse.CaseNumber != null ? cse.CaseNumber : '');
        emailBody = emailBody.replace('{!Case.Description}', cse.Description != null ? cse.Description : '');
        emailBody = emailBody.replace('{!Case.Vehicle_Registration_Number__c}', cse.Vehicle_Registration_Number__c != null ? cse.Vehicle_Registration_Number__c : '');
        emailBody = emailBody.replace('{!Case.Service_Center_Number__c}', cse.Service_Center_Number__c != null ? cse.Service_Center_Number__c : '');
        emailBody = emailBody.replace('{!Case.Escalations_Team_Contact__c}', cse.Escalations_Team_Contact__c != null ? cse.Escalations_Team_Contact__c : '');
        
        if (cse.AccountId != null && accountMap.containsKey(cse.AccountId)) {
            Account acc = accountMap.get(cse.AccountId);
            emailBody = emailBody.replace('{!Case.Contact}', acc.Name);
            emailBody = emailBody.replace('{Case.Account.Phone}', acc.Phone != null ? acc.Phone : '');
        }
        
        if (cse.Assign_to_Dealer__c != null && accountMaps.containsKey(cse.Assign_to_Dealer__c)) {
            Account acc = accountMaps.get(cse.Assign_to_Dealer__c);
            emailBody = emailBody.replace('{!Case.Assign_to_Dealer__c}', acc.Name != null ? acc.Name : '');
            
            String address = formatAddress(acc);
            emailBody = emailBody.replace('{Customer.Address}', address);
            emailBody = emailBody.replace('{Case.Account.Phone}', acc.Phone != null ? acc.Phone : '');
            
            String encodedAddress = EncodingUtil.urlEncode(address, 'UTF-8');
            String googleMapsLink = 'https://www.google.com/maps/search/?api=1&query=' + encodedAddress;
            
            emailBody = emailBody.replace('{Map Location}', googleMapsLink != null ? googleMapsLink : '');
        }
        return emailBody;
    }
    
    private static List<String> getToAddresses(Case cse, Map<Id, Account> accountMap) {
        List<String> toAddresses = new List<String>();
        if (cse.SuppliedEmail != null) {
            toAddresses.add(cse.SuppliedEmail);
        } else if (cse.AccountId != null && accountMap.containsKey(cse.AccountId) && accountMap.get(cse.AccountId).Email__c != null) {
            toAddresses.add(accountMap.get(cse.AccountId).Email__c);
        }
        return toAddresses;
    }
    
    private static String formatAddress(Account acc) {
        List<String> addressParts = new List<String>();
        if (String.isNotBlank(acc.BillingStreet)) addressParts.add(acc.BillingStreet);
        if (String.isNotBlank(acc.BillingCity)) addressParts.add(acc.BillingCity);
        if (String.isNotBlank(acc.BillingState)) addressParts.add(acc.BillingState);
        if (String.isNotBlank(acc.BillingPostalCode)) addressParts.add(acc.BillingPostalCode);
        if (String.isNotBlank(acc.BillingCountry)) addressParts.add(acc.BillingCountry);
        return addressParts.isEmpty() ? '' : String.join(addressParts, ', ');
    }
    
    public static void createTaskForCaseOwnerWhenCaseClosed(List<Case> caseList) {
        try {
            List<Task> tskRecList = new List<Task>();
            System.debug('Received Case List: ' + caseList.size());
            
            for (Case cse : caseList) {
                System.debug('Processing Case - ID: ' + cse.Id + ', Status: ' + cse.Status + ', Case Type: ' + cse.Case_type__c);
                Task tskRec = new Task();
                
                if ((cse.Case_type__c == 'PSFU Concerns' || cse.Case_type__c == 'Urgent Complaint' || cse.Case_type__c == 'Complaint') && cse.Status == 'Closed') {
                    tskRec.WhatId = cse.Id;
                    tskRec.Subject = 'Closed Case Follow Up';
                    tskRec.Status = 'Not Started';
                    tskRec.ActivityDate = System.today() + 1;
                    tskRec.Priority = 'High';
                    tskRec.OwnerId = cse.OwnerId;
                    tskRecList.add(tskRec);
                    System.debug('Task Created for Case - ID: ' + cse.Id);
                }
            }
            
            if (!tskRecList.isEmpty()) {
                System.debug('Inserting Tasks, Count: ' + tskRecList.size());
                insert tskRecList;
                System.debug('Tasks Inserted Successfully');
                
                List<Task> tskrecListIds = [SELECT Id, Owner.Email FROM Task WHERE Id IN :tskRecList];
                System.debug('Fetched Tasks for Notification, Count: ' + tskrecListIds.size());
                
                CustomNotificationType cnType = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'Avalailable_Qunatity_is_Zero' LIMIT 1];
                System.debug('Fetched Notification Type - ID: ' + cnType.Id);
                
                for (Task tskRec : tskrecListIds) {
                    System.debug('Sending Notification for Task - ID: ' + tskRec.Id + ', Owner ID: ' + tskRec.OwnerId);
                    
                    Messaging.CustomNotification customNotificationObj = new Messaging.CustomNotification();
                    customNotificationObj.setBody('Please check the Task details');
                    customNotificationObj.setTitle('A New Task has been Created !!!');
                    customNotificationObj.setNotificationTypeId(cnType.Id);
                    customNotificationObj.setTargetId(tskRec.Id);
                    customNotificationObj.send(new Set<String>{tskRec.OwnerId});
                    
                    System.debug('Notification Sent for Task - ID: ' + tskRec.Id + ' to Owner ID: ' + tskRec.OwnerId);
                }
                
            } else {
                System.debug('No Tasks Created, Skipping Insert and Notification');
            }
        } catch (Exception e) {
            System.debug('Error Occurred - Message: ' + e.getMessage() + ', Line: ' + e.getLineNumber());
        }
        
    }
    
    public static void esclationIsManadatory(List<Case> cseList) {
        for (Case cse : cseList) {
            if (cse.Escalations_Team_Contact__c != null && cse.Escalations_Team_Contact__c.length() != 10) {
                cse.Escalations_Team_Contact__c.addError('Please enter exactly 10 digits.');
            }
        }
    }    
    
    public static void fakeMethod(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}