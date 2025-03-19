@isTest
public class bulkInsert_CustomerVoiceControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a Work Order record
        WorkOrder workOrder = new WorkOrder();
        workOrder.Odometer_Reading__c =120;
        insert workOrder;
          // Define valid picklist values for RR_Concern_Category__c and RR_Sub_Category__c
        String validConcernCategory = 'Charger'; // Replace with an actual valid value
        String validSubCategory = 'not charging'; // Replace with an actual valid value

        // Create multiple Customer Voice records linked to the Work Order
        List<RR_Customer_Voice__c> customerVoices = new List<RR_Customer_Voice__c>();
        for (Integer i = 0; i < 5; i++) {
            customerVoices.add(new RR_Customer_Voice__c(
                RR_Work_Order__c = workOrder.Id,
                RR_Concern_Category__c = validConcernCategory,
                RR_Sub_Category__c = validSubCategory,
                RR_Observation_Action_Taken__c = 'Action Taken ' + i
            ));
        }
        insert customerVoices;
    }

    @isTest
    static void testGetVoices() {
        // Retrieve the Work Order record created in the test setup
        WorkOrder workOrder = [SELECT Id FROM WorkOrder LIMIT 1];

        // Call the getVoices method
        Test.startTest();
        List<RR_Customer_Voice__c> result = bulkInsert_CustomerVoiceController.getVoices(workOrder.Id);
        Test.stopTest();

        // Validate the results
        System.assertEquals(5, result.size(), 'The number of customer voices returned should be 5');
        for (RR_Customer_Voice__c voice : result) {
            System.assertEquals(workOrder.Id, voice.RR_Work_Order__c, 'Each customer voice should be linked to the test work order');
        }
    }
}