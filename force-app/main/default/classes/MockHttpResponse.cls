@isTest
global class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;
    private Blob responseBlob;
    
    public MockHttpResponse(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }
    
    public MockHttpResponse(Integer statusCode, Blob responseBlob) {
        this.statusCode = statusCode;
        this.responseBlob = responseBlob;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        if (responseBody != null) {
            response.setBody(responseBody);
        } else if (responseBlob != null) {
            response.setBodyAsBlob(responseBlob);
        }
        return response;
    }
    
}