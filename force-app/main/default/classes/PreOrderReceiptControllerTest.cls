@isTest
public class PreOrderReceiptControllerTest {
    
    @isTest
    static void testPreOrderReceiptController() {
        // Create a test Account
        Account testAccount = new Account(Name = 'Test Name', Type = 'Customer',Phone='9011113246');
        insert testAccount;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        // Create a test Contact associated with the Account
        Contact testContact = new Contact(
            AccountId = testAccount.Id,
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Hyderabad',
            MailingCountry = 'India',
            MailingPostalCode = '502305',
            MailingState = 'Telangana',
            MailingStreet = 'New',
            Primary_Contact__c = true // Set as Primary contact
        );
        insert testContact;
        Id standardPricebookId = test.getStandardPricebookId();
        Product2 newProduct = new Product2(
            Name = 'Bike',
            Description = 'Vehicle',
            IsActive = true,
            HSN_Code__c ='Test',
            Type__c ='Vehicle',
            ProductCode = 'code 1'
        );
        insert newProduct;
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = newProduct.Id,
            UnitPrice = 1000000,
            IsActive = true // You can set other fields as needed
        );
        insert newPricebookEntry;
        // Create a test Order associated with the Account
        Order testOrder = new Order(
            AccountId = testAccount.Id,
           // Invoice_No__c='RIVER100618',
            BillingCity = 'BillingCity',
            BillingCountry = 'india',
            pricebook2Id = standardPricebookId,
            BillingPostalCode = '12345',
            BillingState = 'karnataka',
            BillingStreet = 'BillingStreet',
            ShippingCity = 'ShippingCity',
            ShippingCountry = 'india',
            ShippingPostalCode = '54321',
            ShippingState = 'karnataka',
            ShippingStreet = 'ShippingStreet',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder;
        

        OrderItem orderItem = new OrderItem(
            OrderId = testOrder.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = newProduct.Id, 
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Vehicle'
        );
        
        Insert orderItem;
        
        // Set up the standard controller for PreOrderReceiptController
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOrder);
        
        // Create an instance of the PreOrderReceiptController class
        PreOrderReceiptController controller = new PreOrderReceiptController(standardController);
        
        
        if (controller.orderItem != null) {
            System.assertEquals(1, controller.orderItem.Quantity);
        }
        
    }
}