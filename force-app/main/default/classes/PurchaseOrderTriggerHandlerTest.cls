@isTest
public class PurchaseOrderTriggerHandlerTest {

    @isTest
    public static void testSendHighValueNotification() {
        // Create test data for Account
        Account acc = new Account(Name = 'Test Account', Store_Manager_Email__c = 'storemanager@test.com', Manager_Thresold_Amount__c = 1000);
        insert acc;

        // Create test data for ProductRequest (Purchase Order)
        ProductRequest po = new ProductRequest(
           // ProductRequestNumber = 'PO12345',
           // Total_Price__c = 1500, // Exceeds the threshold amount
            Account__c = acc.Id,
            ShipmentType = 'VOR'
        );
        insert po;
        
        ProductRequestLineItem poLineItem = new ProductRequestLineItem(
            ParentId = po.Id,
            Product2Id ='01t5j00000FnlasAAB' ,
            QuantityRequested = 140,
            Alloted_Quantity__c = 140,
            Unit_Price__c = 250
            
        );
        

        // Create a list with the Purchase Order
        List<ProductRequest> purchaseOrders = new List<ProductRequest>{ po };

        // Mock email sending to avoid actual email sending in the test
        Test.startTest();
        
        // Call the method to test
        PurchaseOrderTriggerHandler.sendHighValueNotification(purchaseOrders);
        PurchaseOrderTriggerHandler.sendHighValueNotification(NULL);
        
        Test.stopTest();

        // Verify if the email was sent
     //   List<Messaging.SingleEmailMessage> sentEmails = [SELECT ToAddresses FROM Messaging.SingleEmailMessage WHERE Subject = 'High-Value Purchase Order Notification'];
        // Assert if the email has been sent
      //  System.assertEquals(1, sentEmails.size(), 'An email should have been sent.');
       // System.assert(sentEmails[0].ToAddresses.contains('storemanager@test.com'), 'The email should be sent to the correct address.');
    }
}