@isTest
public class CreateReceiptPaymentsControllerTest {
      @isTest
    static void testConstructor() {
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone = '9011113246' );
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Payment__c payment = new Payment__c(
            Amount__c = 100.00,
            Customer_Name__c = 'Test Customer',
            Description__c = 'Test Payment',
            Email__c = 'test@example.com',
            Mode_Of_Payment__c = 'Cash',
            Transaction_Id__c = '89hhiweotri909'
        );
        insert payment;
     Order standardOrder = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'india',
         Dealer__c = dealerAccount.Id
        );
        Insert standardOrder;
        Order_Payment__c orderPayment = new Order_Payment__c(
            Amount1__c = 100.00,
            Order__c = standardOrder.Id,
            Payments__c = payment.Id,
            Type__c = 'Booking Amount'
        );
        insert orderPayment;

        ApexPages.StandardController controller = new ApexPages.StandardController(orderPayment);

        CreateReceiptPaymentsController controllerInstance = new CreateReceiptPaymentsController(controller);

        System.assertEquals(controllerInstance.payment.Amount__c, 100.00);
        System.assertEquals(controllerInstance.amtInWords, '₹ One Hundred  Rupees Only');
        System.assertEquals(controllerInstance.cash, 'Yes');
    }
   /* @isTest
    static void testPdfAction() {
       // Create test data
        Account acc = new Account(Name = 'Test Name', Type = 'Customer');
        insert acc;

        Order testOrder = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft'
            // Do not set the Invoice_No__c field here
        );
        insert testOrder;

        Payment__c testPayment = new Payment__c(
            Amount__c = 1000.00,
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card'
        );
        insert testPayment;

        Order_Payment__c testOrderPayment = new Order_Payment__c(
            Payments__c = testPayment.Id,
            Order__c = testOrder.Id,
            Type__c = 'Down Payment',
            Website_Payment_Id__c = 'RTYU456789'
        );
        insert testOrderPayment;

        // Set up the PageReference and getContent mock
        PageReference mockPageRef = Page.CreateReceiptPayments;
        Test.setCurrentPage(mockPageRef);

        // Mock the getContent method
     //   Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());

        // Call the @future method
        Test.startTest();
        CreateReceiptPaymentsController.pdfAction(testOrderPayment.Payments__c);
        Test.stopTest();

        // Verify that ContentVersion and ContentDocumentLink records are created
        System.assertNotEquals(null, [SELECT Id FROM ContentVersion]);
        // Add more assertions as needed

    }*/
}

// Mock HTTP callout for getContent

/*public class MyHttpCalloutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Mock HTTP response with minimal content
        HttpResponse res = new HttpResponse();
        res.setBody('Test PDF Content');
        res.setStatusCode(200);
        return res;
    }
}*/