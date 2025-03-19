/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QueueableOnOrderRTOStage implements Queueable, Database.allowsCallouts{
    private List<Id> orderIdsToProcess;
    private Map<Id,OrderTriggerHandler.wrapperForAllotment> toPassToQueueable;

    public QueueableOnOrderRTOStage(List<Id> orderIdsToProcess, Map<Id,OrderTriggerHandler.wrapperForAllotment> toPassToQueueable){
        this.orderIdsToProcess=orderIdsToProcess;
        this.toPassToQueueable=toPassToQueueable;

    }
    
    public void execute(QueueableContext qc){
        if(!orderIdsToProcess.isEmpty()){
            Id currentOrderId = orderIdsToProcess.remove(0);
        
                String PhoneNumber = toPassToQueueable.get(currentOrderId).phoneNumber;
                String fileName = toPassToQueueable.get(currentOrderId).fileName;
                String allotMentFileLinks = toPassToQueueable.get(currentOrderId).allotMentFileLinks;
            
            System.debug('PhoneNumber==>'+PhoneNumber);
            System.debug('fileName==>'+fileName);
            System.debug('allotMentFileLinks==>'+allotMentFileLinks);
            
            if(PhoneNumber!=null && fileName!=null && allotMentFileLinks!=null){
                sendWhatsAppAfterAllotment(PhoneNumber,fileName,allotMentFileLinks);
            }
            if(!orderIdsToProcess.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new QueueableOnOrderRTOStage(orderIdsToProcess,toPassToQueueable));
            }
              
        }
        
    }
    public static void sendWhatsAppAfterAllotment(String PhoneNumber,String fileName,String allotMentFileLinks){
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c !=null? w.API_Endpoint__c : '';
        String apikey =  w.API_Key__c !=null? w.API_Key__c : '';
        
        String fullPhoneNumber = '+91'+PhoneNumber;
        String templateName='rto_with_invoice';

        Map<String,Object> payload = new Map<String,Object>();

        Map<String,Object> recipient = new Map<String,Object>();
        recipient.put('id',fullPhoneNumber);

        
        Map<String,Object> document = new Map<String,Object>();
        document.put('filename',fileName);
        document.put('link',allotMentFileLinks);

        Map<String,Object> header = new Map<String,Object>();
        header.put('document',document);
        header.put('type','document');

        Map<String,Object> parameters = new Map<String,Object>();

        Map<String,Object> template = new Map<String,Object>();
        template.put('parameters',parameters);
        template.put('language','en_US');
        template.put('name',templateName);

        payload.put('template',template);
        payload.put('header',header);
        payload.put('type','template');
        payload.put('kookoo_id','OZNTLWA:918197205802');
        payload.put('recipient',recipient);

        String reqBody = JSON.serialize(payload);
        System.debug('Req Body ===>'+JSON.serializePretty(payload));

        try{
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Cookie','PHPSESSID=b1b5beb88ec80de98066dad0b5c9349d');
            req.setHeader('Content-type','application/json');
            req.setHeader('apikey',apikey);
            req.setEndpoint(url);
            req.setBody(reqBody);

            HttpResponse res = http.send(req);

            String status;
            if(res.getStatusCode()==200){
                status='Success';
            }else{
                status='Failed';
            }
            IntegrationLogHelper.IntegrationLogWrapper wrapper = new IntegrationLogHelper.IntegrationLogWrapper();
                    wrapper.requestBody = reqBody;
                    wrapper.responseBody = res.getBody();
                    wrapper.status = status;
                    wrapper.templateName = templateName;
                    wrapper.statusCode = String.valueof(res.getStatusCode());

                    IntegrationLogHelper.createIntegrationLogs(wrapper);
            System.debug('Response body =====>'+res.getBody());
           // System.debug('Response body =====>'+res.getStatus());
            System.debug('Response body =====>'+res.getStatusCode());



        }catch(Exception e){
            System.debug('Error is==>'+e.getMessage());
            System.debug('Error Line Number ===>'+e.getLineNumber());
        }




    }

}