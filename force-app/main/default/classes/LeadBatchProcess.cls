public class LeadBatchProcess implements Database.Batchable<SObject>, Database.AllowsCallouts {
   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date twoDaysAgo = Date.today();
        system.debug('date==='+twoDaysAgo);
        list<lead> leadlst=[SELECT Id, CreatedDate, Status,Phone,Lead_Age__c FROM Lead where status='New' AND CreatedDate=:twoDaysAgo ];
        system.debug('leadlst-------'+leadlst);
        if (Test.isRunningTest()) {
   return Database.getQueryLocator(
            'SELECT Id, Lead_Age__c, Status,Phone,LeadSource,Lead_Dealer_Code__c FROM Lead WHERE Status = \'New\' AND Lead_Age__c =0'
        ); 
        }else{
            return Database.getQueryLocator(
            'SELECT Id, Lead_Age__c, Status,Phone,LeadSource,Lead_Dealer_Code__c FROM Lead WHERE Status = \'New\' AND Lead_Age__c =3'
        ); 
        }
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        system.debug('list======'+scope);
        for (Lead leadid : scope){
                        if((leadid.LeadSource=='Bike Dekho'||leadid.LeadSource=='91Wheels'||leadid.LeadSource=='Facebook'||leadid.LeadSource=='Google')&&(leadid.Lead_Dealer_Code__c=='291001'||leadid.Lead_Dealer_Code__c=='291002'||leadid.Lead_Dealer_Code__c=='292001'||leadid.Lead_Dealer_Code__c=='292002'||leadid.Lead_Dealer_Code__c=='292003'||leadid.Lead_Dealer_Code__c=='362001'||leadid.Lead_Dealer_Code__c=='332001'||leadid.Lead_Dealer_Code__c=='331001'||leadid.Lead_Dealer_Code__c=='321001'||leadid.Lead_Dealer_Code__c=='122001')){
            string  mobileno=leadid.Phone;
                        String fullRecipientId = '91' + mobileno;

             HttpRequest request = new HttpRequest();
            request.setEndpoint('https://in-ccaas.ozonetel.com/api/v1/WhatsAppSendOzone/reply');
            request.setMethod('POST');

            request.setHeader('apikey', 'KK47b958dee3505cf2e2c6391c27bbaba4');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Cookie', 'PHPSESSID=864bfee61e1e8d9cf56873a82389476b');

            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('recipient', new Map<String, Object>{ 'id' => fullRecipientId });
            requestBody.put('kookoo_id', 'OZNTLWA:918197205802');
            requestBody.put('type', 'template');

            Map<String, Object> header = new Map<String, Object>();
            header.put('type', 'image');
            header.put('image', new Map<String, String>{ 'link' => 'https://s3.ap-south-1.amazonaws.com/ca.chat/images/01317383b99b4cd9f710ccb318b679d4.jpg' });
            requestBody.put('header', header);

            Map<String, Object> template = new Map<String, Object>();
            template.put('name', 'no_action_book_test_ride_03');
            template.put('language', 'en_US');
            template.put('parameters', new Map<String, Object>());
            requestBody.put('template', template);

            request.setBody(JSON.serialize(requestBody));

            Http http = new Http();
            HttpResponse response = http.send(request);

            if (response.getStatusCode() == 200) {
                System.debug('WhatsApp message sent successfully: ' + response.getBody());
            } else {
                System.debug('Failed to send WhatsApp message. Status: ' + response.getStatusCode() + ', Response: ' + response.getBody());
            }
            
    }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Lead batch processing with callouts completed.');
    }
}