/*Expose the API as a REST Resource

Developer Name : Prathap KR
Date : 12-07-2024

No changes needed in this class if you are using the custom setting in `OAuthHelper`.

*/
@RestResource(urlMapping='/LeadCreationAPIThinkResult')
global class LeadCreationAPIThinkResult {
    @HttpPost  
    global static string createLeadFromWebsite() {  
        RestRequest req = RestContext.request;  
        RestResponse res = RestContext.response;  
        
        // Parse the request body  
        String requestBody = req.requestBody.toString();  
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);  
        
        String fullName = (String) requestBodyMap.get('LastName');  
        String company = (String) requestBodyMap.get('Company');  
        String email = (String) requestBodyMap.get('Email');  
        String phone = (String) requestBodyMap.get('Phone');  
        String city = (String) requestBodyMap.get('City');  
        String postalCode = String.valueOf(requestBodyMap.get('PostalCode'));  
       String dealerCode = (String) requestBodyMap.get('DealerCode');  

        // Query for existing lead based on phone number  
        List<Lead> leads = [SELECT Id, LastName, Company, Email, Phone, City,Dealer_Code__c  
                            FROM Lead WHERE Phone = :phone LIMIT 1];  

        Lead leadToUpdate;  
        
        if (!leads.isEmpty()) {  
            // If a lead is found, update it  
            leadToUpdate = leads[0];  
        } else {  
            // If no lead is found, create a new one  
            leadToUpdate = new Lead();  
            leadToUpdate.LeadSource = 'ThinkResult'; // Set LeadSource only when creating a new lead  
        }  
        
        // Update the lead fields  
        leadToUpdate.LastName = fullName;  
        leadToUpdate.Company = fullName;  
        leadToUpdate.Email = email;  
        leadToUpdate.Phone = phone;  
        leadToUpdate.City = city;  
        leadToUpdate.PostalCode = postalCode;   
        leadToUpdate.Dealer_Code__c = dealerCode;   
      

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