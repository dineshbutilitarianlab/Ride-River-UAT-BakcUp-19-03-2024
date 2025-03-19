@RestResource(urlMapping='/ManageOrder')
global with sharing class OrderAPI {
    
    @HttpPost
    global static void createStandardOrder() {
        
        set<string> orderPicklistValues = new set<string>(); 
        set<string> paymentTypePicklistValues = new set<string>();
        
        List<OrderItem> orderItems = new List<OrderItem>();
        List<string> productSkuIds = new List<string>();
        
        Map<string,string> mapSkuToProdId = new Map<string,string>();
        Map<Id,Product2> mapIdToProduct = new Map<Id,Product2>();
        Map<String, Object> response = new Map<String, Object>();
        Map<Id,Double> mapProdIdToPrice = new Map<Id,Double>();
        Map<Id,Id> mapProdIdToPEntryId = new Map<Id,Id>();
        
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        Map<String, Object> billing_address = (Map<String, Object>)requestMap.get('billing_address') != null? (Map<String, Object>)requestMap.get('billing_address'):null;
        Map<String, Object> shipping_address = (Map<String, Object>)requestMap.get('shipping_address') != null? (Map<String, Object>)requestMap.get('shipping_address'):null;
        Map<String, Object> PaymentDetails = (Map<String, Object>)requestMap.get('payment_info') != null? (Map<String, Object>)requestMap.get('payment_info'):null;            
        
        Map<String, Object> payGwyInfo = new Map<String, Object>(); 
        If(PaymentDetails != null)
            payGwyInfo = (Map<String, Object>)PaymentDetails.get('pay_gwy_info') != null? (Map<String, Object>)PaymentDetails.get('pay_gwy_info'):null;
        
        Map<String, Object> loanDetails = (Map<String, Object>)requestMap.get('loan_info') != null? (Map<String, Object>)requestMap.get('loan_info'):null;
        Map<String, Object> insuranceDetails = (Map<String, Object>)requestMap.get('insurance_info') != null? (Map<String, Object>)requestMap.get('insurance_info'):null;
        Map<String, Object> subsidyDetails = (Map<String, Object>)requestMap.get('subsidy_info') != null? (Map<String, Object>)requestMap.get('subsidy_info'):null;
        Map<String, Object> offerDetails = (Map<String, Object>)requestMap.get('offer_info') != null? (Map<String, Object>)requestMap.get('offer_info'):null;
        Map<String, Object> warrantyDetails = (Map<String, Object>)requestMap.get('warranty_info') != null? (Map<String, Object>)requestMap.get('warranty_info'):null;
        
        List<Object> OrderProducts = (List<Object>)requestMap.get('products') != null? (List<Object>)requestMap.get('products'):null;
        
        Savepoint sp = Database.setSavepoint();
        try {
            
            If(requestMap.get('seller_code') == null || requestMap.get('seller_code') == ''){
                throw new CustomException('Required field missing: seller_code');
            }
            
            List<Account> customer = new List<Account>();
            List<Account> seller = new List<Account>();
            
            List<Account> sellerAndCustomer = [SELECT Id, Type, Center_Code__c FROM Account WHERE (Center_Code__c = :(String)requestMap.get('seller_code') AND (Type = 'Dealer' OR Type = 'COCO Store')) OR Id = :(String)requestMap.get('crm_account_id')];
            
            For(Account acc: sellerAndCustomer){
                If(acc.Id == (String)requestMap.get('crm_account_id')){
                    customer.add(acc);
                }else If(acc.Center_Code__c == (String)requestMap.get('seller_code') && (acc.Type == 'Dealer' || acc.Type == 'COCO Store')){
                    seller.add(acc);
                }
            }
            
            If(seller.size() == 0){
                throw new CustomException('Dealer not found! Please check the seller_code');
            }
            
            If(customer.size() == 0){
                throw new CustomException('Customer account not found! Please check the crm_account_id');
            }
            /*list<User>ActiveUser =[Select id, AccountId, IsActive, ContactId, Profile.name from user where AccountId =:seller.id AND Profile.Name = 'Sales Manager (Partner)'AND IsActive= true];
            if(ActiveUser.size()==0)
            {
               throw new CustomException('Active user for Dealer is Found!');  
            }*/
            
            If(!OrderProducts.isempty()){
                For(Object product : OrderProducts){
                    Map<string, Object> prodMap = (Map<string, Object>) product;
                    productSkuIds.add((string)prodMap.get('product_sku_id'));
                }
            }
            
            //Get the city pricebook
            If(!requestMap.containsKey('city')){
                throw new CustomException('Required field missing: city');
            }
            
            string cityIdentifier = (String)requestMap.get('city');     
			List<City__c> cities = [SELECT Id, Price_Book__c, City_Masking_Name__c, Price_Book__r.IsActive FROM City__c WHERE City_Masking_Name__c =: cityIdentifier OR City_Pincode__c =: cityIdentifier];
            
            If(cities.size()<=0){
                throw new CustomException('City not found with identifier: '+(String)requestMap.get('city'));
            }else If(cities[0].Price_Book__c == null){
                throw new CustomException('No Price Book is associated with the selected city. Please ensure the Price Book is associated before proceeding.');
            }else If(!cities[0].Price_Book__r.IsActive){
                throw new CustomException('The Price Book associated with the selected city is not active. Please ensure the Price Book is active before proceeding.');
            }
            
            Pricebook2 Pricebook = new Pricebook2();
            //Fetch standard pricebook
            if(!test.isRunningTest()){
                Pricebook = [SELECT Id FROM Pricebook2 WHERE Id = :cities[0].Price_Book__c];
            }
            else {
                Pricebook = [SELECT Id FROM Pricebook2 LIMIT 1];
            }
            
            
            // Create a Standard Order record
            Order standardOrder = new Order(
                recordTypeid = SObjectType.Order.getRecordTypeInfosByDeveloperName().get('Vehicle').getRecordTypeId(),
                AccountId = (String)requestMap.get('crm_account_id'),
                Dealer__c = seller[0].Id,
                Website_Order_Id__c = (String)requestMap.get('order_id'),
                EffectiveDate = Date.today(),
                Status = (String)requestMap.get('order_status') != null?(String)requestMap.get('order_status'):'Activated', 
                Description = (String)requestMap.get('delivery_timeline_description') != null? (String)requestMap.get('delivery_timeline_description'):'',
                pricebook2Id = Pricebook.Id,
                Notify_By_SMS__c = (Boolean)requestMap.get('notify_by_sms') != null?(Boolean)requestMap.get('notify_by_sms'):false,
                Notify_By_Email__c = (Boolean)requestMap.get('notify_by_email') != null?(Boolean)requestMap.get('notify_by_email'):false,
                BillingStreet = ((String)billing_address.get('address_1') != null ? (String)billing_address.get('address_1') : '') +' '+ ((String)billing_address.get('address_2') != null ? (String)billing_address.get('address_2') : ''),
                BillingCity = (String)billing_address.get('city') != null ? (String)billing_address.get('city') : '',
                BillingState = (String)billing_address.get('state') != null ? (String)billing_address.get('state') : '',
                BillingPostalCode = (String)billing_address.get('pincode') != null ? (String)billing_address.get('pincode') : '',
                BillingCountry = (String)billing_address.get('country') != null ? (String)billing_address.get('country') : 'India',
                ShippingStreet = ((String)shipping_address.get('address_1') != null ? (String)shipping_address.get('address_1') : '')+ ' '+((String)shipping_address.get('address_2') != null ? (String)shipping_address.get('address_2') : ''),
                ShippingCity = (String)shipping_address.get('city') != null ? (String)shipping_address.get('city') : '',
                ShippingState = (String)shipping_address.get('state') != null ? (String)shipping_address.get('state') : '',
                ShippingPostalCode = (String)shipping_address.get('pincode') != null ? (String)shipping_address.get('pincode') : '',
                ShippingCountry = (String)shipping_address.get('country') != null ? (String)shipping_address.get('country') : 'India',
                City__c = cities[0].Id
                
            );
            
            
             //Get the picklist values from the org
            List<Schema.PicklistEntry> picklistValuez = Order.Status.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistValue : picklistValuez){
                orderPicklistValues.add(picklistValue.getValue());
            }    
            //Update the order status
            If(requestMap.get('order_status') != null){
                String orderStatus = (String)requestMap.get('order_status');
                If(!orderPicklistValues.contains((String)requestMap.get('order_status'))){
                    String availableValues = String.join(orderPicklistValues, ', ');
                    throw new CustomException('Sorry! Unsupported value for Order Status. Please choose one of the following: ' + availableValues + '.'+ 'Order status values : '+orderStatus);
                }else{
                    standardOrder.status = (String)requestMap.get('order_status');
                }
            }         
            
            //insert order
            try{
                insert standardOrder;
            }catch (exception e){
                throw new CustomException('Error while inserting Order: '+e.getmessage()); 
            }            
            
            //Fetch products
            For(Product2 prod: [SELECT Id, Name,StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productSkuIds]){
                
                mapIdToProduct.Put(prod.Id,prod);
                mapSkuToProdId.Put(prod.StockKeepingUnit, prod.Id);
            }
            
            //Fetch Pricebook entries for the selected products
            For(PriceBookEntry pre: [SELECT Id, Product2Id, PriceBook2Id, UnitPrice FROM PriceBookEntry WHERE Product2Id IN :mapIdToProduct.keySet() AND PriceBook2Id =:Pricebook.Id]){
                
                mapProdIdToPrice.Put(pre.Product2Id,pre.UnitPrice);
                mapProdIdToPEntryId.put(pre.Product2Id,pre.Id);
            }
            
            // Create Order Items using the provided product SKU IDs
            If(!OrderProducts.isempty()){
                For(Object product : OrderProducts){
                    Map<string, Object> productmap = (Map<string, Object>) product;
                    
                    If(mapSkuToProdId.get((string)productmap.get('product_sku_id')) == null){
                        throw new CustomException('Product is not available with SKU '+(string)productmap.get('product_sku_id'));
                    }else if(mapProdIdToPEntryId.get(mapSkuToProdId.get((string)productmap.get('product_sku_id'))) == null){
                        throw new CustomException('Price is not defined for the product with SKU '+(string)productmap.get('product_sku_id'));
                    }
                    
                    OrderItem orderItem = new OrderItem(
                        OrderId = standardOrder.Id,
                        PricebookEntryId = mapProdIdToPEntryId.get(mapSkuToProdId.get((string)productmap.get('product_sku_id'))),
                        Product2Id = mapSkuToProdId.get((string)productmap.get('product_sku_id')),
                        Quantity = (Integer)productmap.get('product_qty'), 
                        UnitPrice = mapProdIdToPrice.get(mapSkuToProdId.get((string)productmap.get('product_sku_id'))),
                        Order_Item_Id__c = (string)productmap.get('order_item_id'),
                        Status__c = (string)productmap.get('product_order_status') != null ? (string)productmap.get('product_order_status'):'',
                        Offer_Amount__c = (double)productmap.get('offer_amount') != null? (double)productmap.get('offer_amount'):0,
                        Offer_Description__c = (string)productmap.get('offer_description') != null? (string)productmap.get('offer_description'):''
                    );
                    
                    orderItems.add(orderItem);
                }
            }
            
            // Insert the Order Items
            try{
                insert orderItems;
            }catch(exception e){
                throw new CustomException('Error while creating order products: '+e.getMessage());
            }
            
            //Update Order
                      
            standardOrder = addOrderDetails(requestMap, standardOrder);
            try{
                Update standardOrder; 
            }catch(exception e){
                throw new CustomException('Error while updating order: '+e.getMessage());
            }
                       
            
            //Create Payments record
            Payment__c newPayment = new Payment__c();
            newPayment.Amount__c = (Decimal) PaymentDetails.get('payment_amount') != null?(Decimal) PaymentDetails.get('payment_amount'):0 ;
            newPayment.Bank_Reference_Number__c = (String) payGwyInfo.get('bank_ref_no') != null? (String) payGwyInfo.get('bank_ref_no'):'';
            newPayment.Card_Name__c = (String) payGwyInfo.get('card_name') != null? (String) payGwyInfo.get('card_name'):'';
            newPayment.Mode_Of_Payment__c = (String) payGwyInfo.get('payment_mode')!= null? (String) payGwyInfo.get('payment_mode'):'';
            newPayment.Tracking_Id__c = (String) payGwyInfo.get('tracking_id') != null? (String) payGwyInfo.get('tracking_id'):'';
            newPayment.Payment_Status__c = (String) payGwyInfo.get('status') != null? (String) payGwyInfo.get('status'):'';
            newPayment.Description__c = (String) payGwyInfo.get('failure_message') != null? (String) payGwyInfo.get('failure_message'):''; 
            newPayment.Transaction_Id__c = (String) PaymentDetails.get('payment_id') != null?(String) PaymentDetails.get('payment_id'):'';
            
            try{
                insert newPayment;
            }catch(exception e){
                throw new CustomException('Error while creating Payment: '+e.getMessage());
            }  
            
            //Create Order Payment
            Order_Payment__c orderPayment = new Order_Payment__c();
            orderPayment.Order__c = standardOrder.Id;
            orderPayment.Payments__c = newPayment.Id;
            
            //Check the payment type
            If(PaymentDetails.get('payment_type') == null || PaymentDetails.get('payment_type') == ''){
                throw new CustomException('Required field missing: payment_type');
            }
            
            List<Schema.PicklistEntry> picklistValues = Order_Payment__c.Type__c.getDescribe().getPicklistValues();
            for (Schema.PicklistEntry picklistValue : picklistValues){
                paymentTypePicklistValues.add(picklistValue.getValue());
            }
            
            If(!paymentTypePicklistValues.contains((String)PaymentDetails.get('payment_type'))){
                String availableValues = String.join(paymentTypePicklistValues, ', ');
                throw new CustomException('Sorry! Unsupported value for payment type (payment_type). Please choose one of the following: ' + availableValues + '.');
            }else{
                orderPayment.Type__c = (String) PaymentDetails.get('payment_type');
            }
            
            try{
                insert orderPayment;
            }catch(exception e){
                throw new CustomException('Error while creating Order payments: '+e.getMessage());
            }
            
            
            // Prepare the response
            response.put('status', 'Success');            
            response.put('order_id', standardOrder.Id);
            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Order Creation', requestMap, 'Success',response );
            
        } catch (Exception e) {
            
            system.debug('erorr>>>>'+e);
            
            // An exception occurred, so rollback to the savepoint
            Database.rollback(sp);
            
            // Handle exceptions and prepare an error response
            if (res != null) {
                handleException(res, e, 'Order Creation', requestMap);
            }
            
        }
    }
    
    /****************************************************************************************************************************************/
    
    @HttpPatch
    global static void updateStandardOrder() {
        
        List<OrderItem> orderItems = new List<OrderItem>();
        
        Map<string,string> mapSkuToProdId = new Map<string,string>();
        Map<Id,Product2> mapIdToProduct = new Map<Id,Product2>();
        Map<String, Object> response = new Map<String, Object>();
        Map<Id,Double> mapProdIdToPrice = new Map<Id,Double>();
        Map<Id,Id> mapProdIdToPEntryId = new Map<Id,Id>();
        List<string> productSkuIds = new List<string>();
        set<string> orderPicklistValues = new set<string>();
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        // Deserialize the JSON request body into a map
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        Map<String, Object> billing_address = (Map<String, Object>)requestMap.get('billing_address') != null? (Map<String, Object>)requestMap.get('billing_address'):null;
        Map<String, Object> shipping_address = (Map<String, Object>)requestMap.get('shipping_address') != null? (Map<String, Object>)requestMap.get('shipping_address'):null;
        
        List<Object> OrderProducts = (List<Object>)requestMap.get('products') != null? (List<Object>)requestMap.get('products'):null;
        
        Savepoint sp = Database.setSavepoint();
        
        try {
            
            //Fetch the Order
            List<Order> existingOrders = [SELECT Id, AccountId,Website_Order_Id__c, Description, Notify_By_SMS__c, Notify_By_Email__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, Is_Integration__c,
                                          BillingCountry, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM Order WHERE Website_Order_Id__c =:(String)requestMap.get('order_id') AND AccountId =: (String)requestMap.get('crm_account_id') LIMIT 1];
            
            //Check the availability of the order
            If(existingOrders.size() == 0){
                throw new CustomException('Sorry! Order is not available with Order Id: '+(String)requestMap.get('order_id')+' and Account Id: '+(String)requestMap.get('crm_account_id'));
            }else{
                
                order existingOrder = existingOrders[0];
                
                // Create a Standard Order record
                Order standardOrder = new Order(
                    Id = existingOrder.Id,
                    Description = (String)requestMap.get('delivery_timeline_description') != null? (String)requestMap.get('delivery_timeline_description'):'',
                    Notify_By_SMS__c = (Boolean)requestMap.get('notify_by_sms') != null?(Boolean)requestMap.get('notify_by_sms'):false,
                    Notify_By_Email__c = (Boolean)requestMap.get('notify_by_email') != null?(Boolean)requestMap.get('notify_by_email'):false
               );
                
                If(billing_address != null){
                    standardOrder.BillingStreet = ((String)billing_address.get('address_1') != null ? (String)billing_address.get('address_1') : '') +' '+ ((String)billing_address.get('address_2') != null ? (String)billing_address.get('address_2') : '');
                    standardOrder.BillingCity = (String)billing_address.get('city') != null ? (String)billing_address.get('city') : '';
                    standardOrder.BillingState = (String)billing_address.get('state') != null ? (String)billing_address.get('state') : '';
                    standardOrder.BillingPostalCode = (String)billing_address.get('pincode') != null ? (String)billing_address.get('pincode') : '';
                    standardOrder.BillingCountry = billing_address.get('country') != null ? (String)billing_address.get('country') :'India';
                    
                }
                
                If(shipping_address != null){
                    standardOrder.ShippingStreet = ((String)shipping_address.get('address_1') != null ? (String)shipping_address.get('address_1') : '')+ ' '+((String)shipping_address.get('address_2') != null ? (String)shipping_address.get('address_2') : '');
                    standardOrder.ShippingCity = (String)shipping_address.get('city') != null ? (String)shipping_address.get('city') : '';
                    standardOrder.ShippingState = (String)shipping_address.get('state') != null ? (String)shipping_address.get('state') : '';
                    standardOrder.ShippingPostalCode = (String)shipping_address.get('pincode') != null ? (String)shipping_address.get('pincode') : '';
                    standardOrder.ShippingCountry = shipping_address.get('country') != null ? (String)shipping_address.get('country') :'India';
                }
                
                // Get the picklist values from the org
                List<Schema.PicklistEntry> picklistValues = Order.Status.getDescribe().getPicklistValues();
                for (Schema.PicklistEntry picklistValue : picklistValues){
                    orderPicklistValues.add(picklistValue.getValue());
                } 

                //Update the order status
                If(requestMap.get('order_status') != null){
                    
                    If(!orderPicklistValues.contains((String)requestMap.get('order_status'))){
                        String availableValues = String.join(orderPicklistValues, ', ');
                        throw new CustomException('Sorry! Unsupported value for Order Status. Please choose one of the following: ' + availableValues + '.');
                    }else{
                        standardOrder.status = (String)requestMap.get('order_status');
                    }
                }
                
                //Toggling the Boolean variable to stop the recursion
                standardOrder.Is_Integration__c = !existingOrder.Is_Integration__c;
                
                //Insert other details to order
                standardOrder = addOrderDetails(requestMap, standardOrder);
                
                //insert order
                try{update standardOrder;}catch (exception e){throw new CustomException('Error while updating Order: '+e.getmessage());}
                
                //Retrieve the Order products
                List<OrderItem> Items = [SELECT Id, Status__c,Order_Item_Id__c, OrderId FROM OrderItem WHERE OrderId = : existingOrder.Id];
                
                Map<string, OrderItem> mapExtIdToItem = new Map<string, OrderItem>();
                If(Items.size()>0)
                    For(OrderItem Item : Items){
                        mapExtIdToItem.put(Item.Id, Item);
                    }
                
                //Update Order products
                If(OrderProducts != null){
                    For(Object product : OrderProducts){
                        
                        Map<string, Object> productmap = (Map<string, Object>) product;
                        If(mapExtIdToItem.get((string)productmap.get('order_item_id')) == null){
                            throw new CustomException('Order product is not present with the specified Id: '+(string)productmap.get('order_item_id'));
                        }else{
                            OrderItem orderItem = new OrderItem(  
                                
                                Id = mapExtIdToItem.get((string)productmap.get('order_item_id')).Id,
                                Status__c = (string)productmap.get('product_order_status')
                            );
                            If(!orderItems.contains(orderItem))
                                orderItems.add(orderItem);
                        }  
                    }
                }                    
                
                //Update order items
                Database.update(orderItems, false);           
                
                // Prepare the response
                response.put('status', 'Success');            
                response.put('order_id', standardOrder.Id);
                res.statusCode = 200;
                res.responseBody = Blob.valueOf(JSON.serialize(response));
                
                //Log Obj creation
                createLogRecord('Order Update', requestMap, 'Success',response );
            }
            
        } catch (Exception e) {
            
            system.debug('errror occured while updating the orde item>>'+e);
            Database.rollback(sp);
                        
            // Handle exceptions and prepare an error response
            if (res != null) {handleException(res, e, 'Order Update', requestMap);}
            
        }
    }
    
    /*********************************************************************************************************************************************/
    
    // Helper method to create a log record
    private static void createLogRecord(String integrationType, Map<String, Object> request, String status, Map<String, Object> response) {
        
        Integration_log__c logObj = new Integration_log__c();
        logObj.Integration_Type__c = integrationType;
        logObj.Request_Payload__c = JSON.serializePretty(request);
        logObj.Response_Payload__c = JSON.seriaLizePretty(response);
        logObj.Status__c = status;
        insert logObj;
    }
    
    /*************************************************************************************************************************************************/
    
    // Helper method to handle exceptions and create error log records
    private static void handleException(RestResponse res, Exception e, String integrationType, Map<String, Object> requestMap) {
        if (res != null) {
            Map<String, Object> response = new Map<String, Object>();
            response.put('status', 'Error');
            response.put('message', e.getMessage());
            res.statusCode = 500;
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            //Log Obj creation
            createLogRecord('Order Update', requestMap, 'Failed',response );
            
        }
    }
    
    /***************************************************************************************************************************************************/
    
    Public static order addOrderDetails(Map<String, Object> requestMap, Order standardOrder){
        
        Map<String, Object> loanDetails = (Map<String, Object>)requestMap.get('loan_info') != null? (Map<String, Object>)requestMap.get('loan_info'):null;
        Map<String, Object> insuranceDetails = (Map<String, Object>)requestMap.get('insurance_info') != null? (Map<String, Object>)requestMap.get('insurance_info'):null;
        Map<String, Object> subsidyDetails = (Map<String, Object>)requestMap.get('subsidy_info') != null? (Map<String, Object>)requestMap.get('subsidy_info'):null;
        Map<String, Object> offerDetails = (Map<String, Object>)requestMap.get('offer_info') != null? (Map<String, Object>)requestMap.get('offer_info'):null;
        Map<String, Object> warrantyDetails = (Map<String, Object>)requestMap.get('warranty_info') != null? (Map<String, Object>)requestMap.get('warranty_info'):null;
        
        
        //Loan Info
        If(LoanDetails != null && (String)LoanDetails.get('finance_code') != null){
            //Fectch finance
            List<Finance__c> finance =[SELECT id, Name From Finance__c WHERE Finance_Code__c = : (String)LoanDetails.get('finance_code') LIMIT 1];
            
            If(finance.size() == 0 ){throw new CustomException('Sorry! No Finace provider record found');}
            Else{
                standardOrder.Finance__c = finance[0].Id;
                standardOrder.Financed_Amount__c = (double)LoanDetails.get('amount') != null? (double)LoanDetails.get('amount'):0;
                standardOrder.Tenure__c = (double)LoanDetails.get('tenure') != null? (double)LoanDetails.get('tenure'):0;
                standardOrder.Tenure_Type__c = (string)LoanDetails.get('tenure_type') != null? (string)LoanDetails.get('tenure_type'):'Year';
                standardOrder.Approval_Status__c = true;
                standardOrder.Loan_Start_Date__c = system.today();
                standardOrder.EMI_Amount__c = (double)LoanDetails.get('emi_amount') != null? (double)LoanDetails.get('emi_amount'):0;
            }  
        }
        
        //Insurance Info
        If(insuranceDetails != null && (String)insuranceDetails.get('insurer_code') != null){
            //Fectch Insurance
            List<Insurance__c> insurance =[SELECT id, Name From Insurance__c WHERE Insurer_Code__c = : (String)insuranceDetails.get('insurer_code') LIMIT 1];
            
            If(insurance.size() == 0 ){ 
                throw new CustomException('Sorry! No Insurance provider record found');
            } Else{
                standardOrder.Insurance__c = insurance[0].Id;
                standardOrder.Insurance_Amount__c = (double)insuranceDetails.get('amount') != null? (double)insuranceDetails.get('amount'):0;
            }
        }
        
        //Subsidy Info
        If(subsidyDetails != null && (boolean)subsidyDetails.get('eligible_for_subsidy') != null && (boolean)subsidyDetails.get('eligible_for_subsidy') != false){
            //Fectch Insurance
            List<Subsidy__c> subsidies =[SELECT id, Name From Subsidy__c WHERE Subsidy_Code__c = : (String)subsidyDetails.get('subsidy_code') LIMIT 1];
            
            If(subsidies.size() == 0 ){throw new CustomException('Sorry! No subidy details found');}
            Else{
                standardOrder.Subsidy__c = subsidies[0].Id;
                standardOrder.Subsidy_Amount__c = (double)subsidyDetails.get('amount') != null? (double)subsidyDetails.get('amount'):0;
                
                standardOrder.Eligible_For_Subsidy__c = (boolean)subsidyDetails.get('eligible_for_subsidy') != null? (boolean)subsidyDetails.get('eligible_for_subsidy'):false;
            }
        }
        
        //Offers Info
        If(OfferDetails != null && (Double)OfferDetails.get('offer_amount') != null){                
            standardOrder.Offers_Amount__c = (Double)OfferDetails.get('offer_amount') != null? (Double)OfferDetails.get('offer_amount'):0;  
            standardOrder.Offer_description__c  = (string)OfferDetails.get('offer_description') != null? (string)OfferDetails.get('offer_description'):'';
        } 
        
        //Warranty Info
        If(warrantyDetails != null && (Double)warrantyDetails.get('warranty_amount') != null){                
            standardOrder.Warranty_Amount__c = (Double)warrantyDetails.get('warranty_amount') != null? (Double)warrantyDetails.get('warranty_amount'):0;  
            standardOrder.Extended_Warranty__c  = (boolean)warrantyDetails.get('is_extended') != null? (boolean)warrantyDetails.get('is_extended'):false;
        }
        
        return standardOrder;
    }
    
    /**************************************************************************************************************************************************/
    
    public class CustomException extends Exception {}
}