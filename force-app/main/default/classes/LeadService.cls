/**
 Created by Prathap KR



 **/


public class LeadService {
    public static void createLead(String lastName, String company, String email, String phone) {
        String accessToken = OAuthHelper.getAccessToken();
        String instanceUrl = 'https://yourInstance.salesforce.com';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(instanceUrl + '/services/data/v61.0/sobjects/Lead/'); // Adjust API version as needed
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
       
        // Prepare lead data
        Map<String, Object> leadData = new Map<String, Object>();
        leadData.put('LastName', lastName);
        leadData.put('Company', company);
        leadData.put('Email', email);
        leadData.put('Phone', phone);
       
        req.setBody(JSON.serialize(leadData));

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() == 201) { // 201 Created
                System.debug('Lead created successfully: ' + res.getBody());
            } else if (res.getStatusCode() == 401) { // 401 Unauthorized
                // Token might be expired, refresh token and retry
                OAuthHelper.refreshToken(OAuth_Credentials__c.getOrgDefaults());
                createLead(lastName, company, email, phone); // Retry after refreshing the token
            } else {
                throw new LeadException('Failed to create lead: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new LeadException('Exception occurred while creating lead: ' + e.getMessage());
        }
    }

    public class LeadException extends Exception {}
}