public class Testridewhatsappmsgforbatchprocessmock implements HttpCalloutMock {
public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":"success","message":"Mock response successful"}');
        res.setStatusCode(200);
        
        return res;
    }
}