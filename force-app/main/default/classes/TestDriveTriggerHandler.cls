/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-26-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class TestDriveTriggerHandler {
    public static void afterUpdate(List<Test_Drive__c> newTestDrives,Map<Id,Test_Drive__c> oldTestDriveMap){
        List<Id> whenHTR = new List<Id>();
        Map<Id,String> HTRByLeadPhoneMap = new Map<Id,String>();
        String templateNameforHTR='home_test_ride_done_with_form1';


        List<Id> whenSTR = new List<Id>();
        Map<Id,String> STRByLeadPhoneMap = new Map<Id,String>();
        String templateNameforSTR='store_test_ride_done_with_form1';

        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.test_ride_done__c;

        Set<Id> leadIds = new Set<Id>();

        try{
            for (Test_Drive__c td : newTestDrives) {
                if (td.Test_Drive_Status__c == 'Completed' && oldTestDriveMap.get(td.Id).Test_Drive_Status__c != 'Completed') {
                    if (td.Lead__c != null) {
                        leadIds.add(td.Lead__c);
                    }
                }
            }
            Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, Phone FROM Lead WHERE Id IN :leadIds]);


            for(Test_Drive__c td : newTestDrives){
                if(td.Test_Drive_Status__c == 'Completed' && oldTestDriveMap.get(td.Id).Test_Drive_Status__c !='Completed'){
                    if(td.Ride_Type__c != null && td.Ride_Type__c == 'Home Ride' && td.Lead__c != null){
                        whenHTR.add(td.Id);
                        String phoneNumber = leadMap.get(td.Lead__c).Phone;
                        HTRByLeadPhoneMap.put(td.Id,phoneNumber);
                    }else if(td.Ride_Type__c != null && td.Ride_Type__c == 'Store Ride' && td.Lead__c != null){
                        whenSTR.add(td.Id);
                        String phoneNumber = leadMap.get(td.Lead__c).Phone;
                        STRByLeadPhoneMap.put(td.Id,phoneNumber);
                    }

                }
            }
            
            if (!whenHTR.isEmpty() && (templateNameforHTR!=null && HTRByLeadPhoneMap!=null && imageUrl !=null)) {
                System.enqueueJob(new QueueableForImageTemplateMsg(whenHTR, templateNameforHTR,imageUrl, HTRByLeadPhoneMap));
            }
            if (!whenSTR.isEmpty()&& (templateNameforSTR!=null && STRByLeadPhoneMap!=null && imageUrl !=null)) {
                System.enqueueJob(new QueueableForImageTemplateMsg(whenSTR, templateNameforSTR,imageUrl, STRByLeadPhoneMap));
            }

        }
        catch(Exception e){
            System.debug('Error is ====>'+e.getMessage());
            System.debug('Error Line Number is ==>'+e.getLineNumber());
        }

    }
    public static void afterInsert(List<Test_Drive__c> newTestDrives){
        //dataSet for Home ride
        List<Id> testDriveIdsToProcessForHome = new List<Id>();
        Map<Id,String> idToPhoneNumberMapForHome = new Map<Id,String>();
        Map<Id,String> idToFormattedDateTimeMapForHome = new Map<Id,String>();
        Map<Id,String> rideTypeMapForHome = new Map<Id,String>();

        //dataSet for Store Ride
        List<Id> testDriveIdsToProcessForStore = new List<Id>();
        Map<Id,String> idToPhoneNumberMapForStore = new Map<Id,String>();
        Map<Id,String> idToFormattedDateTimeMapForStore = new Map<Id,String>();
        Map<Id,String> rideTypeMapForStore = new Map<Id,String>();

        //delaer code custom metadata dataset
        List<String> dealerCodes = new List<String>();
        Map<String,String> dealerToStoreNameMap = new Map<String,String>();
        try{
            List<Store_Details__mdt> storeDetails = [Select id,Name__c,Dealer_Code__c,IsActive__c from Store_Details__mdt WHERE IsActive__c = true];
            System.debug('storeDetails==>'+storeDetails);
            for(Store_Details__mdt store : storeDetails){
                dealerCodes.add(store.Dealer_Code__c);
                dealerToStoreNameMap.put(store.Dealer_Code__c,store.Name__c);
            }
            System.debug('dealerCodes==>'+dealerCodes);
            System.debug('dealerToStoreNameMap==>'+dealerToStoreNameMap);

            Set<Id> leadIds = new Set<Id>();
            for (Test_Drive__c t : newTestDrives) {
               if (t.Lead__c != null) {
                   leadIds.add(t.Lead__c);
            }
        }
        
        Map<Id, Lead> leadMap = new Map<Id, Lead>([SELECT Id, LeadSource, Dealer_Code__c,Lead_Dealer_Code__c,Phone FROM Lead WHERE Id IN :leadIds]);


            for (Test_Drive__c t : newTestDrives) {
                if (t.Lead__c != null && leadMap.containsKey(t.Lead__c)) {
                    Lead leadRecord = leadMap.get(t.Lead__c);  
    
                    
                    if (leadRecord != null && /*leadRecord.LeadSource != 'OzoneTel WhatsApp'  &&*/ (dealerCodes.contains(leadRecord.Dealer_Code__c) || dealerCodes.contains(leadRecord.Lead_Dealer_Code__c))) {
    
                        if (t.Ride_Type__c == 'Home Ride') {
                            Datetime dateTimeString = t.Test_Ride_Date__c;
                            String formattedTimeForHome = dateTimeString.format('dd/MM/yyyy');
                            String rideTypeValueForHome = 'the comfort of your home';
    
                            testDriveIdsToProcessForHome.add(t.Id);
                            idToPhoneNumberMapForHome.put(t.Id, leadRecord.Phone);
                            idToFormattedDateTimeMapForHome.put(t.Id, formattedTimeForHome);
                            rideTypeMapForHome.put(t.Id, rideTypeValueForHome);
                        } else if (t.Ride_Type__c == 'Store Ride') {
                            Datetime dateTimeString = t.Test_Ride_Date__c;
                            String formattedTimeForStore = dateTimeString.format('dd/MM/yyyy');
                            //additional condition
                            String rideTypeValueForStore;

                            if(leadRecord.Dealer_Code__c == null){
                              rideTypeValueForStore = dealerToStoreNameMap.get(leadRecord.Lead_Dealer_Code__c);
                            }else{
                              rideTypeValueForStore = dealerToStoreNameMap.get(leadRecord.Dealer_Code__c);
                            }
                            
    
                            testDriveIdsToProcessForStore.add(t.Id);
                            idToPhoneNumberMapForStore.put(t.Id, leadRecord.Phone);
                            idToFormattedDateTimeMapForStore.put(t.Id, formattedTimeForStore);
                            rideTypeMapForStore.put(t.Id, rideTypeValueForStore);
                        }
                    }
                }
            }
            
            System.debug('testDriveIdsToProcessForHome===>'+testDriveIdsToProcessForHome);
            System.debug('testDriveIdsToProcessForStore===>'+testDriveIdsToProcessForStore);

            if(!testDriveIdsToProcessForHome.isEmpty() && (idToPhoneNumberMapForHome!=null && idToFormattedDateTimeMapForHome!=null &&rideTypeMapForHome!=null)){
                System.enqueueJob(new QueueableOnTestDriveCreation(testDriveIdsToProcessForHome,idToPhoneNumberMapForHome,idToFormattedDateTimeMapForHome,rideTypeMapForHome));
            }
            if(!testDriveIdsToProcessForStore.isEmpty()&& (idToPhoneNumberMapForStore!=null && idToFormattedDateTimeMapForStore!=null &&rideTypeMapForStore!=null)){
                System.enqueueJob(new QueueableOnTestDriveCreation(testDriveIdsToProcessForStore,idToPhoneNumberMapForStore,idToFormattedDateTimeMapForStore,rideTypeMapForStore));
            }

        }catch(Exception e){
          System.debug('Error Occured====>'+e.getMessage());
          System.debug('Error Line Number is ==>'+e.getLineNumber());  
        
        }
    }
    //method Added by Aniket(05/02/2025) 
    public static void ifTestRideCancelled(List<Test_Drive__c> newList,Map<Id,Test_Drive__c> oldMapTestDrive){
        String templateName = 'test_ride_not_taken2';

        
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.test_ride_not_taken2__c;

        List<Id> tdIdsToProcess = new List<Id>();
        Map<Id,String> idToPhoneMap = new Map<Id,String>();

        Set<Id> tdIdsForFetchingLead = new Set<Id>();
        try{
           for(Test_Drive__c td : newList){
            if(td.Test_Drive_Status__c == 'Canceled' && td.Test_Drive_Status__c !=oldMapTestDrive.get(td.Id).Test_Drive_Status__c && td.Lead__c !=null){
                tdIdsForFetchingLead.add(td.Lead__c);
            }
        }
        Map<Id,Lead> leadMap = new Map<Id,Lead>([Select Id,Dealer_Code__c,Phone from Lead WHERE Id IN:tdIdsForFetchingLead]);
        System.debug('leadMap==>'+leadMap);
        for(Test_Drive__c t : newList){
            if(t.Test_Drive_Status__c == 'Canceled' && t.Test_Drive_Status__c !=oldMapTestDrive.get(t.Id).Test_Drive_Status__c && t.Lead__c !=null){
                Lead l = leadMap.get(t.Lead__c);
                tdIdsToProcess.add(l.Id);
                idToPhoneMap.put(l.Id,l.Phone);
            
        }
        if(!tdIdsToProcess.isEmpty() && (templateName!=null&&imageUrl!=null &&idToPhoneMap!=null)){
            System.enqueueJob(new QueueableForImageTemplateMsg(tdIdsToProcess, templateName,imageUrl,idToPhoneMap));
        }
        }
            
        }
        catch(Exception e){
            System.debug('Error Occured ==>'+e.getMessage());
            System.debug('Error Line Nyumber ==>'+e.getLineNumber());
        }
            
        }

}