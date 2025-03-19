@IsTest
private class AccountCheckAPITest {
    @IsTest
    static void testAccountExists() {
        // Create a test account
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        // Simulate a REST API call
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AccountCheck';
        req.httpMethod = 'GET';
        req.addParameter('AccountId', testAccount.Id);
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Boolean result = AccountCheckAPI.checkAccount();
        
    }
    
    @IsTest
    static void testAccountDoesNotExist() {
        // Simulate a REST API call
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AccountCheck';
        req.httpMethod = 'GET';
        req.addParameter('AccountId', '001FakeAccountId0000');
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Boolean result = AccountCheckAPI.checkAccount();
        
    }
    
        @IsTest
    static void testMissingAccountId() {
        // Simulate a REST API call without AccountId parameter
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AccountCheck';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;

        // Call the method
        Boolean result = AccountCheckAPI.checkAccount();
        System.assertEquals(false, result, 'Should return false when AccountId is missing');
    }
}