@isTest
private class InventoryLotTypeTest {

    @isTest
    static void testDeleteSpareVehicleRecord() {
        // Create a test Warehouse record
        Warehouse__c testWarehouse = new Warehouse__c(
            Name = 'Warehouse A'  // Replace with an appropriate value
            // Add other required fields for Warehouse__c
        );
        insert testWarehouse;

        // Create a test record with Type "Spare vehicle"
        Inventory_Lot__c testRecord = new Inventory_Lot__c(
            Type__c = 'Spare vehicle',
            Available_Quantity__c = 5,  // Replace with an appropriate value
            Warehouse__c = testWarehouse.Id  // Use the ID of the related Warehouse record
            // Add other required fields for Inventory_Lot__c
        );
        insert testRecord;

        // Attempt to delete the record
        Test.startTest();
        try {
            delete testRecord;
            // If the record is deleted successfully, the test will fail
            System.assert(false, 'Expected exception not thrown');
        } catch (DmlException e) {
            // Ensure that the expected error message is present in the exception
            System.assertEquals('Records with Type "Spare Vehicle" cannot be deleted.', e.getDmlMessage(0));
        }
        Test.stopTest();
    }

    @isTest
    static void testDeleteNonSpareVehicleRecord() {
        // Create a test Warehouse record
        Warehouse__c testWarehouse = new Warehouse__c(
            Name = 'Warehouse123'  // Replace with an appropriate value
            // Add other required fields for Warehouse__c
        );
        insert testWarehouse;

        // Create a test record with a different Type
        Inventory_Lot__c testRecord = new Inventory_Lot__c(
            Type__c = 'Vehicle',
            Available_Quantity__c = 10,
            Warehouse__c = testWarehouse.Id  // Use the ID of the related Warehouse record
            // Add other required fields for Inventory_Lot__c
        );
        insert testRecord;

        // Attempt to delete the record
        Test.startTest();
        try {
            delete testRecord;
            // If the record is deleted successfully, the test will pass
        } catch (Exception e) {
            // If an unexpected exception occurs, the test will fail
            System.assert(false, 'Unexpected exception thrown');
        }
        Test.stopTest();
    }
}