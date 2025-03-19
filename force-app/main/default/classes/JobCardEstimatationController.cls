public class JobCardEstimatationController {

    public String Owner { get; set; }

    public String user { get; set; }
	public List<string> getOL(){

        List<String> listStr = new List<String>();
        liststr.add('The provided estimation is valid for 5 days from the date of provision.');
        liststr.add('River Mobility Reserves the right to modify the price at any time without prior intimation.');
        liststr.add('This is an estimation hence the actuals may vary.');
        liststr.add('All disputes are subject to Bangalore jurisdiction.');
        return listStr;
    }
    
    public Vehicle vehicle {get; set;}
    public List<WorkOrderLineItem> workOrderLineItems{get; set;}
    public List<WorkPlan> workPlans{get; set;}
	public Account account{get; set;}
	public Contact contact{get; set;}
    public WorkOrder workOrder{get; set;}
    public List<RR_Customer_Voice__c> customerVoices{get; set;}
    public Decimal grandTotal{get; set;}
    public Decimal totalOfWorkPlans{get; set;}
    public Decimal total{get; set;}
    public String lastOdoMeterReading{get; set;}
    public String formattedAddress { get; set; }
    
    public JobCardEstimatationController() {
        String workOrderId = ApexPages.currentPage().getParameters().get('id');
        

        WorkOrder workOrder = [SELECT Id,createdDate,Service_Center__r.Name,Service_Center__r.Center_Code__c,Company__c, Estimate_No__c,WorkOrderNumber, Vehicle__r.Name, Vehicle__r.EngineNumber,Vehicle__r.isCustomerStateSame__c, Service_Center__c, Service_Center__r.BillingState,
                                    Vehicle__r.Dealer__r.name,Vehicle__r.Policy_Number__c, Account.Name, Contact.Name, Account.ShippingCity, Account.BillingState, Contact.MailingState, State, Same_State__c,
                                    Account.ShippingCountry,Account.ShippingPostalCode, Account.ShippingState, Account.ShippingStreet, Account.Phone, Odometer_Reading__c,
                                    Vehicle__r.LastOdometerReading, Vehicle__r.VehicleIdentificationNumber, Vehicle__r.VehicleRegistrationNumber,
                                    Vehicle__r.ChassisNumber, Vehicle__r.Insurance__r.Name,Vehicle__r.Dealer__r.Center_code__c,Vehicle__r.Dealer__r.ShippingState,
                                    Policy_Number__c, RR_Job_Type__c,RR_Estimated_Delivery_Time__c, (SELECT Id, Name FROM Customer_Voices__r),
                                    (SELECT Id, Labour_Charge__c, RR_Labour_Code__r.RR_Labour_Charge__c, RR_Labour_Code__r.Code, Name, Work_Type__c,RR_Labour_Code__r.IGST_Percentage__c,
                                    RR_Labour_Code__r.SGST_Percentage__c, RR_Labour_Code__r.CGST_Percentage__c, IGST_Amount__c, CGST_Amount__c, SGST_Amount__c, HSN_Code__c,Amount__c, Duration_Hour__C, 
                                    Duration_Min__c,RR_Labour_Category__c, Discount__c FROM WorkPlans WHERE RR_Labour_Category__c IN ('Paid', 'Insurance')), (SELECT Id, LineItemNumber, Quantity, UnitPrice,Discount,
									Product2.Name,PricebookEntry.Product2.Name,PricebookEntry.Product2.SGST_Percentage__c, PricebookEntry.Product2.IGST_Percentage__c, PricebookEntry.Product2.CGST_Percentage__c, Product2.HSN_Code__c,
                                    Product2.SGST_Percentage__c, Product2.CGST_Percentage__c,Product2.IGST_Percentage__c, CGST_Amount__c, SGST_Amount__c,IGST_Amount__c,
									Amount__c,TotalPrice,HSN_Code__c,Unit_of_Measurement__c,total_amount__c,RR_Parts_Category__c,Subtotal FROM WorkOrderLineItems WHERE RR_Parts_Category__c IN ('Paid', 'Insurance'))
                                    FROM WorkOrder WHERE Id = :workOrderId LIMIT 1];
                                        /*System.debug('Name----------------->'+workOrder.WorkOrderLineItems[0].PricebookEntry.Product2.Name);
                                        System.debug('CGST----------------->'+workOrder.WorkOrderLineItems[0].PricebookEntry.Product2.CGST_Percentage__c);
                                        System.debug('SGST----------------->'+workOrder.WorkOrderLineItems[0].PricebookEntry.Product2.SGST_Percentage__c);
                                        System.debug('IGST----------------->'+workOrder.WorkOrderLineItems[0].PricebookEntry.Product2.IGST_Percentage__c);*/
                                        
                                  
            this.workOrder = workOrder;
            this.vehicle = workOrder.Vehicle__r;
            this.account = workOrder.Account;
            this.contact = workOrder.Contact;
            this.workOrderLineItems = workOrder.WorkOrderLineItems != null ? workOrder.WorkOrderLineItems : new List<WorkOrderLineItem>();
			this.workPlans = workOrder.WorkPlans != null ? workOrder.WorkPlans : new List<WorkPlan>();
			this.customerVoices = workOrder.Customer_Voices__r != null ? workOrder.Customer_Voices__r : new List<RR_Customer_Voice__c>();
            this.lastOdoMeterReading = workOrder.Odometer_Reading__c == NULL ? '':String.valueOf(workOrder.Odometer_Reading__c.setScale(2)).replaceAll('\\B(?=(\\d{3})+(?!\\d))', ',');
            
            this.grandTotal = 0;
            this.total = 0;
            if(workOrderLineItems.size() > 0) {
                for(WorkOrderLineItem item : workOrderLineItems) {
                    this.total += item.amount__c;
                }
            }
            
            this.totalOfWorkPlans = 0;
            if(workPlans.size() > 0) {
                for(WorkPlan item : workPlans) {
                    this.totalOfWorkPlans += item.Amount__c;
                }
            }
            
            this.grandTotal = this.total + this.totalOfWorkPlans; 
            
            this.formattedAddress = formatAddress(
                account.ShippingStreet,
                account.ShippingCity,
                account.ShippingPostalCode,
                account.ShippingState,
                account.ShippingCountry
			);
        
    } 
    
    public static String formatAddress(String shippingStreet, String shippingCity, String shippingPostalCode, String shippingState, String shippingCountry) {
        String formattedAddress = '';
        Integer maxLength = 20;
        
        // Null checks for each input parameter
        if (shippingStreet != null) {
            // Split the shipping street into lines with maximum 30 characters each
            List<String> streetLines = new List<String>();
            while (shippingStreet.length() > maxLength) {
                streetLines.add(shippingStreet.substring(0, maxLength));
                shippingStreet = shippingStreet.substring(maxLength);
            }
            streetLines.add(shippingStreet); // Add the remaining part
            
            // Concatenate the street lines with <br/>
            formattedAddress = String.join(streetLines, '<br/>') + '<br/>';
        }
        
        // Concatenate city, postal code, state, and country, with null checks
        if (shippingCity != null) {
            formattedAddress += shippingCity;
        }
        if (shippingPostalCode != null) {
            formattedAddress += ' ' + shippingPostalCode;
        }
        if (shippingState != null) {
            formattedAddress += ', ' + shippingState;
        }
        if (shippingCountry != null) {
            formattedAddress += '<br/>' + shippingCountry;
        }
        
        return formattedAddress;
    }

}