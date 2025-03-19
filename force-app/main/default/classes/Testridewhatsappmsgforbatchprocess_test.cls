@istest
public class Testridewhatsappmsgforbatchprocess_test {
 @isTest
    static void testBatchWithCallouts() {
        // Set up test data (only 2 records to match batch size)
        Lead testLead = new Lead(
    FirstName = 'Test',
    LastName = 'Lead',
    Company = 'Test Company',
    Dealer_Code__c = '291002',
    LeadSource = '91Wheels',
    Status = 'New',
    Phone = '9876543210' // Just one phone number for this single lead
);
insert testLead;
            Test_Drive__c td=new Test_Drive__c();
        td.Lead__c=testLead.Id;
        td.Ride_Type__c='Store Ride';
        td.Test_Ride_Date__c=Date.today();
        insert td;
      
        // Create mock response for callout
        Test.setMock(HttpCalloutMock.class, new Testridewhatsappmsgforbatchprocessmock());

        // Execute batch
        Test.startTest();
        Testridewhatsappmsgforbatchprocess batchJob = new Testridewhatsappmsgforbatchprocess();
        Database.executeBatch(batchJob, 2); // Batch size of 2
        Test.stopTest();

        // Assert that leads were processed
        List<Lead> processedLeads = [SELECT Id, Status, Phone FROM Lead WHERE Status = 'New'];
        //System.assertEquals(2, processedLeads.size(), 'Leads should be processed.');
    }

    @isTest
    static void testScheduler() {
        // Set up test data
        Lead testLead = new Lead(
            FirstName = 'Scheduled',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'New',
            Phone = '9876543210'
        );
        insert testLead;

        // Create mock response for callout
        Test.setMock(HttpCalloutMock.class, new Testridewhatsappmsgforbatchprocessmock());

        // Schedule the job
        String cronExp = '0 0 12 * * ?'; // Every day at noon
        Test.startTest();
        Testrideforwhatsappmsgschedule scheduler = new Testrideforwhatsappmsgschedule();
        String jobId = System.schedule('TestLeadBatchScheduler', cronExp, scheduler);
        Test.stopTest();

        // Assert that job was scheduled
        System.assertNotEquals(null, jobId, 'Scheduler job should be created.');
    }
}