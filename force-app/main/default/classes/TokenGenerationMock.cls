// Mock class for token generation callout
@isTest
global class TokenGenerationMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        // Simulate a successful response with a dummy token
        res.setBody('{"data": {"token": "dummyToken"}}');
        res.setStatusCode(200);

        return res;
    }
}