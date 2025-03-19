/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class RSAcalloutHelper {
        
    static String BaseUrl=Label.RsaUrl;
    static string RSAClientID=Label.RSAClientID;
    static string RSAClientScret=Label.RSAclientscret;
  
    @future(callout=true)
    public static void RsaFuthuremethod(string vehicleRegistrationNo,string chassisNO,Id OrderidNo){
        try{
            system.debug(' RSA #1  vehicleRegistrationNo == >'+vehicleRegistrationNo+' && chassisNO == >'+chassisNO+' && OrderidNo == >'+OrderidNo);
            RSAcalloutHelper.getrefreshtokent(vehicleRegistrationNo,chassisNO,OrderidNo);
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void getrefreshtokent(string vehicleRegistrationNo,string chassisNO,Id OrderidNo){
        try{
            system.debug('BaseUrl  == >'+BaseUrl+' && RSAClientID == >'+RSAClientID+' && RSAClientScret === >'+RSAClientScret);
            httprequest req=new httprequest();
            req.setEndpoint(BaseUrl+'/order/client/tieup/login');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('key-id', RSAClientScret);
            String bodydata = '{"clientId":"'+RSAClientID+'", "clientSecretCode":"'+RSAClientScret+'"}';
            req.setBody(bodydata);
            Http h = new Http();
            HttpResponse response = h.send(req);
            ExceptionHelper.createAPICalloutLog(req,response,'');
            if (response.getStatusCode() == 200) {
                System.debug('Response1 === > ' + response.getBody());
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) jsonResponse.get('data');
                string token= (String) dataMap.get('token');
                string refrehtoken=(String)dataMap.get('refreshToken');
                system.debug('token1  == >'+token);
                system.debug('refrehtoken  === >'+refrehtoken);
                RSAcalloutHelper.getbareertooken(vehicleRegistrationNo,chassisNO,OrderidNo,refrehtoken,token);   
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void getbareertooken(string vehicleRegistrationNo,string chassisNO,Id OrderidNo,string refrehtoken,string token){
        try{
            httprequest req=new httprequest();
            req.setEndpoint(BaseUrl+'/order/client/tieup/refresh-token');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setHeader('key-id', RSAClientScret);
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('clientId',RSAClientID);
            requestBody.put('refreshToken', refrehtoken);
            String bodydata = JSON.serialize(requestBody);
            system.debug('bodydata ======== >> '+bodydata);
            req.setBody(bodydata);
            Http h = new Http();
            HttpResponse response = h.send(req);
            if (response.getStatusCode() == 200) {
                System.debug('Response2 === > ' + response.getBody());
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) jsonResponse.get('data');
                string bareertoken=(String)dataMap.get('token');
                system.debug('bareer === >'+bareertoken);
                RSAcalloutHelper.getvehiclesync( vehicleRegistrationNo,chassisNO,OrderidNo,bareertoken);
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void getvehiclesync(string vehicleRegistrationNo,string chassisNO,Id OrderidNo,string bareertoken){
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(BaseUrl+'/order/client/tieup/sync-reg');
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+bareertoken);
            request.setHeader('key-id', RSAClientScret);
            String requestBody = '{"chassisNo":"' + chassisNO + '", "registrationNo":"' + vehicleRegistrationNo + '"}';
            request.setBody(requestBody);
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                System.debug('Response Body === > ' + response.getBody());
            } else {
                System.debug('Error: HTTP Status == > ' + response.getStatusCode() + ' - ' + response.getStatus());
            } 
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    @future(callout=true)
    public static void RsaCreationFuthuremethod(string chassisNO,Id OrderidNo,string Accountname,string MobileNo,Id VehicleId){
        try{
            RSAcalloutHelper.getrefreshtokentlogin(chassisNO,OrderidNo,Accountname,MobileNo,VehicleId);
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void getrefreshtokentlogin(string chassisNO,Id OrderidNo,string Accountname,string MobileNo,Id VehicleId){
        try{
            httprequest req=new httprequest();
            req.setEndpoint(BaseUrl+'/order/client/tieup/login');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('key-id', RSAClientScret);
            String bodydata = '{"clientId":"'+RSAClientID+'", "clientSecretCode":"'+RSAClientScret+'"}';
            req.setBody(bodydata);
            Http h = new Http();
            HttpResponse response = h.send(req);
            if (response.getStatusCode() == 200) {
                System.debug('Response1: ' + response.getBody());
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) jsonResponse.get('data');
                string token= (String) dataMap.get('token');
                string refrehtoken=(String)dataMap.get('refreshToken');
                RSAcalloutHelper.getbareertokenforcreation(chassisNO,OrderidNo,Accountname,MobileNo,refrehtoken,token,VehicleId);
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void getbareertokenforcreation(string chassisNO,Id OrderidNo,string Accountname,string MobileNo,string refrehtoken,string token,Id VehicleId){
        try{
            httprequest req=new httprequest();
            req.setEndpoint(BaseUrl+'/order/client/tieup/refresh-token');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+token);
            req.setHeader('key-id', 'RSAClientScret');
            Map<String, Object> requestBody = new Map<String, Object>();
            requestBody.put('clientId', RSAClientID);
            requestBody.put('refreshToken', refrehtoken);
            String bodydata = JSON.serialize(requestBody);
            req.setBody(bodydata);
            Http h = new Http();
            HttpResponse response = h.send(req);
            if (response.getStatusCode() == 200) {
                System.debug('Response2: ' + response.getBody());
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) jsonResponse.get('data');
                string bareertoken=(String)dataMap.get('token');
                RSAcalloutHelper.fetchSubscriptionPlans(chassisNO,OrderidNo,Accountname,MobileNo,bareertoken,VehicleId);
            } else {
                System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void fetchSubscriptionPlans(string chassisNO,Id OrderidNo,string Accountname,string MobileNo,string bareertoken,Id VehicleId){
        try{
            String clientId = RSAClientID;
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            String url = BaseUrl+'/order/client/tieup/tagged/subscription-plans?clientId=' +clientId ;
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+bareertoken);
            req.setHeader('key-id', RSAClientScret);
            HttpResponse response = http.send(req);
            if (response.getStatusCode() == 200) {
                System.debug('Response3: ' + response.getBody());
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> dataList = (List<Object>) jsonResponse.get('data');
                Integer planId;
                if (!dataList.isEmpty()) {
                    Map<String, Object> firstDataItem = (Map<String, Object>) dataList[0];
                    planId = (Integer) firstDataItem.get('planId');
                    System.debug('Plan ID == > ' + planId);
                }
                RSAcalloutHelper.createSubscription( chassisNO,OrderidNo,Accountname,MobileNo,bareertoken,planId,VehicleId);
            } else {
                System.debug('Error == > ' + response.getStatus() + ' ' + response.getBody());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void createSubscription(string chassisNO,Id OrderidNo,string Accountname,string MobileNo,string bareertoken,Integer planId,Id VehicleId) {
        try{
            String payload = JSON.serialize(new Map<String, Object>{
                'clientId' => RSAClientID,
                    'customerName' => Accountname,
                    'customerMobileNo' => MobileNo,
                    'vehicleType' => Label.RSAvehicleType,
                    'vehicleMake' => Label.RSAvehicleMake,
                    'vehicleModel' => Label.RSAvehicleModel,
                    'vehicleChassisNo' =>chassisNO,
                    'sellerId' => Label.RSAsellerId,
                    'planId' => planId,
                    'purchaseThrough' => Label.RSApurchaseThrough
                    });
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setEndpoint(BaseUrl+'/order/client/tieup/subscription-creation');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'Bearer '+bareertoken);
            req.setHeader('key-id', RSAClientScret);
            req.setBody(payload);
            HttpResponse res = http.send(req);
            if (res.getStatusCode() == 200) {
                System.debug('Subscription created successfully: ' + res.getBody());
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
                // Extract required fields
                Integer subscriptionId = (Integer) dataMap.get('subscriptionId');
                string expiryDateString = (string) dataMap.get('expiryDate');
                string startDatestring = (string) dataMap.get('startDate');
                String formattedDateTimeString = expiryDateString.replace('T', ' ').replace('Z', '');
                DateTime dtexpiryDateString = DateTime.valueOf(formattedDateTimeString);
                String formattedDateTimeStringstartDatestring = startDatestring.replace('T', ' ').replace('Z', '');
                DateTime dtstartDatestring = DateTime.valueOf(formattedDateTimeStringstartDatestring);
                String formattedStringexpiryDateString = dtexpiryDateString.format('dd-MM-yyyy HH:mm:ss');
                String formattedStringstartDatestring = dtstartDatestring.format('dd-MM-yyyy HH:mm:ss');
                order resultorder=[select Id,RSA_Active__c from Order r where Id=:OrderidNo];
                resultorder.RSA_Active__c=true;
                Update resultorder;
                system.debug('order Update ===== >'+resultorder);
                Vehicle ve=[select Id from Vehicle where Id=:VehicleId ];
                ve.RSA_Activation__c=true;
                ve.RSA_Subscription_ID__c=subscriptionId;
                ve.RSA_Start_Date__c=formattedStringstartDatestring;
                ve.RSA_End_Date__c=formattedStringexpiryDateString;
                update ve;
                system.debug('Vehicle Update ===== >'+ve);
            } else {
                System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
}