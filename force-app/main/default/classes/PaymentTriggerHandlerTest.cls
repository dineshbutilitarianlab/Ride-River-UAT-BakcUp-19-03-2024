@isTest
public class PaymentTriggerHandlerTest {

    @isTest
    static void testInsertHandler() {
        
        Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        mapnewRecords = TestDataFactory.CreateOrder();    
        
        map<id, Payment__c> oldmap = new map<id, Payment__c>();

        Test.startTest();
        
        List<Payment__c> paymentList = new List<Payment__c>{(Payment__c)mapnewRecords.get('PaymentId')};
            
            payment__c oldPayment = new payment__c();
        oldPayment.Id =paymentList[0].Id;
        oldPayment.Payment_Status__c = 'Successs';
            oldmap.put(paymentList[0].Id, oldPayment);
        

        // Call the insertHandler method to update Amount1__c on Order_Payment__c records
        PaymentTriggerHandler.insertHandler(paymentList);
        PaymentTriggerHandler.updateHandler(paymentList, oldmap);

        Test.stopTest();

        // Verify that Amount1__c is updated on Order_Payment__c records
        List<Order_Payment__c> updatedOrderPayments = [SELECT Id, Amount1__c,Payments__r.Amount__c FROM Order_Payment__c WHERE Payments__c IN :paymentList];
        for (Order_Payment__c orderPayment : updatedOrderPayments) {
            System.assertEquals(orderPayment.Payments__r.Amount__c, orderPayment.Amount1__c);
        }
    }
    /*
    @isTest
    static void testUpdateHandler() {
        // Create test data
        Order_Payment__c orderPayment = new Order_Payment__c(
            // Set necessary fields
            Amount1__c = 100.0
        );
        insert orderPayment;

        Payment__c oldPayment = new Payment__c(
            // Set necessary fields
            Payment_Status__c = 'Pending'
        );
        insert oldPayment;

        // Update Payment to Success
        Payment__c newPayment = new Payment__c(
            Id = oldPayment.Id,
            Payment_Status__c = 'Success'
        );

        // Create oldMap with the old payment data
        Map<Id, Payment__c> oldMap = new Map<Id, Payment__c>();
        oldMap.put(oldPayment.Id, oldPayment);

        // Update order payment to link to the payment
        orderPayment.Payments__c = oldPayment.Id;
        update orderPayment;

        // Call the handler
        Test.startTest();
        PaymentHandler.updateHandler(new List<Payment__c>{newPayment}, oldMap);
        Test.stopTest();

        // Verify that the order status handler method was called
        // (Add appropriate assertions based on your implementation)
        // You can assert the expected behavior, for example:
        // Verify that the related Order_Payment__c records were updated correctly
        List<Order_Payment__c> updatedOrderPayments = [
            SELECT Id, Amount1__c, Payments__r.Amount__c
            FROM Order_Payment__c
            WHERE Payments__c = :newPayment.Id
        ];
        System.assertEquals(1, updatedOrderPayments.size());
        System.assertEquals(100.0, updatedOrderPayments[0].Amount1__c);
    }
    */
}