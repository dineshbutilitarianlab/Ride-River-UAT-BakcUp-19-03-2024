@isTest
global class ActualUpdateMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Simulate a successful response for the actual update
        res.setBody('{"status": "Success"}');
        res.setStatusCode(200);

        return res;
    }
}