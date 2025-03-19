@isTest
public class POPaymentsController1Test {
    @isTest
    public static void testPOPaymentsControllerMethods() {
        
        // 1. Setup test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9876543210',
            Email__c = 'test@gmail.com', 
            Type = 'Customer'
        );
        insert testAccount;

        Order testOrder = new Order(
            Status = 'Back Order',
            AccountId = testAccount.Id,
            EffectiveDate = Date.Today()
        );
        insert testOrder;

        ProductRequest testPO = new ProductRequest(
            Status = 'New',
            ShipmentType = 'VOR'
        );
        insert testPO;

        PO_Payments__c testPOPayment = new PO_Payments__c(
            Order__c = testOrder.Id,
            Purchase_Order__c = testPO.Id,
            Amount_Paid__c = 150.00
        );
        insert testPOPayment;

        // 2. Positive Test: Testing successful deletion
        Test.startTest();
        try {
            // Verify the payment record exists before deletion
            PO_Payments__c existingPayment = [SELECT Id FROM PO_Payments__c WHERE Id = :testPOPayment.Id LIMIT 1];
            System.assertNotEquals(existingPayment, null, 'The payment record should exist before deletion.');

            // Call the method to delete the valid payment record
            POPaymentsController1.deletePaymentRecord(testPOPayment.Id);

            // Verify that the payment record was deleted
            List<PO_Payments__c> deletedPayment = [SELECT Id FROM PO_Payments__c WHERE Id = :testPOPayment.Id];
            System.assertEquals(deletedPayment.size(), 0, 'The payment record should be deleted.');
        } catch (Exception e) {
            System.debug('Unexpected error in positive scenario: ' + e.getMessage());
            System.assert(false, 'No exception should be thrown in the positive scenario');
        }

        // 3. Negative Test: Testing failure scenario (invalid ID)
        String invalidId = null; // Invalid ID
        try {
            // This should trigger the AuraHandledException due to the invalid ID
            POPaymentsController1.deletePaymentRecord(invalidId);
        } catch (AuraHandledException e) {
            System.debug('Expected exception: ' + e.getMessage());
            System.assert(e.getMessage().contains('Error deleting the payment record'), 'The error message should indicate a deletion failure.');
        }
        
        // 4. Fetching payments (no records should be deleted in the negative test)
        List<PO_Payments__c> payments = POPaymentsController1.getPayments();
        //System.assertNotEquals(payments.size(), 0, 'Payments should not be empty, and the delete operation should not have deleted all records.');
        
        Test.stopTest();
    }
}