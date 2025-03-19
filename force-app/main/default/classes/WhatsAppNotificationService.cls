public class WhatsAppNotificationService {
    @future(callout=true)
    public static void sendWhatsAppNotification(String mobileNumber, String templateName) {
        try {
            String recipientId = '91' + mobileNumber;
            String endpoint = 'https://in-ccaas.ozonetel.com/api/v1/WhatsAppSendOzone/reply';

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('recipient', new Map<String, String>{ 'id' => recipientId });
            requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
            requestBody.put('type', 'template');

            Map<String, Object> template = new Map<String, Object>();
            template.put('name', templateName);
            template.put('language', 'en_US');
            Map<String, Object> parameters = new Map<String, Object>();
            parameters.put('Date', '23/12/2024');  
            parameters.put('location', 'BTM');
            template.put('parameters', parameters);
            
            //template.put('parameters', new Map<String, Object>()); // Add parameters if needed

            requestBody.put('template', template);

            String jsonBody = JSON.serialize(requestBody);
            system.debug('jsonBody ===> ' + jsonBody);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('apikey', 'KK47b958dee3505cf2e2c6391c27bbaba4'); // Replace with actual API key
            req.setBody(jsonBody);

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                System.debug('WhatsApp Notification Sent: ' + res.getBody());
            } else {
                System.debug('Error Sending WhatsApp Notification: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception in WhatsAppNotificationService: ' + e.getMessage());
        }
    }
}