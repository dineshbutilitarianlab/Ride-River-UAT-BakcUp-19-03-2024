/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class QueueableOnDayOfTestRide implements Queueable, Database.allowsCallouts{
    private List<Id> testDriveIds;
    private String templateName;
    private String parameters;
    private Map<Id,String> idToPhoneMap;
    private Map<Id, String> testDriveIdToStoreMap;
    private String imageUrl;

    public QueueableOnDayOfTestRide(List<Id> testDriveIds, String templateName, String parameters,Map<Id, String> idToPhoneMap, Map<Id, String> testDriveIdToStoreMap,String imageUrl) {
        this.testDriveIds = testDriveIds;
        this.templateName = templateName;
        this.parameters = parameters;
        this.idToPhoneMap = idToPhoneMap;
        this.testDriveIdToStoreMap = testDriveIdToStoreMap;
        this.imageUrl=imageUrl;
    }
    
    public void execute(QueueableContext qc){
        if (!testDriveIds.isEmpty()) {
            Id currentTestDriveId = testDriveIds.remove(0);
            String phoneNumber = idToPhoneMap.get(currentTestDriveId);
            String currentParameter = parameters;

            
            if (testDriveIdToStoreMap != null && testDriveIdToStoreMap.containsKey(currentTestDriveId)) {
                currentParameter = testDriveIdToStoreMap.get(currentTestDriveId); 
            }

            system.debug('currentTestDriveId ===> ' + currentTestDriveId);
            system.debug('phoneNumber ===> ' + phoneNumber);
            system.debug('parameters ===> ' + currentParameter);
            system.debug('templateName ===> ' + templateName);

            if (phoneNumber != null && currentTestDriveId != null) {
                withOutParamMsg(phoneNumber, templateName, currentParameter,imageUrl);
            }

            if (!testDriveIds.isEmpty() && !Test.isRunningTest()) {
                System.enqueueJob(new QueueableOnDayOfTestRide(testDriveIds, templateName, parameters, idToPhoneMap, testDriveIdToStoreMap,imageUrl));
            }
        }

    }
    public static void withOutParamMsg(String phoneNumber,String templateName,String parameter,String imageUrl){
        List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
        WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
        String url = w.API_Endpoint__c;
        String apikey = w.API_Key__c;

        String fullrecientphoneno = '91'+phoneNumber;
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('recipient', new Map<String, String>{ 'id' => fullrecientphoneno });
        requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
        requestBody.put('type', 'template');

        //new imageUrl Header 04/02/2025 By Aniket
        Map<String,Object> header = new Map<String,Object>();
        Map<String,Object> image = new Map<String,Object>();
        image.put('link',imageUrl);
        header.put('type','image');
        header.put('image',image);

        requestBody.put('header',header);
        //up to here
 
        Map<String, Object> template = new Map<String, Object>();
        template.put('name', templateName);
        template.put('language', 'en_US');
        template.put('parameters', new Map<String, String>{ '2' => parameter });
 
        requestBody.put('template', template);
 
        String jsonBody = JSON.serialize(requestBody);
 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('apikey',apikey );
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Cookie', 'PHPSESSID=864bfee61e1e8d9cf56873a82389476b');
        req.setBody(jsonBody);
 
        Http http = new Http();
        try {
            HttpResponse res = http.send(req);

            String status;
            if(res.getStatusCode()==200){
                status='Success';
            }else{
                status='Failed';
            }
            IntegrationLogHelper.IntegrationLogWrapper wrapper = new IntegrationLogHelper.IntegrationLogWrapper();
                    wrapper.requestBody = jsonBody;
                    wrapper.responseBody = res.getBody();
                    wrapper.status = status;
                    wrapper.templateName = templateName;
                    wrapper.statusCode = String.valueof(res.getStatusCode());

                    IntegrationLogHelper.createIntegrationLogs(wrapper);
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Body: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }
       
    }
}