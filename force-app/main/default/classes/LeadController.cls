public without sharing class LeadController {
    @AuraEnabled(cacheable=true)
    public static Lead getLeadByPhone(String phoneNumber) {
        List<Lead> leads = [SELECT Id, Name, Phone, Owner.Name, Company, Status
                            FROM Lead WHERE Phone = :phoneNumber AND OwnerId != :UserInfo.getUserId() LIMIT 1];
        return leads.isEmpty() ? null : leads[0];
    }

@AuraEnabled
public static String submitLeadForApproval(Id leadId) {
    System.debug('### Entering submitLeadForApproval method');

    try {
        // 1️⃣ Fetch the Lead record along with Dealer_Code__c
        System.debug('### Fetching Lead record for Id: ' + leadId);
        Lead leadRecord = [SELECT Id, OwnerId, Dealer_Code__c FROM Lead WHERE Id = :leadId LIMIT 1];

        // 2️⃣ Fetch any existing Lead Transfer History record in one query
        Map<Id, Lead_Transfer_History__c> transferRecordMap = new Map<Id, Lead_Transfer_History__c>(
            [SELECT Id, Status__c, Lead__c, Dealer_Code__c  
             FROM Lead_Transfer_History__c 
             WHERE Lead__c = :leadId 
             LIMIT 1]
        );

        User currentUser = [SELECT Id, ManagerId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

        Lead_Transfer_History__c transferRecord;

        if (!transferRecordMap.isEmpty()) {
            transferRecord = transferRecordMap.values()[0];  // Retrieve the first value
            transferRecord.Status__c = 'Approved';
            transferRecord.Approval_Date__c = System.today();
            transferRecord.New_Owner__c = UserInfo.getUserId();

            System.debug('### Updating existing Lead Transfer History record: ' + transferRecord.Id);
            update transferRecord;
        } else {
            // 3️⃣ Create a new Transfer Lead History record if no existing record found
            System.debug('### Creating a new Lead Transfer History record');
            transferRecord = new Lead_Transfer_History__c();
            transferRecord.Lead__c = leadId;
            transferRecord.Requested_By__c = UserInfo.getUserId();
            transferRecord.Old_Owner__c = leadRecord.OwnerId;
            transferRecord.Manager__c = currentUser.ManagerId;
            transferRecord.Status__c = 'Approved';
            transferRecord.Approval_Date__c = System.today();
            transferRecord.New_Owner__c = UserInfo.getUserId();
            
            insert transferRecord;
        }

        // if(transferRecord.Dealer_Code__c!=null){
        //     leadRecord.Dealer_Code__c = transferRecord.Dealer_Code__c;
        //     update leadRecord;
        // }else{
        //     leadRecord.OwnerId = UserInfo.getUserId();
        //     update leadRecord;
        // }



      //  System.debug('### Lead Transfer History record ready for approval with Id: ' + transferRecord.Id);

        // 4️⃣ Submit the Transfer Lead History record for Approval (kept commented as per request)
        // System.debug('### Initiating Approval Process for Transfer Lead History Id: ' + transferRecord.Id);
        // Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        // req.setComments('Resubmitting Transfer Lead Request for approval.');
        // req.setObjectId(transferRecord.Id);
    
        // Approval.ProcessResult result = Approval.process(req);
        // System.debug('### Approval process result: ' + result);
    
        // if (result.isSuccess()) {
        //     System.debug('### Approval process submitted successfully!');
        //     return 'Transfer request submitted successfully!';
        // } else {
        //     System.debug('### Approval process failed.');
        //     return 'Approval process failed.';
        // }

        return 'successfully';
    } catch (Exception e) {
        System.debug('### Error occurred: ' + e.getMessage());
        return 'Error: ' + e.getMessage();
    }
}

    
    
    
}