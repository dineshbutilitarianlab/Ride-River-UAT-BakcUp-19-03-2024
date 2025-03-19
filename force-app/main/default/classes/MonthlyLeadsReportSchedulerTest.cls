@isTest
public class MonthlyLeadsReportSchedulerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Test Leads
        List<Lead> testLeads = new List<Lead>{
            new Lead(FirstName = 'John', LastName = 'Doe', Company = 'TestCorp', LeadSource = 'Web', UTM_Source__c = 'Google'),
            new Lead(FirstName = 'Jane', LastName = 'Smith', Company = 'TechCorp', LeadSource = 'Facebook', UTM_Source__c = 'Meta'),
            new Lead(FirstName = 'Sam', LastName = 'Wilson', Company = 'AdCorp', LeadSource = '91Wheels', UTM_Source__c = 'Google')
        };
        insert testLeads;

        // Create Test Test_Drive__c records
        List<Test_Drive__c> testDrives = new List<Test_Drive__c>{
            new Test_Drive__c(Lead__c = testLeads[0].Id, Test_Drive_Status__c = 'Scheduled', Test_Drive_Date__c = Date.today()),
            new Test_Drive__c(Lead__c = testLeads[1].Id, Test_Drive_Status__c = 'Completed', Test_Drive_Date__c = Date.today())
        };
        insert testDrives;

        // Create Test Accounts
        Account testAccount = new Account(Name = 'Test Account', AccountSource = 'Web');
        insert testAccount;

        /* / Create Test Orders
        /List<Order> testOrders = new List<Order>{
            new Order(AccountId = testAccount.Id, Status = 'Draft', Website_Order_Id__c = '123'),
            new Order(AccountId = testAccount.Id, Status = 'Vehicle Delivered')
        };
        insert testOrders; */
    }

    @isTest
    static void testSendLeadsReport() {
        Test.startTest();
        Date firstDay = Date.today().toStartOfMonth();
        Date lastDay = Date.today();

        // Call method
        MonthlyLeadsReportScheduler.sendLeadsReport(firstDay, lastDay,'Leads');
        Test.stopTest();

    }

    @isTest
    static void testExecuteScheduler() {
        Test.startTest();
        MonthlyLeadsReportScheduler scheduler = new MonthlyLeadsReportScheduler();
        String jobId = System.schedule('Test Monthly Report', '0 0 12 1 * ?', scheduler);
        Test.stopTest();

        
    }
}