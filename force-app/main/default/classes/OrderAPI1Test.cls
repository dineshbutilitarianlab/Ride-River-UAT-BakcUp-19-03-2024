@isTest
public class OrderAPI1Test {
    @isTest
    static void testCreateStandardOrder() {
        // Create a Standard Pricebook
        Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Pricebook',isActive = true);
        insert standardPricebook;
        
        Account acc1 = new account();
        acc1.name = 'test customer';
        acc1.Type = 'Customer';
        acc1.Phone = '9011110246';
        acc1.email__c = 'ctest@gmail.com';
        insert acc1;
        
        Account acc = new account();
        acc.name = 'test service center';
        acc.Center_Code__c = 'test';
        acc.Type = 'Dealer';
        acc.Phone = '9011113246';
        acc.email__c = 'stest@gmail.com';
        insert acc;
        
        Subsidy__c sub = new Subsidy__c();
        sub.Name = 'subsidy';
        sub.Subsidy_Code__c = 'Subsidy';
        insert sub;
        
        Insurance__c insurance = new Insurance__c();
        insurance.Name = 'insurance';
        insurance.Insurer_Code__c = 'INS';
        insert insurance;
        
        Finance__c finance = new Finance__c();
        finance.name = 'test';
        finance.Finance_Code__c = 'Loan';
        insert finance;
        
        City__c city = new City__c();
        city.Name = 'Bengaluru';
        city.City_Masking_Name__c = 'Bengaluru';
        city.Price_Book__c = standardPricebook.Id;
        Insert city;
        
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('crm_account_id', acc1.Id);
        requestBody.put('order_id', 'RIVERBP87654345678');
        requestBody.put('seller_code', 'test');
        List<Map<String, Object>> productSkuIds = new List<Map<String, Object>>();
        
        Map<String, Object> productInfo = new Map<String, Object>{'product_sku_id' => 'TestSKU', 'product_qty' => 1, 'product_unit_price' => 147462, 'product_order_status' => 'Activated', 'product_type' => 'Parts', 'offer_amount' => 100, 'offer_description' => 'Diwali'};
        Map<String, Object> productInfo1 = new Map<String, Object>{'product_sku_id' => 'TestSKU1', 'product_qty' => 1, 'product_unit_price' => 147462, 'product_order_status' => 'Activated', 'product_type' => 'Vehicle', 'offer_amount' => 100, 'offer_description' => 'Diwali'};
                
        productSkuIds.add(productInfo);
        productSkuIds.add(productInfo1);
        
        requestBody.put('products', productSkuIds);
        requestBody.put('delivery_timeline_description', 'Expected Delivery 16 Apr 2024 - 30 Apr 2024');
        requestBody.put('item_payment_type', 'Booking Amount');
        requestBody.put('billing_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pincode' => '421005', 'state' => 'Karnataka'});
        requestBody.put('shipping_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pincode' => '421005', 'state' => 'Karnataka'});
        requestBody.put('order_status', 'Activated');
        requestBody.put('payment_info', new Map<String, Object>{'payment_id' => 'RIVERBP87654345678', 'payment_type' => 'Booking Amount', 'payment_amount' => 2000, 'payment_status' => 'PAID', 'is_payment_completed' => true, 'pay_gwy_info' => new Map<String, Object>{'bank_ref_no' => '325124124', 'card_name' => 'Visa', 'payment_mode' => 'CREDIT-CARD', 'tracking_id' => '5246246162', 'status' => 'Success', 'failure_message' => 'ErrorMessage'}});
        requestBody.put('subsidy_info', new Map<String, Object>{'eligible_for_subsidy' => true, 'subsidy_code' => 'Subsidy', 'amount' => 0});
        requestBody.put('insurance_info', new Map<String, Object>{'insurer_code' => 'INS', 'amount' => 100});
         requestBody.put('loan_info', new Map<String, Object>{'finance_code' => 'Loan', 'amount' => 100, 'tenure_type' => 'Year','tenure' => 0});
        requestBody.put('offer_info', new Map<String, Object>{'offer_amount' => 0, 'offer_description' => ''});
        requestBody.put('warranty_info', new Map<String, Object>{'warranty_amount' => 0, 'is_extended' => false});
        requestBody.put('notify_by_sms', true);
        requestBody.put('notify_by_email', true);
        requestBody.put('city', 'Bengaluru');
        
        
        // Add other required fields to the requestBody
        
        // Set up mock request and response objects
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = response;
        
        // Create test Product2 records 
        Product2 testProduct = new Product2(Name = 'Test Product', StockKeepingUnit = 'TestSKU', HSN_Code__c='HSN123', Type__c = 'Parts', ProductCode= 'MS123', IsActive = true);
        insert testProduct;
        
        Product2 testProduct1 = new Product2(Name = 'Test Product1', StockKeepingUnit = 'TestSKU1', HSN_Code__c='HSN1231', Type__c = 'Vehicle', ProductCode= 'MS456', IsActive = true);
        insert testProduct1;
        
        Id standardPricebookId = test.getStandardPricebookId();
        // Create a PriceBookEntry for the test product
        PriceBookEntry pricebookEntry = new PriceBookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry;
        
        PriceBookEntry pricebookEntry1 = new PriceBookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry1;
        
        PriceBookEntry pricebookEntry3 = new PriceBookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct1.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry3;
        
        PriceBookEntry pricebookEntry2 = new PriceBookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct1.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry2;
        
        // Call the createStandardOrder method
        Test.startTest();
        OrderAPI.createStandardOrder();
        Test.stopTest();
        
        // Retrieve the response
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());
        
        // Assert the response and other relevant test logic
        /*
        System.assertNotEquals('Success', responseBody.get('status'));
        List<Integration_log__c> logs = [SELECT Integration_Type__c, Status__c FROM Integration_log__c];
        System.assertEquals(1, logs.size());
        Integration_log__c log = logs[0];
        System.assertEquals('Order Creation', log.Integration_Type__c);
        System.assertNotEquals('Success', log.Status__c);*/
    }
    
    // Add more test methods to cover additional scenarios and error cases
    
    @isTest
    static void testCreateStandardOrderWithException() {
        // Create a Standard Pricebook
        Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Pricebook');
        insert standardPricebook;
        
        Account acc1 = new account();
        acc1.name = 'test customer';
        acc1.Type = 'Customer';
        acc1.Phone = '9011110246';
        acc1.email__c = 'ctest@gmail.com';
        insert acc1;
        
        Account acc = new account();
        acc.name = 'test service center';
        acc.Center_Code__c = 'test';
        acc.Type = 'Dealer';
        acc.Phone = '9011113246';
        insert acc;
        
        // Create test data for a scenario that causes an exception
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('crm_account_id', acc1.Id);
        requestBody.put('order_id', 'RIVERBP87654345678');
        requestBody.put('seller_code', '2803');
        List<Map<String, Object>> productsList = new List<Map<String, Object>>();
        Map<String, Object> productInfo = new Map<String, Object>{'product_sku_id' => 'TestSKU', 'product_qty' => 1, 'product_unit_price' => 147462, 'product_order_status' => 'BOOKING_CONFIRMED', 'product_type' => 'PART', 'offer_amount' => 0, 'offer_description' => ''};
            productsList.add(productInfo);
        requestBody.put('products', productsList);
        requestBody.put('delivery_timeline_description', 'Expected Delivery 16 Apr 2024 - 30 Apr 2024');
        requestBody.put('item_payment_type', 'Booking Amount');
        requestBody.put('billing_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pin_code' => '421005', 'state' => 'Karnataka'});
        requestBody.put('shipping_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pin_code' => '421005', 'state' => 'Karnataka'});
        requestBody.put('order_status', 'Activated');
        requestBody.put('payment_info', new Map<String, Object>{'payment_id' => 'RIVERBP87654345678', 'payment_type' => 'Booking Amount', 'payment_amount' => 2000, 'payment_status' => 'PAID', 'is_payment_completed' => true, 'pay_gwy_info' => new Map<String, Object>{'bank_ref_no' => '325124124', 'card_name' => 'Visa', 'payment_mode' => 'CREDIT-CARD', 'tracking_id' => '5246246162', 'status' => 'Success', 'failure_message' => 'ErrorMessage'}});
        requestBody.put('subsidy_info', new Map<String, Object>{'eligible_for_subsidy' => false, 'subsidy_code' => '', 'amount' => 0});
        requestBody.put('offer_info', new Map<String, Object>{'offer_amount' => 0, 'offer_description' => ''});
        requestBody.put('warranty_info', new Map<String, Object>{'warranty_amount' => 0, 'is_extended' => false});
        requestBody.put('notify_by_sms', true);
        requestBody.put('notify_by_email', true);
        
        // Omit other required fields to trigger an exception
        
        // Set up mock request and response objects
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = response;
        
        // Call the createStandardOrder method
        Test.startTest();
        OrderAPI.createStandardOrder();
        Test.stopTest();
        
        // Retrieve the response
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());
        
        // Assert the response and handle the exception as needed
        System.assertEquals('Error', responseBody.get('status'));
        
        // Add more assertions based on your expected response and exception handling
    }
    
    
    @isTest
    static void testUpdateStandardOrder() {
        // Create a Standard Pricebook
        Pricebook2 standardPricebook = new Pricebook2(Name = 'Standard Pricebook');
        insert standardPricebook;
        
        Account acc = new account();
        acc.name = 'test service center';
        acc.Center_Code__c = 'test';
        acc.Type = 'Dealer';
        acc.Phone = '9011113246';
        insert acc;
        
        Account acc1 = new Account();
        acc1.name = 'test customer';
        acc1.Type = 'Customer';
        acc1.Phone = '7899898989';
        insert acc1;
        
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('crm_account_id', acc1.Id);
        requestBody.put('order_id', 'RIVER123');
        requestBody.put('seller_code', 'test');
        List<Map<String, Object>> productsList = new List<Map<String, Object>>();
        Map<String, Object> productInfo = new Map<String, Object>{'product_sku_id' => 'TestSKU', 'product_qty' => 1, 'product_unit_price' => 147462, 'product_order_status' => 'BOOKING_CONFIRMED', 'product_type' => 'Part', 'offer_amount' => 100, 'offer_description' => 'Diwali'};
            productsList.add(productInfo);
        requestBody.put('products', productsList);
        requestBody.put('delivery_timeline_description', 'Expected Delivery 16 Apr 2024 - 30 Apr 2024');
        requestBody.put('item_payment_type', 'Booking Amount');
        requestBody.put('billing_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pin_code' => '421005', 'state' => 'Karnataka'});
        requestBody.put('shipping_address', new Map<String, Object>{'address_1' => 'Address line 1', 'address_2' => 'Address line 2', 'city' => 'Ulhasnagar', 'pin_code' => '421005', 'state' => 'Karnataka'});
        requestBody.put('order_status', 'Allotment in Process');
        requestBody.put('payment_info', new Map<String, Object>{'payment_id' => 'RIVERBP87654345678', 'payment_type' => 'Booking Amount', 'payment_amount' => 2000, 'payment_status' => 'PAID', 'is_payment_completed' => true, 'pay_gwy_info' => new Map<String, Object>{'bank_ref_no' => '325124124', 'card_name' => 'Visa', 'payment_mode' => 'CREDIT-CARD', 'tracking_id' => '5246246162', 'status' => 'Success', 'failure_message' => 'ErrorMessage'}});
        requestBody.put('subsidy_info', new Map<String, Object>{'eligible_for_subsidy' => false, 'subsidy_code' => 'Subsisy1', 'amount' => 0});
        requestBody.put('offer_info', new Map<String, Object>{'offer_amount' => 0, 'offer_description' => ''});
        requestBody.put('warranty_info', new Map<String, Object>{'warranty_amount' => 0, 'is_extended' => false});
        requestBody.put('notify_by_sms', true);
        requestBody.put('notify_by_email', true);
        
        
        // Add other required fields to the requestBody
        
        // Set up mock request and response objects
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request;
        RestContext.response = response;
        
        // Create test Product2 records 
        Product2 testProduct = new Product2(Name = 'Test Product', StockKeepingUnit = 'TestSKU', HSN_Code__c='HSN123', Type__c = 'Parts', IsActive = true, productCode='897678yu');
        insert testProduct;
        Id standardPricebookId = test.getStandardPricebookId();
        // Create a PriceBookEntry for the test product
        PriceBookEntry pricebookEntry = new PriceBookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = testProduct.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry;
        
        PriceBookEntry pricebookEntry1 = new PriceBookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 1000000,
            IsActive = true
        );
        insert pricebookEntry1;
        
        
        
        // Construct Order record
        Order newOrder = new Order(
            AccountId = acc1.Id, 
            EffectiveDate = Date.today(),
            Status = 'Draft' ,
            Pricebook2Id = standardPricebook.Id,
            Website_Order_Id__c = 'RIVER123'
        );
        insert newOrder;
        
        // Construct Order Product record
        OrderItem newOrderItem = new OrderItem(
            OrderId = newOrder.Id,
            PricebookEntryId = pricebookEntry1.Id, 
            Quantity = 1, 
            UnitPrice = pricebookEntry1.UnitPrice, 
            ServiceDate = Date.today(),
            Status__c = 'BOOKING_CONFIRMED',
            Type__c = 'Parts'
        );
        insert newOrderItem;
        
        // Call the createStandardOrder method
        Test.startTest();
        OrderAPI.updateStandardOrder();
        
        requestBody.put('order_status', 'Vehicle Delivered');
         // Set up mock request and response objects
        RestRequest request1 = new RestRequest();
        RestResponse response1 = new RestResponse();
        request1.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request1;
        RestContext.response = response1;
        OrderAPI.updateStandardOrder();
        
        requestBody.put('order_id', newOrderItem.Id);
         // Set up mock request and response objects
        RestRequest request2 = new RestRequest();
        RestResponse response2 = new RestResponse();
        request2.requestBody = Blob.valueOf(JSON.serialize(requestBody));
        RestContext.request = request2;
        RestContext.response = response2;
        OrderAPI.updateStandardOrder();
        
        Test.stopTest();
        
        // Retrieve the response
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.responseBody.toString());
        
        // Assert the response and other relevant test logic
        /*
        System.assertNotEquals('Success', responseBody.get('status'));
        List<Integration_log__c> logs = [SELECT Integration_Type__c, Status__c FROM Integration_log__c];
        System.assertEquals(1, logs.size());
        Integration_log__c log = logs[0];
        System.assertEquals('Order Creation', log.Integration_Type__c);
        System.assertNotEquals('Success', log.Status__c);*/
    } 
}