@IsTest
public class GenericClassTest {
    
    @IsTest
    static void testCheckStatePicklistvalue() {
        // Initialize the necessary data
        // Create user with different state values for testing
        User userWithState1 = new User(
            FirstName = 'Test',
            LastName = 'User1',
            Email = 'testuser1@example.com',
            Username = 'testuser1@example.com' + System.currentTimeMillis(),
            Alias = 'tuser1',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0].Id,
            LanguageLocaleKey = 'en_US',
            statecode = 'KARNATAKA'
        );

        User userWithState2 = new User(
            FirstName = 'Test',
            LastName = 'User2',
            Email = 'testuser2@example.com',
            Username = 'testuser2@example.com' + System.currentTimeMillis(),
            Alias = 'tuser2',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'][0].Id,
            LanguageLocaleKey = 'en_US',
            statecode = 'NY'
        );

        insert new List<User> { userWithState1, userWithState2 };

        // Test case 1: Same state codes
        Test.startTest();
        Boolean result = GenericClass.checkStatePicklistvalue('CA', 'CA');
        Test.stopTest();
        System.assert(result == true, 'Expected sameState to be true for same state codes');

        // Test case 2: Same state names
        Test.startTest();
        result = GenericClass.checkStatePicklistvalue('California', 'California');
        Test.stopTest();
        System.assert(result == true, 'Expected sameState to be true for same state names');

        // Test case 3: Different state codes and names
        Test.startTest();
        result = GenericClass.checkStatePicklistvalue('CA', 'NY');
        Test.stopTest();
        System.assert(result == false, 'Expected sameState to be false for different state codes');

        // Test case 4: State code and state name (same state)
        Test.startTest();
        result = GenericClass.checkStatePicklistvalue('CA', 'California');
        Test.stopTest();
        System.assert(result == true, 'Expected sameState to be true for state code and state name of the same state');

        // Test case 5: State name and state code (same state)
        Test.startTest();
        result = GenericClass.checkStatePicklistvalue('New York', 'NY');
        Test.stopTest();
        System.assert(result == true, 'Expected sameState to be true for state name and state code of the same state');

        // Test case 6: Non-matching state name and state code
        Test.startTest();
        result = GenericClass.checkStatePicklistvalue('California', 'NY');
        Test.stopTest();
        System.assert(result == false, 'Expected sameState to be false for non-matching state name and state code');
    }
    
    @IsTest
    static void testGetStateValue() {
        // Test the getStateValue method to ensure it returns the correct maps
        GenericClass.StateWrapper stateWrapper = GenericClass.getStateValue();
        
        System.assert(stateWrapper != null, 'Expected stateWrapper to be not null');
        System.assert(stateWrapper.stateCodeToNameMap != null, 'Expected stateCodeToNameMap to be not null');
        System.assert(stateWrapper.stateNameToCodeMap != null, 'Expected stateNameToCodeMap to be not null');
        
        // Verify that known state values are in the maps
        System.assert(stateWrapper.stateCodeToNameMap.containsKey('ca'), 'Expected stateCodeToNameMap to contain "ca"');
        System.assert(stateWrapper.stateNameToCodeMap.containsKey('california'), 'Expected stateNameToCodeMap to contain "california"');
    }
}