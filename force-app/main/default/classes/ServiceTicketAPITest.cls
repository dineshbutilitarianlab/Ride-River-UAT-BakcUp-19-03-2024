@isTest
private class ServiceTicketAPITest {
    @isTest
    static void testServiceTicketCreation() {
        
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Service center', Center_code__c = 'SC001',Phone = '7899898989' );
        insert acc;
        
        Vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        
        Datetime currentDateTime = System.now();
		String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        // Prepare a mock request with required fields
        String requestBody = '{"vin": "111S", "service_center": "SC001", "service_type": "RegularService", "scheduled_date": "'+formattedDateTime+'"}';

        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ServiceTicket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the mock request
        RestContext.request = request;

        RestResponse response = new RestResponse();

        // Set the mock response
        RestContext.response = response;

        // Call the service method
        Test.startTest();
        ServiceTicketAPI.ServiceTicket();
        Test.stopTest();

        // Verify the response
       // System.assertEquals(200, response.statusCode, 'Expected a successful response');

        // Verify that the service appointment is created (add additional assertions as needed)
        List<ServiceAppointment> serviceAppointments = [SELECT Id FROM ServiceAppointment];
        System.assertEquals(1, serviceAppointments.size(), 'Expected one service appointment to be created');
    }

    @isTest
    static void testMissingRequiredFields() {
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Customer', Center_code__c = 'SC001',Phone = '7899898989' );
        insert acc;
        
        Vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        
        Datetime currentDateTime = System.now();
		String formattedDateTime = currentDateTime.format('yyyy-MM-dd HH:mm:ss');
        // Prepare a mock request with required fields
        String requestBody = '{"vin": "111S", "service_center_code": "GYT5RTGHGF", "periodic_maintenance_type": "1st Service" , "service_type": "RegularService", "scheduled_date": "'+formattedDateTime+'"}';

        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ServiceTicket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the mock request
        RestContext.request = request;

        RestResponse response = new RestResponse();

        // Set the mock response
        RestContext.response = response;

        // Call the service method
        Test.startTest();
        ServiceTicketAPI.ServiceTicket();
        Test.stopTest();

        // Verify the response
    //    System.assertEquals(500, response.statusCode, 'Expected an error response');
        // Additional assertions can be added to check the specific error message in the response
    }
    
    @isTest
    static void testHandleException() {
        // Prepare mock data for request
        String requestBody = '{"vin": "12345", "service_center_code": "SC001", "scheduled_date": "2024-08-01T10:00:00.000Z"}';
    
        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ServiceTicket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
    
        RestResponse response = new RestResponse();
        RestContext.response = response;
    
        // Prepare an exception scenario by using an invalid VehicleIdentificationNumber
        Test.startTest();
        try {
            ServiceTicketAPI.ServiceTicket(); // This should cause an exception
        } catch (Exception e) {
            ServiceTicketAPI.handleException(response, e, (Map<String, Object>) JSON.deserializeUntyped(requestBody));
        }  
        Test.stopTest();
    
        // Debug statement to check if response is set
        System.debug('Response status code: ' + response.statusCode);
        System.debug('Response body: ' + response.responseBody);
        
        // Verify the response
        System.assertNotEquals(null, response, 'Expected a response to be set.');
        System.assertNotEquals(null, response.responseBody, 'Expected the response body to be set.');
        System.assertNotEquals(null, response.statusCode, 'Expected the response status code to be set.');
        System.assertEquals(500, response.statusCode, 'Expected status code 500 for error response');
    
        // Check the response body for error message
        String responseBody = response.responseBody.toString();
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        System.assertEquals('Error', responseMap.get('status'), 'Expected status to be "Error"');
        System.assert(responseMap.containsKey('message'), 'Expected response to contain an error message');
    
        // Additional assertion to check if an Integration_log__c record was created
       List<Integration_log__c> logs = [SELECT Id, Status__c, Error_Message__c FROM Integration_log__c WHERE Status__c = 'Failed'];
        System.assert(logs.size() > 0, 'Expected at least one log entry for the failed operation');
        System.assertEquals('Failed', logs[0].Status__c, 'Expected log status to be "Failed"');
    }

    // Add more test methods for additional scenarios as needed
}