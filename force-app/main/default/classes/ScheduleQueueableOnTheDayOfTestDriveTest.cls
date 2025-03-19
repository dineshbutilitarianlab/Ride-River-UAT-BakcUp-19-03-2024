@IsTest
public class ScheduleQueueableOnTheDayOfTestDriveTest {
    @Istest 
    public static void testScheduleQueueableOnTheDayOfTestDrive(){
        Store_Details__mdt s1 = new Store_Details__mdt(Name__c='test 1',Dealer_Code__c='100001',IsActive__c=true);
        Store_Details__mdt s2 = new Store_Details__mdt(Name__c='test 2',Dealer_Code__c='100002',IsActive__c=true);
        
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key',
            on_day_of_test_ride2__c = 'https://example.com/image.jpg'
        );
        insert mockIntegration;
        
        List<Lead> leadsToInsert = new List<Lead>();
        Lead l1 = new Lead(LastName='Test Lead',Company='Test Company',Status='New',LeadSource='Google',Phone='0987654321',Dealer_Code__c='100001'); 
        Lead l2 = new Lead(LastName='Test Lead 2',Company='Test Company 2',Status='New',LeadSource='Facebook',Phone='1234567890',Dealer_Code__c='100002');
        insert new List<Lead>{l1, l2};
        
        
        Test_Drive__c testDrive1 = new Test_Drive__c(Lead__c = l1.Id,Test_Ride_Date__c = DateTime.now(),Ride_Type__c = 'Home Ride');
        Test_Drive__c testDrive2 = new Test_Drive__c(Lead__c = l2.Id,Test_Ride_Date__c = DateTime.now(), Ride_Type__c = 'Store Ride');
        
        
        Test.startTest();

        insert testDrive1;
        insert testDrive2;
        ScheduleQueueableOnTheDayOfTestDrive obj = new ScheduleQueueableOnTheDayOfTestDrive();
        String cronExp = '0 0 0 15 2 ?';  
        System.schedule('Test Schedule Queueable Job', cronExp, obj);

        Test.stopTest();
        
       
    }

}