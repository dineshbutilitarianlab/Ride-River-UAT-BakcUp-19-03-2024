@isTest
public class homecontrollertest {
    @isTest
    public static void getLeadsListtest(){
        Test.startTest();
        
        // Step 1: Create Lead Record
        Lead l = new Lead(
            LastName   = 'test1234',
            FirstName  = 'test',
            Salutation = 'Mr.',
            LeadSource = 'BikeWale',
            Phone      = '8373879087',
            Company    = 'TCS',
            City       = 'test',      // Ensure these fields exist in the schema
            Country    = 'India',
            State      = 'Bihar',
            Street     = 'test',
            PostalCode = 'test'
        );
        insert l;

        // Step 2: Create Test Drive Record
        Test_Drive__c td = new Test_Drive__c(
            Lead__c = l.Id,
            Name = l.LastName,
            Indemnity__c = true,
            Drivers_License_Number__c = 'AB1234567890123',
            Test_ride_executive_s_Name__c = 'test executive'
        );
        insert td;

        // Step 3: Create Follow-Up Record
        DateTime testDateTime = DateTime.newInstance(2023, 10, 6, 12, 0, 0);
        DateTime testDateTime1 = DateTime.newInstance(2023, 10, 7, 12, 0, 0);

        Follow_Up__c f = new Follow_Up__c(
            Lead__c = l.Id,
            Status__c = 'In Progress',
            Follow_Up_Date__c = testDateTime,
            Name = l.LastName
        );
        insert f;

        // Step 4: Ensure a WhatsappIntegration__c record exists (If required in HomeController)
      WhatsappIntegration__c ws = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            order_cancelled__c='example.jpg',
             fullpayment_done__c='examplePayment.jpg'
        );
        insert ws;

        // Step 5: Execute Methods in homecontroller
        homecontroller.getLeadsList('test');
        homecontroller.getLeads();
        homecontroller.getLeaddeatails(l.Id);
        homecontroller.updatelead(l.Id, 'BikeWale', '9827739327', 34, 'test@gmail.com', 'test', 'India', '0000000', 'Bihar', 'test', 'New', 'test');
        homecontroller.bookingid(l.Id, '000000000');
        homecontroller.createnewfollowup(l.Id, testDateTime1, 'Follow-up Notes');
        homecontroller.createnewfollowuptestride(l.Id, testDateTime1, 'Test Ride Follow-up Notes');
        homecontroller.createstoreride(l.Id, 'test', testDateTime);
        homecontroller.createhomeride(l.Id, 'test', testDateTime, 'test', 'test', 'Bihar', 'India', 'test');
        homecontroller.leadcancelreason(l.Id, 'Out of Delivery Area', 'Reason Description');
        homecontroller.updatefollowup(f.Id);
        homecontroller.updatedltestride(td.Id, 'Ka1234567890123', true);
        // Uncomment below if needed
        homecontroller.updatedstatustestridecomplete(td.Id);
        homecontroller.updatedstatustestride(td.Id);
        homecontroller.updatedtestdrivefeedback(td.Id, 'testing');
        homecontroller.newgetLeadsList('test');

        Test.stopTest();

        // Step 6: Assertions (Verifying that updates were applied)
        Test_Drive__c updatedTD = [SELECT Id, Drivers_License_Number__c FROM Test_Drive__c WHERE Id = :td.Id];
        System.assertEquals('Ka1234567890123', updatedTD.Drivers_License_Number__c, 'Test Drive DL number did not update correctly');


    }
}