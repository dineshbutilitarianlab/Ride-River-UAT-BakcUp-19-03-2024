/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-25-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class QueueableForExtendedWarrantyAPICall implements Queueable, Database.allowsCallouts{
    private String dataToPassInString;
    private String recordId;

    public QueueableForExtendedWarrantyAPICall(String dataToPassInString,String recordId){
        this.dataToPassInString = dataToPassInString;
        this.recordId = recordId;

        System.debug('dataToPassInString'+dataToPassInString);
        System.debug('recordId'+recordId);
    }
    public void execute(QueueableContext qc){
        try{
            List<EW_API_Details__c> ewDetails= EW_API_Details__c.getAll().values();
            EW_API_Details__c apiDetails = EW_API_Details__c.getInstance('EW Integration');
            String endPoint = apiDetails.API_Endpoint__c != null ? apiDetails.API_Endpoint__c : '';
            String token = apiDetails.Token__c != null ? apiDetails.Token__c : '';
            String apiKey =  apiDetails.API_Key__c != null ? apiDetails.API_Key__c : '';
            String cookie = apiDetails.Cookie__c != null ? apiDetails.Cookie__c : '';

            //data from LWC
            Map<String,Object> dataToPassToPayload = (Map<String,Object>) JSON.deserializeUntyped(dataToPassInString);
            String username = (String) dataToPassToPayload.get('dealerCode');
            String purchaseDateStr = (String) dataToPassToPayload.get('purchaseDate');
            String ChassisNo = (String) dataToPassToPayload.get('chassisNumber');
            String Model = (String) dataToPassToPayload.get('model');
            String BatteryNo = (String) dataToPassToPayload.get('battery');
            String Motor = (String) dataToPassToPayload.get('engineNumber');
            String Charger = (String) dataToPassToPayload.get('charger');
            String WarrantyType = (String) dataToPassToPayload.get('warrantyType');
            String SoldFrom = (String) dataToPassToPayload.get('saleOrigin');

            //formating the date
            
            Date purchaseDate = Date.valueOf(purchaseDateStr);
            String VehicleSaleDate = purchaseDate.format(); 
            String formattedVehicleSaleDate = DateTime.newInstance(purchaseDate.year(), purchaseDate.month(), purchaseDate.day(), 0, 0, 0).format('dd-MM-yyyy');


             
            //
            Map<String,Object> payLoad = new Map<String,Object>();
            payLoad.put('username',username);
            payLoad.put('VehicleSaleDate',formattedVehicleSaleDate);
            payLoad.put('ChassisNo',ChassisNo);
            payLoad.put('Model',Model);
            payLoad.put('BatteryNo',BatteryNo);
            payLoad.put('Motor',Motor);
            payLoad.put('Charger',Charger);
            payLoad.put('WarrantyType',WarrantyType);
            payLoad.put('SoldFrom',SoldFrom);
            String reqBody = JSON.serialize(payLoad);
            System.debug('Request body=>'+JSON.serializePretty(payLoad));


            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Cookie',cookie);
            req.setHeader('Authorization',token);
            req.setHeader('X-API-Key',apiKey);
            req.setBody(reqBody);
            
            HttpResponse res = http.send(req);
            ExceptionHelper.createAPICalloutLog(req,res,recordId);
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
                            ewStartDate = Date.valueOf(formattedDateForEWSTART); // Convert String to Date
                            System.debug('Formatted Date for Start: ' + ewStartDate);
                        }
                    }
        
                    Date ewExpireDate;
                    if (inputDateForExpireDate != null && inputDateForExpireDate.contains('-')) {
                        List<String> datePartsForExpire = inputDateForExpireDate.split('-');
                        if (datePartsForExpire.size() == 3) {
                            String formattedDateForEWExpire = datePartsForExpire[2] + '-' + datePartsForExpire[1] + '-' + datePartsForExpire[0];
                            ewExpireDate = Date.valueOf(formattedDateForEWExpire); // Convert String to Date
                            System.debug('Formatted Date For Expire: ' + ewExpireDate);
                        }
                    }
                    //for conversion of Currency Field
                    
                        String dealerAmountStr = String.valueOf(responseMap.get('Dealer Amount'));

                        
                        String customerAmountStr = String.valueOf(responseMap.get('Customer Amount'));

                        // Initialize Decimal variables
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

                    Vehicle v = [Select Id,Policy_Number__c,EW_Start_Date__c,EW_Expire_Date__c,Dealer_Amount__c,Customer_Amount__c from Vehicle WHERE Id =:recordId LIMIT 1];
                    v.Policy_Number__c = (String) responseMap.get('Policy No');
                    v.EW_Start_Date__c= ewStartDate;
                    v.EW_Expire_Date__c = ewExpireDate;
                    v.Dealer_Amount__c = dealerAmount;
                    v.Customer_Amount__c = customerAmount;
                    
                    update v;
                    System.debug('Updated Vehicle==>'+v);

                }
            }
            catch(Exception err){
                System.debug('Error is ==>'+err.getMessage());
                System.debug('Error Line Is ==>'+err.getLineNumber());
            }
        }
        catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Occured==>'+e.getMessage());
            System.debug('Error Line Number ===>'+e.getLineNumber());
        }
    }
}