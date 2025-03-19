@isTest
public class LeadConvertController_Test {

  @istest
    Public static void convertLeadtest(){
        Account Acc=new Account(Name='test');
        insert Acc;
        Contact Con=new Contact(LastName='test',Phone='9686112211',AccountId=Acc.Id);
        insert Con;
          lead l=new lead();
        l.LastName='test1234';
        l.FirstName='test';
        l.Salutation='Mr.';
        l.LeadSource='BikeWale';
        l.Phone='8373879087';
        l.Company='tcs';
           l.City='KA';
        l.Country='India';
        l.State='Karnataka';
        l.Street='test';
        l.PostalCode='560036';
        Insert l;
        list<Lead> llist=new list<Lead>();
        llist.add(l);
        LeadConvertController.convertLead(l.Id,Acc.Id,Con.Id,true);
        LeadConvertController.getLeadDetails(l.Id);
        LeadConvertController.setAccountTypeCustomer(llist);
    }
}