@RestResource(urlMapping='/CreateTestRide')  
global with sharing class CreateEventTestRide {  
    
    @HttpPost  
    global static String doPost(String leadId, String startDate, String endDate, String dealerCode, String pincode, String phoneNumber) {  
        // Input validation  
        if (leadId == null || startDate == null || endDate == null || dealerCode == null || pincode == null || phoneNumber == null) {  
            return '{"error": "leadId, startDate, endDate, dealerCode, pincode, and phoneNumber are required."}';  
        }  
        
        // Convert String dates to Datetime  
        Datetime startDateTime = Datetime.valueOf(startDate);  
        Datetime endDateTime = Datetime.valueOf(endDate);  
        
        // Create a new event  
        Event newEvent = new Event();  
        newEvent.Subject = 'Test Ride';  
        newEvent.StartDateTime = startDateTime;  
        newEvent.EndDateTime = endDateTime;
        newEvent.Pincode__c = pincode;
        newEvent.phone_Number__c = phoneNumber;
        newEvent.Dealer_Code__c = dealerCode;  
        newEvent.WhoId = leadId; // This should be the Lead ID  
        newEvent.OwnerId = UserInfo.getUserId(); // Optional: Set the Owner to the current user  
        newEvent.IsAllDayEvent = false; // Change to true if this is an all-day event  

        // Optionally, you can create a custom object to store dealer information, or you can store it in the event description or a custom field.  
        //newEvent.Description = 'Dealer Code: ' + dealerCode + ', Pincode: ' + pincode + ', Phone Number: ' + phoneNumber; // Example of storing additional info in the description  

        try {  
            insert newEvent;  
            return '{"success": "Event created successfully.", "eventId": "' + newEvent.Id + '"}';  
        } catch (Exception e) {  
            return '{"error": "' + e.getMessage() + '"}';  
        }  
    }  
}