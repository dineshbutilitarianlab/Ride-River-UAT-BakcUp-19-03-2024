/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 01-29-2025
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class Testridewhatsappmsgforbatchprocess implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date twoDaysAgo = Date.today();
        DateTime startOfDay = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
DateTime endOfDay = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 999));
 
//changes for making this code dynamic(Aniket==>29/01/2025)
 
 
List<Test_Drive__c> testDrives = [
    SELECT Id, Lead__c, Test_Ride_Date__c, Ride_Type__c
    FROM Test_Drive__c
    WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay
];
 
        if (Test.isRunningTest()) {
  return Database.getQueryLocator(
    'SELECT Id, Lead__c, Test_Ride_Date__c, Ride_Type__c ' +
    'FROM Test_Drive__c ' +
    'WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay'
);
        }else{
          return Database.getQueryLocator(
    'SELECT Id, Lead__c, Test_Ride_Date__c, Ride_Type__c ' +
    'FROM Test_Drive__c ' +
    'WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay'
);
        }
    }
 
    public void execute(Database.BatchableContext bc, List<Test_Drive__c> scope) {
 
List<WhatsappIntegration__c> ws = WhatsappIntegration__c.getAll().values();
WhatsappIntegration__c w = WhatsappIntegration__c.getInstance('WhatsApp API');
String url = w.API_Endpoint__c;
String apikey = w.API_Key__c;
String templateName = 'on_day_of_test_ride';
 
Set<String> dealerCodeSet = new Set<String>();
Map<String,String> codeByStoreMap = new Map<String,String>();
List<Store_Details__mdt> dealerCodes = [Select id,Dealer_Code__c,IsActive__c,Name__c From Store_Details__mdt WHERE IsActive__c = true];
for(Store_Details__mdt s : dealerCodes){
    dealerCodeSet.add(s.Dealer_Code__c);
    codeByStoreMap.put(s.Dealer_Code__c,s.Name__c);
}
 
        system.debug('list======'+scope);
        for(Test_Drive__c td:scope){
       list<lead> leaddetails=[select Id ,LeadSource,Dealer_Code__c,phone from Lead where Id=:td.Lead__c and Dealer_Code__c IN:dealerCodeSet];
            for(lead leadid:leaddetails){
                string parameter;
                string recientphoneno=leadid.Phone;
                string fullrecientphoneno='91'+recientphoneno;
         if(leadid.LeadSource!='OzoneTel WhatsApp'){//Need to change the LeadSource As per further input
               system.debug('phone'+fullrecientphoneno);
             if(td.Ride_Type__c=='Home Ride'){
                    parameter='At Your Doorstep';
                }else if(td.Ride_Type__c=='Store Ride'){
                    parameter=codeByStoreMap.get(leadid.Dealer_Code__c);
 
                }

 
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('recipient', new Map<String, String>{ 'id' => fullrecientphoneno });
        requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
        requestBody.put('type', 'template');
 
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
            System.debug('Response Status: ' + res.getStatus());
            System.debug('Response Body: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        }

}
            }
        }
    }
 
    public void finish(Database.BatchableContext bc) {
        System.debug('Lead batch processing with callouts completed.');
    }
}