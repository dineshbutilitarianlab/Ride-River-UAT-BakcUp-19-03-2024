@istest 
public class TestRideCreateWhatsappmsgcallout_test {
 @isTest
    public static void testTriggerLogicAndCallout() {
        // Step 1: Set up test data
        Lead leadRecord = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Phone = '1234567890',
            LeadSource = 'Google',
            Dealer_Code__c = '291001',
            Company='NA'
        );
        insert leadRecord;

        Test_Drive__c testDriveRecord = new Test_Drive__c(
            Name = 'Test Ride',
            Lead__c = leadRecord.Id,
            Test_Ride_Date__c = System.now(),
            Ride_Type__c = 'Store Ride'
        );
        insert testDriveRecord;

        // Step 2: Mock the HTTP response
        Test.setMock(HttpCalloutMock.class, new TestRideCreateWhatsappmsgcallout_mock());

        
       
    }
}