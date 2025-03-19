@RestResource(urlMapping='/RegisterAccount1')
global class AccountLeadRegistrationAPI {
    
    @HttpPost
    global static void createAccountContact() {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        Map<String, String> response = new Map<String, String>();
        
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(requestBody);
        Map<String, Object> billing_address = (Map<String, Object>)requestMap.get('billing_address') != null? (Map<String, Object>)requestMap.get('billing_address'):null;
        Map<String, Object> shipping_address = (Map<String, Object>)requestMap.get('shipping_address') != null? (Map<String, Object>)requestMap.get('shipping_address'):null;
        
        String leadEmail = (String)requestMap.get('email_address') != null? (String)requestMap.get('email_address'): '';
        String phone = (String)requestMap.get('phone_number') != null?(String)requestMap.get('phone_number'):'';
        String Company = (String)requestMap.get('full_name');
        String accountId = null;
        String OpportunityId = null;
        String contactId = null;
        List<lead> existingLead = new List<lead>();
        List<Account> existingAccount = new List<Account>();
        
        try{
            
            If(phone != '')
                existingAccount = [SELECT Id FROM Account WHERE Phone = :phone  LIMIT 1];
            
            If(existingAccount.isEmpty()){ 
                existingLead = [SELECT Id,Owner.Type FROM Lead 
                                WHERE (Email = :leadEmail OR Phone = :phone) 
                                AND isConverted = false 
                                LIMIT 1];
                
                if (!existingLead.isEmpty()) {
                    system.debug('existing lead found>>'+existingLead[0]);
                    if (existingLead[0].Owner.Type == 'Queue') {
                        User targetUser = [SELECT Id,LastName FROM User WHERE LastName LIKE '%@store' LIMIT 1];
                        
                        if (targetUser != null) {
                            existingLead[0].OwnerId = targetUser.Id;
                            update existingLead[0];
                        }
                    }
                    
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(existingLead[0].Id);
                    lc.setConvertedStatus('Converted');
                    
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    
                    if (lcr.isSuccess()) {
                        System.debug('Lead converted to Account: ' + lcr.getAccountId() + ', Contact: ' 
                        + lcr.getContactId() + ', Opportunity: ' + lcr.getOpportunityId());
                        Id newContactId = lcr.getContactId();
                        
                        // Set the custom field Primary_Contact__c to true on the Contact
                        //Contact newContact = new Contact(Id = newContactId, Primary_Contact__c = true);
                        //update newContact;
                        
                        Account newAccount = new Account(Id = lcr.getAccountId(),
                                                         Type = 'Customer',
                                                         Name = (String)requestMap.get('full_name'),
                                                         Phone = (String)requestMap.get('phone_number') != null ? (String)requestMap.get('phone_number') : '',
                                                         Email__c = (String)requestMap.get('email_address') != null ? (String)requestMap.get('email_address') : '',
                                                         BillingCountry = (String)billing_address.get('country') != null ? (String)billing_address.get('country') : 'India',
                                                         BillingStreet = ((String)billing_address.get('address_1') != null ? (String)billing_address.get('address_1') : '') +' '+ ((String)billing_address.get('address_2') != null ? (String)billing_address.get('address_2') : ''),
                                                         BillingCity = (String)billing_address.get('city') != null ? (String)billing_address.get('city') : '',
                                                         BillingState = (String)billing_address.get('state') != null ? (String)billing_address.get('state') : '',
                                                         BillingPostalCode = (String)billing_address.get('pin_code') != null ? (String)billing_address.get('pin_code') : '',
                                                         ShippingCountry = (String)shipping_address.get('country') != null ? (String)shipping_address.get('country') : 'India',
                                                         ShippingStreet = ((String)shipping_address.get('address_1') != null ? (String)shipping_address.get('address_1') : '')+ ' '+((String)shipping_address.get('address_2') != null ? (String)shipping_address.get('address_2') : ''),
                                                         ShippingCity = (String)shipping_address.get('city') != null ? (String)shipping_address.get('city') : '',
                                                         ShippingState = (String)shipping_address.get('state') != null ? (String)shipping_address.get('state') : '',
                                                         ShippingPostalCode = (String)shipping_address.get('pin_code') != null ? (String)shipping_address.get('pin_code') : ''
                                                        );
                        update newAccount;
                        
                        accountId = lcr.getAccountId();
                        contactId = lcr.getContactId();
                        OpportunityId = lcr.getOpportunityId();

                        Opportunity opp = new Opportunity(
                            Id = lcr.getOpportunityId(),
                            AccountId = lcr.getAccountId(),
                            Name = (String)requestMap.get('full_name'),
                            Type = 'Existing Business',
                            StageName = 'New',
                            CloseDate = Date.today()
                        );
                        update opp;
                    } else {
                        system.debug('error occurred >> ' + lcr);
                    }
                } else {
                    Lead newLead = new Lead(
                        LastName = (String)requestMap.get('full_name'),
                        Company =(String)requestMap.get('full_name'),
                        Email = (String)requestMap.get('email_address') != null ? (String)requestMap.get('email_address') : '',
                        Phone = (String)requestMap.get('phone_number') != null ? (String)requestMap.get('phone_number') : '',
                        LeadSource	= 'River Website',
                        Status = 'Converted'
                    );
                    insert newLead;
                    
                    if (newLead.Owner.Type == 'Queue') {
                        User targetUser = [SELECT Id,LastName FROM User WHERE LastName LIKE '%@store' LIMIT 1];
                        
                        if (targetUser != null) {
                            newLead.OwnerId = targetUser.Id;
                            update newLead; 
                        }
                    }
                    
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(newLead.Id);
                    lc.setConvertedStatus('Converted');
                    
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    system.debug('New Lead is created >> ' + newLead);  
                    System.debug('Lead converted to Account: ' + lcr.getAccountId() + ', Contact: ' 
                        + lcr.getContactId() + ', Opportunity: ' + lcr.getOpportunityId());                  
                    system.debug('creating new account and contact1');
                    Account newAccount = new Account(
                        Id = lcr.getAccountId(),
                        Name = (String)requestMap.get('full_name'),
                        AccountSource = 'River Website',
                        Type = 'Customer',
                        Email__c = (String)requestMap.get('email_address') != null ? (String)requestMap.get('email_address') : '',
                        BillingCountry = (String)billing_address.get('country') != null ? (String)billing_address.get('country') : 'India',
                        Phone = (String)requestMap.get('phone_number') != null ? (String)requestMap.get('phone_number') : '',
                        BillingStreet = ((String)billing_address.get('address_1') != null ? (String)billing_address.get('address_1') : '') +' '+((String)billing_address.get('address_2') != null ? (String)billing_address.get('address_2') : ''),
                        BillingCity = (String)billing_address.get('city') != null ? (String)billing_address.get('city') : '',
                        BillingState = (String)billing_address.get('state') != null ? (String)billing_address.get('state') : '',
                        BillingPostalCode = (String)billing_address.get('pin_code') != null ? (String)billing_address.get('pin_code') : '',
                        ShippingCountry = (String)shipping_address.get('country') != null ? (String)shipping_address.get('country') : 'India',
                        ShippingStreet = ((String)shipping_address.get('address_1') != null ? (String)shipping_address.get('address_1') : '') +' '+ ((String)shipping_address.get('address_2') != null ? (String)shipping_address.get('address_2') : ''),
                        ShippingCity = (String)shipping_address.get('city') != null ? (String)shipping_address.get('city') : '',
                        ShippingState = (String)shipping_address.get('state') != null ? (String)shipping_address.get('state') : '',
                        ShippingPostalCode = (String)shipping_address.get('pin_code') != null ? (String)shipping_address.get('pin_code') : ''
                    );
                    update newAccount;

                    accountId = newAccount.Id;
                    contactId = lcr.getContactId();
                    OpportunityId = lcr.getOpportunityId();

                    Opportunity opp = new Opportunity(
                        Id = lcr.getOpportunityId(),
                        AccountId = lcr.getAccountId(),
                        Name = (String)requestMap.get('full_name'),
                        Type = 'New Business',
                        StageName = 'New',
                        CloseDate = Date.today()
                    );
                    update opp;
                }
            }
            else{
                accountId = existingAccount[0].Id;
                
                Account newAccount = new Account(
                    id = accountId,
                    Name = (String)requestMap.get('full_name'),
                    Type = 'Customer',
                    Email__c = (String)requestMap.get('email_address') != null ? (String)requestMap.get('email_address') : '',
                    BillingCountry = (String)billing_address.get('country') != null ? (String)billing_address.get('country') : 'India',
                    Phone = (String)requestMap.get('phone_number') != null ? (String)requestMap.get('phone_number') : '',
                    BillingStreet = ((String)billing_address.get('address_1') != null ? (String)billing_address.get('address_1') : '') +' '+((String)billing_address.get('address_2') != null ? (String)billing_address.get('address_2') : ''),
                    BillingCity = (String)billing_address.get('city') != null ? (String)billing_address.get('city') : '',
                    BillingState = (String)billing_address.get('state') != null ? (String)billing_address.get('state') : '',
                    BillingPostalCode = (String)billing_address.get('pin_code') != null ? (String)billing_address.get('pin_code') : '',
                    ShippingCountry = (String)billing_address.get('country') != null ? (String)billing_address.get('country') : 'India',
                    ShippingStreet = ((String)shipping_address.get('address_1') != null ? (String)shipping_address.get('address_1') : '') +' '+ ((String)shipping_address.get('address_2') != null ? (String)shipping_address.get('address_2') : ''),
                    ShippingCity = (String)shipping_address.get('city') != null ? (String)shipping_address.get('city') : '',
                    ShippingState = (String)shipping_address.get('state') != null ? (String)shipping_address.get('state') : '',
                    ShippingPostalCode = (String)shipping_address.get('pin_code') != null ? (String)shipping_address.get('pin_code') : ''
                );
                Update newAccount;

                List<Opportunity> OpportunityList = [SELECT Id, Name, Type, StageName, CloseDate 
                                     FROM Opportunity 
                                     WHERE AccountId = :accountId 
                                     AND StageName != 'Closed Won' 
                                     ORDER BY CreatedDate DESC 
                                     LIMIT 1];

                    if (!OpportunityList.isEmpty()) {
                        for (Opportunity opp : OpportunityList) {
                            opp.Name = (String) requestMap.get('full_name');
                            opp.Type = 'Existing Business';
                            opp.StageName = 'New';
                            opp.CloseDate = Date.today();
                        }
                        update OpportunityList;
                    }

            }
            
            response.put('status', 'Success');
            
            response.put('accountId', accountId);
            res.statusCode = 200; 
            res.responseBody = Blob.valueOf(JSON.serialize(response));
            
            Integration_Log__c  logObj = new Integration_Log__c(
                Integration_Type__c = 'Account Registration',
                Request_Payload__c = JSON.seriaLizePretty(requestMap),
                Response_Payload__c = JSON.seriaLizePretty(response),
                Status__c = 'Success'
            );
            Insert logObj;
            system.debug('Log created>>'+logObj);
        }
        catch(exception e){
            
            system.debug('Exception occured: '+e);
            response.put('status', 'Failed');
            res.statusCode = 500; 
            res.responseBody = Blob.valueOf('Exception: '+e.getMessage());
            
            Integration_Log__c  logObj = new Integration_Log__c(
                Integration_Type__c = 'Account Registration',
                Request_Payload__c = JSON.seriaLizePretty(requestMap),
                Response_Payload__c = JSON.seriaLizePretty(res),
                Error_Message__c = 'Exception: '+e.getMessage(),
                Status__c = 'Failed'
            );
            Insert logObj;
            system.debug('Log created exception>>'+logObj);
            
        }
    }
    
    Global class CommonException extends Exception {}
}