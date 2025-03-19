/*---------------------------------------------------------------------------------------------
        
        * Class Name: CreateReceiptAccessories
        * Created by : Sudarshan N B - 1/10/23
        * Last Modified By : Sudarshan N B - 28/1/24
        * Description : To generate a receipt for Accessories
        ***************************************************************************/
        /******************************************************************************
        * Class Name: CreateReceiptAccessories
        * Last Modified By : Prathap KR - 06/10/24
        * Description : Annual offer 6000 on Accessories
        ***************************************************************************/
        
        
        
        
        
        public class CreateReceiptAccessoriesController {
            
            public List<OrderItem> orderItemList{get;set;}
            public Date currentDate {get;set;}
            public Order order{get;set;}
            public string inWords{get;set;}
            public string invoiceId{get;set;}
            public string DealerName{get;set;}
            public Integer rowCount { get; set; }
            public string height{get;set;}
            public Decimal Gst{get;set;}
            public Decimal taxableAmount{get;set;}
            public Decimal TotalAmount{get;set;}
            public Decimal discountDifference{get;set;}
            public Contact contact{get;set;}
            public Company_Details__mdt compDetails{get;set;}
            public decimal tax{get;set;}
            public string state{get;set;}
            public string AccState{get;set;}
            public boolean sameState{get;set;}
            public string finalAmount{get;set;}
            public Decimal discountAmount{get;set;}
            public decimal defaultDiscount = 0;
        
            public CreateReceiptAccessoriesController(ApexPages.StandardController controller){
                Id orderId = controller.getId();
                compDetails = [SELECT Id, DeveloperName, Account_Number__c, Bank_Name__c, Beneficiary_Name__c, CIN__c, Contact__c, Email__c, GST__c, IFSC__c, PAN__c, Swift_Code__c 
                               FROM Company_Details__mdt 
                               WHERE DeveloperName='River_Mobility_Private_Limited' 
                               LIMIT 1];
                
                order = [SELECT Id, AccountId, OrderNumber, BillingCity, Dealer__c, BillingCountry, BillingPostalCode, BillingState, BillingStreet, ShippingCity, 
                         Website_Order_Id__c, Approval_Status__c, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, RTO_Charges__c, Handling_Charges__c, 
                         Insurance_Amount__c, Warranty_Amount__c, Internal_Purchase__c, Account.Name, Account.Phone, Account.Email__c, Account.BillingCity, 
                         Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet, Extended_Warranty__c, Dealer__r.Name, 
                         Dealer__r.Center_Code__c, Dealer__r.BillingCity, Dealer__r.BillingCountry, Dealer__r.BillingPostalCode, Dealer__r.BillingState, 
                         Dealer__r.BillingStreet, Dealer__r.CIN__c, Dealer__r.RR_Customer_Care_Email__c, Dealer__r.RR_Customer_HelpLine_Number__c, 
                         Dealer__r.Email__c, Dealer__r.GSTIN_Number__c, Dealer__r.Phone, Dealer__r.Beneficiary_Name__c, Dealer__r.Account_Number__c, 
                         Dealer__r.Bank_Name__c, Dealer__r.Swift_Code__c, Dealer__r.IFSC__c, Dealer__r.PAN_Number__c, Accessories_Discount_Amount__c, 
                         Accessories_Discount_Description__c,Merchandise_Additional_Discount__c,Total_Merchandise_Disccount__c 
                         FROM Order 
                         WHERE Id=:orderId ];
                
                DealerName = order.Dealer__r.Name.toUpperCase();
                
                List<Contact> contacts = [SELECT Id, Name, Email, Phone, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet 
                                         FROM Contact 
                                         WHERE AccountId = :order.AccountId AND Primary_Contact__c = true 
                                         LIMIT 1];
                
                if(contacts.size()>0){
                    contact = contacts[0];
                }
                
                sameState = true;
                
                if(order.Dealer__c != null && order.Dealer__r.BillingState != null){
                    state = order.Dealer__r.BillingState.toLowerCase();
                }else if(order.BillingState != null){
                    state = order.BillingState.toLowerCase();
                }else if(order.Account.BillingState != null){
                    state = order.Account.BillingState.toLowerCase();
                }else{
                    state = 'ka';
                }
                
                if(order.Account.BillingState != null){
                    AccState = order.Account.BillingState.toLowerCase();
                }else if(contact != null && contact.MailingState != null && Contact.MailingState != ''){
                    AccState = contact.MailingState.toLowerCase();
                }else{
                    AccState = state;
                }
                
                if(AccState != state){
                    sameState = GenericClass.checkStatePicklistvalue(AccState, state);
                }
                
                orderItemList = [SELECT Id, Quantity, UnitPrice, TotalPrice, Description, Order.Invoice_No__c, Product2.Name, Product2.Description, 
                                 Product2.HSN_Code__c, Product2Id, Product2.CGST_Percentage__c, Product2.IGST_Percentage__c, Product2.SGST_Percentage__c 
                                 FROM OrderItem 
                                 WHERE Type__c != 'Vehicle' AND Type__c != 'Add-ons' AND Type__c != 'Extended Warranty' AND OrderId = :orderId];
                 //InvoiceId generation
            string invoicesequence = System.currentPageReference().getParameters().get('sequence');
            If(invoicesequence != null && invoicesequence != ''){
                invoiceId = invoicesequence;
            }else{
                invoiceId = 'RV_PREINVOICE_AC';
            }
            System.debug('invoiceId>>'+invoiceId);
            
            String dateString = System.currentPageReference().getParameters().get('date');
            if (dateString != null) {
                currentDate = Date.parse(dateString);
            } else {
                currentDate = Date.today();
            }
            
            //Total calculations
            TotalAmount = 0;
            taxableAmount = 0;
             Gst = 0;       
            For(OrderItem item : orderItemList){
                System.debug('Order item - > '+item);
                Decimal cgstPercentage = item.Product2Id != null && item.Product2.CGST_Percentage__c != null? (item.Product2.CGST_Percentage__c): 2.5;
                Decimal sgstPercentage = item.Product2Id != null && item.Product2.SGST_Percentage__c != null? (item.Product2.SGST_Percentage__c): 2.5;
                Decimal igstPercentage = item.Product2Id != null && item.Product2.IGST_Percentage__c != null? (item.Product2.IGST_Percentage__c): 5;
                If(item.Product2Id != null){
                    item.Product2.CGST_Percentage__c = cgstPercentage;
                    item.Product2.SGST_Percentage__c = sgstPercentage;
                    item.Product2.IGST_Percentage__c = igstPercentage;
                }
                decimal gstPercent = 18;
                If(sameState){
                    gstPercent = cgstPercentage + sgstPercentage;
                    item.Product2.IGST_Percentage__c = gstPercent;
                }else{
                    gstPercent = igstPercentage; 
                }
                TotalAmount = TotalAmount+item.TotalPrice;
                if((TotalAmount>order.Accessories_Discount_Amount__c || order.Accessories_Discount_Amount__c!= 0) ||  (TotalAmount>order.Total_Merchandise_Disccount__c && order.Total_Merchandise_Disccount__c !=0)){
                    System.debug('order.Accessories_Discount_Amount__c + order.Total_Merchandise_Disccount__c - > '+order.Accessories_Discount_Amount__c + order.Total_Merchandise_Disccount__c);
                   // discountAmount = order.Accessories_Discount_Amount__c - order.Merchandise_Additional_Discount__c + order.Total_Merchandise_Disccount__c;
                   discountAmount = order.Accessories_Discount_Amount__c + order.Total_Merchandise_Disccount__c; 
                } else{
                    
                    discountAmount = 0;
                }
                if(order.Accessories_Discount_Amount__c== null ||  order.Total_Merchandise_Disccount__c== null){
                     discountAmount = 0;
                }
                
              
                If(!order.Internal_Purchase__c){
                    //decimal price = item.UnitPrice/(1+gstPercent/100);
                    decimal price = item.UnitPrice;
                    item.UnitPrice = price;
  					Gst +=   ((item.UnitPrice*item.Quantity * (gstPercent/200)));
           	   		Gst = Gst.setScale(2);
                 
                }
             
			  taxableAmount = taxableAmount +(item.UnitPrice*item.Quantity);
               
            }
            rowCount = orderItemList.size();
            height = string.valueOf(200 - (rowCount*20 - 1))+'px';
            TotalAmount = (TotalAmount+Gst+Gst);
            taxableAmount= taxableAmount.setScale(2);
            Gst= Gst.setScale(2);
            taxableAmount = (TotalAmount).setScale(2);
            
                     
               
            // Calculate remaining amount after accessories discount
            Decimal accessoriesDiscount = order.Accessories_Discount_Amount__c != null ? order.Accessories_Discount_Amount__c : 0;
            Decimal merchandiseDiscount = order.Total_Merchandise_Disccount__c != null ? order.Total_Merchandise_Disccount__c : 0;    
            
                 system.debug('Total Amount is'+TotalAmount);
                system.debug('Merchandise Amount is'+merchandiseDiscount);
                system.debug('accessoriesDiscount  Amount is'+accessoriesDiscount);
                
                if (TotalAmount > accessoriesDiscount || TotalAmount > merchandiseDiscount ) {
           
                
                TotalAmount = TotalAmount - ( merchandiseDiscount + accessoriesDiscount);
               	TotalAmount = TotalAmount.round();
            } else {
                discountDifference = (accessoriesDiscount+ merchandiseDiscount) - TotalAmount;
                TotalAmount = 0;
            }
            
            // Format TotalAmount to display 0.00 instead of .00
           if (TotalAmount == 0) {
                TotalAmount = 0;
                inWords = '0.00';
                finalAmount = '0.00';
            } else {
                inWords = CurrencyToWordsInRupees.convertToWords(TotalAmount);
                finalAmount = String.valueOf(TotalAmount).replace('.00', '0.00');
            }
        
            }
            
        	

 public PageReference save(){
 
    return null;
}
   }