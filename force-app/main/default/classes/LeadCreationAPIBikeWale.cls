/*Expose the API as a REST Resource

Created by Prathap KR

No changes needed in this class if you are using the custom setting in `OAuthHelper`.

*/
@RestResource(urlMapping='/createLeadBikeWale')
global class LeadCreationAPIBikeWale{
    @HttpPost
    global static string createLeadFromWebsite() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;  
        // Parse the request body
        String requestBody = req.requestBody.toString();
        Map<String, Object> requestBodyMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        String firstName = (String) requestBodyMap.get('FirstName');
        String lastName = (String) requestBodyMap.get('LastName');
        String company = (String) requestBodyMap.get('Company');
        String email = (String) requestBodyMap.get('Email');
        String phone = (String) requestBodyMap.get('Phone');
		 
        lead l = new lead();
        l.FirstName = firstName;
        l.LastName = lastName;
        l.Company = lastName;
        l.Email = email;
        l.Phone = phone;
        l.LeadSource = 'BikeWale';
        insert l;
           
       /* try {
            LeadService.createLead(lastName, company, email, phone);
            res.statusCode = 201;
            res.responseBody = Blob.valueOf('Lead created successfully');
        } catch (LeadService.LeadException e) {
            res.statusCode = 500;
            res.responseBody = Blob.valueOf('Error creating lead: ' + e.getMessage());
        }*/
        
        return l.Id;
        
    }
}