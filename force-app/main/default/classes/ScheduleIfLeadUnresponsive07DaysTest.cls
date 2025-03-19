@IsTest
public class ScheduleIfLeadUnresponsive07DaysTest {
    @IsTest
    public static void testScheduleIfLeadUnresponsive10Days(){
        Store_Details__mdt store1 = new Store_Details__mdt(Name__c='Store1', MasterLabel='Store 1', Dealer_Code__c='291001', IsActive__c=true);
        Store_Details__mdt store2 = new Store_Details__mdt(Name__c='Store2', MasterLabel='Store 2', Dealer_Code__c='291002', IsActive__c=true);
        
        
        
        WhatsappIntegration__c ws = new WhatsappIntegration__c(
            Name='WhatsApp API',
            no_action_book_test_ride_03__c='http://someurl.com/image.jpg'
        );
        insert ws;
        
        String templateName='test_test';
        
        
        List<Lead> leadsToInsert = new List<Lead>();
        Lead lead1 = new Lead(LastName='Test', Company='Test Co', LeadSource='Google', Dealer_Code__c='291001', Phone='1234567890',Status='Test Ride');
        Lead lead2 = new Lead(LastName='Test2', Company='Test2 Co', LeadSource='Facebook', Dealer_Code__c='291002', Phone='9876543210',Status='Test Ride');
        leadsToInsert.add(lead1);
        leadsToInsert.add(lead2);
        insert leadsToInsert;
        
        Test_Drive__c testDrive1 = new Test_Drive__c(Name='Drive 1', Lead__c = lead1.Id, Ride_Type__c= 'Home Ride',Test_Ride_Date__c=System.Now().addDays(-7),Test_Drive_Status__c='Completed');
        Test_Drive__c testDrive2 = new Test_Drive__c(Name='Drive 2', Lead__c = lead2.Id, Ride_Type__c= 'Store Ride',Test_Ride_Date__c=System.Now().addDays(-7),Test_Drive_Status__c='Completed');
        insert testDrive1;
        insert testDrive2;
        
        Test.startTest();
        String cronExpression = '0 0 0 1 1 ?';
        System.schedule('Test3', cronExpression, new ScheduleIfLeadUnresponsive07Days());
        Test.stopTest();
    }

}