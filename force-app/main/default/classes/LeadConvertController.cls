public with sharing class LeadConvertController {
    
    @AuraEnabled
    public static void convertLead(Id leadId, Id accountId, Id contactId, Boolean createOpportunity) {
        try {
            // Fetch Lead Status for "Converted"
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(leadId);
            lc.setConvertedStatus(convertStatus.MasterLabel);
            lc.setAccountId(accountId); // Use existing or new Account
            lc.setContactId(contactId); // Use existing or new Contact
            lc.setDoNotCreateOpportunity(!createOpportunity); // Toggle whether to create Opportunity
            
            // Perform lead conversion
            Database.LeadConvertResult result = Database.convertLead(lc);
            Id convertAccountId=result.getAccountId();
            Account UpdateType=[select Id ,Type From Account where Id=:convertAccountId];
            UpdateType.Type='Customer';
            Update UpdateType;
            
            if (!result.isSuccess()) {
                throw new AuraHandledException('Lead Conversion failed: ' + result.getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error during Lead Conversion: ' + e.getMessage());
        }
    }
    
    // Method to get Lead information
    @AuraEnabled
    public static Lead getLeadDetails(Id leadId) {
        return [SELECT Id, Name,FirstName,LastName, Company FROM Lead WHERE Id = :leadId LIMIT 1];
    }
    
    public static void setAccountTypeCustomer(List<Lead> updatedLeadList) {
        
        Set<Id> setAccConvIds = new Set<Id>();
        for(Lead objLead : updatedLeadList){
            if(objLead.IsConverted && objLead.ConvertedAccountId !=null ){
                setAccConvIds.add(objLead.ConvertedAccountId);
            }
        }
        List<Account> acclst = [SELECT Id,Name FROM Account WHERE Id=:setAccConvIds];
        for(Account obj : acclst){
            obj.type='Customer';
        }
        if(acclst.size()>0){
            update acclst;
        }
        
    }
    
}