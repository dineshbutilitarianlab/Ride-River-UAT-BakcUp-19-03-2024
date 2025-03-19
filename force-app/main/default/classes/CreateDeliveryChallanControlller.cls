/******************************************************************************
* Class Name: CreateDeliveryChallanControlller
* Created by : Sudarshan N B - 1/10/23
* Last Modified By : Sudarshan N B - 24/07/2024
* Description : Controller to generate a receipt for Vehicle
*****************************************************************************/


public class CreateDeliveryChallanControlller {
    
  Public List<OrderItem> orderItemList{get;set;}
    Public Date currentDate {get;set;}
    Public Order order{get;set;}
    Public string inWords{get;set;}
    Public string invoiceId{get;set;}
    Public Contact contact{get;set;}
    public decimal tax{get;set;}
    Public string DealerName{get;set;}
    public Company_Details__mdt compDetails{get;set;}
    Public string state{get;set;}
    Public Decimal calcValue { get; set; }
    Public Decimal calcValue1 { get; set; }
    Public Decimal calcValue2 { get; set; }
    Public Decimal calcValue3 { get; set; }
    Public Decimal trcalcValue1 { get; set; }
    Public Decimal trcalcValue2 { get; set; }
    Public Decimal trcalcValue3 { get; set; }
    Public Decimal trcalcValue { get; set; }
    Public Decimal tValueAftGST { get; set; }
    Public Decimal DiscountOnEx { get; set; }
    Public Decimal Fame { get; set; }
    Public Decimal sSubsidy { get; set; }
    Public Decimal offerAmount { get; set; }
    Public Decimal NetAmount { get; set; }
    public string AccState{get;set;}
    public boolean sameState{get;set;}
    public Decimal cgstPercentage{get;set;}
    public Decimal sgstPercentage{get;set;}
    public Decimal igstPercentage{get;set;}
    public Decimal trcgstPercentage{get;set;}
    public Decimal trsgstPercentage{get;set;}
    public Decimal trigstPercentage{get;set;}
    
    Public CreateDeliveryChallanControlller(ApexPages.StandardController controller){
        
        cgstPercentage = 2.5;
        sgstPercentage = 2.5;
        igstPercentage = 5;
        
        Id orderId = controller.getId();
        system.debug('orderId==>'+orderId);
        
        compDetails = [SELECT Id, DeveloperName, Account_Number__c, Bank_Name__c, Beneficiary_Name__c, CIN__c, Contact__c,
                       Email__c, GST__c, IFSC__c, PAN__c, Swift_Code__c FROM Company_Details__mdt WHERE DeveloperName='River_Mobility_Private_Limited' LIMIT 1];
        
        //Id MstrId= ApexPages.currentPage().getParameters().get('id');
        order= [SELECT Id,AccountId, OrderNumber, BillingCity, BillingCountry, Dealer__c, BillingPostalCode, BillingState, BillingStreet, ShippingCity,Website_Order_Id__c,Approval_Status__c,
                ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, RTO_Charges__c, Handling_Charges__c, Insurance_Amount__c, Warranty_Amount__c,
                Account.Name, Account.Phone,Account.Email__c, Account.BillingCity,Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet,
                Assigned_Vehicle__r.VehicleIdentificationNumber, Assigned_Vehicle__r.VehicleDefinition.ModelCode, Assigned_Vehicle__r.EngineNumber, Assigned_Vehicle__r.Colour__c,
                Assigned_Vehicle__r.VehicleDefinition.Battery_Name__c,Assigned_Vehicle__r.VehicleDefinition.Battery_Quantity__c,Assigned_Vehicle__r.VehicleDefinition.BatteryCapacity,
                Assigned_Vehicle__r.Name, Finance__r.Name, Assigned_Vehicle__r.VehicleDefinition.Battery_Capacity__c, Assigned_Vehicle__r.Vehicle_Details__c, Dealer__r.Name, Dealer__r.Center_Code__c,
                Dealer__r.BillingCity,Dealer__r.BillingCountry, Dealer__r.BillingPostalCode, Dealer__r.BillingState, Dealer__r.BillingStreet,	Transportation_Charges__c,Internal_Purchase__c,
                Discount_on_Ex_Showroom_Price__c, Subsidy_Amount__c, State_Govt_Subsidy__c, Offers_Amount__c,
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
        
        sameState = true;
        
        If(order.Dealer__c != null && order.Dealer__r.BillingState != null){
            state = order.Dealer__r.BillingState.toLowerCase();
        }else If(order.BillingState != null){
            state = order.BillingState.toLowerCase();
        }else If(order.Account.BillingState != null){
            state = order.Account.BillingState.toLowerCase();
        }else{
            state = 'ka';
        }

        
        If(order.Account.BillingState != null){
            AccState = order.Account.BillingState.toLowerCase();
        }else If(contact != null && contact.MailingState != null && Contact.MailingState != ''){
            AccState = contact.MailingState.toLowerCase();
        }else{
            AccState = state;
        }
        
        If(AccState != state){
            sameState = GenericClass.checkStatePicklistvalue(AccState, state);
        }
        
        currentDate = Date.today();
        
        orderItemList = [SELECT Id, HSN_Code__c, Quantity, UnitPrice, TotalPrice, Description, Order.Invoice_No__c,Charger_Included__c, Product2.CGST_Percentage__c, Product2.IGST_Percentage__c, Product2.SGST_Percentage__c
                         FROM OrderItem 
                         WHERE Type__c = 'Vehicle' AND OrderId = :orderId]; 
                
        //InvoiceId generation
        string invoicesequence = System.currentPageReference().getParameters().get('sequence');
        String dateString = System.currentPageReference().getParameters().get('date');
        
        if (dateString != null) {
            currentDate = Date.parse(dateString);
        } else {
            currentDate = Date.today();
        }

        If(invoicesequence != null && invoicesequence != ''){
            invoiceId = invoicesequence;
        }else{
            invoiceId = 'RV_INVOICE_VH';
        }
        
        
        System.debug('invoiceId>>'+invoiceId);
        
        decimal trpCharges = order.Transportation_Charges__c == Null? 0: order.Transportation_Charges__c;
        
        tValueAftGST = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice + trpCharges : 0;
        DiscountOnEx = order.Discount_on_Ex_Showroom_Price__c != null ? order.Discount_on_Ex_Showroom_Price__c : 0;
        Fame = order.Subsidy_Amount__c != null ? order.Subsidy_Amount__c : 0;
        sSubsidy = order.State_Govt_Subsidy__c != null ? order.State_Govt_Subsidy__c : 0;
        offerAmount = order.Offers_Amount__c != null ? order.Offers_Amount__c : 0;
        NetAmount = tValueAftGST - DiscountOnEx - Fame - sSubsidy - offerAmount;
        
        cgstPercentage = orderItemList.size() > 0 && orderItemList[0].Product2Id != null && orderItemList[0].Product2.CGST_Percentage__c != null? (orderItemList[0].Product2.CGST_Percentage__c): 2.5;
        sgstPercentage = orderItemList.size() > 0 && orderItemList[0].Product2Id != null && orderItemList[0].Product2.SGST_Percentage__c != null? (orderItemList[0].Product2.SGST_Percentage__c): 2.5;
        igstPercentage = orderItemList.size() > 0 && orderItemList[0].Product2Id != null && orderItemList[0].Product2.IGST_Percentage__c != null? (orderItemList[0].Product2.IGST_Percentage__c): 5;
        
        trcgstPercentage = 2.5;
        trsgstPercentage = 2.5;
        trigstPercentage = 5;
        
        system.debug('cgstPercentage>>'+cgstPercentage);
        system.debug('sgstPercentage>>'+sgstPercentage);
        system.debug('igstPercentage>>'+igstPercentage);
        
        List<Tax_Detail__mdt> taxMetadata = [SELECT Id, DeveloperName, CGST__c, SGST__c, IGST__c FROM Tax_Detail__mdt WHERE DeveloperName = 'Transportation_Charges_Tax'];
        
        If(taxMetadata.size() > 0){
            trcgstPercentage = taxMetadata.size()>0 && taxMetadata[0].CGST__c != null? taxMetadata[0].CGST__c : 2.5;
            trsgstPercentage = taxMetadata.size()>0 && taxMetadata[0].SGST__c != null? taxMetadata[0].SGST__c : 2.5;
            trigstPercentage = taxMetadata.size()>0 && taxMetadata[0].IGST__c != null? taxMetadata[0].IGST__c : 5;
        }
        
        // Total amount calculation
        if (!order.Internal_Purchase__c) {
            
            if (!sameState) {
                //calcValue1 = orderItemList != null && orderItemList.size() > 0 ? ((orderItemList[0].TotalPrice)-(orderItemList[0].TotalPrice/ (igstPercentage/100+1))).setScale(2) : 0;
                //calcValue1 = orderItemList != null && orderItemList.size() > 0 ? ((orderItemList[0].TotalPrice)-(orderItemList[0].TotalPrice/ (igstPercentage/100+1))).setScale(2) : 0;
                calcValue1 = orderItemList != null && orderItemList.size() > 0 ? ((orderItemList[0].TotalPrice)*(igstPercentage/100)).setScale(2) : 0;
                calcValue2 = 0;
                calcValue3 = 0;
                
                trcalcValue1 = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c - (order.Transportation_Charges__c/(trigstPercentage/100+1))).setScale(2) : 0;
                trcalcValue2 = 0;
                trcalcValue3 = 0;
                
            } else {
                
               // Decimal unitprice = orderItemList != null && orderItemList.size() > 0 ? (orderItemList[0].TotalPrice/ (((cgstPercentage+sgstPercentage)/100)+1)).setScale(2) : 0;
                Decimal unitprice = orderItemList != null && orderItemList.size() > 0 ? (orderItemList[0].TotalPrice).setScale(2) : 0;
                system.debug('unitprice(base price)>>'+unitprice);
                                                                                         
                calcValue1 = 0;
                calcValue2 = unitprice * (cgstPercentage/100);
                                                                                         
                system.debug('calcValue2(>>'+calcValue2);                                                                
                calcValue3 = unitprice * (sgstPercentage/100);
                system.debug('calcValue3(>>'+calcValue3); 
                
                system.debug('order.Transportation_Charges__c(>>'+order.Transportation_Charges__c); 
                Decimal transunitprice = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c/ (((trcgstPercentage+trsgstPercentage)/100)+1)).setScale(2) : 0;
                
                   system.debug('transunitprice(>>'+transunitprice);  
                
                trcalcValue1 = 0;
                trcalcValue2 = transunitprice * (trcgstPercentage/100);
                trcalcValue3 = transunitprice * (trsgstPercentage/100);
                
                system.debug('trcalcValue2(>>'+trcalcValue2);
                system.debug('trcalcValue3(>>'+trcalcValue3);
            }
            
            trcalcValue = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c - (trcalcValue1+trcalcValue2+trcalcValue3)).setScale(2) : 0;
            
        } else {
            
            trcalcValue =  order.Transportation_Charges__c != null ? order.Transportation_Charges__c : 0;
            
            calcValue1 = 0;
            calcValue2 = 0;
            calcValue3 = 0;
            
            trcalcValue1 = 0;
            trcalcValue2 = 0;
            trcalcValue3 = 0;
        }
        
       /* if (!order.Internal_Purchase__c) {
            calcValue = orderItemList != null && orderItemList.size() > 0 ? (orderItemList[0].UnitPrice - (calcValue1 + calcValue2 + calcValue3)).setScale(2) : 0;
        }else{
            calcValue = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice : 0;
        } */
        
	if (!order.Internal_Purchase__c) {
    calcValue = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice.setScale(2) : 0;
        tValueAftGST = calcValue + (calcValue1 + calcValue2 + calcValue3);
         NetAmount = tValueAftGST - DiscountOnEx - Fame - sSubsidy - offerAmount;
	}else{
    calcValue = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice : 0;
          tValueAftGST = calcValue ;
         NetAmount = tValueAftGST - DiscountOnEx - Fame - sSubsidy - offerAmount;
}
        
        //taxableAmount = TotalAmount.setScale(2) - Gst.setScale(2) - Gst.setScale(2);
        inWords = CurrencyToWordsInRupees.convertToWords(NetAmount);
        
    }
}