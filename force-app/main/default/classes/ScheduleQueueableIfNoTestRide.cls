/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class ScheduleQueueableIfNoTestRide implements Schedulable {
    public void execute(SchedulableContext sc){
        DateTime currentTime = DateTime.now();
        DateTime endTime = currentTime.addHours(-4);  
        DateTime startTime = currentTime.addHours(-4).addMinutes(-29); 

        String templateName = 'test_ride_not_taken2';

        //Further code By Aniket on 04/02/2025
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String imageUrl = w.test_ride_not_taken2__c;

        List<Id> tdIdsToProcess = new List<Id>();
        List<Id> leadIdsToFetch = new List<Id>();
        Map<Id,String> idToPhoneMap = new Map<Id,String>();

        List<Test_Drive__c> testDrivesToProcess = [SELECT Id, Test_Ride_Date__c, Test_Drive_Status__c,Lead__r.Phone FROM Test_Drive__c 
                                                  WHERE Test_Ride_Date__c >= :startTime AND 
                                                  Test_Ride_Date__c <= :endTime AND Test_Drive_Status__c = 'Scheduled'];
        for(Test_Drive__c t : testDrivesToProcess){
            tdIdsToProcess.add(t.Id);
            if(t.Lead__c != null && t.Lead__r.Phone != null){
                idToPhoneMap.put(t.Id,t.Lead__r.Phone);
            }
        }
        if(tdIdsToProcess!=null && templateName!=null && imageUrl!=null &&idToPhoneMap!=null){
            System.enqueueJob(new QueueableForImageTemplateMsg(tdIdsToProcess, templateName,imageUrl,idToPhoneMap));
        }
        
        
    }
}