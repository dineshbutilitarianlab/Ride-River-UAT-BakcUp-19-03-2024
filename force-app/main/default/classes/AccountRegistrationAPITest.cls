@isTest
private class AccountRegistrationAPITest {

    @isTest static void testCreateAccountContact1() {
        // Prepare the JSON request body
        String requestBody = '{"email_address": "utkarsh@test.co",'+
                            '"full_name": "test Sinha",'+
                            '"phone_number": "7610403720",'+
                            '"billing_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '},'+
                            '"shipping_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '}}';


        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/RegisterAccount';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(requestBody);

        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST method
        AccountRegistrationAPI.createAccountContact();

        // Verify the response
        System.assertEquals(200, res.statusCode, 'Expected a 200 response code');
        
    }
    
    @isTest static void testCreateAccountContact2() {
            
            Lead ldObj = new Lead( 
                LastName = 'Test Lead',
                Email = 'test@gmail.com',
                Phone = '7899878787',
                Company = 'Test Lead',
                city = 'bangalore'
        	);
            
            Insert ldObj;
            
        // Prepare the JSON request body
        String requestBody = '{"email_address": "test@gmail.com",'+
                            '"full_name": "Test Name",'+
                            '"phone_number": "7899878787",'+
                            '"billing_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '},'+
                            '"shipping_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '}}';

        // Create a REST request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/RegisterAccount';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(requestBody);

        // Create a REST response
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST method
        AccountRegistrationAPI.createAccountContact();

        Lead convertedLead = [SELECT Id, isConverted FROM Lead WHERE isConverted = true LIMIT 1];
        Integration_Log__c log = [SELECT Id, Status__c FROM Integration_Log__c LIMIT 1];
            
        // Verify the response
        System.assertEquals(200, res.statusCode, 'Expected a 200 response code');
        System.assertEquals(convertedLead.Id, ldObj.Id, 'Expected existing lead to convert');
        System.assertEquals(log.Status__c, 'Success', 'Expected to create a log with \'Success\' status');
        
        
    }
    
    
    @isTest static void testCreateAccountContact3() {
                       
        // Prepare the JSON request body
        String requestBody = '{"full_name": "Test Name",'+
                            '"phone_number": "7899878787",'+
                            '"billing_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '},'+
                            '"shipping_address": {'+
                                '"address_1": "Address line 1",'+
                                '"address_2": "Address line 2",'+
                                '"city": "Bengaluru",'+
                                '"pin_code": "560092",'+
                                '"state": "Karnataka"'+
                            '}}';

        // Create a REST request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/RegisterAccount';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(requestBody);

        // Create a REST response
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;

        // Call the REST method
       
        AccountRegistrationAPI.createAccountContact();
                

        List<Lead> convertedLead = [SELECT Id FROM Lead WHERE isConverted = true];
        Integration_Log__c log = [SELECT Id, Status__c FROM Integration_Log__c LIMIT 1];
            
        // Verify the response
        //System.assertEquals(500, res.statusCode, 'Expected a 500 response code');
      //  system.assertEquals(log.Status__c, 'Failed', 'Expected to create a log with \'Failed\' status');
        
        
    }
    
    @isTest static void testupdateAccountContact() {
        
        account acc = new account(name = 'test account', phone = '7899878787', billingcity = 'Testcity', shippingcity = 'Testcity');
        insert acc;
        
        // Prepare the JSON request body
        String requestBody = '{"email_address": "test@gmail.com",'+
            '"full_name": "Test Name",'+
            '"phone_number": "7899878787",'+
            '"billing_address": {'+
            '"address_1": "Address line 1",'+
            '"address_2": "Address line 2",'+
            '"city": "Bengaluru",'+
            '"pin_code": "560092",'+
            '"state": "Karnataka"'+
            '},'+
            '"shipping_address": {'+
            '"address_1": "Address line 1",'+
            '"address_2": "Address line 2",'+
            '"city": "Bengaluru",'+
            '"pin_code": "560092",'+
            '"state": "Karnataka"'+
            '}}';
        
        // Create a REST request
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/RegisterAccount';
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(requestBody);
        
        // Create a REST response
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        // Call the REST method
        AccountRegistrationAPI.createAccountContact();
        
        Integration_Log__c log = [SELECT Id, Status__c FROM Integration_Log__c LIMIT 1];
        
        // Verify the response
        //System.assertEquals(200, res.statusCode, 'Expected a 200 response code');
        system.assertEquals(log.Status__c, 'Success', 'Expected to create a log with \'Success\' status');
        
        
    }
    
        @isTest
    static void testCreateAccountContactException() {
        // Prepare the mock HTTP request with invalid data
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf('{}'); // Empty request body to trigger exception
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        try {
            AccountRegistrationAPI.createAccountContact();
           // System.assert(false, 'Expected an exception but none was thrown.');
        } catch (Exception e) {
           // System.assertNotEquals(null, e, 'Exception should have been thrown.');
        }
        Test.stopTest();
    }


}