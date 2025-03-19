public class TestDriveNotificationSender implements Schedulable {
    
    private Id testDriveId;
    private Id leadId;
    
    public TestDriveNotificationSender(Id testDriveId, Id leadId) {
        this.testDriveId = testDriveId;
        this.leadId = leadId;
    }
    
    public void execute(SchedulableContext context) {
        // Send WhatsApp notification
        Test_Drive__c td = [SELECT Id, Lead__c 
                              FROM Test_Drive__c 
                              WHERE Id = :testDriveId];
        Lead lead = [SELECT Id, Phone 
                      FROM Lead 
                      WHERE Id = :leadId];
        
        WhatsAppMsgForTestrideComplete.WhatsAppMsgForTestrideCompletefutherMethod(lead.Phone, 'test_ride_taken_indie_not_booked_followup');
    }
}