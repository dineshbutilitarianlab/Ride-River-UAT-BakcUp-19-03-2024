/**
 * @description       :
 * @author            : Aniket Karmakar
 * @group             :
 * @last modified on  : 02-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public with sharing class ScheduleQueueableOnTheDayOfTestDrive implements Schedulable{
    public void execute(SchedulableContext sc){
        Date twoDaysAgo = Date.today();
        DateTime startOfDay = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        DateTime endOfDay = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 999));
        
        String templateName = 'on_day_of_test_ride2';
        
        List<Id> testDriveIdsforHome = new List<Id>();
        Map<Id,String> idToPhoneMapForHome = new Map<Id,String>();
        String parameterForHome;
        
        List<Id> testDriveIdsforStore = new List<Id>();
        Map<Id,String> idToPhoneMapForStore = new Map<Id,String>();
        Map<Id,String> testDriveIdToStoreMap = new Map<Id, String>();
        
        
        Set<String> dealerCodeSet = new Set<String>();
        Map<String,String> codeByStoreMap = new Map<String,String>();

        //further code on 04/02/2025 By Aniket 
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.on_day_of_test_ride2__c;
        
        List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c,Name__c From Store_Details__mdt WHERE IsActive__c = true];
        
        for(Store_Details__mdt s : dealerCodes){
            dealerCodeSet.add(s.Dealer_Code__c);
            codeByStoreMap.put(s.Dealer_Code__c,s.Name__c);
        }
        List<Test_Drive__c> testDrives = [SELECT Id, Lead__c, Test_Ride_Date__c,Lead__r.Dealer_Code__c,Lead__r.Lead_Dealer_Code__c, Ride_Type__c,Lead__r.LeadSource,Lead__r.Phone FROM Test_Drive__c
                                            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay];
        
        for (Test_Drive__c t : testDrives) {
            if (t.Ride_Type__c == 'Home Ride') {
                testDriveIdsforHome.add(t.Id);
                idToPhoneMapForHome.put(t.Id, t.Lead__r.Phone);
                parameterForHome = 'Your doorstep';
            } else if (t.Ride_Type__c == 'Store Ride') {
                testDriveIdsforStore.add(t.Id);
                idToPhoneMapForStore.put(t.Id, t.Lead__r.Phone);
                String store;
                if(t.Lead__r.Dealer_Code__c == null){
                    store = codeByStoreMap.get(t.Lead__r.Lead_Dealer_Code__c);
                }else{
                    store = codeByStoreMap.get(t.Lead__r.Dealer_Code__c);
                } 
                testDriveIdToStoreMap.put(t.Id, store);
            }
        }
        
        if (!testDriveIdsforHome.isEmpty()) {
            System.enqueueJob(new QueueableOnDayOfTestRide(testDriveIdsforHome, templateName, parameterForHome, idToPhoneMapForHome, null,imageUrl));
        }
        if (!testDriveIdsforStore.isEmpty()) {
            System.enqueueJob(new QueueableOnDayOfTestRide(testDriveIdsforStore, templateName, null, idToPhoneMapForStore, testDriveIdToStoreMap,imageUrl));
        }
        
        
        //need to change this part
        //     for(Test_Drive__c td:testDrives){
            //             list<lead> leaddetails=[select Id ,LeadSource,Dealer_Code__c,phone from Lead where Id=:td.Lead__c and Dealer_Code__c IN:dealerCodeSet];
            //                   for(lead leadid:leaddetails){
                //                           string parameter;
                //                                   string recientphoneno=leadid.Phone;
                //                                   string fullrecientphoneno='91'+recientphoneno;
                //                             if(leadid.LeadSource!='OzoneTel WhatsApp'){//Need to change the LeadSource As per further input
                    //                                 system.debug('phone'+fullrecientphoneno);
                    //                                     if(td.Ride_Type__c=='Home Ride'){
                        //                                            parameter='At Your Doorstep';
                    //                                      }else if(td.Ride_Type__c=='Store Ride'){
                        //                                              parameter=codeByStoreMap.get(leadid.Dealer_Code__c);
                        
                    // }
                // }
            //     }
        //  }
    }
}