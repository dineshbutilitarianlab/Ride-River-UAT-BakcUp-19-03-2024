public class OtherInvoicePdfController {
    Public List<OrderItem> orderItemList{get;set;}
    Public Date currentDate {get;set;}
    Public Order order{get;set;}
    Public string inWords{get;set;}
    Public string invoiceId{get;set;}
    Public Contact contact{get;set;}
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
    
    public decimal discountInvoice { get; set; }
    public decimal orderItemUP { get; set; }
    public decimal calculatedPercentageAmount { get; set; }
    
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
    public List<Attachment> QRAtt {get;set;}
    public DeliveryChallanPDF__mdt dcPdf { get; set; }
    public Bill_To_Addresse__mdt bOAPdf { get; set; }
    
    public string dodoAccName { get; set; }
    public string dodoBillCityName { get; set; }
    public string dodoBillStateName { get; set; }
    public string dodoBillPostalCode { get; set; }
    public string dodoBillEmail { get; set; }
    public String dodoPhone { get; set; }
    public string cocoBillEmail { get; set; }
    public String cocoPhone { get; set; }
    public String cocoCIN { get; set; }
    
    public Decimal totalValueAfterGST { get; set; }
    public String storeType { get; set; }
    
    public String getFormattedBillingStreet() {
        return order.Dealer__r.BillingStreet != null ? order.Dealer__r.BillingStreet.replace('\n', '<br/>') : '';
    }
    public String getFormattedAccountBillingStreet() {
        return order.Account.BillingStreet != null ? order.Account.BillingStreet.replace('\n', '<br/>') : '';
    }
    public String getFormattedIRN() {
        if (order.IRN_No__c != null) {
            Integer midPoint = Math.ceil(order.IRN_No__c.length() / 2).intValue();
            return order.IRN_No__c.substring(0, midPoint) + '<br/>' + order.IRN_No__c.substring(midPoint);
        }
        return '';
    }
    
    Public OtherInvoicePdfController(ApexPages.StandardController controller){
        try{
            dcPdf = [SELECT Id, CIN__c, Company_Email__c, Company_Phone__c, Company_Website__c, CompanyName__c, Factory_Address__c, Former_Address__c, GST__c, Registered_Office__c,  Bill_From__c, Bill_To__c, PartA__c, Small_CName__c   FROM DeliveryChallanPDF__mdt] ;
            cgstPercentage = 2.5;
            sgstPercentage = 2.5;
            igstPercentage = 5;
            totalValueAfterGST = 0;
            
            Id orderId = controller.getId();
            system.debug('orderId==>'+orderId); 
            compDetails = [SELECT Id, DeveloperName, Account_Number__c, Bank_Name__c, Beneficiary_Name__c, CIN__c, Contact__c, Email__c, GST__c, IFSC__c, PAN__c, Swift_Code__c FROM Company_Details__mdt WHERE DeveloperName='River_Mobility_Private_Limited' LIMIT 1];
            order= [SELECT Id,AccountId, OrderNumber, BillingCity, BillingCountry, Dealer__c, BillingPostalCode, BillingState, BillingStreet, ShippingCity,Website_Order_Id__c,Approval_Status__c,
                    ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet, RTO_Charges__c, Handling_Charges__c, Insurance_Amount__c, Warranty_Amount__c,
                    Account.Name, Account.Phone,Account.Email__c, Account.BillingCity,Account.BillingCountry, Account.BillingPostalCode, Account.BillingState, Account.BillingStreet,
                    Assigned_Vehicle__r.VehicleIdentificationNumber, Assigned_Vehicle__r.VehicleDefinition.ModelCode, Assigned_Vehicle__r.EngineNumber, Assigned_Vehicle__r.Colour__c,
                    Assigned_Vehicle__r.VehicleDefinition.Battery_Name__c,Assigned_Vehicle__r.VehicleDefinition.Battery_Quantity__c,Assigned_Vehicle__r.VehicleDefinition.BatteryCapacity,
                    Assigned_Vehicle__r.Name, Finance__r.Name, Assigned_Vehicle__r.VehicleDefinition.Battery_Capacity__c, Assigned_Vehicle__r.Vehicle_Details__c, Dealer__r.Name, Dealer__r.Center_Code__c,
                    Dealer__r.BillingCity,Dealer__r.BillingCountry, Dealer__r.BillingPostalCode, Dealer__r.BillingState, Dealer__r.BillingStreet,	Transportation_Charges__c,Internal_Purchase__c,
                    Discount_on_Ex_Showroom_Price__c, Subsidy_Amount__c, State_Govt_Subsidy__c, Offers_Amount__c,
                    Dealer__r.CIN__c, Dealer__r.RR_Customer_Care_Email__c, Dealer__r.RR_Customer_HelpLine_Number__c, Dealer__r.Email__c,  Dealer__r.GSTIN_Number__c,  Dealer__r.Phone,
                    Dealer__r.Beneficiary_Name__c, Dealer__r.Account_Number__c, Dealer__r.Bank_Name__c, Dealer__r.Swift_Code__c, Dealer__r.IFSC__c, Dealer__r.PAN_Number__c,
                    IRN_No__c, Account.GSTIN_Number__c,  Dealer__r.Store_Type__c FROM Order  WHERE Id=:orderId ]; 
            
                    if (order.Dealer__r.Store_Type__c != null) {
                        if (order.Dealer__r.Store_Type__c == 'DODO') {
                            storeType = 'DODO';
                            dodoAccName = order.Dealer__r.Name;
                            dodoBillCityName = order.Dealer__r.BillingCity != null ? order.Dealer__r.BillingCity : '';
                            dodoBillStateName = order.Dealer__r.BillingState;
                            dodoBillPostalCode = order.Dealer__r.BillingPostalCode;
                            dodoBillEmail = order.Dealer__r.Email__c;
                            dodoPhone = order.Dealer__r.Phone;
                        } else if (order.Dealer__r.Store_Type__c == 'COCO') {
                            dodoAccName = 'RIVER MOBILITY PRIVATE LIMITED';
                            storeType = 'COCO';
                            dodoBillCityName = order.Dealer__r.BillingCity;
                            dodoBillStateName = order.Dealer__r.BillingState;
                            dodoBillPostalCode = order.Dealer__r.BillingPostalCode;
                            cocoBillEmail = system.Label.COCOEmail;
                            cocoPhone = System.label.COCOPhone;
                            cocoCIN = System.label.COCOCIN;
                        }
                    }
            
            DealerName = order.Dealer__r.Name != null ? order.Dealer__r.Name.toUpperCase() : '';
            System.debug('DealerName::>>' + DealerName);
            List<Contact> contacts = [SELECT Id, Name, Email, Phone, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet FROM Contact  WHERE AccountId = :order.AccountId AND Primary_Contact__c = true   LIMIT 1];
            If(contacts.size()>0){
                contact = contacts[0];
            }else{
                System.debug('Contact not found ==>');
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
                System.debug('samestate---'+sameState);
            }
            
            currentDate = Date.today();
            System.debug('Order Id---' + orderId);
            
            orderItemList = [SELECT Id, HSN_Code__c, Quantity, UnitPrice, TotalPrice, Description, Order.Invoice_No__c,Charger_Included__c, Product2.CGST_Percentage__c,  Product2.IGST_Percentage__c, Product2.SGST_Percentage__c, OrderItemNumber, Product2.Name, Product2.Merchandise_discount_price__c, Discounted_Amount_on_Merchandise__c FROM OrderItem  WHERE  OrderId = :orderId]; 
            
            for (OrderItem oi : orderItemList) {
                if (oi.Product2 != null) {
                    if(!sameState){
                        Decimal igstAmount = (oi.UnitPrice * oi.Quantity * oi.Product2.IGST_Percentage__c) / 100;
                        Decimal taxableAmount = (oi.UnitPrice * oi.Quantity) - oi.Discounted_Amount_on_Merchandise__c;
                        totalValueAfterGST += taxableAmount + igstAmount;
                        System.debug('totalValueAfterGST::::>>' + totalValueAfterGST);
                    }
                    else{
                        Decimal cgstAmount = (oi.UnitPrice * oi.Quantity * oi.Product2.CGST_Percentage__c) / 100;
                        Decimal sgstAmount = (oi.UnitPrice * oi.Quantity * oi.Product2.SGST_Percentage__c) / 100;
                        Decimal taxableAmount = (oi.UnitPrice * oi.Quantity) - oi.Discounted_Amount_on_Merchandise__c;
                        totalValueAfterGST += taxableAmount + cgstAmount + sgstAmount;
                    }
                }
            }
            System.debug('totalValueAfterGST::::>>' + totalValueAfterGST);
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
            System.debug('trpCharges>>'+trpCharges);
            
            discountInvoice = (orderItemList[0].UnitPrice * orderItemList[0].Quantity) - orderItemList[0].Discounted_Amount_on_Merchandise__c;
            System.debug('discountInvoice::>>' + discountInvoice);
            
            //totalAmountInvoice = (orderItemList[0].UnitPrice - discountInvoice)  * orderItemList[0].Quantity;
            tValueAftGST = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice + trpCharges- discountInvoice : 0;
            DiscountOnEx = order.Discount_on_Ex_Showroom_Price__c != null ? order.Discount_on_Ex_Showroom_Price__c : 0;
            Fame = order.Subsidy_Amount__c != null ? order.Subsidy_Amount__c : 0;
            sSubsidy = order.State_Govt_Subsidy__c != null ? order.State_Govt_Subsidy__c : 0;
            offerAmount = order.Offers_Amount__c != null ? order.Offers_Amount__c : 0;
            //NetAmount = tValueAftGST.round() - DiscountOnEx - Fame - sSubsidy - offerAmount;
            calculatedPercentageAmount = 0;
            NetAmount = totalValueAfterGST.round() - DiscountOnEx - Fame - sSubsidy - offerAmount;
            NetAmount = NetAmount.round();
            
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
                    calcValue1 = orderItemList != null && orderItemList.size() > 0 ? ((orderItemList[0].TotalPrice)*(igstPercentage/100)) : 0;
                    
                    System.debug('calcValue1 =>' + calcValue1);
                    calcValue2 = 0;
                    calcValue3 = 0;
                    
                    trcalcValue1 = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c - (order.Transportation_Charges__c/(trigstPercentage/100+1))) : 0;
                    System.debug('trcalcValue1>>'+trcalcValue1);
                    trcalcValue2 = 0;
                    trcalcValue3 = 0;
                    
                } else {
                    
                    // Decimal unitprice = orderItemList != null && orderItemList.size() > 0 ? (orderItemList[0].TotalPrice/ (((cgstPercentage+sgstPercentage)/100)+1)).setScale(2) : 0;
                    Decimal unitprice = orderItemList != null && orderItemList.size() > 0 ? (orderItemList[0].TotalPrice): 0;
                    system.debug('unitprice(base price)>>'+unitprice);
                    
                    calcValue1 = 0;
                    calcValue2 = discountInvoice * (cgstPercentage/100);
                    
                    system.debug('calcValue2(>>'+calcValue2);                                                                
                    calcValue3 = discountInvoice * (sgstPercentage/100);
                    system.debug('calcValue3(>>'+calcValue3); 
                    
                    system.debug('order.Transportation_Charges__c(>>'+order.Transportation_Charges__c); 
                    Decimal transunitprice = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c/ (((trcgstPercentage+trsgstPercentage)/100)+1)).setScale(2) : 0;
                    
                    system.debug('transunitprice(>>'+transunitprice);  
                    
                    trcalcValue1 = 0;
                    trcalcValue2 = transunitprice * (trcgstPercentage/100);
                    trcalcValue3 = transunitprice * (trsgstPercentage/100);
                    
                    system.debug('trcalcValue2(>>'+trcalcValue2);
                    system.debug('trcalcValue3(>>'+trcalcValue3);
                    
                    calculatedPercentageAmount = discountInvoice + calcValue2 + calcValue3;
                    System.debug('calculatedPercentageAmount::>>' + calculatedPercentageAmount);
                }
                trcalcValue = order.Transportation_Charges__c != null ? (order.Transportation_Charges__c - (trcalcValue1+trcalcValue2+trcalcValue3)): 0;
            } else {
                
                trcalcValue =  order.Transportation_Charges__c != null ? order.Transportation_Charges__c : 0;
                calcValue1 = 0;
                calcValue2 = 0;
                calcValue3 = 0;
                
                trcalcValue1 = 0;
                trcalcValue2 = 0;
                trcalcValue3 = 0;
            }
            if (!order.Internal_Purchase__c) {
                calcValue = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice : 0;
                System.debug('calcValue:::>>>'+calcValue);
                tValueAftGST = calcValue + (calcValue1 + calcValue2 + calcValue3) - discountInvoice;
                //NetAmount = (tValueAftGST.round()  - DiscountOnEx - Fame - sSubsidy - offerAmount).round();
                NetAmount = totalValueAfterGST.round() - DiscountOnEx - Fame - sSubsidy - offerAmount;
            }else{
                calcValue = orderItemList != null && orderItemList.size() > 0 ? orderItemList[0].UnitPrice : 0;
                System.debug('else calcValue:::>>>'+calcValue);
                tValueAftGST = calcValue.round() - discountInvoice;
                NetAmount = totalValueAfterGST.round() - DiscountOnEx - Fame - sSubsidy - offerAmount;
                //NetAmount = (tValueAftGST- DiscountOnEx - Fame - sSubsidy - offerAmount).round();
            }
            
            //taxableAmount = TotalAmount.setScale(2) - Gst.setScale(2) - Gst.setScale(2);
            inWords = CurrencyToWordsInRupees.convertToWords(NetAmount);
        }
        catch(Exception e){
            System.debug('Error Occured===>>'+e.getMessage()+'And Error occured in Line Number====>'+e.getLineNumber());
        }
    }
}