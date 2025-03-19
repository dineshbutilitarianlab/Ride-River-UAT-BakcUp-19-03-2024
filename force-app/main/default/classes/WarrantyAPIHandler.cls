public class WarrantyAPIHandler {
    private static WarrantyAPIConfig__mdt config;

    private static WarrantyAPIConfig__mdt getAPIConfig() {
        if (config == null) {
            config = [SELECT API_Endpoint__c, Authorization_Key__c, API_Key__c, Cookie__c 
                      FROM WarrantyAPIConfig__mdt LIMIT 1];
        }
        return config;
    }

    public static void sendWarrantyData(Map<String, String> warrantyData) {
        try {
            WarrantyAPIConfig__mdt apiConfig = getAPIConfig();

            HttpRequest request = new HttpRequest();
            request.setEndpoint(apiConfig.API_Endpoint__c);
            request.setMethod('POST');

            request.setHeader('Authorization', apiConfig.Authorization_Key__c);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('X-API-Key', apiConfig.API_Key__c);
            request.setHeader('Cookie', apiConfig.Cookie__c);

            String requestBody = JSON.serialize(warrantyData);
            request.setBody(requestBody);

            System.debug('API Request: ' + request);
            System.debug('Request Body: ' + requestBody);

            Http http = new Http();
            HttpResponse response = http.send(request);

            ExceptionHelper.createAPICalloutLog(request, response, apiConfig.API_Endpoint__c);

            if (response.getStatusCode() == 200) {
                System.debug('API Success Response: ' + response.getBody());
            } else {
                System.debug('API Error Response: ' + response.getBody());
                throw new WarrantyAPIException('API Call Failed. Status: ' + response.getStatusCode() +
                                               ', Response: ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new WarrantyAPIException('API Callout Exception: ' + e.getMessage());
        }
    }

    public class WarrantyAPIException extends Exception {}
}