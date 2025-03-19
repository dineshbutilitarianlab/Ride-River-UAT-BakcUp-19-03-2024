@RestResource(urlMapping='/createLeadOzoneTel')  
global class LeadCreationfromOzoneTel{  
     @HttpPost  
    global static string createLeadFromWebsite() {  
        RestRequest req = RestContext.request;  
        RestResponse res = RestContext.response;  
        
        // Parse the request body  
        String requestBody = req.requestBody.toString();  
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);  
        
        String fullName = (String) requestBodyMap.get('FullName');  
        String company = (String) requestBodyMap.get('Company');  
        String email = (String) requestBodyMap.get('Email');  
        String phone = (String) requestBodyMap.get('Phone');  
        String city = (String) requestBodyMap.get('City');  
        String postalCode = String.valueOf(requestBodyMap.get('PostalCode'));  
        Boolean homeTestRide = (Boolean) requestBodyMap.get('HomeTestRide');  
        Boolean instoreTestdrive = (Boolean) requestBodyMap.get('InstoreTestdrive');  
        
        // Retrieve date/time values from the request body  
        String startDateTimeStr = (String) requestBodyMap.get('startDateTimeStr');  
        String endDateTimeStr = (String) requestBodyMap.get('endDateTimeStr');  

        // Initialize Datetime variables  
        Datetime startDateTime;  
        Datetime endDateTime;  

        // Convert to Datetime if values are provided  
        if (startDateTimeStr != null) {  
            startDateTime = Datetime.valueOf(startDateTimeStr);  
        } else {  
            // Handle null case for startDateTime (e.g., set to a default value or log an error)  
            startDateTime = null; // or some default value  
        }  

        if (endDateTimeStr != null) {  
            endDateTime = Datetime.valueOf(endDateTimeStr);  
        } else {  
            // Handle null case for endDateTime (e.g., set to a default value or log an error)  
            endDateTime = null; // or some default value  
        }  

        String dealerCode = (String) requestBodyMap.get('DealerCode');  

        // Query for existing lead based on phone number  
        List<Lead> leads = [SELECT Id, LastName, Company, Email, Phone, City,   
                            Test_ride_Start_date__c, Test_ride_end_date__c,   
                            Dealer_Code__c, Home_Test_Ride__c, Instore_Test_drive__c   
                            FROM Lead WHERE Phone = :phone LIMIT 1];  

        Lead leadToUpdate;  
        
        if (!leads.isEmpty()) {  
            // If a lead is found, update it  
            leadToUpdate = leads[0];  
        } else {  
            // If no lead is found, create a new one  
            leadToUpdate = new Lead();  
            leadToUpdate.LeadSource = 'OzoneTel WhatsApp'; // Set LeadSource only when creating a new lead  
        }  
        
        // Update the lead fields  
        leadToUpdate.LastName = fullName;  
        leadToUpdate.Company = fullName;  
        leadToUpdate.Email = email;  
        leadToUpdate.Phone = phone;  
        leadToUpdate.City = city;  
        leadToUpdate.PostalCode = postalCode;  
        leadToUpdate.Test_ride_Start_date__c = startDateTime;  
        leadToUpdate.Test_ride_end_date__c = endDateTime;  
        leadToUpdate.Dealer_Code__c = dealerCode;   
        
        leadToUpdate.Home_Test_Ride__c = homeTestRide != null ? homeTestRide : false;  
        leadToUpdate.Instore_Test_drive__c = instoreTestdrive != null ? instoreTestdrive : false;  

        if (leadToUpdate.Id != null) {  
            // Update existing lead  
            update leadToUpdate;  
        } else {  
            // Insert new lead  
            insert leadToUpdate;  
        }  
        
        return 'Lead processed successfully: ' + leadToUpdate.Id;  
    }  
}