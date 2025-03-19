@isTest
private class UpdateOrderToWebsiteTest {

    @isTest
    static void testGenerateJSON() {
        
        // Create test data - Order and related OrderItems
        Map<string,Sobject> dataMap = TestDataFactory.CreateOrder();
        
        OrderItem testOrderItem2 = (OrderItem)dataMap.get('OrderProductId');
        Order testOrder = (order)dataMap.get('OrderId');

        // Start Test
        Test.startTest();

        // Call the generateJSON method
        String jsonString = UpdateOrderToWebsite.generateJSON(testOrder, new List<OrderItem>{testOrderItem2});

        // Stop Test
        Test.stopTest();

        // Verify the generated JSON string
        System.assertNotEquals(null, jsonString, 'JSON string should not be null');
        System.assert(JSON.deserializeUntyped(jsonString) instanceof Map<String, Object>, 'Generated JSON should be a valid Map');
    }

    @isTest
    static void testTokenGenerationAndCallout() {

        // Create test data - Order and related OrderItems
        Map<string,Sobject> dataMap = TestDataFactory.CreateOrder();
        
        OrderItem testOrderItem2 = (OrderItem)dataMap.get('OrderProductId');
        Order testOrder = (order)dataMap.get('OrderId');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TokenGenerationMock());
        UpdateOrderToWebsite.executeDisplayOutput(testOrder.Id);
        Test.stopTest();
    }
    
    
     @isTest
    static void testActualUpdateCallout() {
        //Get the credentials
        River_Integration_Credential__mdt metadata = [SELECT Id, Client_Id__c, Client_Secret__c, Actual_Endpoint_URL__c, Authentication_Endpoint_URL__c 
                                                      FROM River_Integration_Credential__mdt 
                                                      WHERE DeveloperName = 'Website_Credentials'];
        

        // Create test data - Order and related OrderItems
        Map<string,Sobject> dataMap = TestDataFactory.CreateOrder();
        
        OrderItem testOrderItem2 = (OrderItem)dataMap.get('OrderProductId');
        Order testOrder = (order)dataMap.get('OrderId');
        String jsonString = UpdateOrderToWebsite.generateJSON(testOrder, new List<OrderItem>{testOrderItem2});

        // Start Test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ActualUpdateMock());
		string token = 'testtoken';
        UpdateOrderToWebsite.doCallout(token, metadata, jsonString);
        Test.stopTest();

    }
}