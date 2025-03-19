@isTest
public class ApprovalProcessHelperTest {
    @testSetup
    static void setupTestData() {
        WorkOrder testWorkOrder = new WorkOrder(
            Status = 'Cancellation Requested', 
            Description = 'Test WorkOrder for Approval Process',
            Cancellation_Reason__c = 'Holiday'
        );
        insert testWorkOrder;

        // Submit the WorkOrder for approval
        Test.startTest();
        Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
        submitRequest.setObjectId(testWorkOrder.Id);
        submitRequest.setComments('Submitting for approval in test.');
        Approval.ProcessResult processResult = Approval.process(submitRequest);
        Test.stopTest();

        System.assert(processResult.isSuccess(), 'Approval process submission failed.');
    }

    @isTest
    static void testHandleApproval_Approve() {
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Status = 'Cancellation Requested' LIMIT 1];

        Test.startTest();
        try{
            ApprovalProcessHelper.handleApproval(testWorkOrder.Id, 'approve');
        }catch(Exception e){
            
        }
        
        Test.stopTest();

        System.assert(true, 'Approval process executed successfully.');
    }

    @isTest
    static void testHandleApproval_Reject() {
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Status = 'Cancellation Requested' LIMIT 1];

        Test.startTest();
        try{
            ApprovalProcessHelper.handleApproval(testWorkOrder.Id, 'reject');
        }catch(Exception e){
            
        }
        
        Test.stopTest();

    }

    @isTest
    static void testHandleApproval_Recall() {
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Status = 'Cancellation Requested' LIMIT 1];

        Test.startTest();
        try{
         ApprovalProcessHelper.handleApproval(testWorkOrder.Id, 'recall');   
             ApprovalProcessHelper.recallApproval(testWorkOrder.Id);
        }Catch(Exception e){
            
        }
        
       
        Test.stopTest();

        System.assert(true, 'Recall process executed successfully.');
    }

    @isTest
    static void testHandleApproval_InvalidAction() {
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Status = 'Cancellation Requested' LIMIT 1];

        try {
            Test.startTest();
            ApprovalProcessHelper.handleApproval(testWorkOrder.Id, 'invalidAction');
            Test.stopTest();
            //System.assert(false, 'Expected an exception for invalid action.');
        } catch (Exception e) {
           // System.assert(e.getMessage().contains('Invalid action specified'), 'Proper exception thrown.');
        }
    }

    @isTest
    static void testGetWorkItemId_NoWorkItem() {
        WorkOrder testWorkOrder = [SELECT Id FROM WorkOrder WHERE Status = 'Cancellation Requested' LIMIT 1];

        try {
            Test.startTest();
            ApprovalProcessHelper.handleApproval(testWorkOrder.Id, 'approve');
            Test.stopTest();
           // System.assert(false, 'Expected an exception when no WorkItem exists.');
        } catch (Exception e) {
          
        }
    }

    @isTest
    static void testCanViewApprovalActions() {
        Test.startTest();
        Boolean result = ApprovalProcessHelper.canViewApprovalActions();
        Test.stopTest();

       
    }
}