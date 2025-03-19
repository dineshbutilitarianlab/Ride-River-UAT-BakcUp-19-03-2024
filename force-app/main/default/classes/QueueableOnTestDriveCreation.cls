/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QueueableOnTestDriveCreation implements Queueable,Database.allowsCallouts{
    private List<Id> testDriveIds;
    private Map<Id,String> idToPhoneMap;
    private Map<Id,String> idToTimeMap;
    private Map<Id,String> idToRideTypeMap;
     
    public QueueableOnTestDriveCreation(List<Id> testDriveIds,Map<Id,String> idToPhoneMap,Map<Id,String> idToTimeMap,Map<Id,String> idToRideTypeMap){
        this.testDriveIds = testDriveIds;
        this.idToPhoneMap = idToPhoneMap;
        this.idToTimeMap = idToTimeMap;
        this.idToRideTypeMap = idToRideTypeMap;
    }
    public void execute(QueueableContext qc){
        if(!testDriveIds.isEmpty()){
            Id currentTestDriveId = testDriveIds.remove(0);
            String phoneNumber = idToPhoneMap.get(currentTestDriveId);
            String timeFormat = idToTimeMap.get(currentTestDriveId);
            String rideType = idToRideTypeMap.get(currentTestDriveId);

            System.debug('phoneNumber===>'+phoneNumber);
            System.debug('timeFormat===>'+timeFormat);
            System.debug('rideType===>'+rideType);

            if(phoneNumber!=null && timeFormat!=null && rideType!=null){
                sendWhatsAppMessage(phoneNumber,timeFormat,rideType);
            }
            if(!testDriveIds.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new QueueableOnTestDriveCreation(testDriveIds,idToPhoneMap,idToTimeMap,idToRideTypeMap));
            }
        }

    }
    public static void sendWhatsAppMessage(String phoneNumber,String timeFormat,String rideType){
        String recipientId = '91' + phoneNumber;
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c!=null?w.API_Endpoint__c:'';
        String apikey = w.API_Key__c!=null?w.API_Key__c:'';
        String imageLink = w.test_ride_booked_text_2_image__c;
        
        String templateName = 'test_ride_booked_text2';
        //String endpoint = 'https://in-ccaas.ozonetel.com/api/v1/WhatsAppSendOzone/reply';
 
         Map<String, Object> requestBody = new Map<String, Object>();
 
          //additional fixes
          Map<String,Object> header = new Map<String,Object>();
          header.put('type','image');
          Map<String,Object> image = new Map<String,Object>();
          image.put('link',imageLink);
          header.put('image',image);
 
         requestBody.put('recipient', new Map<String, String>{ 'id' => recipientId });
         requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
         requestBody.put('type', 'template');
         requestBody.put('header',header);
 
         Map<String, Object> template = new Map<String, Object>();
         template.put('name', templateName);
         template.put('language', 'en_US');
         template.put('parameters', new Map<String, String>{ '1' => rideType,
             '2'=>timeFormat });
 
            
 
         requestBody.put('template', template);
 
         String jsonBody = JSON.serialize(requestBody);
         System.debug('jsonBody==>'+jsonBody);

        if(url!=null && apikey!=null && imageLink!=null){
            HttpRequest req = new HttpRequest();
         req.setEndpoint(url);
         req.setMethod('POST');
         req.setHeader('apikey', apikey);
         req.setHeader('Content-Type', 'application/json');
         req.setHeader('Cookie', 'PHPSESSID=864bfee61e1e8d9cf56873a82389476b');
         req.setBody(jsonBody);
 
         Http http = new Http();
         try {
             HttpResponse res = http.send(req);
             String status;
             if(res.getStatusCode()==200){
                status='Success';
                System.debug('Success: ' + res.getBody());
             }else{
                status='Failed';
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getBody());
             }
             System.debug('Calling IntegrationLogHelper.createIntegrationLogs()...');
             IntegrationLogHelper.IntegrationLogWrapper wrapper = new IntegrationLogHelper.IntegrationLogWrapper();
                    wrapper.requestBody = jsonBody;
                    wrapper.responseBody = res.getBody();
                    wrapper.status = status;
                    wrapper.templateName = templateName;
                    wrapper.statusCode = String.valueof(res.getStatusCode());
                    IntegrationLogHelper.createIntegrationLogs(wrapper);
             System.debug('Successfully called IntegrationLogHelper.createIntegrationLogs()');
                
             System.debug('Response Status: ' + res.getStatus());
             System.debug('Response Body: ' + res.getBody());
         } catch (Exception e) {
             System.debug('Error: ' + e.getMessage());
         }
        }
        
 
     }
     public class integrationLogWrapper{
        public String requestBody{get; set;}
        public String responseBody{get; set;}
        public String templateName{get; set;}
        public String status{get;set;}
    }

    }