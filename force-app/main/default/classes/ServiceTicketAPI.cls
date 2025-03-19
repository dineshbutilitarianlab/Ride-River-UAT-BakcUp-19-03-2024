@RestResource(urlMapping='/ServiceTicket')
global class ServiceTicketAPI {
@HttpPost
    global static void ServiceTicket() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> response = new Map<String, Object>();  
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        string VIN = (String)requestMap.get('vin') != null? (String)requestMap.get('vin'):'';
        string centerCode = (String)requestMap.get('service_center_code') != null? (String)requestMap.get('service_center_code'):'';
        DateTime scheduledDateTime = (String)requestMap.get('scheduled_date') == null? system.now(): DateTime.valueOf((String)requestMap.get('scheduled_date'));
        
        system.debug(JSON.serializePretty(requestMap));
        
        try{
            
      /*    If((String)requestMap.get('service_center_code') == null){
                Throw new CommonException('Required field missing! (service_center_code)');
            }else */
            If((String)requestMap.get('service_type') == null){
                Throw new CommonException('Required field missing! (service_type)');
            }else If((String)requestMap.get('vin') == null){
                Throw new CommonException('Required field missing! (vin)');
            }
        /*  else If((String)requestMap.get('scheduled_date') == null){
                Throw new CommonException('Required field missing! (scheduled_date)');
            }   */
            
            //Check the vehicle against VIN no.
            List<Vehicle> vehicle = [SELECT Id,	CurrentOwner.Name, AssetId, CurrentOwner.Phone, Grace_Period__c, CurrentOwnerId, VehicleRegistrationNumber, VehicleDefinition.ModelCode, VehicleDefinition.Product.Colour__c,VehicleIdentificationNumber, Asset.PurchaseDate  
                                     FROM Vehicle 
                                     WHERE VehicleIdentificationNumber = :VIN 
                                     LIMIT 1];
            
            //Fetch the service center by code
            List<Account> servicecenter = new List<Account>();
            if(centerCode!= null && centerCode != ''){
                servicecenter = [SELECT Id, Name 
                                           FROM Account 
                                           WHERE Center_Code__c = :centerCode 
                                           LIMIT 1];
            }        
            
            If(vehicle.size()!= 1){
                Throw new CommonException('Vehicle not found with this VIN number');
            }
       /*   else If(servicecenter.size() != 1){
                Throw new CommonException('No servce center found with this code');
            }  */
            
            //Fetch primary contact
            Contact conObj = [SELECT Id,Email FROM Contact WHERE AccountId =: vehicle[0].CurrentOwnerId AND Primary_Contact__c = true];
            
            List<AssetMilestone> asset = new List<AssetMilestone>();
            dateTime duedate;
            
            If(requestMap.containsKey('service_type') && requestMap.containsKey('periodic_maintenance_type')){
                asset = [SELECT Id, Name, MilestoneDate FROM AssetMilestone WHERE MilestoneType = :(string)requestMap.get('periodic_maintenance_type') AND AssetId = :vehicle[0].AssetId];
                
                If(asset.size()>0 && asset[0].MilestoneDate != null){
                    duedate = (dateTime)asset[0].MilestoneDate.adddays(vehicle[0].Grace_Period__c != null ?(integer)vehicle[0].Grace_Period__c:30);
                }else{
                    duedate = scheduledDateTime.adddays(vehicle[0].Grace_Period__c != null ?(integer)vehicle[0].Grace_Period__c:30);
                }
                
                If(duedate!= null && duedate<=scheduledDateTime){
                    Throw new CommonException('You can not create a service appointment for the selected type of periodic service, as the period for taking vehicle service is over.');
                }
            }else{
                duedate = scheduledDateTime.adddays(10);
            }
            
           
            
            Serviceappointment svr = new serviceappointment(
            	ContactId = conObj.Id,
              //  Service_Centre__c = servicecenter[0].id,
                ParentRecordId = vehicle[0].CurrentOwnerId,
                Vehicle__c = vehicle[0].Id,
                Asset_Milestone__c = asset.size()>0?asset[0].Id:null,
                DueDate = duedate != null? duedate : scheduledDateTime.addDays(10),
                Status = 'Requested'
            /*  EarliestStartTime = scheduledDateTime,                                
                Service_Type__c = requestMap.containsKey('service_type')?(String)requestMap.get('service_type'):'',               
                Periodic_Maintenance_Type__c = requestMap.containsKey('periodic_maintenance_type')?(String)requestMap.get('periodic_maintenance_type'):''
              */  
            );
            if (servicecenter != null && !servicecenter.isEmpty()) {
                svr.Service_Centre__c = servicecenter[0].Id;
            }
            Insert svr;
            
            // Prepare the response
            response.put('status', 'Success');            
           // response.put('owner_name', vehicle[0].CurrentOwner.Name);
            response.put('crm_appointment_id', svr.Id);
          //  response.put('service_type', svr.Service_Type__c);
           // response.put('service_center_name', servicecenter.isEmpty() ? 'Not Provided' : servicecenter[0].Name);
            response.put('due_date', svr.DueDate != null ? svr.DueDate.addHours(5).addMinutes(30) : null);
           // response.put('vehicle_registration_no', vehicle[0].VehicleRegistrationNumber);
            response.put('vin', vehicle[0].VehicleIdentificationNumber);
            
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Service Appointment creation', requestMap, 'Success',response, '');
            
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
    global static void handleException(RestResponse res, Exception e, Map<String, Object> requestMap) {
        if (res != null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'Error');
            response.put('message', e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Service Appointment creation', requestMap, 'Failed',response, e.getMessage());
        }
    }
    
    Global class CommonException extends Exception {}
}