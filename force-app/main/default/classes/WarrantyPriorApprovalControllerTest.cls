@isTest
public class WarrantyPriorApprovalControllerTest {

    @isTest
    public static void testSubmitApprovalProcess() {
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            Alias = 'abcd',
            Email = 'abcdl@rideriver.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testabcd@example.com'
        );
        insert testUser;

        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '9876543210',
            Type = 'Customer'
        );
        insert testAccount;

        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id
        );
        insert testWorkOrder;

        Warranty_Prior__c warrantyPrior = new Warranty_Prior__c(
            Status__c = 'Pending',
            Job_Card__c = testWorkOrder.Id
        );
        insert warrantyPrior;
        
        Test.startTest();
        
        System.runAs(testUser) {
            String result = WarrantyPriorApprovalController.submitApprovalProcess(
                warrantyPrior.Id, 
                'Parts', 
                'ASM feedback test', 
                'FFIR1234', 
                'Dealer observation', 
                'Test Media', 
                'Standard Value',
                'Standard Value'
            );
            
        }
        Test.stopTest();

    }

    @isTest
    public static void testGetRelatedWarrantyPrior() {
        // Setup test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id
        );
        insert testWorkOrder;
        // Create a related Warranty Prior record
        Warranty_Prior__c warrantyPrior = new Warranty_Prior__c(
            Status__c = 'Pending',
            Job_Card__c = testWorkOrder.Id
        );
        insert warrantyPrior;

        // Call the getRelatedWarrantyPrior method (logic will be executed or skipped based on context)
        Test.startTest();
        Warranty_Prior__c result = WarrantyPriorApprovalController.getRelatedWarrantyPrior(testAccount.Id);
        Warranty_Prior__c result1 = WarrantyPriorApprovalController.getRelatedWarrantyPrior(null);
        WarrantyPriorApprovalController.checkApprovalStatus(warrantyPrior.ID);
        WarrantyPriorApprovalController.isWarrantySubmittedForApproval(warrantyPrior.ID);
        Test.stopTest();
        

        // Assert that the related warranty prior record is fetched
       // System.assertNotEquals(result, null, 'The related Warranty Prior record should not be null.');
    }
}