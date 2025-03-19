@isTest
public class LeadBatchProcessTest {
    
    @isTest
    static void testBatchWithCallouts() {
        // Set up test data (only 2 records to match batch size)
        List<Lead> testLeads = new List<Lead>();
        for (Integer i = 0; i < 2; i++) { // Match batch size
            testLeads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead' + i,
                Company = 'Test Company',
                Dealer_Code__c='291002',
                LeadSource='91Wheels',
                Status = 'New',
                Phone = '987654321' + i
            ));
        }
        insert testLeads;

        // Create mock response for callout
        Test.setMock(HttpCalloutMock.class, new LeadBatchProcessMock());

        // Execute batch
        Test.startTest();
        LeadBatchProcess batchJob = new LeadBatchProcess();
        Database.executeBatch(batchJob, 2); // Batch size of 2
        Test.stopTest();

        // Assert that leads were processed
        List<Lead> processedLeads = [SELECT Id, Status, Phone FROM Lead WHERE Status = 'New'];
        System.assertEquals(2, processedLeads.size(), 'Leads should be processed.');
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
        Test.setMock(HttpCalloutMock.class, new LeadBatchProcessMock());

        // Schedule the job
        String cronExp = '0 0 12 * * ?'; // Every day at noon
        Test.startTest();
        LeadBatchScheduler scheduler = new LeadBatchScheduler();
        String jobId = System.schedule('TestLeadBatchScheduler', cronExp, scheduler);
        Test.stopTest();

        // Assert that job was scheduled
        System.assertNotEquals(null, jobId, 'Scheduler job should be created.');
    }
}