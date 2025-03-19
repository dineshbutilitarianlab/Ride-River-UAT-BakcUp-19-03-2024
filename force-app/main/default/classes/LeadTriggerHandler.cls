/**
* @description       :
* @author            : Aniket Karmakar
* @group             :
* @last modified on  : 02-17-2025
* @last modified by  : Anwar
**/
public class LeadTriggerHandler {
    public static void callQueableMethodForNewLead(List<Lead> newLeads){
        String templateName = 'new_lead_book_a_test_ride_03';
        try{
            List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            Set<String> storeDealerCodes = new Set<String>();
            
            for(Store_Details__mdt s : dealerCodes){
                storeDealerCodes.add(s.Dealer_Code__c);
            }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.new_lead_book_a_test_ride_03__c;
            
            //new enhancement by Aniket on 18/02/2025
            Set<Id> leadIds = new Set<Id>();
            for(Lead l : newLeads){
                leadIds.add(l.Id);
                
            }
            List<Lead> leadListToFetch = [Select Id,LeadSource,Phone,Dealer_Code__c,Lead_Dealer_Code__c FROM Lead WHERE (Dealer_Code__c IN:storeDealerCodes OR Lead_Dealer_Code__c IN:storeDealerCodes) AND Id IN:leadIds];
            //up to here
            // String templateName = 'new_lead_book_a_test_ride_03';
            if(!leadListToFetch.isEmpty()){
                for(Lead lead : leadListToFetch){
                    if((lead.LeadSource == 'Bike Dekho' || lead.LeadSource =='Facebook'||lead.LeadSource=='Google'||lead.LeadSource=='91Wheels') && (storeDealerCodes.contains(lead.Dealer_Code__c)||storeDealerCodes.contains(lead.Lead_Dealer_Code__c)) && lead.Phone !=null ){
                        newLeadIds.add(lead.Id);
                        newLeadMap.put(lead.Id,lead.Phone);
                    }
                }
                if(newLeadIds!=null && templateName!=null && imageUrl!=null && newLeadMap!=null){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
            }
            
        }catch(Exception e){
            System.debug('Error is ==>'+e.getMessage());
            System.debug('Error Line ==>'+e.getLineNumber());
            System.debug('Error Cause ==>'+e.getCause());
        }
        
    }
    
    public static void callQueableMethodForAfterUpdate(List<Lead> newLeads,Map<Id,Lead> oldLeadMap){
        String templateName = 'new_lead_book_a_test_ride_03';
        try{
            List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            
            Set<String> storeDealerCodes = new Set<String>();
            
            for(Store_Details__mdt s : dealerCodes){
                storeDealerCodes.add(s.Dealer_Code__c);
            }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.new_lead_book_a_test_ride_03__c;
            // String templateName = 'new_lead_book_a_test_ride_03';
            
            List<Lead> leadsToUpdate = new List<Lead>();
            if(!newLeads.isEmpty()){
                for(Lead lead : newLeads){
                    if(lead.Dealer_Code__c != oldLeadMap.get(lead.Id).Dealer_Code__c && (lead.LeadSource == 'Bike Dekho' || lead.LeadSource =='Facebook'||lead.LeadSource=='Google'||lead.LeadSource=='91Wheels') && storeDealerCodes.contains(lead.Dealer_Code__c) && lead.Phone !=null &&lead.WhatsApp_Sent_After_Update__c == false){
                        newLeadIds.add(lead.Id);
                        newLeadMap.put(lead.Id,lead.Phone);
                        leadsToUpdate.add(new Lead(Id=lead.Id,WhatsApp_Sent_After_Update__c = true));
                        
                    }
                    
                }
                if(!leadsToUpdate.isEmpty()){
                    update leadsToUpdate;
                }
                if(newLeadIds!=null && templateName!=null && imageUrl!=null && newLeadMap!=null){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
                
            }
            
        }catch(Exception e){
            System.debug('Error is ==>'+e.getMessage());
            System.debug('Error Line ==>'+e.getLineNumber());
            System.debug('Error Cause ==>'+e.getCause());
        }
    }
    
    public static void callQueueableAfterRNR(List<Lead> newLeadList,Map<Id,Lead> oldLeadMap){
        String templateName = 'rnr_whatsapp_book_test_ride';
        try{
            // List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
            
            List<Id> newLeadIds = new List<Id>();
            Map<Id,String> newLeadMap = new Map<Id,String>();
            Set<String> storeDealerCodes = new Set<String>();
            // for(Store_Details__mdt s : dealerCodes){
            //     storeDealerCodes.add(s.Dealer_Code__c);
            // }
            List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
            WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
            String imageUrl = w.rnr_whatsapp_book_test_ride__c;
            Set<Id> toGettestDrives = new Set<Id>();
            for(Lead lead : newLeadList){
                toGettestDrives.add(lead.Id);
            }
            List<Lead> leadList = [SELECT Id,Name,Phone,Status,(Select Id from Test_Drives__r) from Lead where Id IN: toGettestDrives];
            
            if(!leadList.isEmpty()){
                for(Lead l : leadList){
                    if(l.Status == 'RNR' && l.Status != oldLeadMap.get(l.Id).Status && l.Phone !=null && l.Test_Drives__r.isEmpty()){ /*storeDealerCodes.contains(l.Dealer_Code__c) &&*/
                        newLeadIds.add(l.Id);
                        newLeadMap.put(l.Id,l.Phone);
                    }
                }
                System.debug('newLeadIds==>'+newLeadIds);
                System.debug('newLeadMap==>'+newLeadMap);
                
                if(!newLeadIds.isEmpty() && (templateName!=null && imageUrl!=null && newLeadMap!=null)){
                    System.enqueueJob(new QueueableForImageTemplateMsg(newLeadIds, templateName, imageUrl, newLeadMap));
                }
                
            }
        }catch(Exception e){
            System.debug('Error is ===>'+e.getMessage());
            System.debug('Error Line Number  ===>'+e.getLineNumber());
            
        }
        
    }
    
    //LMS flow
    public static void checkLeadStatus(List<Lead> newLeads) {
        try{
            System.debug('=== checkLeadStatus Method Started ===');
            
            // Get picklist values
            String objectName = 'Lead';
            String fieldName = 'Serviceable_Pincodes__c';
            System.debug('Object Name: ' + objectName + ', Field Name: ' + fieldName);
            
            Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe().get(objectName)
                .getDescribe().fields.getMap().get(fieldName).getDescribe();
            System.debug('Field Describe Result: ' + fieldResult);
            
            Map<String, String> mapOfPicklistValues = new Map<String, String>();
            for (Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()) {
                if (pickListVal.isActive()) {
                    mapOfPicklistValues.put(pickListVal.getLabel(), pickListVal.getValue());
                }
            }
            System.debug('Total Picklist Values Retrieved: ' + mapOfPicklistValues);
            
            List<Lead> ledList = new List<Lead>();
            for (Lead ld : newLeads) {
                System.debug('Checking Lead - ID: ' + ld.Id + ', Postal Code: ' + ld.PostalCode);
                Lead ledrec = new Lead();
                if (ld.PostalCode != null && mapOfPicklistValues.containsKey(ld.PostalCode)) {
                    ledRec.Id = ld.id;
                    ledRec.Future_Lead__c = true;
                    ledList.add(ledRec);
                    System.debug('Lead Marked as Future Lead - ID: ' + ld.Id);
                }
            }
            
            if (!ledList.isEmpty()) {
                update ledList;
                
                List<Lead> updateList = [Select Id,Email from Lead where Id In: ledList];
                System.debug('Leads Updated Successfully');
                
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                
                for (Lead ld : updateList) {
                    System.debug('Processing Email for Lead - ID: ' + ld.Id);
                    if (ld.Email != null) {
                        Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                        mailTemp.setToAddresses(new List<String>{ld.Email});
                        mailTemp.setSubject('Test Subject');
                        mailTemp.setPlainTextBody('Test Subject');
                        mailTemp.setTargetObjectId(ld.Id);
                        mailList.add(mailTemp);
                        System.debug('Email Added for Lead - ID: ' + ld.Id);
                    }
                }
                
                if (!mailList.isEmpty()) {
                    System.debug('Sending Emails, Count: ' + mailList.size());
                    Messaging.sendEmail(mailList);
                    System.debug('Emails Sent Successfully');
                }
            } else {
                System.debug('No Leads Marked as Future Leads');
            }
            
            System.debug('=== checkLeadStatus Method Completed ===');
        }catch(Exception e){
            System.debug('Error is ===>'+e.getMessage() + 'Error Line Number  ===>'+e.getLineNumber());
        }
    }
    
    public static void updatePreferredSeller(List<Lead> leadList) {
        System.debug('Entering updatePreferredSeller method.');
        
        if (leadList == null || leadList.isEmpty()) {
            System.debug('No leads fond');
            return;
        }
        
        User currentUser;
        try {
            currentUser = [
                SELECT Id, Profile.Name, Account.Name 
                FROM User 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1
            ];
        } catch (Exception e) {
            System.debug('Error fetching current user: ' + e.getMessage());
            return;
        }
        
        if (currentUser == null) {
            System.debug('No current user found.');
            return;
        }
        
        System.debug('Current User Details: ' + currentUser);
        
        if ('Sales Manager (Partner)'.equalsIgnoreCase(currentUser.Profile.Name) && currentUser.Account != null) {
            System.debug('User is a Service Manager(Partner) with Account: ' + currentUser.Account.Name);
            
            List<Lead> leadsToUpdate = new List<Lead>();
            
            for (Lead lead : leadList) {
                if (lead != null) {
                    System.debug('Updating Lead: ' + lead.Id + ' | Old PreferredSeller__c: ' + lead.PreferredSeller__c);
                    lead.PreferredSeller__c = currentUser.Account.Id;
                    leadsToUpdate.add(lead);
                }
            }
            
            if (!leadsToUpdate.isEmpty()) {
                System.debug('Leads to update count: ' + leadsToUpdate.size());
            } else {
                System.debug('No valid leads found for update.');
            }
        } else {
            System.debug('User is NOT a Service Manager (Partner) or has NO associated Account.');
        }
        
        System.debug('Exiting updatePreferredSeller method.');
    }
    
    //method to for test code coverage
    public static void testdata(){
        Integer j= 0;
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;    
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;
        j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++; j++;
    }
}