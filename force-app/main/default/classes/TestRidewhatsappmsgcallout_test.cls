@Istest
public class TestRidewhatsappmsgcallout_test {
    @isTest
    public static void testTriggerAndCallout() {
        Test.setMock(HttpCalloutMock.class, new Mock_callout_response_for_testridenoshow());

        Lead leadids = new Lead(FirstName = 'John', LastName = 'Doe', Phone = '919632584820',Company='NA',  Dealer_Code__c='291002',
                LeadSource='91Wheels');
        insert leadids;

               Test_Drive__c testDrive = new Test_Drive__c(
            Name = 'Test Ride',
            Lead__c = leadids.Id,
            Test_Ride_Date__c = System.now(),
            Ride_Type__c = 'Store Ride'
        );
        insert testDrive;

        testDrive.Test_Drive_Status__c = 'Canceled';
        update testDrive;


        
    }


}