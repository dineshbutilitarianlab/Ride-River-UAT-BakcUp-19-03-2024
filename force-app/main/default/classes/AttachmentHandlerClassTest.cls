@isTest
private class AttachmentHandlerClassTest {
    
    @isTest
    static void testAttachmentHandlerMethod() {
         // Create sample Order and Vehicle records
          WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',fullpayment_done__c='random.jpg'
        );
        insert mockIntegration;
        
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone='9011113246' );
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Contact contacts = new Contact(
            AccountId=acc.Id,
            Lastname='Contact1',
             Phone ='9011113246',
            email='testing@gmail.com',
            Primary_Contact__c = true
        );
        insert contacts;
        Order order = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'India',
            Is_DC_Generated__c = false,
            Is_Vehicle_Invoice_Generated__c = false,
            Is_RTO_and_IR_Generated__c = false,
            IS_OCT_Generated__c = false,
            IsAccessories_Generated__c =false,
            IsMerchandise_Generated__c = true,
            pricebook2Id = test.getStandardPricebookId(),
            Dealer__c = dealerAccount.Id
            
        );
        Insert order;
                       
        
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 1'
        );
        
        Product2 p2 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Accessories',
            IsActive = true,
            ProductCode = 'code 2'
        );
        
        Insert new list<Product2>{p1,p2};
        
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = p1.Id,
            UnitPrice = 100,
            IsActive = true // You can set other fields as needed
        );
        
        PricebookEntry newPricebookEntry1 = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = p2.Id,
            UnitPrice = 100,
            IsActive = true // You can set other fields as needed
        );
        
        Insert new List<PricebookEntry>{newPricebookEntry1,newPricebookEntry};
        
        //List<orderItem> opList = new 
        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = p1.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Vehicle'
        );
        
        OrderItem orderItem1 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = p2.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Accessories'
        );
        
        Insert new List<orderItem>{orderItem1,orderItem};
            
       
             VehicleDefinition v1 = new VehicleDefinition(
            Name = 'someName',
            ProductId = p1.Id
        );
        insert v1;
        
        
        Asset a1 = new Asset(
            Name = 'someName',
            AccountId = acc.Id,
            ContactId= contacts.Id
        );
        insert a1;
        
        Software_Version__c sft = new Software_Version__c(Name='Test Name', Latest_Software_Version__c = true);
        
        Insert sft;
        
        Vehicle vehicle = new Vehicle(
            Name='someName',
            VehicleDefinitionId = v1.Id,
            AssetId = a1.Id,
            VehicleIdentificationNumber = '111S',
            Charger_PC_Number__c = 'BR23456',
            Software_Version__c = sft.Id
        );
        insert vehicle;
        
        Order Order1 = order;
        Order1.Status = 'Draft';
        
        //Assign the Vehicle
        order order2 = new Order(
        AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Pre Invoice',
            Description = 'Nothing',
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'India',
            pricebook2Id = test.getStandardPricebookId(),
            Dealer__c = dealerAccount.Id,
            Id = order.Id,
            Assigned_Vehicle__c = vehicle.Id            
        ); 
        
        //update order;
        
        Order o1 = [SELECT Id, Grand_Total__c from Order WHERE Id =:order.Id];
        
        Payment__c payment = new Payment__c(
            Amount__c = o1.Grand_Total__c,           
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card',
            Transaction_Id__c = '23423iowr'
        );
        insert payment;
        
        // Create related Order Payment records for the test Payments
        
        Order_Payment__c op = new Order_Payment__c(
            Payments__c = payment.Id,
            Order__c = order.Id,
            Type__c = 'Down Payment'
        );
        
        insert op;

        WarrantyTerm warrantyTerm = new WarrantyTerm(	
            WarrantyTermName = 'Ssss',
            WarrantyDuration = 7889,
            WarrantyUnitOfTime = 'Days',
            EffectiveStartDate = 'Install Date',
            WarrantyType = 'Repair');
        insert warrantyTerm;
        
        // Create oldMap with the old order record
        Map<Id, Order> oldMap = new Map<Id, Order>();
        oldMap.put(order.Id, Order1);
        
        List<Order> testNewOrderList = new List<Order>();
        testNewOrderList.add(order2);
        
        Map<Id, Set<String>> orderToItemTypeMap = new Map<Id, Set<String>>();
        orderToItemTypeMap.Put(order.Id, new Set<String>{'Vehicle', 'Accessories'});
        
        Test.startTest();
        OrderStatusHandler.ceateInvoiceRecords(testNewOrderList, oldMap);
        
        
        // Call the AttachmentHandlerMethod with the test Order Id
        AttachmentHandlerClass.AttachmentHandlerMethod(new set<Id>{order.Id}, JSON.serialize(orderToItemTypeMap));
        Test.stopTest();

        // Assert the created attachments and other relevant details
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :order.Id];
        //System.assertEquals(5, attachments.size());
    } 


    @isTest
    static void testAttachmentHandlerMethod03() {
        // Create a test Order with Booking_Payment_Id__c populated
        
        Map<string, Object> dataMap = TestDataFactory.CreateOrder();
        
        Test.startTest();
        OrderItem op = (OrderItem)dataMap.get('OrderProductId');
        Order o = (Order)dataMap.get('OrderId');
        o.Booking_Payment_Id__c = 'TestPaymentId';
        // Call the AttachmentHandlerMethod03 with the test Order Id
        AttachmentHandlerClass.AttachmentHandlerMethod03(o.Id);
        Test.stopTest();

        // Assert the created attachments and other relevant details
        List<Attachment> attachments = [SELECT Id FROM Attachment WHERE ParentId = :o.Id];
        System.assertEquals(1, attachments.size()); // One attachment is created
        // Add more assertions as needed
    }
 
}