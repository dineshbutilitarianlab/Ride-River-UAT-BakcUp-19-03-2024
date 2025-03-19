@isTest
public class CreateReceiptOChargesControllerTest {
    @isTest
    static void testController() {
        // Create a test Order and a related Contact record
        Account testAccount = new Account(Name = 'Test Name',Type = 'Customer', Phone='9011113246', Email__c = 'customer@gmail.com', BillingCountry='india', BillingState='karnataka');
        insert testAccount;
        
        Account testAccount1 = new Account(Name = 'Test Name1',Type = 'Customer', Phone='9011113247', Email__c = 'customer1@gmail.com', BillingCountry='india' ,BillingState='telangana');
        insert testAccount1;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' , BillingCountry='india' ,BillingState='karnataka');
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;

        Contact testContact = new Contact();
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:testAccount.Id AND Primary_Contact__c = true];
        
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Phone = '9011113246',
            MailingCity = 'Karnataka',
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
            BillingCountry = 'india',
            BillingPostalCode = '54321',
            BillingState = 'karnataka',
            BillingStreet = '456 Billing Street',
            ShippingCity = 'Shipping City',
            ShippingCountry = 'india',
            ShippingPostalCode = '67890',
            ShippingState = 'karnataka',
            ShippingStreet = '789 Shipping Street',
            Insurance_Amount__c = 100.00,
            RTO_Charges__c = 20.00,
            Transportation_Charges__c = 100,
            Handling_Charges__c = 10.00,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder;
        
        Order testOrder1 = new Order(
            AccountId = testAccount.Id,
            BillingCity = 'Billing City',
            BillingCountry = 'india',
            BillingPostalCode = '54321',
            BillingState = 'karnataka',
            BillingStreet = '456 Billing Street',
            ShippingCity = 'Shipping City',
            ShippingCountry = 'india',
            ShippingPostalCode = '67890',
            ShippingState = 'karnataka',
            ShippingStreet = '789 Shipping Street',
            Insurance_Amount__c = 100.00,
            RTO_Charges__c = 20.00,
            Extended_Warranty__c = true,
            Warranty_amount__c = 100,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder1;
        
        Order testOrder2 = new Order(
            AccountId = testAccount1.Id,
            BillingCity = 'Billing City',
            BillingCountry = 'India',
            BillingPostalCode = '54321',
            BillingState = 'karnataka',
            BillingStreet = '456 Billing Street',
            ShippingCity = 'Shipping City',
            ShippingCountry = 'india',
            ShippingPostalCode = '67890',
            ShippingState = 'karnataka',
            ShippingStreet = '789 Shipping Street',
            Insurance_Amount__c = 100.00,
            Extended_Warranty__c = true,
            Warranty_amount__c = 100,
            RTO_Charges__c = 20.00,
            Handling_Charges__c = 10.00,
            Transportation_Charges__c = 100,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Dealer__c = dealerAccount.Id
        );
        insert testOrder2;

        ApexPages.StandardController controller = new ApexPages.StandardController(testOrder);

        // Start the test and create an instance of the controller
        Test.startTest();
        CreateReceiptOChargesController controllerInstance = new CreateReceiptOChargesController(controller);

        // Verify controller properties are correctly set
        System.assertEquals(testOrder.Id, controllerInstance.order.Id);
        System.assertEquals(testContact.Id, controllerInstance.contact.Id);
        System.assertEquals(Date.today(), controllerInstance.currentDate);

        // Verify calculations
        Decimal expectedTotalAmount = 110.00;
        Decimal expectedTaxableAmount = expectedTotalAmount / 1.18;
        expectedTaxableAmount = expectedTaxableAmount.setScale(2);
        Decimal expectedGst = expectedTaxableAmount * 0.09;
        expectedGst = expectedGst.setScale(2);
        String expectedInWords = CurrencyToWordsInRupees.convertToWords(expectedTotalAmount);
       
        
        ApexPages.StandardController controller1 = new ApexPages.StandardController(testOrder1);
		CreateReceiptOChargesController controllerInstance1 = new CreateReceiptOChargesController(controller1);
        
        ApexPages.StandardController controller2 = new ApexPages.StandardController(testOrder2);
		CreateReceiptOChargesController controllerInstance2 = new CreateReceiptOChargesController(controller2);
        
        // Stop the test
        Test.stopTest();
    }
}