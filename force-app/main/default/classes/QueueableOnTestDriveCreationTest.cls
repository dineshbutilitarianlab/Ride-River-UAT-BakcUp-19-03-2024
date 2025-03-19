@IsTest
public class QueueableOnTestDriveCreationTest {
    @IsTest
    public static void testQueueableOnTestDriveCreation() {
        
        Lead testLead1 = new Lead(FirstName = 'Test', LastName = 'Ride', Company = 'Test Company 1', LeadSource = 'Google', Dealer_Code__c = '292001', Phone = '1234567890');
        insert testLead1; 
        
        Test_Drive__c testDrive = new Test_Drive__c(Name='Drive 1', Lead__c = testLead1.Id,Test_Drive_Date__c=System.Now());
        insert testDrive;
        
       
        List<Id> testDriveIds = new List<Id>{testDrive.Id};
        Map<Id, String> idToPhoneMap = new Map<Id, String>{testDrive.Id => '1234567890'};
        Map<Id,String> idToTimeMap = new Map<Id,String>{testDrive.Id => '04-02-2025'};  
        Map<Id,String> idToRideTypeMap = new Map<Id,String>{testDrive.Id => 'Home Ride'};    
            
        insertMockWhatsappIntegration();
        
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        Test.startTest();
        
        
        QueueableOnTestDriveCreation queueableJob = new QueueableOnTestDriveCreation(testDriveIds, idToPhoneMap, idToTimeMap, idToRideTypeMap);
        System.enqueueJob(queueableJob);
        
        Test.stopTest();    
    }
    
    private static void insertMockWhatsappIntegration() {
        
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            test_ride_booked_text_2_image__c = 'https://example.com/image.jpg'
        );
        insert mockIntegration;
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             
            System.assertEquals('https://api.whatsapp.com/send', req.getEndpoint(), 'Endpoint URL mismatch');
            System.assertEquals('POST', req.getMethod(), 'Method should be POST');
            System.assertEquals('mock-api-key', req.getHeader('apikey'), 'API key mismatch');
            System.assertEquals('application/json', req.getHeader('Content-Type'), 'Content-Type mismatch');
          
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
            System.assert(requestBody.containsKey('recipient'), 'Recipient key missing in request body');
            System.assert(requestBody.containsKey('template'), 'Template key missing in request body');
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
    }
}