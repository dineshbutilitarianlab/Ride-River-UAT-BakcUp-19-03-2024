@isTest
public class WorkPlanControllerTest {
    @testSetup
    static void setup() {
        // Create a test Work Order
        WorkOrder testWorkOrder = new WorkOrder(Odometer_Reading__c= 190);
        insert testWorkOrder;

        CodeSet ct = new CodeSet();
        ct.Name = 'LabourCode';
        ct.Code = '123';
        insert ct;

        // Create test Work Plans related to the Work Order
        List<WorkPlan> testWorkPlans = new List<WorkPlan>();
        for (Integer i = 0; i < 3; i++) {
            WorkPlan wp = new WorkPlan(
                Name = 'Test Work Plan ' + i,
                WorkOrderId = testWorkOrder.Id,
                RR_Labour_Code__c = ct.Id,
                Status__c = 'Open',
                Duration_Hour__c = 1.0 + i,
                Labour_Charge__c = 100.0 + (i * 10)
            );
            testWorkPlans.add(wp);
        }
        insert testWorkPlans;
    }

    @isTest
    static void testGetRelatedWorkPlans() {
        // Retrieve the test Work Order created in the testSetup
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];

        // Call the method under test
        Test.startTest();
        List<WorkPlan> result = WorkPlanController.getRelatedWorkPlans(testWorkOrder.Id);
        Test.stopTest();

        System.assertEquals(3, result.size(), 'There should be 3 related Work Plans');
    }

    @isTest
    static void testDeleteWorkPlanApex() {
        // Retrieve a WorkPlan record
        WorkPlan wpToDelete = [SELECT Id FROM WorkPlan LIMIT 1];

        // Call the delete method
        Test.startTest();
        WorkPlanController.deleteWorkPlanApex(wpToDelete.Id);
        Test.stopTest();

        // Verify the WorkPlan has been deleted
        List<WorkPlan> remainingWorkPlans = [SELECT Id FROM WorkPlan WHERE Id = :wpToDelete.Id];
        System.assertEquals(0, remainingWorkPlans.size(), 'The WorkPlan record should have been deleted');
    }
}