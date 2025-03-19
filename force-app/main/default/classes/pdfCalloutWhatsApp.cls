/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-10-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class pdfCalloutWhatsApp {
    public static final String ENDPOINT_URL='https://in-ccaas.ozonetel.com';
    public static final String API_KEY='KK47b958dee3505cf2e2c6391c27bbaba4';
    public static final String TEMPLATE_NAME='booking_done_with_receipt1';
    public static final String PDF_FILE='http://www.africau.edu/images/default/sample.pdf';
    public static final String PHONE_NUMBER='9051911072';
    public static final String BOOKING_ID='XXXXX';
    public static final String COLOR='Black';
    public static final String FILE_NAME='Dummy';


    public static void pdfCalloutWhatsAppDemoMethod() {
       String recipientNumber = '91'+ PHONE_NUMBER;
       
       

       Http http = new Http();
       HttpRequest req = new HttpRequest();
       req.setEndpoint(ENDPOINT_URL+'/api/v1/WhatsAppSendOzone/reply');
       req.setMethod('POST');
       req.setTimeout(2000);
       req.setHeader('apikey', API_KEY);
       req.setHeader('Content-Type', 'application/json');

       Map<String,Object> payload = new Map<String,Object>();
       Map<String,Object> recipient = new Map<String,Object>();
       recipient.put('id',recipientNumber);

       Map<String,Object> header = new Map<String,Object>();
       Map<String,Object> document = new Map<String,Object>();
       document.put('filename',FILE_NAME); 
       document.put('link',PDF_FILE);
       
       header.put('document',document);
       header.put('type','document');

       Map<String,Object> parameters = new Map<String,Object>();
       
       parameters.put('2',COLOR);
       parameters.put('1',BOOKING_ID);
       

       Map<String,Object> template = new Map<String,Object>();
       template.put('parameters',parameters);
       template.put('language','en_US');
       template.put('name',TEMPLATE_NAME);

       payload.put('template',template);
       payload.put('header',header);
       payload.put('type','template');
       payload.put('kookoo_id','OZNTLWA:919573794341');
       payload.put('recipient',recipient);


    // 
    
   // new Template Try(3rd try)
//    Map<String,Object> recipient = new Map<String,Object>();
//    recipient.put('id',recipientNumber);

//    Map<String,Object> message = new Map<String,Object>();
//    message.put('caption','Ride River PDF');
//    message.put('text',PDF_FILE);
   
//    payload.put('message',message);
//    payload.put('type','document');
//    payload.put('kookoo_id','OZNTLWA:919573794341');
//    payload.put('recipient',recipient);
   //upto this
   //4th Try
//    Map<String,Object> recipient = new Map<String,Object>();
//        recipient.put('id',recipientNumber);

//        Map<String,Object> header = new Map<String,Object>();
//        Map<String,Object> document = new Map<String,Object>();
//        document.put('link',PDF_FILE); 
       
       
//        header.put('document',document);
//        header.put('type','document');

//        Map<String,Object> parameters = new Map<String,Object>();
       
//        parameters.put('2',COLOR);
//        parameters.put('1',BOOKING_ID);
       

//        Map<String,Object> template = new Map<String,Object>();
//        template.put('parameters',parameters);
//        template.put('language','en_US');
//        template.put('name',TEMPLATE_NAME);

//        payload.put('template',template);
//        payload.put('header',header);
//        payload.put('type','template');
//        payload.put('kookoo_id','OZNTLWA:919573794341');
//        payload.put('recipient',recipient);
   //
   //5th try
    
      
       String reqBody = JSON.serialize(payload);
       System.debug('Request Body==>'+JSON.serializePretty(payload));
       try{
        HttpResponse response = http.send(req);
                if (response.getStatusCode() == 200) {
                    System.debug('Success: ' + response.getBody());
                } else {
                    System.debug('Error: ' + response.getStatusCode() + ' ' + response.getBody());
                }
       }
       catch(Exception e ){
        System.debug('Error is ==>'+e.getMessage());
        System.debug('Error Line Is ====>'+e.getLineNumber());
       }


    } 
}