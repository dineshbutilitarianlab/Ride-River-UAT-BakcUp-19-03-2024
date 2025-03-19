public with sharing class cardsComponentController {
    
    @AuraEnabled(cacheable = true)
    public static String fetchOnLoadData(String userId) {
        if(userId != null){
            User user = [SELECT Id, ContactId FROM User WHERE Id =: userId];
            if(user.ContactId != null){
                Contact ct = [SELECT Id, Role_Type__c FROM Contact WHERE  Id =: user.ContactId];
                return ct.Role_Type__c;
            }
            return 'No Contact associated with this user.';
        }
        return 'userID not provided.';
    }
}