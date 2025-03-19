@RestResource(urlMapping='/VIN_Verification')
global with sharing class VIN_VerificationAPI {
    
    @HttpPost
    global static void verifyVIN() {
        
        Map<String, Object> response = new Map<String, Object>();
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        string VIN = '';
        string phone = '';
        
        If(!requestMap.containsKey('vin_number')){
            Throw new CommonException('Required field missing (vin_number)');
        }else {
           VIN = (String)requestMap.get('vin_number') != null? (String)requestMap.get('vin_number'):''; 
        }
        
        If(!requestMap.containsKey('phone_number')){
            Throw new CommonException('Required field missing (phone_number)');
        }else {
           phone = (String)requestMap.get('phone_number') != null? (String)requestMap.get('phone_number'):''; 
        }
            
        try{
            //Check the vehicle against VIN no.
            List<Vehicle> vehicle = [SELECT Id,Name, Colour__c,CurrentOwner.Name, CurrentOwner.Phone, CurrentOwnerId, VehicleRegistrationNumber, VehicleDefinition.ModelCode, 
                                     VehicleDefinition.Product.Colour__c,VehicleIdentificationNumber, Asset.PurchaseDate, Purchased_Date__c  
                                     FROM Vehicle 
                                     WHERE VehicleIdentificationNumber =:VIN 
                                     LIMIT 1];
            
            
            If(vehicle.size()!= 1){
                Throw new CommonException('Vehicle not found with this VIN number');
            }
            /*else If(phone != vehicle[0].CurrentOwner.Phone){
                Throw new CommonException('Owner\'s Phone number does not match');
            }*/
            
            //Fetch primary contact
            List<Contact> conObjList = [SELECT Id,Email,Phone,Name 
                              FROM Contact 
                              WHERE AccountId =: vehicle[0].CurrentOwnerId 
                              AND Primary_Contact__c = true];
            
            
            Contact conObj = new Contact();
            
            If(conObjList.size()<=0){
                Throw new CommonException('Primary contact not set');
            }else{
                conObj = conObjList[0];
                
                If(phone != conObjList[0].Phone){
                    Throw new CommonException('Owner\'s Phone number does not match');
                }                
            }
            
            //Check the warranties
            List<AssetWarranty> assetWarranties = [SELECT id, WarrantyType FROM AssetWarranty WHERE AssetId = :vehicle[0].AssetId];
            
            string warrantytype = 'Standard';
            For(AssetWarranty asst : assetWarranties){
                If(asst.WarrantyType == 'Extended'){
                    warrantytype = 'Extended';
                }
            }
            
            // Prepare the response
            response.put('status', 'Success'); 
            
            response.put('fullname', conObj.Name);
            response.put('email', conObj.Email);
            response.put('phone', conObj.Phone);
            response.put('vehicle_name', vehicle[0].Name);
            response.put('vehicle_colour',vehicle[0].Colour__c);
            response.put('vehicle_registration_no', vehicle[0].VehicleRegistrationNumber);
            response.put('vin_number', vehicle[0].VehicleIdentificationNumber);
            response.put('purchase_date', vehicle[0].Purchased_Date__c);
            response.put('warranty_type', warrantytype);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('VIN Verification', requestMap, 'Success',response, '');
            
        } catch (Exception e) {
            
            // Handle exceptions and prepare an error response
            if (res != null) {
                handleException(res, e, requestMap);
            }
            
        }
    }
    
    // Helper method to create a log record
    private static void createLogRecord(String integrationType, Map<String, Object> request, String status, Map<String, Object> response, string errormessage) {
        
        Integration_log__c logObj = new Integration_log__c();
        logObj.Integration_Type__c = integrationType;
        logObj.Request_Payload__c = JSON.serializePretty(request);
        logObj.Response_Payload__c = JSON.seriaLizePretty(response);
        
        If(status != 'Success'){
            logObj.Error_Message__c = errormessage;
        }
        
        logObj.Status__c = status;
        insert logObj;
    }
    
    // Helper method to handle exceptions and create error log records
    private static void handleException(RestResponse res, Exception e, Map<String, Object> requestMap) {
        if (res != null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'Error');
            response.put('message', e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('VIN Verification', requestMap, 'Failed',response, e.getMessage());
        }
    }
    
    Global class CommonException extends Exception {}
    
}