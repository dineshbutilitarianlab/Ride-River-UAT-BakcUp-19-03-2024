@IsTest
public class HTTPUtilityTest {
    @IsTest
    public static void testHttpReqHelper() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data
        Map<String, String> headerMap = new Map<String, String>{
            'Authorization' => 'Bearer TestToken',
                'Content-Type' => 'application/json'
                };
                    String method = 'POST';
        String jsonBody = '{"testKey": "testValue"}';
        String endPoint = 'https://test.endpoint.com';
        Id refId = UserInfo.getUserId();
        
        // Call the method
        Test.startTest();
        Map<String, String> response = HTTPUtility.getInstance().httpReqHelper(headerMap, method, jsonBody, endPoint, refId);
        Test.stopTest();
    }
    
    @IsTest
    public static void testGetTransactionStatus() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Setup test data
        String merchantId = 'Merchant123';
        String securityToken = 'Token123';
        String storeId = 'Store123';
        String plutusTransactionReferenceId = 'Ref123';
        String endpointURL = 'https://test.endpoint.com';
        
        Test.startTest();
        PlutusApiResponse response = HTTPUtility.getInstance().getTransactionStatus(
            merchantId, securityToken, storeId, plutusTransactionReferenceId, endpointURL
        );
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testCreateLog() {
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setEndpoint('https://test.endpoint.com');
        httpReq.setBody('{"testKey": "testValue"}');
        
        HttpResponse httpRes = new HttpResponse();
        httpRes.setStatusCode(200);
        httpRes.setBody('{"ResponseCode": "200", "ResponseMessage": "Success"}');
        
        DateTime startTime = DateTime.now();
        DateTime endTime = DateTime.now().addSeconds(5);
        String refId = UserInfo.getUserId();
        
        
        Test.startTest();
        HTTPUtility.createLog(httpReq, httpRes, startTime, endTime, refId);
        Test.stopTest();
        
        
    }
    
}