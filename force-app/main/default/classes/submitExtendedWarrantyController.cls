/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class submitExtendedWarrantyController {
    @AuraEnabled(cacheable = true)
    public static wrapperForEW getVehicleDetailsForEW(String recordId){
        
        try {
            System.debug('RecordId===>'+recordId);
            if(recordId != null){
                List<Vehicle> vehicleList = [Select Id,Purchased_Date__c,ChassisNumber,Name,RR_Battery_Number__c,EngineNumber,Charger_PC_Number__c,Dealer__c,EW_Submitted__c,Dealer__r.Center_Code__c from Vehicle Where Id =:recordId LIMIT 1];
                if(vehicleList.size()>0){
                    Vehicle v = vehicleList[0];
                    
                       
                            wrapperForEW w = new wrapperForEW();
                            w.dealerCode = v.Dealer__r.Center_Code__c;
                            w.purchaseDate = v.Purchased_Date__c;
                            w.chassisNumber = v.ChassisNumber;
                            w.model = v.Name;
                            w.battery = v.RR_Battery_Number__c;
                            w.engineNumber = v.EngineNumber;
                            w.charger = v.Charger_PC_Number__c;
                            w.EWSubmitted = v.EW_Submitted__c;
            
                            return w;
                            
                       
                    
                }   
            }  
                return null;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
           
    }
    public class wrapperForEW{
        @AuraEnabled
        public String dealerCode{get;set;}
        @AuraEnabled
        public Date purchaseDate{get;set;}
        @AuraEnabled
        public String chassisNumber{get;set;}
        @AuraEnabled
        public String model{get;set;}
        @AuraEnabled
        public String battery{get;set;}
        @AuraEnabled
        public String engineNumber{get;set;}
        @AuraEnabled
        public String charger{get;set;}
        @AuraEnabled 
        public Boolean EWSubmitted{get;set;}


    }
    @AuraEnabled
    public static String callTheEWAPIQueueable(String dataToPassInString,String recordId){
        try {
            
            if(dataToPassInString != null && recordId !=null){
                System.debug('JSON to Pass to Queueable==>'+dataToPassInString);
                System.debug('RecoordId==>'+recordId);
                //System.enqueueJob(new QueueableForExtendedWarrantyAPICall(dataToPassInString,recordId));

            List<EW_API_Details__c> ewDetails= EW_API_Details__c.getAll().values();
            EW_API_Details__c apiDetails = EW_API_Details__c.getInstance('EW Integration');
            String endPoint = apiDetails.API_Endpoint__c != null ? apiDetails.API_Endpoint__c : '';
            String token = apiDetails.Token__c != null ? apiDetails.Token__c : '';
            String apiKey =  apiDetails.API_Key__c != null ? apiDetails.API_Key__c : '';
            String cookie = apiDetails.Cookie__c != null ? apiDetails.Cookie__c : '';

            //data from LWC
            Map<String,Object> dataToPassToPayload = (Map<String,Object>) JSON.deserializeUntyped(dataToPassInString);
            String username = (String) dataToPassToPayload.get('dealerCode') != null ? (String) dataToPassToPayload.get('dealerCode') :'';
            String purchaseDateStr = (String) dataToPassToPayload.get('purchaseDate') !=null ? (String) dataToPassToPayload.get('purchaseDate') : '';
            String ChassisNo = (String) dataToPassToPayload.get('chassisNumber') !=null ? (String) dataToPassToPayload.get('chassisNumber') : '';
            String Model = (String) dataToPassToPayload.get('model') != null ? (String) dataToPassToPayload.get('model') : '';
            String BatteryNo = (String) dataToPassToPayload.get('battery') != null ? (String) dataToPassToPayload.get('battery') : '';
            String Motor = (String) dataToPassToPayload.get('engineNumber') != null ? (String) dataToPassToPayload.get('engineNumber') : '';
            String Charger = (String) dataToPassToPayload.get('charger') != null ? (String) dataToPassToPayload.get('charger') : '';
            String WarrantyType = (String) dataToPassToPayload.get('warrantyType') != null ? (String) dataToPassToPayload.get('warrantyType') : '';
            String SoldFrom = (String) dataToPassToPayload.get('saleOrigin') != null ? (String) dataToPassToPayload.get('saleOrigin') : '';

            //formating the date
            System.debug('purchaseDateStr==>'+purchaseDateStr);
            Date purchaseDate = Date.valueOf(purchaseDateStr);
                System.debug('purchaseDate==>'+purchaseDate);
            String VehicleSaleDate = purchaseDate.format(); 
                System.debug('VehicleSaleDate==>'+VehicleSaleDate);
            String formattedVehicleSaleDate = DateTime.newInstance(purchaseDate.year(), purchaseDate.month(), purchaseDate.day(), 0, 0, 0).format('dd-MM-yyyy');
                System.debug('formattedVehicleSaleDate==>'+formattedVehicleSaleDate);

             
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
            req.setHeader('Authorization','Token '+token);
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

                    Vehicle v = [Select Id,Policy_Number__c,EW_Start_Date__c,EW_Expire_Date__c,Dealer_Amount__c,Customer_Amount__c,EW_Submitted__c from Vehicle WHERE Id =:recordId LIMIT 1];
                    v.Policy_Number__c = (String) responseMap.get('Policy No');
                    v.EW_Start_Date__c= ewStartDate;
                    v.EW_Expire_Date__c = ewExpireDate;
                    v.Dealer_Amount__c = dealerAmount;
                    v.Customer_Amount__c = customerAmount;
                    v.EW_Submitted__c=true;
                    
                    update v;
                    System.debug('Updated Vehicle==>'+v);
                
                    return 'SUCCESS'; 

                }else if(res.getStatusCode() == 400 ){
                    String errorMessage = '';
                    Map<String,Object> responseMapForError = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    System.debug('responseMapForError==>'+responseMapForError);
                    errorMessage = (String) responseMapForError.get('message');
                    System.debug(' '+errorMessage);
                    return errorMessage;
                }
            }
            catch(Exception err){
                
                System.debug('Error is ==>'+err.getMessage());
                System.debug('Error Line Is ==>'+err.getLineNumber());
            }

            }
            
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
     

   
}