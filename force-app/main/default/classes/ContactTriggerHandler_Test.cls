@isTest
private class ContactTriggerHandler_Test {
    @isTest static void testNull() {
        
        Account acc = new Account();
        acc.Name = 'testing Account';
        acc.Type = 'Customer';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'testing Contact';
        con.AccountId = acc.Id;
        con.Phone = '9123456789';
        con.Email = 'test@test.com';
        con.Primary_Contact__c = true;
        insert con;
    }
}