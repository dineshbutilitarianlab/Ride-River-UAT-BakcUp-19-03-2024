@isTest
public class QueueableForImageTemplateMsgTest {
    
    @isTest
    static void testQueueableForImageTemplateMsg() {
        Lead testLead1 = new Lead(FirstName = 'Test 1', LastName = 'lastName 1', Company = 'Test Company 1', LeadSource = 'Google', Dealer_Code__c = '292001', Phone = '1234567890');
        Lead testLead2 = new Lead(FirstName = 'Test 2', LastName = 'lastName 2', Company = 'Test Company 2', LeadSource = 'Facebook', Dealer_Code__c = '292002', Phone = '0987654321');
        
        insert new List<Lead>{testLead1, testLead2};
            
            Map<Id, String> leadIdByPhoneMap = new Map<Id, String>{
                testLead1.Id => '1234567890',
                    testLead2.Id => '0987654321'
                    };
                        insertMockWhatsappIntegration();
        
        List<Id> leadIds = new List<Id>{testLead1.Id, testLead2.Id};
            String templateName = 'TestTemplate';
        String imageUrl = 'https://example.com/image.jpg';
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());        
        Test.startTest();
        QueueableForImageTemplateMsg queueableJob = new QueueableForImageTemplateMsg(leadIds, templateName, imageUrl, leadIdByPhoneMap);
        System.enqueueJob(queueableJob);
        Test.stopTest();
    }
    
    private static void insertMockWhatsappIntegration() {
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key'
        );
        insert mockIntegration;
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
    }
}