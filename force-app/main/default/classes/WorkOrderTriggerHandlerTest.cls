@isTest
public class WorkOrderTriggerHandlerTest {

    @isTest
    static void testHandleTrigger() {
        // Create a test Warehouse
        Warehouse__c testWarehouse = new Warehouse__c();
        testWarehouse.Name = 'Test Warehouse';
        
        insert testWarehouse;

        // Create a test WorkOrder with the required fields, including Warehouse__c
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.Warehouse__c = testWarehouse.Id; // Set the Warehouse reference
        
        insert testWorkOrder;

        // Create a test Work Type record (related to Work_Type__c lookup field)
        WorkType testWorkType = new WorkType();
        testWorkType.Name = 'Test Work Type';
        testWorkType.Amount__c = 100.0;
        testWorkType.EstimatedDuration = 2; // Correct the field name
        testWorkType.DurationType = 'Hours'; // Correct the field name
        
        insert testWorkType;

        // Create a test WorkPlan associated with the test WorkOrder
        WorkPlan testWorkPlan = new WorkPlan();
        testWorkPlan.Name = 'Test Workplan';
        testWorkPlan.Labour_Charge__c = 100.0; // Set values as needed
        testWorkPlan.Work_Type__c = testWorkType.Id; // Use the ID of the created WorkType record
        testWorkPlan.WorkOrderId = testWorkOrder.Id;

        // Insert the WorkPlan record inside the Test.startTest() and Test.stopTest() block
        Test.startTest();
        insert testWorkPlan;
        Test.stopTest();

        
    }
}