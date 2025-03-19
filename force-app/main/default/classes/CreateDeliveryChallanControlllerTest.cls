@isTest
public class CreateDeliveryChallanControlllerTest {

    @isTest
    static void testdeliverychallanController() {
         // Create test data
        Account acc = new Account(Name = 'Test Name',Type = 'Customer', Phone = '9011113246', Email__c = 'customer@test.com', BillingCity = 'Bangalore', shippingCity = 'Bangalore' );
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com', BillingCity = 'Bangalore', shippingCity = 'Bangalore' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Contact testContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Test Contact', // Change 'Name' to 'LastName'
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test St',
            Primary_Contact__c = true
            
        );
        insert testContact;
        
        Order__c orderForNumber = new order__c();
        
        orderForNumber.name = 'test';
        orderfornumber.InvoiceNumber__c = 5;
        insert orderfornumber;
        
        Order testOrder = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Website_Order_Id__c = 'QWERTY1234567WE',
            Dealer__c = dealerAccount.Id,
            Internal_Purchase__c = true
            // Do not set the Invoice_No__c field here
        );
        insert testOrder;

        // Create a PageReference for testing
        PageReference pageRef = Page.CreateDeliveryChallan;
        Test.setCurrentPage(pageRef);

        // Create a standard controller with the test order ID
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOrder);

        // Start the test by instantiating the controller
        CreateDeliveryChallanControlller controller = new CreateDeliveryChallanControlller(standardController);

        // Perform assertions
        System.assertEquals(testOrder.Id, controller.order.Id);
        System.assertEquals(testContact.Id, controller.contact.Id);

        // Add more assertions as needed based on your specific logic in the controller
    }
    
        @isTest
    static void testdeliverychallanController1() {
        // Create test data
        Account acc = new Account(Name = 'Test Name',Type = 'Customer', Phone = '9011113246', BillingCity = 'Bangalore', shippingCity = 'Bangalore' );
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com', BillingCity = 'Bangalore', shippingCity = 'Bangalore' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Contact testContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Test Contact', // Change 'Name' to 'LastName'
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test St',
            Primary_Contact__c = true            
            
        );
        insert testContact;
        
        Order testOrder = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Website_Order_Id__c = 'QWERTY1234567WE',
            Transportation_Charges__c = 100,
            BillingCountry = 'India',
            Billingstate='maharashtra',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder;
        // Create a PageReference for testing
        PageReference pageRef = Page.CreateReceiptVehicle;
        Test.setCurrentPage(pageRef);

        // Create a standard controller with the test order ID
        ApexPages.StandardController standardController = new ApexPages.StandardController(testOrder);

        // Start the test by instantiating the controller
        CreateDeliveryChallanControlller controller = new CreateDeliveryChallanControlller(standardController);

        // Perform assertions
        System.assertEquals(testOrder.Id, controller.order.Id);
        System.assertEquals(testContact.Id, controller.contact.Id);

        // Add more assertions as needed based on your specific logic in the controller
    }
    
}