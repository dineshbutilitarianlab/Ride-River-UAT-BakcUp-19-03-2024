@IsTest(SeeAllData=true)
public class cardsComponentControllerTest {
    @isTest
    public static void cardsComponentControllerTest() {
        User use = [SELECt Id,Name,Profile.Name from User WHeRE Profile.Name = 'Sales Manager (Partner)' AND isActive = true AND  Contact.Location__c != null LIMIT 1];
        Test.startTest();
        cardsComponentController.fetchOnLoadData(use.Id);
        cardsComponentController.fetchOnLoadData(UserInfo.getUserId());
        cardsComponentController.fetchOnLoadData(null);
        Test.stopTest();
    }
}