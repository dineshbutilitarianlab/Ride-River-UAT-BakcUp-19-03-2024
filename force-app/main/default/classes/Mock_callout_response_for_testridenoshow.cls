public class Mock_callout_response_for_testridenoshow implements HttpCalloutMock {
 public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"success"}'); 
            res.setStatusCode(200);
            return res;
        }
}