@RestResource(urlMapping='/ManagePayment')
global with sharing class PaymentAPI {
    
    @HttpPost
    global static void createPayment() {
        set<string> paymentTypePicklistValues = new set<string>(); 
        set<string> paymentSourcePicklistValues = new set<string>();
        
        RestResponse res = RestContext.response;
        
        if (res != null) {
            res.addHeader('Content-Type', 'application/json');
        }
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request
        Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Savepoint sp = Database.setSavepoint();
        try {
            
            Map<String, Object> paymentInfo = (Map<String, Object>) requestData.get('payment_info');
            Map<String, Object> payGwyInfo = (Map<String, Object>) paymentInfo.get('pay_gwy_info'); 
            
            //Check the payment type
            If(PaymentInfo.get('payment_type') == null || PaymentInfo.get('payment_type') == ''){
                throw new CustomException('Required field missing: payment_type');
            }
            
            //Check the order id
            If(requestData.get('order_id') == null || requestData.get('order_id') == ''){
                throw new CustomException('Required field missing: order_id');
            }
            
            //Check the payment source
            If(paymentInfo.get('payment_source') == null || paymentInfo.get('payment_source') == ''){
                throw new CustomException('Required field missing: payment_source');
            }
            
            If(payGwyInfo.get('status') == null || payGwyInfo.get('status') == ''){
                throw new CustomException('Required field missing: status');
            }
            
            String paymentId = (String) paymentInfo.get('payment_id');
            List<Payment__c> Payments = [SELECT Id, Transaction_Id__c FROM Payment__c WHERE Transaction_Id__c = :paymentId LIMIT 1]; 
            
            If(Payments.size()>0)
                throw new CustomException('Duplicate payment found with same Payment Id!');
            
            
            Payment__c newPayment = new Payment__c();
            newPayment.Amount__c = (Decimal) paymentInfo.get('payment_amount');
            newPayment.Bank_Reference_Number__c = PayGwyInfo.get('bank_ref_no') != null?(String) payGwyInfo.get('bank_ref_no'):'';
            newPayment.Card_Name__c = (String) payGwyInfo.get('card_name');
            newPayment.Mode_Of_Payment__c = (String) payGwyInfo.get('payment_mode');
            newPayment.Tracking_Id__c = (String) payGwyInfo.get('tracking_id');
            newPayment.Payment_Status__c = (String) payGwyInfo.get('status');
            newPayment.Description__c = (String) payGwyInfo.get('failure_message');
            newPayment.Transaction_Id__c = paymentId;
            
            List<Schema.PicklistEntry> SourcepicklistValues = Payment__c.Source_Of_Payment__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistValue : SourcepicklistValues){
                paymentSourcePicklistValues.add(picklistValue.getValue());
            }
            
            If(!paymentSourcePicklistValues.contains((String)PaymentInfo.get('payment_source'))){
                String availableValues = String.join(paymentSourcePicklistValues, ', ');
                throw new CustomException('Sorry! Unsupported value for payment type (payment_source). Please choose one of the following: ' + availableValues + '.');
            }else{
                newPayment.Source_Of_Payment__c = (String) paymentInfo.get('payment_source');
            }
            
            
            try{
                insert newPayment;
            }catch(exception e){
                throw new CustomException('Error while creating payments: '+e.getMessage());
            }
            
            //Fetch the Order
            String orderId = (String) requestData.get('order_id');
            List<Order> order = [SELECT Id FROM Order WHERE Website_Order_Id__c = :orderId LIMIT 1];
            
            If(order.size() == 0){
                throw new CustomException('Order not found with Order Id (order_id): '+ (String) requestData.get('order_id'));
            }
            
            Order_Payment__c orderPayment = new Order_Payment__c();
            orderPayment.Order__c = order[0].Id;
            orderPayment.Payments__c = newPayment.Id;
            
            List<Schema.PicklistEntry> picklistValues = Order_Payment__c.Type__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistValue : picklistValues){
                paymentTypePicklistValues.add(picklistValue.getValue());
            }
            
            If(!paymentTypePicklistValues.contains((String)PaymentInfo.get('payment_type'))){
                String availableValues = String.join(paymentTypePicklistValues, ', ');
                throw new CustomException('Sorry! Unsupported value for payment type (payment_type). Please choose one of the following: ' + availableValues + '.');
            }else{
                orderPayment.Type__c = (String) PaymentInfo.get('payment_type');
            }
            
            try{
                insert orderPayment;
            }catch(exception e){
                throw new CustomException('Error while creating Order payments: '+e.getMessage());
            }
            
            if (res != null) {
                Map<String, Object> response = new Map<String, Object>();
                response.put('status', 'Success');
                response.put('Payment', newPayment.Id);
                response.put('type', 'CREATE');
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            }
            
            // Create a logObj record
            createLogRecord('Payment Creation', requestData, 'Success', (Map<string, object>)JSON.deSerializeUntyped(JSON.serialize(res)));
            
        } catch (Exception e) {
            Database.rollback(sp);
            if (res != null) {
                handleException(res, e, 'Payment Creation', requestData);
            }
        }
    }
    
    @HttpPatch
    global static void updatePayment() {
        
        set<string> paymentTypePicklistValues = new set<string>();
        
        RestResponse res = RestContext.response;
        
        if (res != null) {
            res.addHeader('Content-Type', 'application/json');
        }
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request
        Map<String, Object> requestData = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            Map<String, Object> paymentInfo = (Map<String, Object>) requestData.get('payment_info');
            Map<String, Object> payGwyInfo = (Map<String, Object>) paymentInfo.get('pay_gwy_info');
            
            String paymentId = (String) paymentInfo.get('payment_id');
            
            List<Payment__c> existingPayment = [SELECT Id, Amount__c, Bank_Reference_Number__c, Card_Name__c, Mode_Of_Payment__c, Tracking_Id__c, Payment_Status__c, Description__c,Transaction_Id__c FROM Payment__c WHERE Transaction_Id__c =: paymentId LIMIT 1];
            
            If(existingPayment.size()==0)
                throw new CustomException('Sorry! There is no payment record exist with the Payment Id \''+paymentId+'\'');
            
            List<Order_Payment__c> orderPayment = [SELECT Id, Type__c  FROM Order_Payment__c WHERE Payments__c = :existingPayment[0].Id LIMIT 1];
            
            If(orderPayment.size()==0)
                throw new CustomException('Sorry! There is no payment record exist with the Payment Id \''+paymentId+'\'');
            
            //Checking the Order Payment types
            
            String paymentType = (String) paymentInfo.get('payment_type');
            
            List<Schema.PicklistEntry> picklistValues = Order_Payment__c.Type__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistValue : picklistValues){
                paymentTypePicklistValues.add(picklistValue.getValue());
            }
            
            If(!paymentTypePicklistValues.contains((String)PaymentInfo.get('payment_type'))){
                String availableValues = String.join(paymentTypePicklistValues, ', ');
                throw new CustomException('Sorry! Unsupported value for payment type (payment_type). Please choose one of the following: ' + availableValues + '.');
            }
            
            If(orderPayment[0].Type__c != paymentType){
                throw new CustomException('Payment Type mismatch!');
            }
            
            //Update the Payments
            existingPayment[0].Amount__c = (Decimal) paymentInfo.get('payment_amount');
            existingPayment[0].Bank_Reference_Number__c = (String) payGwyInfo.get('bank_ref_no');
            existingPayment[0].Card_Name__c = (String) payGwyInfo.get('card_name');
            existingPayment[0].Mode_Of_Payment__c = (String) payGwyInfo.get('payment_mode');
            existingPayment[0].Tracking_Id__c = (String) payGwyInfo.get('tracking_id');
            existingPayment[0].Payment_Status__c = (String) payGwyInfo.get('status');
            existingPayment[0].Description__c = (String) payGwyInfo.get('failure_message');
            
            update existingPayment[0];
            
            Map<String, Object> response = new Map<String, Object>();
            if (res != null) {
                
                response.put('status', 'Success');
                response.put('Payment', existingPayment[0].Id);
                response.put('type', 'UPDATE');
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
            }
            
            // Create a logObj record
            createLogRecord('Payment Update', requestData, 'Success', response);
            
        } catch (Exception e) {
            Database.rollback(sp);
            if (res != null) {
                handleException(res, e, 'Payment Update', requestData);
            }
        }
    }
    
    // Helper method to create a log record
    private static void createLogRecord(String integrationType, Map<String, Object> request, String status, Map<string, Object> response) {
        Integration_log__c logObj = new Integration_log__c();
        logObj.Integration_Type__c = integrationType;
        logObj.Request_Payload__c = JSON.serializePretty(request);
        logObj.Response_Payload__c = JSON.serializePretty(response);
        logObj.Status__c = status;
        insert logObj;
    }
    
    // Helper method to handle exceptions and create error log records
    private static void handleException(RestResponse res, Exception e, String integrationType,  Map<String, Object> request) {
        if (res != null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'Error');
            response.put('message', e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            createLogRecord(integrationType, request, 'Failed', (Map<string, object>)JSON.deSerializeUntyped(JSON.serialize(res)));
        }
    }
    
    public class CustomException extends Exception {}
}