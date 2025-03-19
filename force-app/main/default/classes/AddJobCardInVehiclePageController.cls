/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class AddJobCardInVehiclePageController {
    @AuraEnabled(cacheable = true)
    public static wrapperForJobCards getVehicleDetails(String recordId){
        try {
            Vehicle v = [Select Id,Account__c,VehicleIdentificationNumber from Vehicle Where Id =: recordId LIMIT 1];
            Account a = [Select Id from Account Where Id=:v.Account__c LIMIT 1];
            Contact c = [Select Id,AccountId from Contact Where AccountId =:a.Id];
            AssetMilestone m = [Select id,MilestoneType,VehicleId from AssetMilestone Where VehicleId=:recordId LIMIT 1];

            wrapperForJobCards w = new wrapperForJobCards();
            w.VehicleId = v.Id;
            w.AccountIds=a.Id;
            w.ContactIds=c.Id;
            w.VIN=v.VehicleIdentificationNumber;
            w.mileStoneType=m.MilestoneType;

            return w;

            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class wrapperForJobCards{
        @AuraEnabled
        public Id VehicleId{get;set;}
        @AuraEnabled
        public Id AccountIds{get;set;}
        @AuraEnabled
        public Id ContactIds{get;set;}
        @AuraEnabled
        public String VIN{get;set;}
        //updation
        @AuraEnabled 
        public String mileStoneType{get;set;}
    }
    @AuraEnabled
    public static String createJobCard(String jobCardData){
        try {
            System.debug('jobCardData===>'+jobCardData);
            Map<String,Object> jobCardMap = (Map<String,Object>) JSON.deserializeUntyped(jobCardData);
            // Id aId = (Id)jobCardMap.get('accId');
            // Account a = [Select id,ParentId from Account Where id =:aId LIMIT 1];
            WorkOrder w = new WorkOrder();
            w.AccountId=(Id)jobCardMap.get('accId');
            w.ContactId=(Id)jobCardMap.get('conId');
            w.vehicle__c=(Id)jobCardMap.get('vehId');
            w.Odometer_Reading__c=(Integer)jobCardMap.get('oRed');
            w.RR_Job_Type__c=(String)jobCardMap.get('jobType');

            insert w;
            System.debug('Inserted WorkOrderId==>'+w.Id);
            return w.Id;
            
        } catch (Exception e) {
            System.debug('Error Message is ==>'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
           
            
        }
    }
}