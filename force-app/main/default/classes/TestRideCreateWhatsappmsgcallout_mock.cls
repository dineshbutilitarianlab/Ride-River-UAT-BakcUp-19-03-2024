public class TestRideCreateWhatsappmsgcallout_mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "success"}');
        response.setStatusCode(200);
        return response;
    }

}