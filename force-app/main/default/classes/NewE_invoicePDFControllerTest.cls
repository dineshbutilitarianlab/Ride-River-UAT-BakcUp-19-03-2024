@isTest
public class NewE_invoicePDFControllerTest {
    
    @isTest
    static void setupData() {
        Account seller = new Account(
            Name = 'Test Seller', 
            GSTIN_Number__c = '29TESTGSTINT', 
            Type = 'Dealer', 
            BillingPostalCode = '431809', 
            Email__c = 'agv@gmail.com', 
            Phone = '7866545678', 
            Center_Code__c = '564757',
            Store_Type__c='DODO',
            BillingState  ='karnataka'
        );
        insert seller;
        
        Account buyer = new Account(
            Name = 'Test Buyer', 
            GSTIN_Number__c = '29BUYERGSTIN', 
            BillingPostalCode = '431807',
            Email__c = 'agddv@gmail.com', 
            Phone = '7864545678', 
            Center_Code__c = '566757',
            Store_Type__c='DODO'
        );
        insert buyer;
        
        Contact testContact = new Contact(
            AccountId = buyer.Id,
            LastName = 'Test Contact', 
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test St',
            Primary_Contact__c = true
        );
        insert testContact;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = 'DFGHJ',
            Type__c = 'Vehicle',
            CGST_Percentage__c = 5,
            SGST_Percentage__c = 5,
            IGST_Percentage__c = 10
        );
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert pbe;
        
        Order testOrder = new Order(
            Name = 'Test Order',
            AccountId = buyer.Id,
            Dealer__c = seller.Id,
            Is_IGST_on_Intrastate__c = true,
            EffectiveDate = System.today(),
            Status = 'Draft',
            Pricebook2Id = standardPricebook.Id,
            IRN_No__c = '1e7dee68c39fb6a62874fe4ea613866d9f687c37078ee03eeb07d11c012ca016',
            Transportation_Charges__c = 500.00, 
            Discount_on_Ex_Showroom_Price__c = 50.00,
            Subsidy_Amount__c = 100.00,
            State_Govt_Subsidy__c = 75.00,
             Internal_Purchase__c = false

        );
        insert testOrder;
        
        OrderItem testItem = new OrderItem(
            OrderId = testOrder.Id, 
            PricebookEntryId = pbe.Id, 
            Type__c = 'Vehicle',
            Quantity = 2, 
            UnitPrice = 100
            
        );
        insert testItem;

        PageReference pageRef = Page.NewE_invoicePDF; 
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('sequence', 'INV-12345');
        ApexPages.currentPage().getParameters().put('date', '2025-03-21');

        ApexPages.StandardController stdController = new ApexPages.StandardController(testOrder);
        NewE_invoicePDFController controller = new NewE_invoicePDFController(stdController);
    }

    @isTest
    static void testWithDifferentStoreType() {
        Account seller = new Account(
            Name = 'Test Seller11', 
            GSTIN_Number__c = '29TESTGSTINT', 
            Type = 'Dealer', 
            BillingPostalCode = '431809', 
            Email__c = 'agv@gmail.com', 
            Phone = '7866545678', 
            Center_Code__c = '564757',
            Store_Type__c='COCO',
            BillingState  ='karnataka'
        );
        insert seller;
        
        Account buyer = new Account(
            Name = 'Test Buyer', 
            GSTIN_Number__c = '29BUYERGSTIN', 
            BillingPostalCode = '431807',
            Email__c = 'agddv@gmail.com', 
            Phone = '7864545678', 
            Center_Code__c = '566757',
            Store_Type__c='COCO'
        );
        insert buyer;
        
        Contact testContact = new Contact(
            AccountId = buyer.Id,
            LastName = 'Test Contact', 
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test St',
            Primary_Contact__c = true
        );
        insert testContact;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 product = new Product2(
            Name = 'Test Product',
            ProductCode = 'TP-001',
            IsActive = true,
            HSN_Code__c = 'DFGHJ',
            Type__c = 'Vehicle'
        );
        insert product;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = product.Id,
            UnitPrice = 100.0,
            IsActive = true
        );
        insert pbe;
        
        Order testOrder = new Order(
            Name = 'Test Order',
            AccountId = buyer.Id,
            Dealer__c = seller.Id,
            Is_IGST_on_Intrastate__c = true,
            EffectiveDate = System.today(),
            Status = 'Draft',
            Pricebook2Id = standardPricebook.Id,
            IRN_No__c = '1e7dee68c39fb6a62874fe4ea613866d9f687c37078ee03eeb07d11c012ca016'
        );
        insert testOrder;
        
        OrderItem testItem = new OrderItem(
            OrderId = testOrder.Id, 
            PricebookEntryId = pbe.Id,  
            Quantity = 2,
            Type__c = 'Vehicle',
            UnitPrice = 100
        );
        insert testItem;

        PageReference pageRef = Page.NewE_invoicePDF; 
        Test.setCurrentPage(pageRef);

        ApexPages.currentPage().getParameters().put('sequence', 'INV-67890');
        ApexPages.currentPage().getParameters().put('date', 
    DateTime.newInstance(System.today(), Time.newInstance(0,0,0,0)).format('dd/MM/yyyy'));


        ApexPages.StandardController stdController = new ApexPages.StandardController(testOrder);
        NewE_invoicePDFController controller = new NewE_invoicePDFController(stdController);
    }
}