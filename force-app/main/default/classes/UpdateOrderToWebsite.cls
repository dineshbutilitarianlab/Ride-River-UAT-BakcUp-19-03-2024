public class UpdateOrderToWebsite { 
    
    public static String generateJSON(Order order, List<OrderItem> orderItems) {
        
        JSONGenerator gen = JSON.createGenerator(true);
        
        gen.writeStartObject();
        
        // Simple Fields
       // writeStringField(gen, 'crm_account_id', order.AccountId);
        writeStringField(gen, 'order_id', order.Website_Order_Id__c);
        writeNumberField(gen, 'order_amount', order.Grand_Total__c);
        writeStringField(gen, 'order_status', order.Order_Status__c);
       // writeStringField(gen, 'seller_code', order.Account.Center_Code__c);
        writeBooleanField(gen, 'notify_by_sms', order.Notify_By_SMS__c);
        writeBooleanField(gen, 'notify_by_email', order.Notify_By_Email__c);
        
        // Products
        gen.writeFieldName('product_skus');
        gen.writeStartArray();
        
        for (OrderItem item : orderItems) {
            // Product creation
            gen.writeStartObject();
            writeStringField(gen, 'product_sku_id', item.Product2.StockKeepingUnit);
            // writeNumberField(gen, 'product_qty', item.Quantity);
            // writeNumberField(gen, 'product_unit_price', item.UnitPrice);
            
            // Adding the Product Type
            string prodtype;
            If(item.Type__c == 'Vehicle'){
                prodtype = 'VEHICLE';
            }else if(item.Type__c == 'Accessories'){
                prodtype = 'ACCESSORY';
            }else if(item.Type__c == 'Parts'){
                prodtype = 'PART';
            }            
            
            writeStringField(gen, 'product_type', prodtype);            
            
            writeStringField(gen, 'product_order_status', item.Status__c);
            writeStringField(gen, 'order_item_id', item.Order_Item_Id__c);
            //writeNumberField(gen, 'offer_amount', item.Offer_Amount__c);
            //writeStringField(gen, 'offer_description', item.Offer_Description__c);
            gen.writeEndObject();
        }
        
        gen.writeEndArray();
        
        /*
        // Billing Address
        writeAddress(gen, 'billing_address', order.BillingStreet, order.BillingCity, order.BillingPostalCode, order.BillingState);
        
        // Shipping Address
        writeAddress(gen, 'shipping_address', order.ShippingStreet, order.ShippingCity, order.ShippingPostalCode, order.ShippingState);
        
        // Loan Info
        writeLoanInfo(gen, Order.Finance__r.Finance_Code__c, Order.Financed_Amount__c, Order.Tenure__c, Order.Tenure_Type__c, Order.EMI_Amount__c);
        
        // Insurance Info
        writeInsuranceInfo(gen, Order.Insurance__r.Insurer_Code__c, order.Insurance_Amount__c, Order.Policy_Number__c);
        
        // Subsidy Info
        writeSubsidyInfo(gen, order.Eligible_For_Subsidy__c, order.Subsidy__r.Subsidy_Code__c, order.Subsidy_Amount__c);
        
        // Offer Info
        writeOfferInfo(gen, order.Offers_Amount__c, order.Offer_description__c);
        
        // Warranty Info
        writeWarrantyInfo(gen, order.Warranty_Amount__c, order.Eligible_For_Subsidy__c);
*/        

        gen.writeEndObject();
        
        
        return gen.getAsString();
    }
    
    /**************************************************************************************************************************/
    /* 
    // Helper method to write an address object with null checks
    private static void writeAddress(JSONGenerator gen, String fieldName, String address1, String city, String pinCode, String state) {
        gen.writeFieldName(fieldName);
        gen.writeStartObject();
        writeStringField(gen, 'address_1', address1);
        writeStringField(gen, 'city', city);
        writeStringField(gen, 'pin_code', pinCode);
        writeStringField(gen, 'state', state);
        gen.writeEndObject();
    }
    
    // Helper method to write loan info with null checks
    private static void writeLoanInfo(JSONGenerator gen, String financeCode, Decimal amount, Decimal tenure, String tenureType, Decimal emiAmount) {
        gen.writeFieldName('loan_info');
        gen.writeStartObject();
        writeStringField(gen, 'finance_code', financeCode);
        writeNumberField(gen, 'amount', amount);
        writeNumberField(gen, 'tenure', tenure);
        writeStringField(gen, 'tenure_type', tenureType);
        writeNumberField(gen, 'emi_amount', emiAmount);
        gen.writeEndObject();
    }
    
    // Helper method to write insurance info with null checks
    private static void writeInsuranceInfo(JSONGenerator gen, String insurerCode, Decimal amount, String policyNumber) {
        gen.writeFieldName('insurance_info');
        gen.writeStartObject();
        writeStringField(gen, 'insurer_code', insurerCode);
        writeNumberField(gen, 'amount', amount);
        writeStringField(gen, 'policy_number', policyNumber);
        gen.writeEndObject();
    }
    
    // Helper method to write subsidy info with null checks
    private static void writeSubsidyInfo(JSONGenerator gen, Boolean eligibleForSubsidy, String subsidyCode, Decimal amount) {
        gen.writeFieldName('subsidy_info');
        gen.writeStartObject();
        gen.writeBooleanField('eligible_for_subsidy', eligibleForSubsidy);
        writeStringField(gen, 'subsidy_code', subsidyCode);
        writeNumberField(gen, 'amount', amount);
        gen.writeEndObject();
    }
    
    // Helper method to write offer info with null checks
    private static void writeOfferInfo(JSONGenerator gen, Decimal offerAmount, String offerDescription) {
        gen.writeFieldName('offer_info');
        gen.writeStartObject();
        writeNumberField(gen, 'offer_amount', offerAmount);
        writeStringField(gen, 'offer_description', offerDescription);
        gen.writeEndObject();
    }
    
    // Helper method to write warranty info with null checks
    private static void writeWarrantyInfo(JSONGenerator gen, Decimal warrantyAmount, Boolean isExtended) {
        gen.writeFieldName('warranty_info');
        gen.writeStartObject();
        writeNumberField(gen, 'warranty_amount', warrantyAmount);
        gen.writeBooleanField('is_extended', isExtended);
        gen.writeEndObject();
    }
    
    */
    /*********************************************************************************************************************/
    
    // Helper method to write a string field with null check
    private static void writeStringField(JSONGenerator gen, String fieldName, String fieldValue) {
        gen.writeStringField(fieldName, fieldValue == null ? '' : fieldValue);
    }
    
    // Helper method to write a number field with null check
    private static void writeNumberField(JSONGenerator gen, String fieldName, Decimal fieldValue) {
        gen.writeNumberField(fieldName, fieldValue == null ? 0 : fieldValue);
    }
    
    // Helper method to write a number field with null check
    private static void writeBooleanField(JSONGenerator gen, String fieldName, Boolean fieldValue) {
        gen.writeBooleanField(fieldName, fieldValue == null ? false : fieldValue);
    }
    
    /*************************************************************************************************************/
    
    public static String tokenGeneration( River_Integration_Credential__mdt metadata ) {
        
        String endpoint = metadata.Authentication_Endpoint_URL__c;
        
        String clientId = metadata.Client_Id__c;
        String clientSecret = metadata.Client_Secret__c;
        
        String requestBody = '{"client_id":"' + clientId + '",' +
            '"client_secret":"' + clientSecret + '"}';
        
        // Create an HTTP request
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);
        
        // Create an HTTP instance
        Http http = new Http();
        
        System.debug('Request Body: ' + req.getBody());
        
        HttpResponse res = http.send(req);
        
        System.debug('Response Status: ' + res.getStatus());
        System.debug('Response Body: ' + res.getBody());
        
        String token = '';
        if (res.getStatusCode() == 200) {
            token = res.getBody();
        } else {
            token = null;
            System.debug('Token generation failed with status code: ' + res.getStatusCode());
        }
        
        return token;
    }
    
    public static void doCallout(String token, River_Integration_Credential__mdt metadata, String jsonString) {        
        
        String displayEndpoint = metadata.Actual_Endpoint_URL__c;
        
        // Assuming token is obtained and not empty
        if (String.isNotBlank(token)) {
            
            // Create an HTTP request to display output
            HttpRequest displayReq = new HttpRequest();
            displayReq.setEndpoint(displayEndpoint);
            displayReq.setMethod('PATCH');
            displayReq.setHeader('Content-Type', 'application/json');
            displayReq.setHeader('Authorization', 'Bearer ' + token); // Set the Authorization header with the token
            displayReq.setBody(jsonString);
            
            Http http = new Http();
            
            // Make the HTTP request to display output
            HttpResponse displayRes = http.send(displayReq);
            
            System.debug('Response Status: ' + displayRes.getStatus());
            System.debug('Response Body: ' + JSON.serializePretty(JSON.deserializeUntyped(displayRes.getBody())));
            
            if (displayRes.getStatusCode() == 204) {
                System.debug('Response Status: ' + displayRes.getStatusCode());
            } 
            else {
                System.debug('Response Status: ' + displayRes.getStatusCode());
            }
        } else {
            System.debug('Token not obtained. Unable to call displayOutput method.');
        }
    }
    
    @future(callout = true)
    // Method to execute the displayOutput method
    public static void executeDisplayOutput(Id orderId) {
        
        Order order = [SELECT Id, AccountId,Website_Order_Id__c, Status, pricebook2Id, Order_Status__c,BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                       ShippingStreet,ShippingCity,ShippingState, ShippingPostalCode, ShippingCountry, Finance__r.Name, Financed_Amount__c,Tenure__c, Tenure_Type__c, Approval_Status__c, 
                       Loan_Start_Date__c, EMI_Amount__c, Insurance__r.Name,Insurance_Amount__c, Subsidy__r.Name, Subsidy_Amount__c, Eligible_For_Subsidy__c,Insurance__r.Insurer_Code__c,
                       Offers_Amount__c, Offer_description__c, Warranty_Amount__c, Extended_Warranty__c, Subsidy__r.Subsidy_Code__c,Grand_Total__c,Notify_By_SMS__c,Notify_By_Email__c,
                       Finance__r.Finance_Code__c,Policy_Number__c,Account.Center_Code__c,
                       (SELECT Id,Product2.Name, Quantity, UnitPrice, Order_Item_Id__c, Status__c, Offer_Amount__c, Offer_Description__c, Type__c,Product2.StockKeepingUnit
                        FROM Orderitems) 
                       FROM Order 
                       WHERE Id = :orderId  
                       LIMIT 1];
        
        List<OrderItem> orderItems = order.Orderitems;
        
        //Get the credentials
        River_Integration_Credential__mdt metadata = [SELECT Id, Client_Id__c, Client_Secret__c, Actual_Endpoint_URL__c, Authentication_Endpoint_URL__c FROM River_Integration_Credential__mdt WHERE DeveloperName = 'Website_Credentials'];
        
        String tokenResponse;
        //Get the access token
        
        	tokenResponse = tokenGeneration(metadata);
       
        
        Map<String, Object> tokenMap = (Map<String, Object>)JSON.deserializeUntyped(tokenResponse);
        Map<String, Object> tokenData = (Map<String, Object>)tokenMap.get('data');
        String token = (String)tokenData.get('token');
        
        String jsonString = generateJSON(order,orderItems);
        
        system.debug('Json body is>>\n '+JSON.serializePretty(JSON.deserializeUntyped(jsonString)));
        
        If(!Test.isRunningTest()){
            doCallout(token, metadata, jsonString);
        }
        
    }
    
}