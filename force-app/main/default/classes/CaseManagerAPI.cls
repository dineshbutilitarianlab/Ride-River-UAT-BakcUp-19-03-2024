@RestResource(urlMapping='/ManageTicket')
global class CaseManagerAPI {
    
    //Method to create the Case
    @HttpPost
    global static void CreateTicket() {
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> response = new Map<String, Object>();  
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        string VIN = (String)requestMap.get('vin') != null? (String)requestMap.get('vin'):'';
        string centerCode = (String)requestMap.get('service_center_code') != null? (String)requestMap.get('service_center_code'):'';
        
        try{
            
            string caseType = requestMap.containsKey('case-type')?(String)requestMap.get('case-type'):'';
            
            If((String)requestMap.get('ticket_description') == null || (String)requestMap.get('ticket_description') == ''){
                Throw new CommonException('Required field missing! (ticket_description)');
            }else If((String)requestMap.get('vin') == null || (String)requestMap.get('vin') == ''){
                Throw new CommonException('Required field missing! (vin)');
            }else If(((String)requestMap.get('service_center_code') == null || (String)requestMap.get('service_center_code') == '') && (caseType == 'Complaint' || caseType == 'Urgent Complaint')){
                Throw new CommonException('Required field missing! (service_center_code)');
            }
            
            //Check the vehicle against VIN no.
            List<Vehicle> vehicle = [SELECT Id,	CurrentOwner.Name, CurrentOwner.Phone, CurrentOwnerId, VehicleRegistrationNumber, VehicleDefinition.ModelCode, VehicleDefinition.Product.Colour__c,VehicleIdentificationNumber, Asset.PurchaseDate  
                                     FROM Vehicle 
                                     WHERE VehicleIdentificationNumber = :VIN
                                     LIMIT 1];            
            
            If(vehicle.size()!= 1){
                Throw new CommonException('Vehicle not found with this VIN number');
            }
            
            List<Account> servicecenter = new List<Account>();
            
            If(caseType == 'Complaint' || caseType == 'Urgent Complaint'){
                
                //Fetch the service center by code
                servicecenter = [SELECT Id, Name 
                                               FROM Account 
                                               WHERE Center_Code__c = :centerCode 
                                               LIMIT 1];
                
                If(servicecenter.size() != 1){
                    Throw new CommonException('No servce center found with this code');
                }
            }
            
            
            //Fetch primary contact
            List<contact> conList = [SELECT Id,Email, Name, Phone FROM Contact WHERE AccountId =: vehicle[0].CurrentOwnerId AND Primary_Contact__c = true LIMIT 1];
            Contact conObj = new contact();
            
            IF(conList.size()>0){
                conObj = conList[0];
            }else{
                Throw new CommonException('Primary contact not set for the vehicle owner account');
            }
            
            Case svr = new Case(
                AccountId = vehicle[0].CurrentOwnerId,
                ContactId = conObj.Id,
                Category__c = 'Minor',
                Vehicle__c = vehicle[0].Id,
                Origin = 'Web',
                Description = (String)requestMap.get('ticket_description'),
                Ticket_Id__c = (String)requestMap.get('app_ticket_id'),
                Case_Type__c = requestMap.containsKey('case-type')?(String)requestMap.get('case-type'):'',
                Subject__c = requestMap.containsKey('subject')?(String)requestMap.get('subject'):'',
                Vehicle_Registration_Number__c = vehicle[0].VehicleRegistrationNumber,
                Vehicle_Identification_Number__c = vehicle[0].VehicleIdentificationNumber
                
            );
            
            If(servicecenter.size() > 0){
                svr.Assign_to_Dealer__c = servicecenter[0].Id;
            }
            
            Insert svr;
            
            // Prepare the response
            response.put('status', 'Success');  
            response.put('crm_ticket_id', svr.Id);
      /*    response.put('app_ticket_id', svr.Ticket_Id__c);
            response.put('owner_name', conObj.Name);
            response.put('email', conObj.Email);
            response.put('phone', conObj.Phone);
            response.put('vehicle_registration_no', vehicle[0].VehicleRegistrationNumber);
            response.put('vin_number', vehicle[0].VehicleIdentificationNumber);
       */     
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Case creation', requestMap, 'Success',response, '');
            
        } catch (Exception e) {
            
            // Handle exceptions and prepare an error response
            if (res != null) {
                handleException(res, e, requestMap);
                //Log Obj creation
            createLogRecord('Case creation', requestMap, 'Failed',response, e.getMessage());
            }
            
        }
        
    }
    
    //Method to update the Images
    @HTTPPATCH
    Global static void updateImages(){
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, Object> response = new Map<String, Object>();  
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        Map<String, String> mimeToExtensionMap = new Map<String, String>{
            'image/jpeg' => 'jpg',
                'image/pjpeg' => 'jpg',
                'image/png' => 'png',
                'image/gif' => 'gif',
                'image/bmp' => 'bmp',
                'image/webp' => 'webp',
                'image/tiff' => 'tiff',
                'image/svg+xml' => 'svg',
                'image/x-icon' => 'ico'
                };
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        string ticketid = (String)requestMap.get('crm_ticket_id') != null? (String)requestMap.get('crm_ticket_id'):'';
        
        try{
            List<Object> imageDatas = (List<Object>)requestMap.get('images');
            
            If((String)requestMap.get('crm_ticket_id') == null || (String)requestMap.get('crm_ticket_id') == ''){
                Throw new CommonException('Required field missing! (crm_ticket_id)');
            }else If((List<Object>)requestMap.get('images') == null){
                Throw new CommonException('Required field missing! (images)');
            }else If(imageDatas.size() < 1){
                Throw new CommonException('No image data! (images)');
            }else If(!requestMap.containsKey('mime_type') || requestMap.get('mime_type') == ''){
                Throw new CommonException('Required field missing! (mime_type)');
            }else If(!mimeToExtensionMap.containsKey((string)requestMap.get('mime_type'))){
                Throw new CommonException('Only the following MIME types are allowed: image/pjpeg, image/png, image/bmp, image/webp, image/tiff, image/svg+xml, image/x-icon.');
            }
            
          	String extension = mimeToExtensionMap.get((string)requestMap.get('mime_type'));
            
            List<Case> relatedCase = [SELECT id,Ticket_Id__c, CaseNumber FROM Case WHERE Id =: (String)requestMap.get('crm_ticket_id') LIMIT 1];
            
            If(relatedCase.size() != 1){
                Throw new CommonException('No case registered with ticket id: '+(String)requestMap.get('crm_ticket_id'));
            }
            
            //call a method to create case attachments and return image URLs
            List<Map<string,string>> mapImageNameToUrlList = createAttachment(imageDatas,relatedCase[0], extension);
            
            // Prepare the response
            response.put('status', 'Success');  
            response.put('crm_ticket_id', relatedCase[0].Id);
            response.put('app_ticket_id', relatedCase[0].Ticket_Id__c);
            response.put('images',mapImageNameToUrlList);
            
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Case creation', null, 'Success',response, '');
            
        } catch (Exception e) {
            
            // Handle exceptions and prepare an error response
            if (res != null) {
                handleException(res, e, requestMap);
                //Log Obj creation
                createLogRecord('Case creation', null, 'Failed',response, e.getMessage());
            }
            
        }
    }
    
    
    public static List<Map<string,string>> createAttachment(List<Object> imageDataList, case caseObj, string extension) {
        List<Map<string,string>> mapImageNameToUrlList = new List<Map<string,string>>();
        List<contentVersion> contentVersions = new List<contentVersion>();
        List<ContentDistribution> distributions = new List<ContentDistribution>();
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        Integer count = 1;
        
        for (Object imageData : imageDataList) {
            
            // Create ContentVersion record
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = caseObj.CaseNumber+'-'+count;
            contentVersion.PathOnClient = contentVersion.Title+'.'+extension;
            contentVersion.VersionData = EncodingUtil.base64Decode((string)imageData);
            contentVersions.add(contentVersion);
            count++;
        }
        Insert contentVersions;
        
       contentVersions = [SELECT Id, ContentDocumentId, Title, VersionData FROM ContentVersion WHERE Id IN:contentVersions];
            
        for (ContentVersion contentVersion : contentVersions) {    
           
           
            
            // Create DocumentLink record
            ContentDocumentLink documentLink = new ContentDocumentLink();
            documentLink.ContentDocumentId = contentVersion.ContentDocumentId;
            documentLink.LinkedEntityId = caseObj.Id;
            documentLink.ShareType = 'V';
            documentLink.Visibility = 'AllUsers';
            documentLinks.add(documentLink);
            
            // Get public URL using ContentDistribution
            ContentDistribution distribution = new ContentDistribution();
            distribution.ContentVersionId = contentVersion.Id;
            distribution.Name = contentVersion.Title;
            distribution.PreferencesAllowOriginalDownload = true;
            distribution.PreferencesAllowViewInBrowser = true;
            distributions.add(distribution);
            
            // Build the public URL
            String imageUrl = Url.getOrgDomainUrl().toExternalForm() +
                '/sfc/dist/version/download/?oid=' + UserInfo.getOrganizationId() +
                '&ids=' + distribution.Id;
            
            
           
        }
        
        Insert distributions;
        Insert documentLinks;
        
        For(ContentDistribution contentDistribution :[SELECT Id, ContentDownloadUrl, ContentDocumentId, ContentVersion.Title, DistributionPublicUrl
                                                      FROM ContentDistribution 
                                                      WHERE Id IN :distributions]){
                                                          
                                                          Map<string,string> mapImageNameToUrl = new Map<string,string>();
                                                          mapImageNameToUrl.put('Name',contentDistribution.contentVersion.Title );
                                                          mapImageNameToUrl.put('image_url',contentDistribution.DistributionPublicUrl);
                                                          
                                                          mapImageNameToUrlList.add(mapImageNameToUrl);
                                                      }
        
        // Return with Attachment Id and public URL
        return mapImageNameToUrlList;
    }
    
    
    // Helper method to create a log record
    global static void createLogRecord(String integrationType, Map<String, Object> request, String status, Map<String, Object> response, string errormessage) {
        
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
            //createLogRecord('Case creation', requestMap, 'Failed',response, e.getMessage());
        }
    }
    
    
    Global class CommonException extends Exception {}
}