trigger UpdateAccountContactInfo on Contact (after insert, after update) {
    Set<Id> accountIds = new Set<Id>();
    
    for (Contact cont : Trigger.New) {
        if (cont.Primary_Contact__c == true) {
            accountIds.add(cont.AccountId);
        }
    }
    
    List<Account> accountsToUpdate = new List<Account>();
    for (Account acc : [SELECT Id, Email__c FROM Account WHERE Id IN :accountIds]) {
        Contact primaryContact = [SELECT Id, Email FROM Contact WHERE AccountId = :acc.Id AND Primary_Contact__c = true LIMIT 1];
        if (primaryContact != null && primaryContact.Email != null) {
            acc.Email__c  = primaryContact.Email;
            accountsToUpdate.add(acc);
        }
    }
    update accountsToUpdate;
}