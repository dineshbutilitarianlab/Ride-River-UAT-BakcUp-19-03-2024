public class CreateReceiptPaymentsController {
    
    public string fileName{get;set;}
    Public date currentReportDate{get;set;}
    Public Payment__c payment{get;set;}
    Public string amtInWords{get;set;}
    public string cash{get;set;}
    Public Order Order{get;set;}
    Public Order_Payment__c op{get;set;}
    public datetime currenttime {get;set;}
    Public string DealerName{get;set;}
    
    Public CreateReceiptPaymentsController(ApexPages.StandardController controller){
        
        currentReportDate = system.today();
        id paymentId = controller.getId();
        currenttime = system.now();
        currenttime = currenttime.addHours(5);
        currenttime = currenttime.addMinutes(30);
        
        op = [SELECT Id, Amount1__c, Order__r.Remaining_Amount__c,Order__r.Grand_Total__c, Order__r.Total_Amount_paid__c,Payments__c, Order__r.Dealer__c,
              Order__r.Dealer__r.Name, Order__r.Dealer__r.BillingStreet, Order__r.Dealer__r.BillingCity, Order__r.Dealer__r.BillingState, 
              Order__r.Dealer__r.BillingPostalCode, Order__r.Dealer__r.BillingCountry, Order__r.Dealer__r.Phone, Order__r.Account.Name,
              Order__r.RTO_Charges__c, Order__r.Handling_Charges__c, Order__r.Insurance_Amount__c
              FROM Order_Payment__c 
              WHERE Id = :paymentId];
        
        DealerName = op.Order__r.Dealer__c != null? op.Order__r.Dealer__r.Name.toUpperCase():'River Mobility';

        payment = [SELECT id,Amount__c,Customer_Name__c,Description__c,Email__c,Mode_Of_Payment__c,Phone__c,CreatedDate,Name,Transaction_Id__c, 
                   Cheque_Number__c, payment_Date__c  
                   FROM Payment__c 
                   WHERE Id = :op.Payments__c];     
        
                
        amtInWords = CurrencyToWordsInRupees.convertToWords(payment.Amount__c);
        payment.payment_Date__c = payment.payment_Date__c.addHours(5).addMinutes(30);
        cash = '';
        If(payment.Mode_Of_Payment__c == 'Cash'){
            cash = 'Yes';
        }
    }  
}