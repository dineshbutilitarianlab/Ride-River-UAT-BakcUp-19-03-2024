@isTest
private class OrderProductTriggerControllerTest {
    // Test method to cover Updatehandler method
    @isTest
    static void testUpdatehandler() {
      Map<Id,OrderItem> olditem=new map<Id,OrderItem>();
        // Create test data
        // Insert test OrderItem records
         Account acc = new Account(Name = 'Test Name',Type = 'Customer', Phone = '9011113246' );
        insert acc;
        Id standardPricebookId = test.getStandardPricebookId();
         Order standardOrder = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            pricebook2Id = standardPricebookId,
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            //Payment_Type__c = itemPaymentType,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'India'
        );
        Insert standardOrder;
         Product2 newProduct = new Product2(
            Name = 'Bike',
            Description = 'Vehicle',
            IsActive = true,
            HSN_Code__c ='Test',
            Type__c ='Vehicle',
             ProductCode = 'testproduvt'
        );
        insert newProduct;
           PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = newProduct.Id,
            UnitPrice = 1000000,
            IsActive = true // You can set other fields as needed
        );
           
        Warehouse__c warehouse = new Warehouse__c(
        Name='Test',
        Manager__c = UserInfo.getUserId()
       // Company_Warehouse__c = warehouse.Id;
            );
        insert warehouse;
        Inventory_Lot__c inventoryLotss = new Inventory_Lot__c(
            Name = 'Test',
            Warehouse__c = warehouse.Id,
            Type__c ='Vehicle',
            Available_Quantity__c = 10

        );
        insert inventoryLotss;


        insert newPricebookEntry;
        List<OrderItem> orderItems = new List<OrderItem>();
           OrderItem orderItem = new OrderItem(
            OrderId = standardOrder.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = newProduct.Id,
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Vehicle',
            Status__c = 'FULLY_REFUNDED',
            Inventory_Lot__c = inventoryLotss.Id,
               Is_Integration__c = true
        );
        
        Insert orderItem;
           
            olditem.put(orderItem.Id,orderItem);    
          OrderItem orderit=[select id,OrderId,Status__c,Type__c,Inventory_Lot__c,Quantity, Is_Integration__c from OrderItem where Status__c = 'FULLY_REFUNDED'];  
                 orderit.Status__c='REFUND_REQUESTED';
                  orderItems.add(orderit);
                  update orderItems;
        Test.startTest();
        // Insert the test OrderItem records
       

        // Call the Updatehandler method
        OrderProductTriggerController.Updatehandler(orderItems,olditem);
        OrderProductTriggerController.Deletehandler(orderItems);
        

        Delete orderItem;
        Test.stopTest();
    }

}