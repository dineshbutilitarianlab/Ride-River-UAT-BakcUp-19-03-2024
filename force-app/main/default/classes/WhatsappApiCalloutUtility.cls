public class WhatsappApiCalloutUtility {
        
    public static void imageTemplate(String mobileNumber, String templateName, String imageUrl){
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c;
        String apikey = w.API_Key__c;
        
        String recipientPhoneNumber = '91' + mobileNumber;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(url);
        request.setMethod('POST');
        
        request.setHeader('apikey', apikey);
        request.setHeader('Content-Type', 'application/json');
        
         Map<String,Object> payload = new Map<String,Object>();
        Map<String,Object> recipient = new Map<String,Object>();
        recipient.put('id',recipientPhoneNumber);
        
        Map<String,Object> header = new Map<String,Object>();
        Map<String,Object> image = new Map<String,Object>();
        image.put('link',imageUrl);
        header.put('image',image);
        header.put('type','image');
        
        Map<String,Object> template = new Map<String,Object>();
        template.put('parameters', new Map<String, Object>());
        template.put('language','en_US');
        template.put('name',templatename);
        
        payload.put('template',template);
        payload.put('header',header);
        payload.put('type','template');
        payload.put('kookoo_id','OZNTLWA:918197205802');
        payload.put('recipient',recipient);
        
        String reqBody = JSON.serialize(payload);
        request.setBody(reqBody);
        
        try {
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('Success: ' + response.getBody());
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    public static  void sendWhatsAppMessage(string mobileNumber,string templatename) {
        
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c;
        String apikey = w.API_Key__c;
        
        String recipientPhoneNumber = '91' + mobileNumber; // Concatenates '91' with the passed mobile number
        
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(url);
        request.setMethod('POST');
        
        request.setHeader('apikey', apikey);
        request.setHeader('Content-Type', 'application/json');
        
        //dynamic payload
        Map<String,Object> payload = new Map<String,Object>();
        Map<String,Object> recipient = new Map<String,Object>();
        recipient.put('id',recipientPhoneNumber);
        
        Map<String,Object> header = new Map<String,Object>();
        Map<String,Object> image = new Map<String,Object>();
        image.put('link','https://s3.ap-south-1.amazonaws.com/ca.chat/images/0f0ebf1a8f8451265bc9cd1d1182aa36.jpg');
        header.put('image',image);
        header.put('type','image');
        
        Map<String,Object> template = new Map<String,Object>();
        template.put('parameters', new Map<String, Object>());
        template.put('language','en_US');
        template.put('name',templatename);
        
        payload.put('template',template);
        payload.put('header',header);
        payload.put('type','template');
        payload.put('kookoo_id','OZNTLWA:918197205802');
        payload.put('recipient',recipient);
        
        String reqBody = JSON.serialize(payload);
        
        System.debug('reqBody==>'+JSON.serializePretty(payload));
        
        /*String body = '{' +
            '"recipient": {' +
            '"id": "' + recipientPhoneNumber + '"' + 
            '},' +
            '"kookoo_id": "OZNTLWA:918197205802",' +
            '"type": "template",' +
            '"header": {' +
            '"type": "image",' +
            '"image": {' +
            '"link":"https://s3.ap-south-1.amazonaws.com/ca.chat/images/0f0ebf1a8f8451265bc9cd1d1182aa36.jpg"' +
            '}' +
            '},' +
            '"template": {' +
            '"name": "' + templatename + '",' + 
            '"language": "en_US",' +
            '"parameters": {}' +
            '}' +
            '}';*/
        
        request.setBody(reqBody);
        
        //dynamic payload
       
        
        
        
        try {
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                System.debug('Success: ' + response.getBody());
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
}