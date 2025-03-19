public class bulkInsert_CustomerVoiceController {
    @Auraenabled(cacheable=true)
    Public static List<RR_Customer_Voice__c> getVoices(id jcId){
        system.debug('recordId>>>'+jcId);
        List<RR_Customer_Voice__c> voiceList = [SELECT Id,Name,RR_Work_Order__c,RR_Concern_Category__c,RR_Sub_Category__c,RR_Observation_Action_Taken__c FROM RR_Customer_Voice__c WHERE  RR_Work_Order__c =:jcId];
        system.debug('records>>'+voiceList);
        return voiceList;
    }
}