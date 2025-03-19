public class WhatsAppMsgForTestrideComplete {
     @future(callout=true)
    public static void WhatsAppMsgForTestrideCompletefutherMethod(string mobileNo,string templateName){
        
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c;
        String apikey = w.API_Key__c;
        String recipientId = '91' + mobileNo;

        // API endpoint
        //String endpoint = 'https://in-ccaas.ozonetel.com/api/v1/WhatsAppSendOzone/reply';

        // Prepare request body
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('recipient', new Map<String, String>{ 'id' => recipientId });
        requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
        requestBody.put('type', 'template');

        // Prepare template
        Map<String, Object> template = new Map<String, Object>();
        template.put('name', templateName);
        template.put('language', 'en_US');
        template.put('parameters', new Map<String, Object>()); // Parameters are currently empty

        requestBody.put('template', template);

        // Serialize request body to JSON
        String jsonBody = JSON.serialize(requestBody);

        // Prepare HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('apikey', apikey); // Replace with actual API key
        req.setHeader('Content-Type', 'application/json');
        //req.setHeader('Cookie', 'PHPSESSID=baefcd0d990d72449dfb7692422f8a65'); // Replace with the actual session ID if required
        req.setBody(jsonBody);

        // Send the HTTP request
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Body: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
    }

}