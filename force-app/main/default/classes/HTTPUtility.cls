public with sharing class HTTPUtility {
    public static final String NO_RESPONSE = 'NO_RESPONSE';
    public static final String HTTP_ERROR = 'ERROR WHILE MAKING REQUEST';
    static HttpUtility httpUtilityInstance;
  
    public HttpUtility() {}
    
    public static HttpUtility getInstance() {
        if(httpUtilityInstance == null) {
            httpUtilityInstance = new HttpUtility();
        }
        return httpUtilityInstance;
    }

    public Map<String,String> httpReqHelper(Map<String,String> headerMap, String method, String jsonBody, String endPoint, Id refId) {
        System.debug('method == > '+ method +' && jsonBody == >'+jsonBody+' && endPoint === >'+endPoint+' && refId == >'+refId);
        DateTime sDate = System.now();
        Map<String,String> respMap = new Map<String,String>();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(endpoint);
        httpRequest.setMethod(method);
        if(jsonBody != null)
        httpRequest.setBody(jsonBody);
        httpRequest.setTimeout(600);          
        if(!headerMap.isEmpty()){
            for(String key : headerMap.keySet()){
                httpRequest.setHeader(key,headerMap.get(key)); 
            }
        }
        try {
            Http http = new Http();
            HTTPResponse response = http.send(httpRequest);
            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('responseBody === >'+responseBody);
            DateTime eDate = System.now();
            respMap.put('code',String.valueOf(response.getStatusCode()));
            respMap.put('status',response.getStatusCode() == 200 || response.getStatusCode() == 201?'Success':'Failure');
            ExceptionHelper.createAPICalloutLog(httpRequest,response,refId);
            if (responseBody != null) {
                respMap.put('AdditionalInfo', Boolean.valueOf(responseBody.containsKey('AdditionalInfo')) ? String.valueOf(responseBody.get('AdditionalInfo')) : null);
                respMap.put('PlutusTransactionReferenceID', Boolean.valueOf(responseBody.containsKey('PlutusTransactionReferenceID')) ? String.valueOf(responseBody.get('PlutusTransactionReferenceID')) : null);
                respMap.put('ResponseCode', Boolean.valueOf(responseBody.containsKey('ResponseCode')) ? String.valueOf(responseBody.get('ResponseCode')) : null);
                respMap.put('ResponseMessage', Boolean.valueOf(responseBody.containsKey('ResponseMessage')) ? String.valueOf(responseBody.get('ResponseMessage')) : null);
            }
            System.debug('respMap === >'+respMap);
            return respMap;
        }
        catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message #1 ==>'+e.getMessage()+' && Error Line #2 == >'+e.getLineNumber());
            respMap.put('code','404');
            respMap.put('status','Failure');
            respMap.put('message',HTTP_ERROR);
            return respMap;
        }
    }

    public PlutusApiResponse getTransactionStatus(String merchantId, String securityToken, String storeId, String plutusTransactionReferenceId,String EndpointURL) {
        PlutusApiResponse responseObj = new PlutusApiResponse();
        try{
            HttpRequest req = new HttpRequest();
            req.setEndpoint(EndpointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            Map<String, Object> requestBody = new Map<String, Object>{
                'MerchantID' => merchantId,
                'SecurityToken' => securityToken,
                'StoreId' => storeId,
                'PlutusTransactionReferenceID' => plutusTransactionReferenceID
            };
            req.setBody(JSON.serialize(requestBody));
            Http http = new Http();
            HttpResponse res = http.send(req);
            ExceptionHelper.createAPICalloutLog(req,res,'');
            if (res.getStatusCode() == 200) {
                responseObj = (PlutusApiResponse) JSON.deserialize(res.getBody(), PlutusApiResponse.class);
                return responseObj;
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }

    public PlutusApiResponse createPlutusApiResponse() {
        return new PlutusApiResponse();
    }


}