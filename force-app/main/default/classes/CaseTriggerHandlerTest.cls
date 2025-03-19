@isTest
public class CaseTriggerHandlerTest {
    @isTest
    public static void caseMethod(){
        Account acc = new Account();
        acc.Name = 'Testings Account';
        acc.Phone = '1234567890';
        acc.Email__c = 'testas@test.com';
        acc.Type = 'Customer';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Testing Acc Account';
        acc1.Phone = '1234567822';
        acc1.Email__c = 'test123aa4@test.com';
        acc1.Type = 'Dealer';
        acc1.Center_Code__c = '291002';
        acc1.CIN__c = 'U34100KA2022PTC158972';
        acc1.BillingCountry = 'India';
        acc1.BillingCity = 'Ward No 82, 664, 100ft Road';
        acc1.BillingPostalCode = '560038';
        acc1.BillingState = 'Karnataka';
        insert acc1;
        
        Case cse1 = new Case();
        cse1.Origin = 'Email';
        cse1.Subject = 'Email';
        cse1.description = 'Email';
        cse1.AccountId = acc.Id;
        cse1.Assign_to_Dealer__c = acc1.id;
        cse1.Vehicle_Registration_Number__c = '123456';
        cse1.Status = 'Closed';
        cse1.Case_Type__c = 'Urgent Complaint';
        cse1.Escalations_Team_Contact__c = '9035224444';
        cse1.Closed_Resolution__c = 'testing abcdefhghiiadlsajdlks abcdefhghiiadlsajdlks';
        Insert cse1;
        
        cse1.Status = 'RNR';
        cse1.Case_Type__c = 'PSFU Concerns';
        update cse1;
        
        CaseTriggerHandler.fakeMethod();

    }
    
    
    
}