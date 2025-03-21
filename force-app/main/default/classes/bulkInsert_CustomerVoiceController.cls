public class bulkInsert_CustomerVoiceController {
    @AuraEnabled(cacheable=true)
    public static List<RR_Customer_Voice__c> getVoices(Id jcId) {
        return [SELECT Id, Name, RR_Work_Order__c, RR_Concern_Category__c, RR_Sub_Category__c, RR_Observation_Action_Taken__c 
                FROM RR_Customer_Voice__c 
                WHERE RR_Work_Order__c = :jcId];
    }
}