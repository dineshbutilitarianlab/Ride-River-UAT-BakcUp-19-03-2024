@IsTest(SeeAllData=true)
public class WarrantyPriorTriggerHandlerTest {
    
    @isTest
    public static void testHandleWarrantyApproval() {
        // Fetch an existing Warranty Prior record with a related Job Card
        Warranty_Prior__c existingWarranty = [SELECT Id, Status__c, Job_Card__c 
                                              FROM Warranty_Prior__c 
                                              WHERE Status__c != 'Approved' 
                                              LIMIT 1];

        if (existingWarranty == null) {
            System.debug('No existing Warranty Prior records found for testing.');
            return;
        }

        // Fetch the related WorkOrder
        WorkOrder relatedWorkOrder = [SELECT Id, AccountId, Vehicle__c 
                                      FROM WorkOrder 
                                      WHERE Id = :existingWarranty.Job_Card__c 
                                      LIMIT 1];

        if (relatedWorkOrder == null) {
            System.debug('No related WorkOrder found for testing.');
            return;
        }

        Test.startTest();
        existingWarranty.Status__c = 'Approved';
        update existingWarranty;
        Test.stopTest();

    }

}