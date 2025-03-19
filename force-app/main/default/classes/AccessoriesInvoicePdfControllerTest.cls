@isTest
public class AccessoriesInvoicePdfControllerTest {
    
    @isTest
    static void testAccessoriesInvoicePdfController() {
        Account acc = new Account(
            Name = 'Test Name',
            Type = 'Dealer',
            Phone = '9011113246',
            Email__c = 'customer@test.com',
            BillingCity = 'Bangalore',
            BillingStreet = '123 Test St\nBangalore',
            BillingState = 'Karnataka',
            BillingCountry = 'India',
            BillingPostalCode = '560001',
            Store_Type__c = 'COCO'
        );
        insert acc;
        
        Account dealerAccount = new Account(
            Name = 'Test Name',
            Type = 'Dealer',
            Phone = '9011113286',
            Email__c = 'dealer@test.com',
            BillingCity = 'Bangalore',
            BillingStreet = '456 Dealer St\nBangalore',
            BillingState = 'Karnataka',
            BillingCountry = 'India',
            BillingPostalCode = '560002',
            Account_Number__c = '47723745723457',
            Bank_Name__c = 'Canara',
            Center_Code__c = 'BR',
            Invoice_Sequence__c = 0,
            Store_Type__c = 'DODO'
        );
        insert dealerAccount;
        
        Product2 testProduct = new Product2(
            Name = 'Test Accessory',
            IsActive = true,
            ProductCode = 'abcd',
            HSN_Code__c = 'abcd',
            Type__c = 'Accessories',
            CGST_Percentage__c = 2.5,
            SGST_Percentage__c = 2.5,
            IGST_Percentage__c = 5
        );
        insert testProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pricebookEntry;
        
        Contact testContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Test Contact',
            Email = 'test@example.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'India',
            MailingPostalCode = '12345',
            MailingState = 'Karnataka',
            MailingStreet = '123 Test St',
            Primary_Contact__c = true
        );
        insert testContact;
        
        Order testOrder = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Website_Order_Id__c = 'QWERTY1234567WE',
            Dealer__c = dealerAccount.Id,
            Internal_Purchase__c = false,
            Pricebook2Id = pricebookId,
            Transportation_Charges__c = 100,
            BillingCountry = 'India',
            BillingState = 'Karnataka',
             IRN_No__c = 'qwer1234'
        );
        insert testOrder;
        
        OrderItem oI = new OrderItem(
            OrderId = testOrder.Id,
            UnitPrice = 121,
            PricebookEntryId = pricebookEntry.Id,
            Quantity = 200
        );
        insert oI;
        
        // Create a PageReference for testing
        PageReference pageRef = Page.AccessoriesInvoicePdf; 
        Test.setCurrentPage(pageRef);        

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOrder);
        
        AccessoriesInvoicePdfController controller = new AccessoriesInvoicePdfController(standardController);
        
        // Perform assertions
        System.assertEquals(testOrder.Id, controller.order.Id);
        System.assertEquals(testContact.Id, controller.contact.Id);
         System.assertNotEquals(null, controller.getFormattedBillingStreet());
        System.assertNotEquals(null, controller.getFormattedAccountBillingStreet());
        
        // Test state and AccState assignments
        System.assertEquals('karnataka', controller.state.toLowerCase());
        System.assertEquals('karnataka', controller.AccState.toLowerCase());
        
        // Test the if (!sameState) block
       System.assertEquals(true, controller.sameState);
        
        // Test the if (!order.Internal_Purchase__c) block
        System.assertEquals(false, controller.order.Internal_Purchase__c);
        //System.assertNotEquals(0, controller.calcValue1);
        System.assertNotEquals(0, controller.calcValue2);
        System.assertNotEquals(0, controller.calcValue3);
        //System.assertNotEquals(0, controller.trcalcValue1);
        System.assertNotEquals(0, controller.trcalcValue2);
        System.assertNotEquals(0, controller.trcalcValue3);
        System.assertNotEquals(0, controller.trcalcValue);
        System.assertNotEquals(0, controller.tValueAftGST);
        System.assertNotEquals(0, controller.NetAmount);
    }
    
    @isTest
    static void testdeliverychallanController1() {
        // Create test data
       Account acc = new Account(
            Name = 'Test Name',
            Type = 'Dealer',
            Phone = '9011113246',
            BillingCity = 'Bangalore',
            BillingStreet = '123 Test St\nBangalore',
            BillingState = 'Karnataka',
            BillingCountry = 'India',
            BillingPostalCode = '560001',
           Store_Type__c = 'DODO'
        );
        insert acc;
        
        Account dealerAccount = new Account(
            Name = 'Test Name',
            Type = 'Dealer',
            Phone = '9011113286',
            Email__c = 'dealer@test.com',
            BillingCity = 'Bangalore',
            BillingStreet = '456 Dealer St\nBangalore',
            BillingState = 'Maharashtra',
            BillingCountry = 'India',
            BillingPostalCode = '560002',
            Account_Number__c = '47723745723457',
            Bank_Name__c = 'Canara',
            Center_Code__c = 'BR',
            Invoice_Sequence__c = 0,
            Store_Type__c = 'COCO'
        );
        insert dealerAccount;
        
        Contact testContact = new Contact(
            AccountId = acc.Id,
            LastName = 'Test Contact', // Change 'Name' to 'LastName'
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
        
        Order testOrder = new Order(
            AccountId = acc.Id,
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Website_Order_Id__c = 'QWERTY1234567WE',
            Transportation_Charges__c = 100,
            BillingCountry = 'India',
            Billingstate='maharashtra',
            Dealer__c = dealerAccount.Id,
             IRN_No__c = 'qwer1234'
        );
        insert testOrder;
        
        
        PageReference pageRef = Page.AccessoriesInvoicePdf; // Replace with your Visualforce page name
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController standardController = new ApexPages.StandardController(testOrder);
        
        AccessoriesInvoicePdfController controller = new AccessoriesInvoicePdfController(standardController);
        
        // Perform assertions
        System.assertEquals(testOrder.Id, controller.order.Id);
        System.assertNotEquals(null, controller.getFormattedBillingStreet());
        System.assertNotEquals(null, controller.getFormattedAccountBillingStreet());
        
        // Test state and AccState assignments
        System.assertEquals('maharashtra', controller.state.toLowerCase());
        System.assertEquals('karnataka', controller.AccState.toLowerCase());
        
        // Test the if (!sameState) block
        System.assertEquals(false, controller.sameState);
        
        // Test the if (!order.Internal_Purchase__c) block
        System.assertEquals(false, controller.order.Internal_Purchase__c);
        System.assertNotEquals(0, controller.calcValue1);
        System.assertNotEquals(0, controller.calcValue2);
        System.assertNotEquals(0, controller.calcValue3);
        System.assertNotEquals(0, controller.trcalcValue1);
        System.assertNotEquals(0, controller.trcalcValue2);
        System.assertNotEquals(0, controller.trcalcValue3);
        System.assertNotEquals(0, controller.trcalcValue);
        System.assertNotEquals(0, controller.tValueAftGST);
        System.assertNotEquals(0, controller.NetAmount);
    }
    
}