@isTest
private class EmailToLead2Test {
    
    @isTest
    static void testHandleInboundEmail() {
        // Create a new instance of Messaging.InboundEnvelope and Messaging.InboundEmail for testing.
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        // Set necessary properties for the email. Modify these values to match your test scenario.
        email.fromAddress = 'test@example.com';
        email.fromName = 'Test User';
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test Body';
        email.inreplyto = 'TestInReplyTo';

        // Create a test Lead with the same email address and subject for duplicate scenario.
        Lead testLead = new Lead(
            Email = 'test@example.com',
            Title = 'Test Subject',
            LastName = 'Test User',
            Company = 'Test User',
            LeadSource = 'Email-To-Lead',
            Description = 'From Email'
            
        );
        insert testLead;

        Test.startTest();

        // Call the handleInboundEmail method.
        EmailToLead2 handler = new EmailToLead2();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Test.stopTest();

        // Assert the results.
        System.assertEquals(true, result.success, 'Expected success');
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :email.fromAddress AND Title = :email.subject];
        System.assertEquals(1, leads.size(), 'Expected one new Lead record');

        // Clean up the test data if necessary.
        delete testLead;
    }
    
    @isTest
    static void testHandleInboundEmail1() {
        // Create a new instance of Messaging.InboundEnvelope and Messaging.InboundEmail for testing.
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        
        // Set necessary properties for the email. Modify these values to match your test scenario.
        email.fromAddress = 'test@example.com';
        email.fromName = 'Test User';
        email.subject = 'Test Subject';
        email.plainTextBody = 'Test Body';
        email.inreplyto = 'TestInReplyTo';


        Test.startTest();

        // Call the handleInboundEmail method.
        EmailToLead2 handler = new EmailToLead2();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, env);

        Test.stopTest();

        // Assert the results.
        System.assertEquals(true, result.success, 'Expected success');
        List<Lead> leads = [SELECT Id FROM Lead WHERE Email = :email.fromAddress AND Title = :email.subject];
        System.assertEquals(1, leads.size(), 'Expected one new Lead record');

    }
}