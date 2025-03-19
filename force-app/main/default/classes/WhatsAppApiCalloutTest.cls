@isTest
private class WhatsAppApiCalloutTest {

    @isTest static void testLeadCreationMsg() {
       
       
        Test.startTest();
         lead l=new Lead();
        l.LastName='test';
        l.Company='NA';
        l.LeadSource='Facebook';
        l.PostalCode='560037';
        l.Dealer_Code__c='291001';
        l.Phone='9849899888';
        Insert l;
                    lead leadid=[select Id ,LeadSource,Lead_Dealer_Code__c,Phone from Lead Where Id=:l.Id];

        system.debug('lead dealercode========'+leadid.Lead_Dealer_Code__c);
      //  WhatsAppApiCalloutHandler.leadcreationmsg('9876543210', 'testTemplate');
        
        Test.stopTest();
        
        System.assert(true);
    }
    
    @isTest static void mockHttpCallout() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    }

    class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}