@RestResource(urlMapping='/AccountCheck/*')
global with sharing class AccountCheckAPI {

    @HttpGet
    global static Boolean checkAccount() {
        try {
            String accountId = RestContext.request.params.get('AccountId');
            
            if (accountId == null || accountId.trim() == '') {
                throw new IllegalArgumentException('AccountId parameter is missing.');
            }
            
            // Query the account
            List<Account> accountRecords = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
            
            // Return true if the account exists, otherwise false
            return !accountRecords.isEmpty();
        } catch (Exception e) {
            
            // Log the exception for debugging purposes
            System.debug('Error: ' + e.getMessage());
            return false;
        }
    }
}