@isTest
public class TestDataFactoryTest {
    @isTest
    Public static void CreateOrderTest(){
        Test.startTest();
        Map<string, Object> newMap = TestDataFactory.CreateOrder();
        Test.stoptest();
        system.assertNotEquals(null,newMap, 'map cannot be null');
    }
    
    
    @isTest
    Public static void CreateAccountWithProductTest(){
        Test.startTest();
        Map<string, Object> newMap1 = TestDataFactory.CreateAccountWithProduct();
        Test.stoptest();
        system.assertNotEquals(null,newMap1, 'map cannot be null');
    }
    
    
    @isTest
    Public static void createVehicleTest(){
        Test.startTest();
        Map<string, Object> newMap2 = TestDataFactory.createVehicle();
        Test.stoptest();
        system.assertNotEquals(null,newMap2, 'map cannot be null');
    }

}