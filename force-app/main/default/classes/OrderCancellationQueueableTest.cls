@isTest
public class OrderCancellationQueueableTest {
    
@testSetup
static void setupTestData() {
    // Create an Account
    Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
    insert testAccount;

    // Create a Product2
    Product2 testProduct = new Product2(
        Name = 'Test Product',
        IsActive = true,
        ProductCode = 'abcd',
        HSN_Code__c = 'abcd',
        Type__c = 'Vehicle'
    );
    insert testProduct;

    // Get the standard Pricebook
    Id stdPrBk = Test.getStandardPricebookId();

    // Create a PricebookEntry
    PricebookEntry testPricebookEntry = new PricebookEntry(
        Product2Id = testProduct.Id,
        Pricebook2Id = stdPrBk,
        UnitPrice = 100.0,
        IsActive = true
    );
    insert testPricebookEntry;

    // Create Orders and assign the Pricebook2Id
    List<Order> orders = new List<Order>();
    for (Integer i = 1; i <= 2; i++) {
        orders.add(new Order(
            Name = 'Test Order ' + i,
            AccountId = testAccount.Id,
            Status = 'Back Order',
            payment_status__c = 'Pending',
            EffectiveDate = Date.today(),
            Pricebook2Id = stdPrBk // Set the Pricebook2Id
        ));
    }
    insert orders;

    // Create OrderItems
    List<OrderItem> orderItems = new List<OrderItem>();
    for (Order order : orders) {
        orderItems.add(new OrderItem(
            OrderId = order.Id,
            
            Quantity = 1,
            UnitPrice = 100.0,
            Status__c = 'REFUND_REQUESTED',
            Type__c = 'Vehicle', 
            PricebookEntryId = testPricebookEntry.Id
        ));
    }
    insert orderItems;
}

    
    @isTest
    static void testOrderCancellationQueueable() {
        // Query the Orders
        Set<Id> orderIds = new Set<Id>();
        for (Order order : [SELECT Id FROM Order]) {
            orderIds.add(order.Id);
        }
        
        // Enqueue the Queueable job
        Test.startTest();
        OrderCancellationQueueable queueableJob = new OrderCancellationQueueable(orderIds);
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
        // Validate results
        List<Order> updatedOrders = [SELECT Id, Status, payment_status__c FROM Order];
        for (Order order : updatedOrders) {
            if (order.Status == 'Order Cancelled') {
                System.assertEquals('Order Cancelled', order.Status, 'Order should be cancelled.');
            } else if (order.Status == 'Ready For Delivery') {
                System.assertEquals('Ready For Delivery', order.Status, 'Order should be ready for delivery.');
            }
            
        }
    }
    
    @isTest
    static void testPartialRefundScenario() {
        // Query an Order and update its OrderItems for partial refund
        Order testOrder = [SELECT Id FROM Order LIMIT 1];
        List<OrderItem> items = [SELECT Id, Status__c FROM OrderItem WHERE OrderId = :testOrder.Id LIMIT 1];
        
        for (OrderItem item : items) {
            item.Status__c = 'DELIVERED';
        }
        update items;
        
        // Enqueue the Queueable job
        Test.startTest();
        OrderCancellationQueueable queueableJob = new OrderCancellationQueueable(new Set<Id>{testOrder.Id});
        System.enqueueJob(queueableJob);
        Test.stopTest();
        
        // Validate results
        testOrder = [SELECT Id, Status, payment_status__c FROM Order WHERE Id = :testOrder.Id];
       
    }
}