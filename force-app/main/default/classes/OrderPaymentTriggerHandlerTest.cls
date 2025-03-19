@isTest
public class OrderPaymentTriggerHandlerTest {
    
    @isTest
    static void testInsertHandler() {
        // Create test data for Order_Payment__c and Payment__c objects
        List<Order_Payment__c> orderPayments = new List<Order_Payment__c>();
        List<Payment__c> payments = new List<Payment__c>();
        
        // Create test Payment records
 		// Create test Order_Payment records
        Payment__c payment = new Payment__c(
            Amount__c = 1000.00,           
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card',
            Transaction_Id__c = 'RTYU456789'
        );
        insert payment;
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
        // Create related Order Payment records for the test Payments
        
        Order_Payment__c op = new Order_Payment__c(
            Payments__c = payment.Id,
            Order__c = standardOrder.Id,
            Type__c = 'Down Payment'
        );
        
        insert op;
        
        // Call the insertHandler method
        Test.startTest();
        OrderPaymentTriggerHandler.insertHandler(orderPayments);
        Test.stopTest();
        
        // Verify that the Amount1__c field in Order_Payment records was updated
        op = [SELECT Amount1__c FROM Order_Payment__c WHERE Id = :op.Id];
        System.assertEquals(1000.00, op.Amount1__c);
        
      
    }
    
    @isTest
    static void testUpdateOrderOnInsert() {
        // Create test data for Order_Payment__c records
        List<Order_Payment__c> orderPayments = new List<Order_Payment__c>();
        map<Id,Order_Payment__c> maporderPayments=new map<Id,Order_Payment__c>();
        
        
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
        // Create related Order Payment records for the test Payments
        
        Order onew = [SELECT Id, Grand_Total__c FROM Order WHERE Id =: standardOrder.Id];
        
        // Create test Order_Payment records
         Payment__c payment = new Payment__c(
            Amount__c = onew.Grand_Total__c,           
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card',
             Transaction_Id__c= 'RTYU456789'
        );
        insert payment;
        Order_Payment__c op = new Order_Payment__c(
            Payments__c = payment.Id,
            Order__c = standardOrder.Id,
            Type__c = 'Down Payment'
        );
        
        insert op;
        
        
        // Call the updateOrderOnInsert method
        Test.startTest();
        OrderPaymentTriggerHandler.updateOrderOnInsert(orderPayments);
        Test.stopTest();
        
        // Verify that the Order records were updated
        Order op1 = [SELECT Payment_Status__c, Order_Status__c FROM Order];
       // System.assertEquals('Completed', op1.Payment_Status__c);
       // System.assertNotEquals('Allotment in Process', op1.Order_Status__c);
        
       
    }
    
    @isTest
    static void testUpdateOrderOnUpdate() {
        // Create test data for Order_Payment__c records
        List<Order_Payment__c> orderPayments = new List<Order_Payment__c>();
        //map of old records
       map<Id,Order_Payment__c> oldrecordmap=new Map<Id, Order_Payment__c>();
        // Create test Order_Payment records
        // Create test Order_Payment records
        Payment__c payment = new Payment__c(
            Amount__c = 1000.00,           
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card',
            Transaction_Id__c= 'RTYU456789'
        );
        insert payment;
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
        // Create related Order Payment records for the test Payments
        
        Order_Payment__c op = new Order_Payment__c(
            Payments__c = payment.Id,
            Order__c = standardOrder.Id,
            Type__c = 'Down Payment',
            Amount1__c=10000
        );
        
        insert op;
        oldrecordmap.put(op.Id,op);
        //orderPayments.add(op);
        Order_Payment__c amountupdate=[select id,Amount1__c,Order__c,Type__c from Order_Payment__c where id=:op.Id];
        amountupdate.Amount1__c=1500;
        update amountupdate;
        orderPayments.add(amountupdate);
        // Call the updateOrderOnUpdate method
        Test.startTest();
       // OrderPaymentTriggerHandler.updateOrderOnUpdate(orderPayments, new Map<Id, Order_Payment__c>());
        OrderPaymentTriggerHandler.updateOrderOnUpdate(orderPayments,oldrecordmap);

        Test.stopTest();
        
        // Verify that the Order records were updated
        Order op2 = [SELECT Payment_Status__c, Order_Status__c FROM Order];
        //System.assertEquals('Completed', op2.Payment_Status__c);
        
    }
    
    @isTest
    static void testCheckDuplicateOnInsert() {
        
       Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        
        mapnewRecords = TestDataFactory.CreateOrder();
        
        List<Order_Payment__c>  opList = new List<Order_Payment__c>{(Order_Payment__c)mapnewRecords.get('OrderPaymentId')};
            List<Payment__c>  pList = new List<Payment__c>{(Payment__c)mapnewRecords.get('PaymentId')};
                
       Order_Payment__c op = new Order_Payment__c(
            Payments__c = mapnewRecords.get('PaymentId').Id,
            Order__c = mapnewRecords.get('OrderId').Id,
            Type__c = 'Down Payment'
        );
        
        Order_Payment__c op1 = new Order_Payment__c(
            Payments__c = mapnewRecords.get('PaymentId').Id,
            Order__c = mapnewRecords.get('OrderId').Id,
            Type__c = 'Down Payment'
        );                

        Test.startTest();

        // Call the checkDuplicateOnInsert method to check for duplicate Order Payment records
        OrderPaymentTriggerHandler.checkDuplicateOnInsert(new List<Order_Payment__c>{op, op1}, false);

        Test.stopTest();
	}
    //Method added by Aniket on 12/02/2025 for WhatsApp Integration
    @IsTest
    static void testWhatsAppIntegration(){
        Account testAccount = new Account(Name = 'Test Account',Type='Customer',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,	
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Pending', Contact__c = con.id,Booking_Form_File_URL__c='test.pdf',Website_Order_Id__c='TestABC!@#',Allotment_In_Process_File_URL__c='testInvoice.pdf');
        insert oldOrder;
        
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0,Type__c='Vehicle', Quantity = 1, PricebookEntryId = testPricebookEntry.Id);
        insert testOrderItem;
         
        Order_Invoice__c o = new Order_Invoice__c (Invoice_Type__c='Vehicle Invoice',Order__c=oldOrder.Id,Name='test',Invoice_Number__c='ab1cd2');
        insert o;
        
         Payment__c payment = new Payment__c(
            Amount__c = 1000.00,           
            Payment_Status__c = 'Awaited',
            Mode_Of_Payment__c = 'Credit Card',
            Transaction_Id__c = 'RTYU456789',
             Source_Of_Payment__c='Website'
         
        );
        insert payment;
        
        Order_Payment__c op = new Order_Payment__c(Payments__c=payment.Id,Order__c=oldOrder.Id,Type__c='Booking Amount',Payment_Acknowledgement_Generated__c=false);
        insert op;
        
        
        
        Attachment a = new Attachment(Name='Test.pdf',Body=Blob.valueof('test'),ParentId=op.Id);
        insert a;
        
        Test.startTest();
        op.Payment_Acknowledgement_Generated__c=true;
        update op;
        Test.stopTest();

    }
    
}