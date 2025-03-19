/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ScheduleIfLeadUnresponsive07Days implements Schedulable{
    public static void execute(SchedulableContext sc){
        Set<Id> leadidstoProcess = new Set<Id>();
        Set<String> storeDealerCodes = new Set<String>();
       
        
        List<Id> leadIdsToPass = new List<Id>();
        String templateName = 'lead_unresponsive_test_ride_done_booking_not_done';
        Map<Id,String> idToPhoneMap = new Map<Id,String>();

        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.lead_unresponsive_test_ride_done_booking__c;

        List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c From Store_Details__mdt WHERE IsActive__c = true];
        for(Store_Details__mdt s : dealerCodes){
            storeDealerCodes.add(s.Dealer_Code__c);
        }
        List<Lead> leadList= [Select id,Status,Dealer_Code__c,Lead_Dealer_Code__c,(Select id from Test_Drives__r) From Lead Where Status != 'Converted' and (Dealer_Code__c IN:storeDealerCodes OR Lead_Dealer_Code__c IN:storeDealerCodes)];
        for(Lead l : leadList){
            if(l.Test_Drives__r.size()>0){
                leadidstoProcess.add(l.Id);
            }
           
        }
        List<Test_Drive__c> testDriveList = [Select id,Name,Test_Ride_Date__c,Lead__c,Lead__r.Phone,Test_Drive_Status__c from Test_Drive__c
                                             WHERE Lead__c IN:leadidstoProcess and Test_Drive_Status__c='Completed' and Lead__c !=null];
        
        System.debug('testDriveList==>'+testDriveList);
        for(Test_Drive__c t : testDriveList){

            Datetime dt = t.Test_Ride_Date__c;
            if(dt != null){
                Date d = dt.date();
                Date todaysDate = Date.Today();
                Integer difference = d.daysBetween(todaysDate);
                System.debug('difference==>'+difference);
                if(difference==7){
                    leadIdsToPass.add(t.Lead__c);
                    idToPhoneMap.put(t.Lead__c,t.Lead__r.Phone);
    
                }
            }
            
            
        }
        System.debug('leadIdsToPass===>'+leadIdsToPass);
        System.debug('idToPhoneMap===>'+idToPhoneMap);
        if(!leadIdsToPass.isEmpty()&& (templateName!=null && imageUrl!=null && idToPhoneMap!=null)){
            System.enqueueJob(new QueueableForImageTemplateMsg(leadIdsToPass,templateName,imageUrl,idToPhoneMap));
        }
    }
}