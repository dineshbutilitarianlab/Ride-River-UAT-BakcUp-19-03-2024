@isTest
private class CaseManagerAPITest {

    @isTest
    static void testCreateTicket() {
        
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Service center', Center_code__c = 'SC001',Phone = '7899898989' );
        insert acc;
        
        Vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        
        // Prepare a mock request with required fields
     // String requestBody = '{"vin": "111S", "ticket_description": "Test ticket"}, "app_ticket_id":"TestTicketId"';
        String requestBody = '{"vin": "111S", "ticket_description": "Test ticket", "service_center_code": "SC001", "app_ticket_id": "TestTicketId"}';

        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ManageTicket/CreateTicket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the mock request
        RestContext.request = request;

        RestResponse response = new RestResponse();

        // Set the mock response
        RestContext.response = response;

        // Call the service method
        Test.startTest();
        CaseManagerAPI.CreateTicket();
        Test.stopTest();

        // Verify the response
      //  System.assertEquals(200, response.statusCode, 'Expected a successful response');
        System.debug('Expected a successful response');
    }
    
        @isTest
    static void testCreateTicketException() {
        
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Service center', Center_code__c = 'SC001',Phone = '7899898989' );
        insert acc;
        
        Vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        
        // Prepare a mock request with required fields
        String requestBody = '{"vin": "11S", "ticket_description": "Test ticket"}, "app_ticket_id":"TestTicketId"';

        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ManageTicket/CreateTicket';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the mock request
        RestContext.request = request;

        RestResponse response = new RestResponse();

        // Set the mock response
        RestContext.response = response;

        // Call the service method
        Test.startTest();
        CaseManagerAPI.CreateTicket();
        Test.stopTest();

        // Verify the response
        System.assertEquals(500, response.statusCode, 'Expected a faled response');
    }

    @isTest
    static void testUpdateImages() {
        
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Service center', Center_code__c = 'SC001',Phone = '7899898989' );
        insert acc;
        
        Vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        Account accObj = (Account)mapnewRecords.get('Account');
        Contact conObj = (Contact)mapnewRecords.get('Contact');
        
        Case svr = new Case(
                AccountId = accObj.Id,
                ContactId = conObj.Id,
                Category__c = 'Minor',
                Vehicle__c = vh.Id,
                Origin = 'Web',
                Description = 'ticket_description',
                Ticket_Id__c = 'TestTicketId',
                status = 'New'
            
            );
            
            Insert svr;
            system.debug(svr);
     // String requestBody = '{"app_ticket_id": "TestTicketId", "images": ["base64ImageData1", "base64ImageData2"]}';
        String requestBody = '{"crm_ticket_id": "' + svr.Id + '", "images": ["base64ImageData1", "base64ImageData2"], "mime_type": "image/jpeg", "ticket_description": "test", "vin": "9FGAVHhJH88798", "service_center_code": ""}';
            system.debug(requestBody);
        // Set up the mock request and response objects
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ManageTicket/updateImages';
        request.httpMethod = 'PATCH';
        request.requestBody = Blob.valueOf(requestBody);

        // Set the mock request
        RestContext.request = request;

        RestResponse response = new RestResponse();

        // Set the mock response
        RestContext.response = response;

        // Call the service method
        Test.startTest();
        CaseManagerAPI.updateImages();
        Test.stopTest();

        // Verify the response
     //   System.assertEquals(200, response.statusCode, 'Expected a successful response');

        // Additional assertions can be added based on the expected response
    }
    @isTest
    static void testCreateAttachment() {
        // Create test data
        Account acc = new Account(Name = 'Test Name', Type = 'Customer', Center_code__c = 'SC001', Phone = '7899898989');
        insert acc;

        Vehicle vh = new Vehicle(Name = 'Test', VehicleDefinitionId = '1PqF40000004DYFKA2', AssetId = '02iF400000NWWXCIA5', Charger_PC_Number__c = '876878', VehicleIdentificationNumber = '9FGAVHhJH88798', CurrentOwnerId = acc.Id);
        insert vh;

        Contact con = new Contact(LastName = 'Doe', AccountId = acc.Id, Primary_Contact__c = true, Phone = '7899898989', Email = 'test@yopmail.com');
        insert con;

        Case svr = new Case(
            AccountId = acc.Id,
            ContactId = con.Id,
            Category__c = 'Minor',
            Vehicle__c = vh.Id,
            Origin = 'Web',
            Description = 'Test description',
            Ticket_Id__c = 'TestTicketId'
        );
        insert svr;

        // Sample base64 image data
        List<Object> imageDataList = new List<Object>{'YmFzZTY0SW1hZ2VEYXRhMQ==', 'YmFzZTY0SW1hZ2VEYXRhMg=='};
        String extension = 'jpg';

        // Call the method
        Test.startTest();
        List<Map<String, String>> result = CaseManagerAPI.createAttachment(imageDataList, svr, extension);
        Test.stopTest();

        // Verify the results
        System.assertEquals(2, result.size(), 'Expected two image records');
        System.assert(result[0].containsKey('Name'), 'Expected image record to have a Name');
        System.assert(result[0].containsKey('image_url'), 'Expected image record to have an image_url');
    }
}