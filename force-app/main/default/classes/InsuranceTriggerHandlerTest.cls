@isTest
public class InsuranceTriggerHandlerTest {
    @testSetup
    static void setupTestData() {
        Insurance__c ins1 = new Insurance__c(Name = 'Test Insurance');
        insert ins1;
    }
    
    @isTest
    static void testCheckForDuplicateNames() {
        List<Insurance__c> newInsuranceRecords = new List<Insurance__c>{
            new Insurance__c(Name = 'Test Insurance'),
            new Insurance__c(Name = 'Unique Insurance')
        };
        
        Test.startTest();
        InsuranceTriggerHandler.checkForDuplicateNames(newInsuranceRecords);
        Test.stopTest();
        
        try {
            insert newInsuranceRecords;
        } catch (DmlException e) {
        }
    }
}