public class CreateReceiptRtoInsuranceController {
    
    Public Date currentDate {get;set;}
    Public Order order{get;set;}
    Public string inWords{get;set;}
    Public string invoiceId{get;set;}
    Public string height{get;set;}
    Public string DealerName{get;set;}
    public Integer rowCount { get; set; }
    Public Decimal TotalAmount{get;set;}
    public DateTime currentTime { get; set; }
    Public Contact contact{get;set;}
    public Company_Details__mdt compDetails{get;set;}
    list<Order> ordersToUpdate = new List<Order>();
    
    Public CreateReceiptRtoInsuranceController(ApexPages.StandardController controller){
         
        try{
            
           
            Id orderId = controller.getId();
            compDetails = [SELECT Id, DeveloperName, Account_Number__c, Bank_Name__c, Beneficiary_Name__c, CIN__c, Contact__c,
                           Email__c, GST__c, IFSC__c, PAN__c, Swift_Code__c 
                           FROM Company_Details__mdt 
                           WHERE DeveloperName='River_Mobility_Private_Limited' LIMIT 1];
            
            //Id MstrId= ApexPages.currentPage().getParameters().get('id');
            order= [SELECT Id,AccountId, OrderNumber, Invoice_No__c, BillingCity, Dealer__c, BillingCountry, BillingPostalCode, BillingState, BillingStreet, ShippingCity,Website_Order_Id__c,Approval_Status__c,
                    ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, RTO_Charges__c, Handling_Charges__c, Insurance_Amount__c, Warranty_Amount__c,
                    Account.Name, Name,Account.Phone,Account.Email__c, Account.BillingCity,Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet,                
                    Extended_Warranty__c, Grand_Total__c, Total_Amount_paid__c, Remaining_Amount__c,
                    Dealer__r.CIN__c, Dealer__r.RR_Customer_Care_Email__c, Dealer__r.RR_Customer_HelpLine_Number__c, Dealer__r.Email__c,  Dealer__r.GSTIN_Number__c,  Dealer__r.Phone, 
                    Dealer__r.BillingCity, Dealer__r.BillingCountry, Dealer__r.BillingPostalCode, Dealer__r.BillingState, Dealer__r.BillingStreet, Dealer__r.Name
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
            
            currentDate = Date.today();
            
             System.debug('order # 1 === >'+order);
            //InvoiceId generation
            If(order.Website_Order_Id__c != null){
                Integer stringLength = order.Website_Order_Id__c.length();        
                invoiceId = 'RVRE'+ order.Website_Order_Id__c.substring(stringLength - 4, stringLength)+'RTO';
                System.debug('invoiceId ==>'+invoiceId);
            }
            else{
                invoiceId = order.OrderNumber;
                System.debug('invoiceId ==>'+invoiceId);
            }
            /*
            else{
                System.debug('order # 2 === >'+order.Name.length());
                Integer stringLength = order.Name.length();
                invoiceId = 'RVRE'+ order.Name.substring(stringLength - 4, stringLength)+'RTO';
            }
            */
           /*  if (invoiceId != null) {
                    order.RTO_Receipt_Number__c = invoiceId;
                    ordersToUpdate.add(order);
                }*/
            //Time calculation
            DateTime currentDateTime = System.now();
            
            // Set the time zone to Indian Standard Time (IST)
            TimeZone istTimeZone = TimeZone.getTimeZone('Asia/Kolkata');
            currentTime = currentDateTime.addSeconds(istTimeZone.getOffset(currentDateTime) / 1000);
            
            //height calculation
            
            If((order.Insurance_Amount__c != null && order.Insurance_Amount__c != 0 ) && (order.RTO_Charges__c != null && order.RTO_Charges__c != 0)){
                rowCount = 2;
            }else If((order.Insurance_Amount__c != null && order.Insurance_Amount__c != 0 ) || (order.RTO_Charges__c != null && order.RTO_Charges__c != 0)){
                rowCount = 1;
            }else{
                rowCount = 1;
            }
            
            height = string.valueOf(180 - (rowCount*20 - 1))+'px';
            
            TotalAmount = 0;        
            
            TotalAmount = (order.Insurance_Amount__c != null?order.Insurance_Amount__c:0) +(order.RTO_Charges__c != null?order.RTO_Charges__c:0) ;
            TotalAmount = TotalAmount.setscale(2);
            
            
            inWords = CurrencyToWordsInRupees.convertToWords(TotalAmount);
            
            
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        
        
    }
       /* public void updateOrder() {
        try {
            if (!ordersToUpdate.isEmpty()) {
                System.debug('ordersToUpdate==>'+ordersToUpdate);
                update ordersToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error during update: ' + e.getMessage());
        }
    }*/

    
}