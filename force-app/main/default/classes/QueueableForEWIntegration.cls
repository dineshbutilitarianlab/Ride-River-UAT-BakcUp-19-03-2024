/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QueueableForEWIntegration implements Queueable, Database.allowsCallouts{
    private List<Id> orderIdsToProcess;
    private Map<Id,OrderTriggerHandler.wrapperForEWIntegration> wrapperValues;
    public QueueableForEWIntegration(List<Id> orderIdsToProcess, Map<Id,OrderTriggerHandler.wrapperForEWIntegration> wrapperValues){
        this.orderIdsToProcess=orderIdsToProcess;
        this.wrapperValues=wrapperValues;

    }
    public void execute(QueueableContext qc){
        if(!orderIdsToProcess.isEmpty()){
            Id currentOrderId = orderIdsToProcess.remove(0);
            
            
            if(currentOrderId != null && wrapperValues!=null){
                calloutToEWAPI(currentOrderId,wrapperValues);
            }
            if(!orderIdsToProcess.isEmpty() && !Test.isRunningTest()){
                System.enqueueJob(new QueueableForEWIntegration(orderIdsToProcess,wrapperValues));
            }
            
    }
}
public static void calloutToEWAPI(Id currentOrderId,Map<Id,OrderTriggerHandler.wrapperForEWIntegration> c){
    try{
            List<EW_API_Details__c> ewDetails= EW_API_Details__c.getAll().values();
            EW_API_Details__c apiDetails = EW_API_Details__c.getInstance('EW Integration');
            String endPoint = apiDetails.API_Endpoint__c != null ? apiDetails.API_Endpoint__c : '';
            String token = apiDetails.Token__c != null ? apiDetails.Token__c : '';
            String apiKey =  apiDetails.API_Key__c != null ? apiDetails.API_Key__c : '';
            String cookie = apiDetails.Cookie__c != null ? apiDetails.Cookie__c : '';
            
            String vpDate = String.valueof(c.get(currentOrderId).purchaseDate);
            System.debug('Date ==>'+vpDate);
            List<String> datePart = vpDate.split('-');
            String dateForReqBody = datePart[2]+'-'+datePart[1]+'-'+datePart[0];
            System.debug('dateForReqBody==>'+dateForReqBody);


            Map<String,Object> payLoad = new Map<String,Object>();
            payLoad.put('username',c.get(currentOrderId).dealerCode);
            payLoad.put('VehicleSaleDate',dateForReqBody);
            payLoad.put('ChassisNo',c.get(currentOrderId).chassisNumber);
            payLoad.put('Model',c.get(currentOrderId).model);
            payLoad.put('BatteryNo',c.get(currentOrderId).battery);
            payLoad.put('Motor',c.get(currentOrderId).engineNumber);
            payLoad.put('Charger',c.get(currentOrderId).charger);
            payLoad.put('WarrantyType','Extended Warranty');
            payLoad.put('SoldFrom','Workshop');
            String reqBody = JSON.serialize(payLoad);
            System.debug('Request body=>'+JSON.serializePretty(payLoad));

            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cookie',cookie);
            req.setHeader('Authorization','Token '+token);
            req.setHeader('X-API-Key',apiKey);
            req.setBody(reqBody);
            
            HttpResponse res = http.send(req);
            try{
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    
                    Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                    System.debug('Response Map==>'+responseMap);
                                            
                    String inputDateForStartDate = String.valueOf(responseMap.get('EW Start Date')); 
                    String inputDateForExpireDate = String.valueOf(responseMap.get('EW Expire Date')); 
                    
                    Date ewStartDate;
                    if (inputDateForStartDate != null && inputDateForStartDate.contains('-')) {
                        List<String> dateParts = inputDateForStartDate.split('-');
                        if (dateParts.size() == 3) {
                            String formattedDateForEWSTART = dateParts[2] + '-' + dateParts[1] + '-' + dateParts[0];
                            ewStartDate = Date.valueOf(formattedDateForEWSTART); 
                            System.debug('Formatted Date for Start: ' + ewStartDate);
                        }
                    }
        
                    Date ewExpireDate;
                    if (inputDateForExpireDate != null && inputDateForExpireDate.contains('-')) {
                        List<String> datePartsForExpire = inputDateForExpireDate.split('-');
                        if (datePartsForExpire.size() == 3) {
                            String formattedDateForEWExpire = datePartsForExpire[2] + '-' + datePartsForExpire[1] + '-' + datePartsForExpire[0];
                            ewExpireDate = Date.valueOf(formattedDateForEWExpire); 
                            System.debug('Formatted Date For Expire: ' + ewExpireDate);
                        }
                    }
                    //for conversion of Currency Field
                    
                        String dealerAmountStr = String.valueOf(responseMap.get('Dealer Amount'));

                        
                        String customerAmountStr = String.valueOf(responseMap.get('Customer Amount'));

                        
                        Decimal dealerAmount = 0;
                        Decimal customerAmount = 0;

                       
                        if (String.isNotBlank(dealerAmountStr)) {
                        try {
                            dealerAmount = Decimal.valueOf(dealerAmountStr);
                            dealerAmount = dealerAmount.setScale(2); 
                        } catch (Exception e) {
                            System.debug('Error converting Dealer Amount to Decimal: ' + e.getMessage());
                        }
                        }

                        
                        if (String.isNotBlank(customerAmountStr)) {
                        try {
                            customerAmount = Decimal.valueOf(customerAmountStr);
                            customerAmount = customerAmount.setScale(2); 
                        } catch (Exception e) {
                            System.debug('Error converting Customer Amount to Decimal: ' + e.getMessage());
                        }
                        }

                    Vehicle v = [Select Id,Policy_Number__c,EW_Start_Date__c,EW_Expire_Date__c,Dealer_Amount__c,Customer_Amount__c,EW_Submitted__c from Vehicle WHERE Id =:c.get(currentOrderId).vehicleId LIMIT 1];
                    v.Policy_Number__c = (String) responseMap.get('Policy No');
                    v.EW_Start_Date__c= ewStartDate;
                    v.EW_Expire_Date__c = ewExpireDate;
                    v.Dealer_Amount__c = dealerAmount;
                    v.Customer_Amount__c = customerAmount;
                    v.EW_Submitted__c=true;                  
                    update v;
                    System.debug('Updated Vehicle==>'+v);
                
                    

                }else if(res.getStatusCode() == 400 ){
                    String errorMessage = '';
                    Map<String,Object> responseMapForError = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    System.debug('responseMapForError==>'+responseMapForError);
                    errorMessage = (String) responseMapForError.get('message');
                    System.debug(' '+errorMessage);
                    
                }
            }
            catch(Exception err){
                
                System.debug('Error is ==>'+err.getMessage());
                System.debug('Error Line Is ==>'+err.getLineNumber());
            }

            }
            catch(Exception e){
                System.debug('Error Occured ==>'+e.getMessage());
                System.debug('Error Line Number Is===>'+e.getLineNumber());
            }

    }
       

}