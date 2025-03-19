public class TestRidewhatsappmsgcallout {
      @future(callout=true)
    public static void TestRidewhatsappmsgcalloutfuthermethod(string MobileNo){
        TestRidewhatsappmsgcallout.sendWhatsAppMessage(MobileNo);
    }
    
          public static void sendWhatsAppMessage(String recipientId) {
        String endpoint = 'https://in-ccaas.ozonetel.com/api/v1/WhatsAppSendOzone/reply';

        String requestBody = '{"recipient":{"id":"' + recipientId + '"},' +
                             '"kookoo_id": "OZNTLWA:918197205802",' +
                             '"type":"template",' +
                             '"template":{' +
                                 '"name":"test_ride_not_taken",' +
                                 '"language":"en_US",' +
                                 '"parameters":{}}}';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('apikey', 'KK47b958dee3505cf2e2c6391c27bbaba4'); // API key
        req.setHeader('Cookie', 'PHPSESSID=864bfee61e1e8d9cf56873a82389476b'); // Session cookie
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug('Response: ' + res.getBody());
        } else {
            System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
        }
    }
    
    

}