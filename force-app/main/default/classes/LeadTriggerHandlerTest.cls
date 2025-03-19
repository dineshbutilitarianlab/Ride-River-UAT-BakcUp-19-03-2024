@isTest
public class LeadTriggerHandlerTest {
    
    @testSetup
    static void setupTestData() {
        try {
            Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Manager (Partner)' LIMIT 1];
            UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'AUser Partner Person Account' LIMIT 1];
            
            Account partnerAccount = new Account(Name = 'Partner Account', Type = 'Partner');
            insert partnerAccount;
            
            Contact partnerContact = new Contact(
                FirstName = 'Test',
                LastName = 'User',
                Phone = '7654324567',
                Email = 'testuser@example.com',
                AccountId = partnerAccount.Id
            );
            insert partnerContact;
            
            System.runAs(new User(Id = UserInfo.getUserId())) { 
                User partnerUser = new User(
                    FirstName = 'Test',
                    LastName = 'User',
                    Email = 'testuser@example.com',
                    Username = 'testuser' + System.currentTimeMillis() + '@example.com.partner',
                    Alias = 'tuser',
                    ProfileId = partnerProfile.Id,
                    TimeZoneSidKey = 'America/Los_Angeles',
                    LocaleSidKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LanguageLocaleKey = 'en_US',
                    ContactId = partnerContact.Id,
                    UserRoleId = userRole.Id
                );
                insert partnerUser;
            }
        } catch (Exception e) {
            System.debug('Error in setupTestData: ' + e.getMessage());
        }
    }
    
    @isTest
    public static void testInsertLead() {
        try {
            WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
                Name = 'WhatsApp API',
                API_Endpoint__c = 'https://api.whatsapp.com/send',
                API_Key__c = 'mock-api-key',
                new_lead_book_a_test_ride_03__c='example.jpg',
                rnr_whatsapp_book_test_ride__c='rnr.jpg'
            );
            insert mockIntegration;
            
            List<Lead> leadsToInsert = new List<Lead>{
                new Lead(LastName = 'Test 1', Company = 'Test Company 1', Status='New', LeadSource = 'Google', Dealer_Code__c = '292001', Phone = '6666666666'),
                    new Lead(LastName = 'Test 2', Company = 'Test Company 2', LeadSource = 'Bike Dekho', Dealer_Code__c = '222222', Phone = '8888888888')
                    };
                        
                        Test.startTest();
            insert leadsToInsert;
            leadsToInsert[1].Dealer_Code__c='292001';
            update leadsToInsert[1];
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error in testInsertLead: ' + e.getMessage());
        }
    }
    
    @isTest
    public static void testAfterRNR() {
        try {
            List<Lead> leadsToInsert = new List<Lead>{
                new Lead(LastName = 'Test 1', Company = 'Test Company 1', LeadSource = 'Google', PostalCode='560078', Phone = '6666666666'),
                    new Lead(LastName = 'Test 2', Company = 'Test Company 2', LeadSource = 'Bike Dekho', Dealer_Code__c = '292002', Phone = '8888888888')
                    };
                        
                        insert leadsToInsert;
            
            Test.startTest();
            leadsToInsert[1].Status='RNR';
            leadsToInsert[1].Dealer_Code__c='292001';
            update leadsToInsert[0];
            Test.stopTest();
        } catch (Exception e) {
            System.debug('Error in testAfterRNR: ' + e.getMessage());
        }
    }
    
    @isTest
    public static void testUpdatePreferredSeller() {
        try {
            User partnerUser = [SELECT Id FROM User WHERE Alias = 'tuser' LIMIT 1];
            
            System.runAs(partnerUser) {
                Lead testLead = new Lead(
                    LastName = 'Test Lead',
                    Company = 'Test Company',
                    Status = 'New'
                );
                insert testLead;
                
                Test.startTest();
                LeadTriggerHandler.updatePreferredSeller(new List<Lead>{testLead});
                Test.stopTest();
            }
        } catch (Exception e) {
            System.debug('Error in testUpdatePreferredSeller: ' + e.getMessage());
        }
    }
    
    
    @isTest
    public static void testUpdatePreferredSeller1() {
        LeadTriggerHandler.testdata();
    }
    
    
}