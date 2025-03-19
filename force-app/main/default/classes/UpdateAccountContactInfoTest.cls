@isTest
public class UpdateAccountContactInfoTest {
    @testSetup
    static void setup() {
        // Create a test account
        Account testAccount = new Account(Name='Test Account');
        insert testAccount;
        
        // Create a test contact with a phone number
        Contact testContact = new Contact(
            FirstName='Test',
            LastName='Contact',
            Email='test@example.com',
            Phone='1234567890', // Add a phone number
            AccountId=testAccount.Id,
            Primary_Contact__c=true
        );
        insert testContact;
    }
    
    @isTest
    static void testUpdateAccountEmail() {
        // Verify that the account email was updated
        Account testAccount = [SELECT Id, Email__c FROM Account WHERE Name='Test Account'];
        System.assertEquals('test@example.com', testAccount.Email__c);
    }
    
    @isTest
    static void testNoUpdateAccountEmail() {
        // Create a new contact that is not the primary contact
        Contact newContact = new Contact(
            FirstName='New',
            LastName='Contact',
            Email='new@example.com',
            Phone='9876543210', // Add a phone number
            AccountId=[SELECT Id FROM Account WHERE Name='Test Account'].Id,
            Primary_Contact__c=false
        );
        insert newContact;
        
        // Update the primary contact to no longer be the primary contact
        Contact testContact = [SELECT Id, Primary_Contact__c FROM Contact WHERE Email='test@example.com'];
        testContact.Primary_Contact__c = false;
        update testContact;
        
        // Verify that the account email was not updated
        Account testAccount = [SELECT Id, Email__c FROM Account WHERE Name='Test Account'];
        System.assertEquals('test@example.com', testAccount.Email__c);
    }
}