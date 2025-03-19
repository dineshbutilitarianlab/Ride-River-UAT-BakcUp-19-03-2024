trigger UpdateAccountEmail on Contact (after insert, after update) {
    Set<Id> accountIds = new Set<Id>();
    for (Contact cont : Trigger.New) {
        if (cont.Primary_Contact__c == true) {
            accountIds.add(cont.AccountId);
        }
    }
    
    Map<Id, Contact> primaryContacts = new Map<Id, Contact>(
        [SELECT Id, Email, AccountId FROM Contact WHERE AccountId IN :accountIds AND Primary_Contact__c = true]
    );
    
    List<Account> accountsToUpdate = new List<Account>();
    for (Account acc : [SELECT Id, Email__c FROM Account WHERE Id IN :accountIds]) {
        Contact primaryContact = primaryContacts.get(acc.id);
        if (primaryContact != null && primaryContact.Email != null) {
            acc.Email__c = primaryContact.Email;
            accountsToUpdate.add(acc);
        }
    }
}