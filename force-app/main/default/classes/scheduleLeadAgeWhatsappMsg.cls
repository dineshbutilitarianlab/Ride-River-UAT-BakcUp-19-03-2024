/**
 * @description       : 
 * @author            : Aniket Karmkar
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class scheduleLeadAgeWhatsappMsg implements Schedulable{
    public void execute(SchedulableContext sc) {
        List<Id> ledIdsToPass = new List<Id>();
        Map<Id,String> idToPhoneMap = new Map<Id,String>();
        // Set<Id> leadIdsFortestDrive = new Set<Id>();

        Set<String> storeDealerCodes = new Set<String>();
        List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
        for(Store_Details__mdt s : dealerCodes){
            storeDealerCodes.add(s.Dealer_Code__c);
        }
        System.debug('dealerCodes==>'+dealerCodes);

        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.no_action_book_test_ride_03__c;
        String templateName = 'no_action_book_test_ride_03';

        List<Lead> leadList = [SELECT Id,Name,Dealer_Code__c,Lead_Dealer_Code__c,Lead_Age__c,LeadSource,Phone,(Select Id from Test_Drives__r) FROM Lead Where Lead_Age__c = 0 And (Dealer_Code__c IN:storeDealerCodes OR Lead_Dealer_Code__c IN:storeDealerCodes)];

        System.debug('leadList==>'+leadList);

        // for(Lead l : leadList){
        //     leadIdsFortestDrive.add(l.Id);
        // }
        // List<Test_Drive__c> testDriveList = [Select id,Lead__c from Test_Drive__c where Lead__c IN:leadIdsFortestDrive];
        //System.debug('testDriveList==>'+testDriveList);

        for(Lead lead : leadList){
            System.debug('lead ===> ' + lead);
            if(lead.Phone != null && lead.Test_Drives__r.size()==0 &&(lead.LeadSource == 'Bike Dekho' ||lead.LeadSource == 'Facebook'||lead.LeadSource == 'Google'||lead.LeadSource == '91Wheels')){
                ledIdsToPass.add(lead.Id);
                idToPhoneMap.put(lead.Id,lead.Phone);
            }
        }
        if(ledIdsToPass != null && templateName != null && imageUrl != null && idToPhoneMap != null ){
            System.enqueueJob(new QueueableForImageTemplateMsg(ledIdsToPass, templateName, imageUrl, idToPhoneMap));
        }
    }
}