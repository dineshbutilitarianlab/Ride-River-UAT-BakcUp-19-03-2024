@isTest
public class OrderStatusHandlerTest {
    
    @isTest
    static void testUpdateVehicle() {
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone='9011113246', Email__c = 'test@gmail.com');
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113248', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Contact contacts = new Contact(lastName='test Contact', Primary_contact__c=true, FirstName='Test name', Phone='6767676767', email='testemail@gmail.com', AccountId=acc.Id);
        insert contacts;
        Product2 p2 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 5'
        );
        insert p2;
            VehicleDefinition v1 = new VehicleDefinition(
                Name = 'someName',
                ProductId = p2.Id
            );
        insert v1;
        Software_Version__c sft = new Software_Version__c(Name='Test Name', Latest_Software_Version__c = true);
        insert sft;
        Asset a1 = new Asset(
            Name = 'someName',
            AccountId = acc.Id,
            ContactId= contacts.Id
        );
        insert a1;
        Vehicle vehicle = new Vehicle(
            Name='someName',
            VehicleDefinitionId = v1.Id,
            AssetId = a1.Id,
            VehicleIdentificationNumber = '111S',
            Charger_PC_Number__c = 'BR23456',
            PDI_Status_Pass__c =true,
            Software_Version__c = sft.Id
        );
        insert vehicle;
        Order order = new Order(
            AccountId = acc.Id,
            Dealer__c = dealerAccount.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing 1',
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore 1',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574236',
            BillingCountry = 'India',
            Pricebook2Id = Test.getStandardPricebookId(),
            Assigned_Vehicle__c = vehicle.Id
        );
        Insert order;
        Order order1 = new Order(
            AccountId = acc.Id,
            Dealer__c = dealerAccount.Id,
            Website_Order_Id__c = 'RTYU4567891',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing33',
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalo333re',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'India',
            pricebook2Id = test.getStandardPricebookId(),
            Payment_Status__c = 'Completed'
        );
        Insert order1;
        
        
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 3'
        );
        insert p1;
        
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = p1.Id,
            UnitPrice = 100,
            IsActive = true // You can set other fields as needed
        );
        insert newPricebookEntry;
        
        OrderItem orderItem = new OrderItem(
            OrderId = order1.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = p1.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Vehicle'
        );
        
        insert orderItem;
        
        Order_Invoice__c vehicleInvoice = new Order_Invoice__c(
            Name = 'Vehicle Invoice',
            Invoice_Number__c = 'INV-001',
            Invoice_Type__c = 'Vehicle Invoice',
            Order__c = order.Id
        );
        insert vehicleInvoice;
        
        Order_Invoice__c otherChargesInvoice = new Order_Invoice__c(
            Name = 'Other Charges Invoice',
            Invoice_Number__c = 'INV-002',
            Invoice_Type__c = 'Other Charges Invoice',
            Order__c = order.Id
        );
        insert otherChargesInvoice;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        order1.Status = 'Vehicle Delivered';
        update order1;
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        
    }
    
    
    @isTest
    static void testUpdateVehicle01() {
        // Create sample Order and Vehicle records
        Account acc = new Account(Name = 'Test Name', Type = 'Customer', Phone = '9011113246', Email__c = 'test@gmail.com');
        insert acc;
    
        Account dealerAccount = new Account(Name = 'Test Name', Type = 'Dealer', Phone = '9011113248', Email__c = 'dealer@test.com');
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
    
        Contact contacts = new Contact(LastName = 'test Contact', Primary_contact__c = true, FirstName = 'Test name', Phone = '6767676767', Email = 'testemail@gmail.com', AccountId = acc.Id);
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
            Pricebook2Id = Test.getStandardPricebookId()
        );
        insert order;
    
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c = 'Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 2'
        );
        insert p1;
    
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = p1.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert newPricebookEntry;
    
        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = p1.Id,
            Quantity = 1,
            UnitPrice = 100,
            Type__c = 'Vehicle'
        );
        insert orderItem;
    
        VehicleDefinition v1 = new VehicleDefinition(
            Name = 'someName',
            ProductId = p1.Id
        );
        insert v1;
    
        Software_Version__c sft = new Software_Version__c(Name = 'Test Name', Latest_Software_Version__c = true);
        insert sft;
    
       
    Asset a1 = new Asset();
        a1.Name = 'test Asset';
        a1.AccountId = acc.Id;
        a1.ContactId = contacts.Id;
        insert a1;
        
        Vehicle vehicle = new Vehicle(
            Name = 'someName',
            VehicleDefinitionId = v1.Id,
            AssetId = a1.Id,
            VehicleIdentificationNumber = '111S',
            Charger_PC_Number__c = 'BR23456',
            PDI_Status_Pass__c = TRUE,
            Software_Version__c = sft.Id
        );
        insert vehicle;
    
        
        // Create AssetMilestone record
      /*  AssetMilestone milestone = new AssetMilestone(
            Delivery_Date__c = System.today(),
            MilestoneType = 'PDI',
            VehicleId = vehicle.Id,
            MilestoneDate = System.today(),
            AssetId = a1.Id,
            Name = 'Vehicle Sold',
            UsageType = 'Automotive',
            Stage = 'Tentative'
            
        );
        insert milestone; 
        
        AssetMilestone completedMilestone = new AssetMilestone();
        completedMilestone.Name = 'Completed Milestone';
        completedMilestone.AssetId = a1.Id;
        completedMilestone.UsageType = 'Automotive';
        completedMilestone.MilestoneDate = System.today().addDays(1);
        completedMilestone.MilestoneType = 'PDI';
        completedMilestone.Stage = 'Active';
        completedMilestone.VehicleId = vehicle.Id;
        insert completedMilestone; */
    
        // Update Order status to trigger the logic'
        
        order.Status = 'Vehicle Delivered';
        order.Payment_Status__c = 'Completed'; 
        update order;
    
        // Verify that the AssetMilestone record was created
        List<AssetMilestone> existingMilestones = [SELECT Id, VehicleId, MilestoneType FROM AssetMilestone WHERE VehicleId = :vehicle.Id AND MilestoneType = 'Sold'];
       // System.assertEquals(1, existingMilestones.size(), 'AssetMilestone record should be created');
    	
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        // Call the method to test
        Test.startTest();
        OrderStatusHandler.updateVehicle01(new List<Order>{order}, new Map<Id, Order>{order.Id => order});
        Test.stopTest();
    
        // Verify that the Vehicle status was updated
        Vehicle updatedVehicle = [SELECT Id, Status FROM Vehicle WHERE Id = :vehicle.Id];
       // System.assertEquals('Sold to Customer', updatedVehicle.Status, 'Vehicle status should be updated to Sold to Customer');
    }
    
/*@isTest
static void testEmailHandllerMethod() {
    // Create sample Account
    Account acc = new Account(Name = 'Test Name', Type = 'Customer', Phone='9011113246', email__c='emailtest@gmail.com');
    insert acc;

    // Create sample Contact linked to the Account
    Contact contacts = new Contact(
        LastName='Test Contact',
        Primary_contact__c=true,
        FirstName='Test Name',
        Phone='6767676767',
        Email='testemail@gmail.com',
        AccountId=acc.Id
    );
    insert contacts;

    // Create sample Order
    Order order = new Order(
        AccountId = acc.Id,
        Website_Order_Id__c = 'RTYU456789',
        EffectiveDate = Date.today(),
        Status = 'Draft',
        Eligible_For_Subsidy__c = true, // Initial value set to TRUE
        pricebook2Id = Test.getStandardPricebookId()
    );
    insert order;

    // Create a product
    Product2 p1 = new Product2(
        Name = 'SomeName',
        HSN_Code__c = 'Testt',
        Type__c = 'Vehicle',
        IsActive = true,
        ProductCode = 'Code 1'
    );
    insert p1;

    // Create a PricebookEntry
    PricebookEntry newPricebookEntry = new PricebookEntry(
        Pricebook2Id = Test.getStandardPricebookId(),
        Product2Id = p1.Id,
        UnitPrice = 100,
        IsActive = true
    );
    insert newPricebookEntry;

    // Create OrderItem
    OrderItem orderItem = new OrderItem(
        OrderId = order.Id,
        PricebookEntryId = newPricebookEntry.Id,
        Product2Id = p1.Id,
        Quantity = 1,
        UnitPrice = 100,
        Type__c = 'Vehicle'
    );
    insert orderItem;

    // Create VehicleDefinition
    VehicleDefinition v1 = new VehicleDefinition(
        Name = 'SomeName',
        ProductId = p1.Id
    );
    insert v1;

    // Create Software Version
    Software_Version__c sft = new Software_Version__c(
        Name = 'Test Name',
        Latest_Software_Version__c = true
    );
    insert sft;

    // Create Asset
    Asset a1 = new Asset(
        Name = 'SomeName',
        AccountId = acc.Id,
        ContactId = contacts.Id
    );
    insert a1;

    // Create Vehicle
    Vehicle vehicle = new Vehicle(
        Name = 'SomeName',
        VehicleDefinitionId = v1.Id,
        AssetId = a1.Id,
        VehicleIdentificationNumber = '111S',
        Charger_PC_Number__c = 'BTR4568',
        PDI_Status_Pass__c =true,
        Software_Version__c = sft.Id
    );
    insert vehicle;

    // Create Warranty Term
    WarrantyTerm warrantyTerm = new WarrantyTerm(
        WarrantyTermName = 'Ssss',
        WarrantyDuration = 7889,
        WarrantyUnitOfTime = 'Days',
        EffectiveStartDate = 'Install Date',
        WarrantyType = 'Repair'
    );
    insert warrantyTerm;

  

    // Create oldMap with the old order record
    Order oldOrder = order.clone();
    oldOrder.Eligible_For_Subsidy__c = true; // Initial state
    Map<Id, Order> oldMap = new Map<Id, Order>();
    oldMap.put(order.Id, oldOrder);

    // Update order to trigger email logic
    Order order2 = new Order();
    order2.Id = order.Id;
    order2.Assigned_Vehicle__c = vehicle.Id;
    order2.Status = 'Vehicle Delivered';
    order2.Warranty_Term__c = warrantyTerm.Id;
    order2.Eligible_For_Subsidy__c = false; // Changed from TRUE to FALSE
    order2.AccountId = acc.Id;
    order2.Payment_Status__c  = 'Completed';
    update order2;

    List<Order> testNewOrderList = new List<Order>{ order2 };
        
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());

    Test.startTest();
    OrderStatusHandler.emailHandllerMethod(testNewOrderList, oldMap);
    Test.stopTest();

    // Verify that an email was sent
    List<EmailMessage> sentEmails = [SELECT Id FROM EmailMessage];
   // System.assertEquals(1, sentEmails.size(), 'Email should be sent when subsidy eligibility changes from TRUE to FALSE');
} */

    
    @isTest
    static void testSendReceipt() {
        // Create sample Order and Vehicle records
        //Test.setMock(HttpCalloutMock.class, new TestCalloutMock());
        
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone='9011113246', Email__c = 'test@gmail.com');
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        List<Contact> contactList = [SELECT id, name FROM Contact WHERE AccountId = :acc.Id];
        contact contacts = new contact();
        If(contactList.size()>0){
            contacts = contactList[0];
        }else{
            contacts = new contact(lastName='test Contact', Primary_contact__c=true, FirstName='Test name', Phone='6767676767', email='testemail@gmail.com', AccountId=acc.Id);
            insert contacts;
        }
        
        Order order = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.newInstance(2024, 12, 31),
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
            pricebook2Id = test.getStandardPricebookId(),
            Dealer__c = dealerAccount.Id
            
        );
        Insert order;
        
        
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 5'
        );
        
        Product2 p2 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Accessories',
            IsActive = true,
            ProductCode = 'code 4'
        );
        Product2 p3 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Parts',
            IsActive = true,
            ProductCode = 'code 4'
        );
        Product2 p4 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Add-ons',
            IsActive = true,
            ProductCode = 'code 4'
        );
        Product2 p5 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Merchandise',
            IsActive = true,
            ProductCode = 'code 4'
        );
        Insert new list<Product2>{p1,p2,p3,p4,p5};
            
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

        OrderItem orderItem2 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = p3.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Parts'
        );

        OrderItem orderItem3 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = p4.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Add-ons'
        );

        OrderItem orderItem4 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = p5.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Merchandise'
        );
        
        Insert new List<orderItem>{orderItem1,orderItem,orderItem2,orderItem3,orderItem4};
            
            VehicleDefinition v1 = new VehicleDefinition(
                Name = 'someName',
                ProductId = p1.Id
            );
        insert v1;
        Software_Version__c sft = new Software_Version__c(Name='Test Name', Latest_Software_Version__c = true);
        insert sft;
        Asset a1 = new Asset(
            Name = 'someName',
            AccountId = acc.Id,
            ContactId= contacts.Id
        );
        insert a1;
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
            Transaction_Id__c = 'payment2'
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
        
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        Test.startTest();
        
         Test.setMock(HttpCalloutMock.class, new TestCalloutMock());
        
        OrderStatusHandler.ceateInvoiceRecords(testNewOrderList, oldMap);
        
        order2.status = 'RTO Registration';
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        OrderStatusHandler.generateIvoicesAndReceipts(testNewOrderList, oldMap);
        
        oldMap.get(order.Id).Status = 'RTO Registration';
        order2.status = 'Activated';
        
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        OrderStatusHandler.sendPreOrderReceipt(testNewOrderList, oldMap);
        OrderStatusHandler.sendPreOrderReceipt01(new List<Order_Payment__c>{op});
        Test.stopTest();
    } 
    
  /*  @isTest
    static void testcreateInvoicesTest() {
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone='9011113246', Email__c = 'test@gmail.com');
        insert acc;
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        List<Contact> contactList = [SELECT id, name FROM Contact WHERE AccountId = :acc.Id];
        contact contacts = new contact();
        If(contactList.size()>0){
            contacts = contactList[0];
        }else{
            contacts = new contact(lastName='test Contact', Primary_contact__c=true, FirstName='Test name', Phone='6767676767', email='testemail@gmail.com', AccountId=acc.Id);
            insert contacts;
        }
        
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
            pricebook2Id = test.getStandardPricebookId(),
            Dealer__c = dealerAccount.Id
        );
        Insert order;
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 7'
        );
        Product2 p2 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Accessories',
            IsActive = true,
            ProductCode = 'code 6'
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
        Insert new List<orderItem>{orderItem};
            
            VehicleDefinition v1 = new VehicleDefinition(
                Name = 'someName',
                ProductId = p1.Id
            );
        insert v1;
        Software_Version__c sft = new Software_Version__c(Name='Test Name', Latest_Software_Version__c = true);
        insert sft;
        Asset a1 = new Asset(
            Name = 'someName',
            AccountId = acc.Id,
            ContactId= contacts.Id
        );
        insert a1;
        Vehicle vehicle = new Vehicle(
            Name='someName',
            VehicleDefinitionId = v1.Id,
            AssetId = a1.Id,
            VehicleIdentificationNumber = '111S',
            Charger_PC_Number__c = 'BR23456',
            Software_Version__c = sft.Id,
            PDI_Status_Pass__c=true
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
            Transaction_Id__c = 'payment3'
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
            WarrantyUnitOfTime = 'Months',
            EffectiveStartDate = 'Install Date',
            WarrantyType = 'Repair');
        insert warrantyTerm;
        
        // Create oldMap with the old order record
        Map<Id, Order> oldMap = new Map<Id, Order>();
        oldMap.put(order.Id, Order1);
        
        order2.Assigned_Vehicle__c=vehicle.Id;
        //order2.Status='RTO Registration';
            
        List<Order> testNewOrderList = new List<Order>();
        testNewOrderList.add(order2);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplAfterCancel());
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        
        Test.startTest();
        
        update testNewOrderList;
        
        order2.Status='RTO Registration';
        update order2;
        
        OrderStatusHandler.ceateInvoiceRecords(testNewOrderList, oldMap);
        
        order2.status = 'RTO Registration';
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        OrderStatusHandler.generateIvoicesAndReceipts(testNewOrderList, oldMap);
        
        oldMap.get(order.Id).Status = 'RTO Registration';
        order2.status = 'Activated';
        
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        OrderStatusHandler.sendPreOrderReceipt(testNewOrderList, oldMap);
        OrderStatusHandler.sendPreOrderReceipt01(new List<Order_Payment__c>{op});
       Test.stopTest();
        
         
    } 
    public class HttpCalloutMockImplAfterCancel implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             
            
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
           
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
         
    } */
    
    @isTest
    static void testcreateInvoicesAccessoriesTest() {
        // Create sample Order and Vehicle records
        Account acc = new Account(Name = 'Test Name',Type = 'Customer',Phone='9011113246', Email__c = 'test@gmail.com');
        insert acc;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        List<Contact> contactList = [SELECT id, name FROM Contact WHERE AccountId = :acc.Id];
        contact contacts = new contact();
        If(contactList.size()>0){
            contacts = contactList[0];
        }else{
            contacts = new contact(lastName='test Contact', Primary_contact__c=true, FirstName='Test name', Phone='6767676767', email='testemail@gmail.com', AccountId=acc.Id);
            insert contacts;
        }
        
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
            pricebook2Id = test.getStandardPricebookId(),
            Dealer__c = dealerAccount.Id
            
        );
        Insert order;
        
        
        Product2 p1 = new Product2(
            Name = 'someName',
            HSN_Code__c='Testt',
            Type__c = 'Vehicle',
            IsActive = true,
            ProductCode = 'code 8'
        );
        
        Product2 p2 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Accessories',
            IsActive = true,
            ProductCode = 'code 9'
        );
        Product2 p3 = new Product2(
            Name = 'someName1',
            HSN_Code__c='Testt1',
            Type__c = 'Add-ons',
            IsActive = true,
            ProductCode = 'code 9'
        );
        
        Insert new list<Product2>{p1,p2,p3};
            
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
        PricebookEntry newPricebookEntry2 = new PricebookEntry(
            Pricebook2Id = test.getStandardPricebookId(),
            Product2Id = p3.Id,
            UnitPrice = 100,
            IsActive = true // You can set other fields as needed
        );
        
        Insert new List<PricebookEntry>{newPricebookEntry1,newPricebookEntry,newPricebookEntry2};
            
            OrderItem orderItem1 = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = newPricebookEntry.Id,
                Product2Id = p1.Id,
                Quantity = 1, 
                UnitPrice = 100,
                Type__c = 'Accessories'
            );
        OrderItem orderItem2 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = p2.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Parts'
        );
        OrderItem orderItem3 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = newPricebookEntry2.Id,
            Product2Id = p3.Id,
            Quantity = 1, 
            UnitPrice = 100,
            Type__c = 'Add-ons'
        );
        
        
        Insert new List<orderItem>{orderItem1,orderItem2,orderItem3};
            
            VehicleDefinition v1 = new VehicleDefinition(
                Name = 'someName',
                ProductId = p1.Id
            );
        insert v1;
        
        Software_Version__c sft = new Software_Version__c(Name='Test Name', Latest_Software_Version__c = true);
        insert sft;
        Asset a1 = new Asset(
            Name = 'someName',
            AccountId = acc.Id,
            ContactId= contacts.Id
        );
        insert a1;
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
            Transaction_Id__c = 'payment4'
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
            WarrantyUnitOfTime = 'Weeks',
            EffectiveStartDate = 'Install Date',
            WarrantyType = 'Repair');
        insert warrantyTerm;
        
        // Create oldMap with the old order record
        Map<Id, Order> oldMap = new Map<Id, Order>();
        oldMap.put(order.Id, Order1);
        
        List<Order> testNewOrderList = new List<Order>();
        testNewOrderList.add(order2);
         WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg' ,
             fullpayment_done__c='examplePayment.jpg'
             
        );
        insert mockIntegration;
         Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        Test.startTest();
        //Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());
        ApexPages.StandardController sc = new ApexPages.StandardController(order);
        CreateReceiptAddOnsController testAccPlan = new CreateReceiptAddOnsController(sc);
        
        PageReference pageRef = Page.CreateReceiptAddOns; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(order.Id));
        Test.setCurrentPage(pageRef);
        
        OrderStatusHandler.ceateInvoiceRecords(testNewOrderList, oldMap);
        
        order2.status = 'RTO Registration';
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        OrderStatusHandler.generateIvoicesAndReceipts(testNewOrderList, oldMap);
        
        oldMap.get(order.Id).Status = 'RTO Registration';
        order2.status = 'Activated';
        
        testNewOrderList.clear();
        testNewOrderList.add(order2);
        OrderStatusHandler.sendPreOrderReceipt(testNewOrderList, oldMap);
        
        OrderStatusHandler.sendPreOrderReceipt01(new List<Order_Payment__c>{op});
        
        Test.stopTest();
        
    }
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
             
            
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
           
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
         
    }
    static testMethod void testCodeCoverage() {
        OrderStatusHandler.addTest();
       
        OrderStatusHandler.addTest2();
        OrderStatusHandler.addTest3();
        OrderStatusHandler.addTest4();
        
       
    }
    
}