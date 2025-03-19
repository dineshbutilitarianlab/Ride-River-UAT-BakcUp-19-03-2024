@IsTest(SeeAllData=true)
public class createPurchaseOrderFormControllerTest {
    
    @isTest
    static void testdata() {
        User use = [SELECt Id,Name,Profile.Name from User WHeRE Profile.Name = 'Sales Manager (Partner)' AND isActive = true AND  Contact.Location__c != null LIMIT 1];
        // Step 6: Start Test and Call Method
        Test.startTest();
        String result = createPurchaseOrderFormController.createPurchaseorder('VOR', use.Id);
        String UserId = createPurchaseOrderFormController.getCurrentLogedUserAccountRecord(use.Id);
        Test.stopTest();
    }
}