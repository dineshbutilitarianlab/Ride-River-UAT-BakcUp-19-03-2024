@IsTest
global class TestCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
      
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "success"}');
        res.setStatusCode(200);
        return res;
    }
}