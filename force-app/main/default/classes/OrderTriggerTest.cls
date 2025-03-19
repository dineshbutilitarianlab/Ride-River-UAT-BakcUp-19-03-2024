@isTest
public class OrderTriggerTest {
    
    @testSetup
    static void setup() {
        // Create test data
        Account account = new Account(Name = 'Test Account', AccountSource = 'Other',Type ='Dealer');
        insert account;
        
        Account dealerAccount = new Account(Name = 'Test Dealer Account', Center_Code__c = 'TEST',Type ='Dealer');
        insert dealerAccount;
        
        OrderCounter__c counterSetting = new OrderCounter__c(Name = 'Count', Counter__c = 0);
        insert counterSetting;
    }
    
    @isTest
    static void testOrderTriggerBeforeInsert() {
        // Create a new order
        Order order = new Order(AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id, Dealer__c = [SELECT Id FROM Account WHERE Name = 'Test Dealer Account'].Id,EffectiveDate = Date.valueOf('2024-12-19'),Status='Draft');
        
        // Insert the order
        Test.startTest();
        insert order;
        Test.stopTest();
        
        // Verify that the Website_Order_Id__c is populated
        Order insertedOrder = [SELECT Website_Order_Id__c FROM Order WHERE Id = :order.Id];
        System.assert(insertedOrder.Website_Order_Id__c != null);
        
        // Verify that the counter is incremented
        OrderCounter__c updatedCounterSetting = [SELECT Counter__c FROM OrderCounter__c WHERE Name = 'Count'];
        System.assert(updatedCounterSetting.Counter__c == 1);
    }
    
    @isTest
    static void testOrderTriggerBeforeUpdate() {
        // Create a new order
        Order order = new Order(AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id, Dealer__c = [SELECT Id FROM Account WHERE Name = 'Test Dealer Account'].Id,EffectiveDate = Date.valueOf('2024-12-19'),Status='Payment is pending ');
        insert order;
        
        // Update the order
        Test.startTest();
        order.Status = 'Closed';
        update order;
        Test.stopTest();
        
        // Verify that the Website_Order_Id__c is updated
        Order updatedOrder = [SELECT Website_Order_Id__c FROM Order WHERE Id = :order.Id];
        System.assert(updatedOrder.Website_Order_Id__c != null);
        
        // Verify that the counter is incremented
        OrderCounter__c updatedCounterSetting = [SELECT Counter__c FROM OrderCounter__c WHERE Name = 'Count'];
        System.assert(updatedCounterSetting.Counter__c == 1);
    }
    
    @isTest
    static void testOrderTriggerAfterUpdate() {
        // Create a new order
        Order order = new Order(AccountId = [SELECT Id FROM Account WHERE Name = 'Test Account'].Id, Dealer__c = [SELECT Id FROM Account WHERE Name = 'Test Dealer Account'].Id, EffectiveDate = Date.valueOf('2024-12-19'),Status='Payment is pending');
        insert order;
        
        // Update the order
        Test.startTest();
        order.Status = 'Closed';
        update order;
        Test.stopTest();
        
        // Verify that the OrderTriggerHandler.handleOrderUpdate method is called
        // You may need to add additional assertions here depending on the implementation of the OrderTriggerHandler class
    }
}