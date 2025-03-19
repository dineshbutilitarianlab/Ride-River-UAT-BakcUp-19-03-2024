public class PreOrderReceiptController {

 
    Public OrderItem orderItem{get;set;}
    Public DateTime currentDate {get;set;}
    Public Order order{get;set;}
    Public string inWords{get;set;}
    Public Decimal Gst{get;set;}
    Public Contact contact{get;set;}
    Public string DealerName{get;set;}
    public Company_Details__mdt compDetails{get;set;}
    
    Public PreOrderReceiptController(ApexPages.StandardController controller){
        
        Id orderId = controller.getId(); 
        
        compDetails = [SELECT Id, DeveloperName, Account_Number__c, Bank_Name__c, Beneficiary_Name__c, CIN__c, Contact__c,
                       Email__c, GST__c, IFSC__c, PAN__c, Swift_Code__c 
                       FROM Company_Details__mdt 
                       WHERE DeveloperName='River_Mobility_Private_Limited' 
                       LIMIT 1];
        
        //Id MstrId= ApexPages.currentPage().getParameters().get('id');
        order= [SELECT Id,AccountId, Invoice_No__c, OrderNumber, Website_Order_Id__c, Booking_Payment_Id__c, createdDate, Booking_Amount__c, BillingCity, BillingCountry, BillingPostalCode, 
                BillingState, BillingStreet, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                Dealer__r.Center_Code__c, Dealer__r.Name, Dealer__r.BillingCity,Dealer__r.BillingCountry, Dealer__r.BillingPostalCode, Dealer__r.BillingState, Dealer__r.BillingStreet, Internal_Purchase__c,
                 Dealer__r.CIN__c, Dealer__r.RR_Customer_Care_Email__c, Dealer__r.RR_Customer_HelpLine_Number__c, Dealer__r.Email__c,  Dealer__r.GSTIN_Number__c,  Dealer__r.Phone,
                Dealer__r.Beneficiary_Name__c, Dealer__r.Account_Number__c, Dealer__r.Bank_Name__c, Dealer__r.Swift_Code__c, Dealer__r.IFSC__c, Dealer__r.PAN_Number__c
                FROM Order 
                WHERE Id=:orderId ]; 
        
        DealerName = order.Dealer__r.Name.toUpperCase();
        
        List<Contact> contacts = [SELECT Id, Name, Email, Phone, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet   
                   FROM Contact 
                   WHERE AccountId = :order.AccountId AND Primary_Contact__c = true 
                   LIMIT 1];
        
        If(contacts.size()>0){
            contact = contacts[0];
        }
        
        
        currentDate = order.createdDate;
        currentDate = currentDate.addHours(5);
        currentDate = currentDate.addMinutes(30);
        
        orderItem = [SELECT Id,  Quantity, UnitPrice, TotalPrice, Description, Order.Invoice_No__c,Product2.Name,Product2.Colour__c, Product2.Description, Product2.ModelName 
                     FROM OrderItem 
                     WHERE OrderId = :orderId 
                     AND Type__c = 'Vehicle' 
                     LIMIT 1]; 
        
    }

}