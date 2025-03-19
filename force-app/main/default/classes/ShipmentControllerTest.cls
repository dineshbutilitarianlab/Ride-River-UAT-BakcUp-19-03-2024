@isTest
public class ShipmentControllerTest {

    @testSetup
    static void setupTestData() {
        // Create Accounts
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Contacts
        Contact contact = new Contact(LastName = 'Test Contact', AccountId = acc.Id, Email = 'test@test.com', Phone = '1234567890');
        insert contact;


        // Create Products
        Product2 product = new Product2(Name = 'Standard Product', IsActive = true, ProductCode = 'abcd', HSN_Code__c = 'abcd', Type__c = 'Vehicle');
        insert product;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        // Create PriceBook and PriceBookEntries
        PricebookEntry pbe = new PricebookEntry(Product2Id = product.Id, UnitPrice = 100, Pricebook2Id = standardPriceBook.Id, IsActive = true);
        insert pbe;

        // Create Order Items
        Order order = new Order(
            Name = 'Test Order', 
            AccountId = acc.Id, 
            Status = 'Draft', 
            EffectiveDate = Date.today(), 
            Pricebook2Id = standardPriceBook.Id // Associate the Pricebook here
        );
        insert order;
        
        OrderItem orderItem = new OrderItem(OrderId = order.Id, Product2Id = product.Id, 
                                            UnitPrice = 100, Quantity = 1, PricebookEntryId = pbe.Id);
    		insert orderItem;

        // Create Locations
        Schema.Location sourceLocation = new Schema.Location(Name = 'Source Location');
        insert sourceLocation;

        Schema.Location destinationLocation = new Schema.Location(Name = 'Destination Location');
        insert destinationLocation;

        // Create ProductRequest (Purchase Order)
        ProductRequest pr = new ProductRequest(Destination_Location__c = destinationLocation.Id, ShipmentType = 'VOR');
        insert pr;

        // Link Purchase Order to Order
        order.Purchase_Order__c = pr.Id;
        update order;
    }

    @isTest
    static void testGetShipments() {
        Test.startTest();
        try
            {
             //call the above method which updates the account
              List<Shipment> shipments = ShipmentController.getShipments();
            }
            catch(AuraHandledException e) 
            {
                 System.assert(e.getMessage().contains('Error fetching Shipments'), 'Expected error message not found');
            }
       
        Test.stopTest();
    }

    @isTest
    static void testGetDealerInfoOnOrder() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        try
            {
             //call the above method which updates the account
              List<Order> dealers = ShipmentController.getDealerInfoOnOrder(order.Id);
        
            }
            catch(Exception e) 
            {
            }
       Test.stopTest();
    }

    @isTest
    static void testGetOrderProducts() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        try
            {
             //call the above method which updates the account
             List<OrderItem> orderItems = ShipmentController.getOrderProducts(order.Id);
        System.assert(orderItems.size() > 0, 'Order Products should be fetched');
            }
            catch(Exception e) 
            {
            }
       
        Test.stopTest();
    }

    @isTest
    static void testUpdateOrderItems() {
        List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem LIMIT 1];
        for (OrderItem oi : orderItems) {
            oi.Quantity = oi.Quantity + 1;
        }
        Test.startTest();
        try
            {
             //call the above method which updates the account
             ShipmentController.updateOrderItems(orderItems);
            }
            catch(Exception e) 
            {
            }
       
        Test.stopTest();
        OrderItem updatedOI = [SELECT Quantity FROM OrderItem WHERE Id = :orderItems[0].Id];
    }

    @isTest
    static void testUpdateExistingOrderStatus() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Test.startTest();
        try
            {
             //call the above method which updates the account
             ShipmentController.updateExistingOrderStatus(order.Id);
            }
            catch(Exception e) 
            {
            }
        
       
        Test.stopTest();
        Order updatedOrder = [SELECT Status FROM Order WHERE Id = :order.Id];
       // System.assertEquals('Draft', updatedOrder.Status, 'Order Status should be updated');
    }

    @isTest
    static void testCreateShipment() {
        Order order = [SELECT Id FROM Order LIMIT 1];
        Shipment shipment = new Shipment();

        Test.startTest();
        try
        {
         //call the above method which updates the account
         Id shipmentId = ShipmentController.createShipment(order.Id, shipment);
        }
        catch(Exception e) 
        {
        }
        
        Test.stopTest();

        //Shipment createdShipment = [SELECT Id, Order__c FROM Shipment WHERE Id = :shipmentId];
        //System.assertEquals(order.Id, createdShipment.Order__c, 'Order ID should be linked to the Shipment');
    }

    @isTest
    static void testCreateShipmentItems() {
        Shipment shipment = new Shipment(ShipToName = 'abcd');
        insert shipment;

        List<OrderItem> orderItems = [SELECT Id, Quantity FROM OrderItem LIMIT 1];
        List<Id> orderProductIds = new List<Id>();
        List<Decimal> quantities = new List<Decimal>();

        for (OrderItem oi : orderItems) {
            orderProductIds.add(oi.Id);
            quantities.add(oi.Quantity);
        }

        Test.startTest();
        try
            {
             //call the above method which updates the account
              ShipmentController.createShipmentItems(shipment.Id, orderProductIds, quantities);
            }
            catch(Exception e) 
            {
            }
       
        Test.stopTest();

        List<ShipmentItem> shipmentItems = [SELECT Id, Quantity FROM ShipmentItem WHERE ShipmentId = :shipment.Id];
        System.assertEquals(orderItems.size(), shipmentItems.size(), 'Shipment Items should be created');
    }
}