@isTest
public class ScheduleLeadAgeWhatsappMsgTest {
    
    @isTest
    public static void testScheduleLeadAgeWhatsappMsg() {
        
        Store_Details__mdt store1 = new Store_Details__mdt(Name__c='Store1', MasterLabel='Store 1', Dealer_Code__c='291001', IsActive__c=true);
        Store_Details__mdt store2 = new Store_Details__mdt(Name__c='Store2', MasterLabel='Store 2', Dealer_Code__c='291002', IsActive__c=true);
        
        
        
        WhatsappIntegration__c ws = new WhatsappIntegration__c(
            Name='WhatsApp API',
            no_action_book_test_ride_03__c='http://someurl.com/image.jpg'
        );
        insert ws;
        
        String templateName='test_test';
        
        // Create Leads
        List<Lead> leadsToInsert = new List<Lead>();
        Lead lead1 = new Lead(LastName='Test', Company='Test Co', LeadSource='Google', Dealer_Code__c='291001', Phone='1234567890',Status='New');
        Lead lead2 = new Lead(LastName='Test2', Company='Test2 Co', LeadSource='Facebook', /*Dealer_Code__c='291002'*/PostalCode='560078', Phone='9876543210');
        leadsToInsert.add(lead1);
        leadsToInsert.add(lead2);
        insert leadsToInsert;
        
        
        Test.startTest();
        String cronExpression = '0 0 0 1 1 ?';
        System.schedule('Test WhatsApp Schedule22', cronExpression, new scheduleLeadAgeWhatsappMsg());
        
        
        
        Test.stopTest();
        
       
    }
}