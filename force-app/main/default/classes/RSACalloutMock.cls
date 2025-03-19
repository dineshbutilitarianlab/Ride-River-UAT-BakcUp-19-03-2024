@isTest
global class RSACalloutMock implements HttpCalloutMock {
    
   global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();    
        if (req.getEndpoint().contains('/login')) {
            res.setStatusCode(200);
            res.setBody('{"data": {"token": "mockToken", "refreshToken": "mockRefreshToken"}}');
        } else if (req.getEndpoint().contains('/refresh-token')) {
            res.setStatusCode(200);
            res.setBody('{"data": {"token": "mockBearerToken"}}');
        } else if (req.getEndpoint().contains('/sync-reg')) {
            res.setStatusCode(200);
            res.setBody('{"success": true}');
        } else if (req.getEndpoint().contains('/tagged/subscription-plans')) {
            res.setStatusCode(200);
            res.setBody('{"data": [{"planId": 1234}]}');
        } else if (req.getEndpoint().contains('/subscription-creation')) {
            res.setStatusCode(200);
            res.setBody('{"data": {"subscriptionId": 5678, "expiryDate": "2024-12-25T14:38:28.408Z", "startDate": "2024-12-25T14:38:28.408Z"}}');
        } else {
            res.setStatusCode(400);
            res.setBody('{"error": "Invalid endpoint"}');
        }
        return res;
    }
    
}