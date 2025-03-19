@isTest
public class PaymentAPITest {
    
    // Test method for createPayment()
    @isTest
    static void testCreatePayment() {
        //Createing the Data
        Map<string, object> newmap = TestDataFactory.CreateOrder();
        Account acc = (Account)newmap.get('AccountId');
        Order o = (Order)newmap.get('OrderId');
        
        o.Website_Order_Id__c = '12345';
        update o;
        
        // Construct a sample JSON request body for creating a payment
        
        String jsonPayload = '{' +
            '"order_id": "12345",'+
            '"crm_account_id":"' + acc.Id+'",'+
            '"payment_info": {' +
            '"payment_id": "RIVERDP351515",' +
             '"payment_source": "Website",' +
            
            '"payment_type": "Down Payment",' +
            '"payment_amount": 5000,' +
            '"payment_status": "PAID",' +
            '"is_payment_completed": true,' +
            '"pay_gwy_info": {' +
            '"bank_ref_no": "325124124",' +
            '"card_name": "Visa",' +
            '"payment_mode": "CREDIT-CARD",' +
            '"tracking_id": "5246246161",' +
            '"status": "Awaited",' +
            '"failure_message": "ErrorMessage"' +
            '}' +
            '}' +
            '}';
        
        // Set up a mock REST request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        // Create a mock response and set the status code
        RestResponse res = new RestResponse();
        res.statusCode = 200; // Set the desired status code
        RestContext.response = res;
        
        // Call the createPayment() method
        Test.startTest();
        PaymentAPI.createPayment();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Expected a 200 status code');
        
        //get Payment
        List<Payment__c> createdPayments = [SELECT Id FROM Payment__c WHERE Transaction_Id__c = 'RIVERDP351515' LIMIT 1];
        
        // Assert that a record was created
        System.assertEquals(1, createdPayments.size(), 'Expected a Payment__c record to be created');
        
    }
    
    
    // Test method for createPayment()
    @isTest
    static void testCreatePayment1() {
        //Createing the Data
        Map<string, object> newmap = TestDataFactory.CreateOrder();
        Account acc = (Account)newmap.get('AccountId');
        Order o = (Order)newmap.get('OrderId');
        
        o.Website_Order_Id__c = '12345';
        update o;
        
        // Construct a sample JSON request body for creating a payment
        
        String jsonPayload = '{' +
            '"order_id": "12345",'+
            '"crm_account_id":"' + acc.Id+'",'+
            '"payment_info": {' +
            '"payment_id": "RIVERDP351515",' +
            '"payment_source": "Website",' +
            '"payment_type": "Refund",' +
            '"payment_amount": 5000,' +
            '"payment_status": "PAID",' +
            '"is_payment_completed": true,' +
            '"pay_gwy_info": {' +
            '"bank_ref_no": "325124124",' +
            '"card_name": "Visa",' +
            '"payment_mode": "CREDIT-CARD",' +
            '"tracking_id": "5246246161",' +
            '"status": "Awaited",' +
            '"failure_message": "ErrorMessage"' +
            '}' +
            '}' +
            '}';
        
        // Set up a mock REST request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        // Create a mock response and set the status code
        RestResponse res = new RestResponse();
        res.statusCode = 200; // Set the desired status code
        RestContext.response = res;
        
        // Call the createPayment() method
        Test.startTest();
        PaymentAPI.createPayment();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Expected a 200 status code');
        
        //get Order Payment
        List<Payment__c> createdPayments = [SELECT Id FROM Payment__c WHERE Transaction_Id__c = 'RIVERDP351515' LIMIT 1];
        
        // Assert that a record was created
        System.assertEquals(1, createdPayments.size(), 'Expected a Payment__c record to be created');
        
    }
    
    
    // Test method for updatePayment()
    @isTest
    static void testUpdatePayment() {
        //Createing the Data
        Map<string, object> newmap = TestDataFactory.CreateOrder();
        Account acc = (Account)newmap.get('AccountId');
        Order o = (Order)newmap.get('OrderId');
        Order_Payment__c op = (Order_Payment__c)newmap.get('OrderPaymentId');
        
        o.Website_Order_Id__c = '12345';
        update o;
        
        Payment__c pay = (Payment__c)newmap.get('PaymentId');
        pay.Transaction_Id__c = 'RTYU456789';
        update pay;
        
        // Construct a sample JSON request body for creating a payment
        
        String jsonPayload = '{' +
            '"order_id": "12345",'+
            '"crm_account_id":"' + acc.Id+'",'+
            '"payment_info": {' +
            '"payment_id": "RTYU456789",' +
            '"payment_type": "Down Payment",' +
            '"payment_source": "Website",' +
            '"payment_amount": 5000,' +
            '"payment_status": "PAID",' +
            '"is_payment_completed": true,' +
            '"pay_gwy_info": {' +
            '"bank_ref_no": "325124124",' +
            '"card_name": "Visa",' +
            '"payment_mode": "CREDIT-CARD",' +
            '"tracking_id": "5246246161",' +
            '"status": "Awaited",' +
            '"failure_message": "ErrorMessage"' +
            '}' +
            '}' +
            '}';
        
        // Set up a mock REST request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        // Create a mock response and set the status code
        RestResponse res = new RestResponse();
        res.statusCode = 200; // Set the desired status code
        RestContext.response = res;
        
        // Call the createPayment() method
        Test.startTest();
        PaymentAPI.updatePayment();
        Test.stopTest();
        System.assertEquals(200, RestContext.response.statusCode, 'Expected a 200 status code');
        
                // Query the Payment__c object to check if a record was created
        List<Payment__c> createdPayments = [SELECT Id FROM Payment__c WHERE Transaction_Id__c = 'RTYU456789' LIMIT 1];
        
        // Assert that a record was created
        System.assertEquals(1, createdPayments.size(), 'Expected a Payment__c record to be created');
    }
    
        // Test method for updatePayment()
    @isTest
    static void testUpdatePayment1() {
        //Createing the Data
        Map<string, object> newmap = TestDataFactory.CreateOrder();
        Account acc = (Account)newmap.get('AccountId');
        Order o = (Order)newmap.get('OrderId');
        Order_Payment__c op = (Order_Payment__c)newmap.get('OrderPaymentId');
        
        o.Website_Order_Id__c = '12345';
        update o;
        
        Payment__c pay = (Payment__c)newmap.get('PaymentId');
        pay.Transaction_Id__c = 'RTYU456789';
        update pay;
        
        // Construct a sample JSON request body for creating a payment
        
        String jsonPayload = '{' +
            '"order_id": "12345",'+
            '"crm_account_id":"' + acc.Id+'",'+
            '"payment_info": {' +
            '"payment_id": "RTYU456789",'+
            '"payment_source": "Website",' +
            '"payment_type": "Refund",' +
            '"payment_amount": 5000,' +
            '"payment_status": "PAID",' +
            '"is_payment_completed": true,' +
            '"pay_gwy_info": {' +
            '"bank_ref_no": "325124124",' +
            '"card_name": "Visa",' +
            '"payment_mode": "CREDIT-CARD",' +
            '"tracking_id": "5246246161",' +
            '"status": "Success",' +
            '"failure_message": "ErrorMessage"' +
            '}' +
            '}' +
            '}';
        
        // Set up a mock REST request
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = req;
        
        // Create a mock response and set the status code
        RestResponse res = new RestResponse();
        res.statusCode = 200; // Set the desired status code
        RestContext.response = res;
        
        // Call the createPayment() method
        Test.startTest();
        PaymentAPI.updatePayment();
        Test.stopTest();
        System.assertEquals(500, RestContext.response.statusCode, 'Expected a 200 status code');
        
        List<Payment__c> createdPayments = [SELECT Id FROM Payment__c WHERE Transaction_Id__c = 'RTYU456789' LIMIT 1];
        
        // Assert that a record was created
        System.assertEquals(1, createdPayments.size(), 'Expected a Payment__c record to be created');
    }
}