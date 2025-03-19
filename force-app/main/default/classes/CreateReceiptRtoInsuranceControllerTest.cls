@isTest
public class CreateReceiptRtoInsuranceControllerTest {
    @isTest
    static void testController() {
        // Create a test Order and a related Contact record
        Account testAccount = new Account(Name = 'Test Name',Type = 'Customer', Phone='9011113246',Email__c = 'customer@test.com' );
        insert testAccount;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:testAccount.Id AND Primary_Contact__c = true];
        Contact testContact = new Contact();
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test Street',
            AccountId = testAccount.Id,
            Primary_Contact__c = true
        );
        insert testContact;
        }         

        Order testOrder = new Order(
            AccountId = testAccount.Id,
            BillingCity = 'Billing City',
            BillingCountry = 'India',
            BillingPostalCode = '54321',
            BillingState = 'karnataka',
            BillingStreet = '456 Billing Street',
            ShippingCity = 'Shipping City',
            ShippingCountry = 'India',
            ShippingPostalCode = '67890',
            ShippingState = 'karnataka',
            ShippingStreet = '789 Shipping Street',
            Insurance_Amount__c = 100.00,
            RTO_Charges__c = 20.00,
            Handling_Charges__c = 10.00,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Website_Order_Id__c = 'RIVER12345WERTY',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder;

        ApexPages.StandardController controller = new ApexPages.StandardController(testOrder);

        // Start the test and create an instance of the controller
        Test.startTest();
        CreateReceiptRtoInsuranceController controllerInstance = new CreateReceiptRtoInsuranceController(controller);

        // Verify controller properties are correctly set
        System.assertEquals(testOrder.Id, controllerInstance.order.Id);
        System.assertEquals(testContact.Id, controllerInstance.contact.Id);
        System.assertEquals(Date.today(), controllerInstance.currentDate);

        // Verify calculations
        Decimal expectedTotalAmount = 100.00 + 20.00;
        
        String expectedInWords = CurrencyToWordsInRupees.convertToWords(expectedTotalAmount);

        System.assertEquals(expectedTotalAmount, controllerInstance.TotalAmount);
        System.assertEquals(expectedInWords, controllerInstance.inWords);

        // Stop the test
        Test.stopTest();
    }
}