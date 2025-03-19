@isTest
public class POPaymentsControllerTest {
    @isTest
    public static void testPOPaymentsControllerMethods() {
        Account testAccount = new Account(Name = 'Test Account',Phone = '9876543210',Email__c = 'test@gmail.com',Type = 'Customer');
        insert testAccount;
        
        Product2 testProduct = new Product2(Name = 'Test Accessory',IsActive = true, ProductCode = 'abcd',HSN_Code__c = 'abcd',Type__c = 'Accessories');
        insert testProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(Id = pricebookId,IsActive = true);
        update standardPricebook;
        
        PricebookEntry pricebookEntry = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = testProduct.Id,UnitPrice = 100.00,   IsActive = true);
        insert pricebookEntry;
        
        Order testOrder = new Order(Status = 'Back Order',AccountId = testAccount.Id,Pricebook2Id = pricebookId,EffectiveDate = Date.Today());
        insert testOrder;
        
        OrderItem testOrderItem = new OrderItem( OrderId = testOrder.Id,Product2Id = testProduct.Id,Quantity = 10,UnitPrice = 100,PricebookEntryId = pricebookEntry.Id);
        insert testOrderItem;
        
        ProductRequest testPO = new ProductRequest( Status = 'New',ShipmentType = 'VOR');
        insert testPO;
        
        PO_Payments__c testPOPayment = new PO_Payments__c(Order__c = testOrder.Id,Purchase_Order__c = testPO.Id,Amount_Paid__c = 150.00);
        insert testPOPayment; 
        Test.startTest();
        
        try {
            PO_Payments__c existingPayment = [SELECT Id FROM PO_Payments__c WHERE Id = :testPOPayment.Id LIMIT 1];
            System.assertNotEquals(existingPayment, null, 'The payment record should exist before deletion.');
            
            POPaymentsController.deletePaymentRecord(testPOPayment.Id);
            
            List<PO_Payments__c> deletedPayment = [SELECT Id FROM PO_Payments__c WHERE Id = :testPOPayment.Id];
            System.assertEquals(deletedPayment.size(), 0, 'The payment record should be deleted.');
        } catch (Exception e) {
            
        }
        
        try {
            POPaymentsController.deletePaymentRecord(UserInfo.getUserId());
        } catch (AuraHandledException e) {
            
        }
        
        Boolean isDuplicate = POPaymentsController.checkDuplicateUTR('UTR1234');
        
        Boolean isNotDuplicate = POPaymentsController.checkDuplicateUTR('UTR9999');
        
        Order fetchedOrder = POPaymentsController.getOrder(testOrder.Id);
        Order fetchedOrder1= POPaymentsController.getOrder(null);
        
        // Fetch payments
        List<PO_Payments__c> payments = POPaymentsController.getPayments(testOrder.Id);
        List<PO_Payments__c> payments1=POPaymentsController.getPayments(null);
        
        Test.stopTest();
    }
}