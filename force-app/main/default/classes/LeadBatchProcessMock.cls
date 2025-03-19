public class LeadBatchProcessMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Mock response for WhatsApp API
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success": true, "message": "WhatsApp message sent successfully"}');
        res.setStatusCode(200);
        return res;
    }
}