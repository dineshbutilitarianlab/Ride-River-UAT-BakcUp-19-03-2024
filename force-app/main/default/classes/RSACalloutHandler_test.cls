@istest
public class RSACalloutHandler_test {
    
    @istest
    public static Id getchasisnumbertestforstatusvehicleallocation() {
        List<Order> ordlist = new List<Order>(); 
        
        Account Acc = new Account();
        Acc.Name = 'test';
        insert Acc;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = Acc.Id;
        con.Phone = '0000000000';
        insert con;
        
        Asset a = new Asset();
        a.Name = 'Test';
        a.ContactId = con.Id;
        a.AccountId = Acc.Id;
        insert a;
        
        Product2 p = new Product2();
        p.ProductCode = 'testpro';
        p.Name = 'test';
        p.Name = 'Road Side Assistance';
        p.Type__c = 'Accessories';
        p.HSN_Code__c = '00000000';
        insert p; 
        
        // Query Standard Pricebook
        
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'VehicleDefinitiontest';
        vd.ProductId = p.Id;
        insert vd;
        
        Software_Version__c sv = new Software_Version__c();
        insert sv;
        
        Vehicle v = new Vehicle();
        v.Name = 'test';
        v.VehicleIdentificationNumber = 'Test00001223';
        v.VehicleDefinitionId = vd.Id;
        v.Charger_PC_Number__c = '000000000';
        v.Software_Version__c = sv.Id;
        v.PDI_Status_Pass__c = true;
        v.AssetId = a.Id;
        v.CurrentOwnerId = Acc.Id; // Assign to Account
        v.RSA_Activation__c = false; // Ensure this matches the query condition
        insert v;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'test';
        insert pb; 
        
        
        
        Order o = new Order();
        o.Pricebook2Id = pb.Id;  
        o.AccountId = Acc.Id;
        o.Payment_Status__c = 'Completed';
        o.Status = 'Activated';
        o.EffectiveDate = Date.today();
        o.Assigned_Vehicle__c = v.Id;
        insert o; 
        
        
        
        
        
        list<Pricebook2> standardPricebook = [SELECT Id,IsStandard,IsActive FROM Pricebook2];
        Id standardPricebookcostumproduct;
        for(Pricebook2 ppb:standardPricebook){
            if(ppb.IsStandard==true){
                PricebookEntry standardPriceEntry = new PricebookEntry();
                standardPriceEntry.Pricebook2Id = ppb.Id;
                standardPriceEntry.Product2Id = p.Id;
                standardPriceEntry.UnitPrice = 10000.00; // Set the standard price
                standardPriceEntry.IsActive = true;
                insert standardPriceEntry;
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.UnitPrice = 10000.00;
                pe.Pricebook2Id =ppb.Id ;  
                pe.Product2Id = p.Id;  
                insert pe;
                OrderItem Oitem = new OrderItem();
                Oitem.Product2Id = p.Id;
                Oitem.OrderId = o.Id;
                Oitem.UnitPrice = pe.UnitPrice;
                Oitem.PricebookEntryId = pe.Id;
                Oitem.Quantity = 1;
                insert Oitem;
                system.debug('Orderidtest'+o.Id);
                
                standardPricebookcostumproduct=pe.Id;
                
            }
        }
        
        
        
        
        
        return o.Id;
        
    }
    
    @istest
    public static void getchasisnumbertestforstatusvehicleallocationtest() {
        Id orderid = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();
        Order ord = [SELECT Id, Status,RSA_Active__c FROM Order WHERE Id = :orderid];
        
        ord.Status = 'Ready For Delivery';
        ord.RSA_Active__c=true;
        update ord;
        List<Order> orderlst = new List<Order>();
        // Test.startTest();
        // RSACalloutHandler.getchasisnumber(orderlst);
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        // Test.stopTest();
        
    }
    
    @istest
    public static void getchasisnumbertestforstatusvehicleallocationtestupdatereg() {
        Id orderid = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();
        Order ord = [SELECT Id, Status,RSA_Active__c FROM Order WHERE Id = :orderid];
        
        ord.Status = 'Payment Pending';
        ord.RSA_Active__c = true;
        ord.Payment_Status__c = 'Completed';
        update ord;
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
    }
    
    //test class method Added by Aniket on 16/01/2025
    @isTest
    public static void testGetChasisNumberWithoutVehicleOrder() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Id orderId = RSACalloutHandler_test.getchasisnumbertestforstatusvehicleallocation();//getchasisnumberWihtoutVehicleOrder
        
        Order_Invoice__c oi = new Order_Invoice__c(Order__c=orderId,Name='Test Invoice',Invoice_Number__c='i12Ac4',Invoice_Type__c='Vehicle Invoice',
                                                   Invoice_date__c=System.Today());
        insert oi;
        
        Order order = [SELECT Id, Status, RSA_Active__c FROM Order WHERE Id = :orderId];
        order.Status = 'RTO Registration';
        order.RSA_Active__c = false;
        update order;
        
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg',
            fullpayment_done__c='examplePayment.jpg'
        );
        insert mockIntegration;
        
        //Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RSACalloutMock());
        RSACalloutHandler.getchasisnumberWihtoutVehicleOrder(new List<Order>{order});
        
        Test.stopTest();
        
    }
    
    @IsTest
    public static void handleGetChassisNumber() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        con.Phone = '0000000000';
        insert con;
        
        Asset a = new Asset();
        a.Name = 'Test Asset';
        a.ContactId = con.Id;
        a.AccountId = acc.Id;
        insert a;
        
        Product2 objProduct = new Product2();
        objProduct.Name = 'Road Side Assistance';
        objProduct.Description = 'Test Product';
        
        objProduct.StockKeepingUnit = 'testing';
        objProduct.IsActive = true;
        objProduct.ProductCode = '456c';
        objProduct.HSN_Code__c = '1';
        objProduct.Type__c = 'Accessories';
        insert objProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Custom Price Book',
            IsActive = true
        );
        insert customPricebook;
        
        PricebookEntry standardPBEntry = new PricebookEntry();
        standardPBEntry.Pricebook2Id = standardPricebook.Id;
        standardPBEntry.Product2Id = objProduct.Id;
        standardPBEntry.UnitPrice = 500;
        standardPBEntry.IsActive = true;
        insert standardPBEntry;
        
        PricebookEntry customPBEntry = new PricebookEntry();
        customPBEntry.Pricebook2Id = customPricebook.Id;
        customPBEntry.Product2Id = objProduct.Id;
        customPBEntry.UnitPrice = 500;
        customPBEntry.IsActive = true;
        insert customPBEntry;
        
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'VehicleDefinitionTest';
        vd.ProductId = objProduct.Id;
        insert vd;
        
        Software_Version__c sv = new Software_Version__c();
        insert sv;
        
        Vehicle v = new Vehicle();
        v.Name = 'Test Vehicle';
        v.VehicleIdentificationNumber = 'Test00001223';
        v.VehicleDefinitionId = vd.Id;
        v.Charger_PC_Number__c = '000000000';
        v.Software_Version__c = sv.Id;
        v.PDI_Status_Pass__c = true;
        v.AssetId = a.Id;
        v.CurrentOwnerId = acc.Id;
        v.RSA_Activation__c = false;
        v.VehicleRegistrationNumber ='DFGH';
        v.ChassisNumber = 'DFGHJKL';
        insert v;
        
        Order odr = new Order();
        odr.Name = 'Test Order';
        odr.Assigned_Vehicle__c = v.Id;
        odr.Status = 'RTO Registration';
        odr.AccountId = acc.Id;
        odr.EffectiveDate = System.Today();
        odr.Pricebook2Id = standardPricebook.Id;
        insert odr;
        
        OrderItem oi = new OrderItem();
        oi.OrderId = odr.Id;
        oi.PricebookEntryId = standardPBEntry.Id;
        oi.Quantity = 1;
        oi.UnitPrice = 500;
        insert oi;
        
        System.debug('Order ID: ' + odr.Id);
        
        Test.startTest();
        odr.Status = 'Vehicle Delivered';
        odr.Assigned_Vehicle__c = v.Id;
        odr.Payment_Status__c = 'Completed';
        update odr;
        RSACalloutHandler.addTest();
        RSACalloutHandler.addTest1();
        RSACalloutHandler.addTest2();
        RSACalloutHandler.addTest3();        
        Test.stopTest();
    }
    
    
}