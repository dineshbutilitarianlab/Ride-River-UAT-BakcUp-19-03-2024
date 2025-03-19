public class Insurance_Invoice_PDF_Controller {
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    public WorkOrder workOrderRecord {get; set;}
    public List<WorkOrderLineItem> workOrderLineItemList {get; set;}
    public List<WorkPlan> workPlansItemList {get; set;}

    // Part Summary Fields
    public decimal partTotal {get; set;}
    public decimal partDiscount {get; set;}
    public decimal parttaxValue {get; set;}
    public decimal partCGST {get; set;}
    public decimal partSGST {get; set;}
    public decimal partIGST {get; set;}

    // Labour Summary Fields
    public decimal labourTotal {get; set;}
    public decimal labourDiscount {get; set;}
    public decimal labourtaxValue {get; set;}
    public decimal labourCGST {get; set;}
    public decimal labourSGST {get; set;}
    public decimal labourIGST {get; set;}

    public decimal partsTotal {get; set;}
    public decimal laboursTotal {get; set;}
    public decimal invoiceTotal {get; set;}
    public String invoiceTotalInWords {get; set;}


    public Insurance_Invoice_PDF_Controller(ApexPages.StandardController controller) {
        workOrderRecord = new WorkOrder();
        workOrderLineItemList = new List<WorkOrderLineItem>();
        workPlansItemList = new List<WorkPlan>();

        // part summary fields
        partTotal = 0;
        partDiscount = 0;
        parttaxValue = 0;
        partCGST = 0;
        partSGST = 0;
        partIGST = 0;

        // Labour summary fields
        labourTotal = 0;
        labourDiscount = 0;
        labourtaxValue = 0;
        labourCGST = 0;
        labourSGST = 0;
        labourIGST = 0;

        partsTotal = 0;
        laboursTotal = 0;
        invoiceTotal = 0;
        invoiceTotalInWords = '';

        String workOrderId = Apexpages.currentPage().getParameters().get('id');
        List<WorkOrder> workOrderList = [Select Id,CreatedDate,EndDate,Service_Center__r.Name ,Service_Center__r.GSTIN_Number__c,Service_Center__r.ShippingStreet,Service_Center__r.ShippingCity,Service_Center__r.ShippingState,Service_Center__r.ShippingCountry,Service_Center__r.ShippingPostalCode, Invoice_No__c, WorkOrderNumber, Invoice_Date__c, Account.ShippingState,Account.Name,Status,Service_Center__r.Center_Code__c,
                                        Vehicle__r.Insurance__r.Name,Vehicle__r.Policy_Number__c, Vehicle__r.EngineNumber,Invoice_Type__c,Vehicle__r.isCustomerStateSame__c,Odometer_Reading__c,
                                        Vehicle__r.VehicleIdentificationNumber,Vehicle__r.Name,Vehicle__r.VehicleRegistrationNumber,Vehicle__r.LastOdometerReading,toLabel(RR_Job_Type__c),
                                        Vehicle__r.Dealer__r.Name,Vehicle__r.Dealer__r.ShippingStreet,Vehicle__r.Dealer__r.GSTIN_Number__c,Vehicle__r.Insurance__r.Address__City__s, Vehicle__r.Insurance__r.Address__CountryCode__s, 
                                        Vehicle__r.Insurance__r.Address__Street__s, Vehicle__r.Insurance__r.Address__StateCode__s, Vehicle__r.Insurance__r.Address__PostalCode__s,
                                        Vehicle__r.Insurance__r.GSTIN_Number__c,Vehicle__r.CurrentOwner.Name,Vehicle__r.CurrentOwner.GSTIN_Number__c,Vehicle__r.CurrentOwner.ShippingStreet,RR_Service_Advisor__r.Name,toLabel(RR_Service_Advisor__r.ResourceType)
                                        From WorkOrder Where Id = :workOrderId Limit 1];
        
        if(workOrderList != null && workOrderList.size() > 0) {
            workOrderRecord = workOrderList[0];
            workOrderLineItemList = [Select Id, WorkOrderId, ParentWorkOrderLineItemId, Product2Id, AssetId, OrderId, RootWorkOrderLineItemId, Description, 
                                    StartDate, EndDate, Status, PricebookEntryId, Quantity, UnitPrice, Discount, ListPrice, Subtotal, TotalPrice, Duration, 
                                    DurationType, DurationInMinutes, WorkTypeId, Street, City, State, PostalCode, Country, Latitude, Longitude, GeocodeAccuracy, 
                                    Address, ServiceTerritoryId, Subject, StatusCategory, IsClosed, Priority, ServiceAppointmentCount, LocationId, Total_Amount__c, 
                                    Inventory_Lot__c, Product_Available__c, Stage__c, RR_Parts_Category__c, RR_Product__c, RR_Product__r.Name, RR_Product__r.HSN_Code__c,
                                    RR_Product__r.IGST_Percentage__c,RR_Product__r.CGST_Percentage__c, RR_Product__r.SGST_Percentage__c, IGST_Amount__c, CGST_Amount__c, SGST_Amount__c, Amount__c, Unit_of_Measurement__c 
                                    from WorkOrderLineItem where WorkOrderId =:workOrderRecord.Id AND RR_Parts_Category__c = 'Insurance'];

            workPlansItemList    =  [Select Id, Name, WorkOrderId,Description, WorkOrderLineItemId, WorkPlanTemplateId, ParentRecordId, ParentRecordType, Contact__c, Duration_Hour__c,
                                    Duration_Min__c, RR_Labour_Category__c, Labour_Charge__c, RR_Labour_Code__r.RR_Labour_Charge__c, Status__c, Work_Type__c, Estimate_Duration_Type__c, Estimated_Duration__c,
                                    RR_Labour_Code__c,RR_Labour_Code__r.Code, RR_Labour_Code__r.IGST_Percentage__c, RR_Labour_Code__r.SGST_Percentage__c, RR_Labour_Code__r.CGST_Percentage__c, IGST_Amount__c, CGST_Amount__c, SGST_Amount__c, Amount__c
                                    from WorkPlan Where WorkOrderId =:workOrderRecord.Id AND RR_Labour_Category__c = 'Insurance'];

            
            if(workOrderLineItemList != null && workOrderLineItemList.size() > 0){
                for(WorkOrderLineItem workItem : workOrderLineItemList){
                    if(workItem.Quantity != null && workItem.UnitPrice != null){
                        partTotal += (workItem.Quantity * workItem.UnitPrice);
                    }
                    if(workItem.Discount != null){
                        partDiscount += workItem.Subtotal * workItem.Discount/100;
                    }
                    if(workItem.TotalPrice != null){
                        parttaxValue += workItem.TotalPrice;
                    }
                    if(workItem.IGST_Amount__c != null){
                        partIGST += workItem.IGST_Amount__c;
                    }
                    if(workItem.CGST_Amount__c != null){
                        partCGST += workItem.CGST_Amount__c;
                    }
                    if(workItem.SGST_Amount__c != null){
                        partSGST += workItem.SGST_Amount__c;
                    }
                }
            }

            if(workPlansItemList != null && workPlansItemList.size() > 0){
                for(WorkPlan workItem : workPlansItemList){
                    if(workItem.Labour_Charge__c != null){
                        labourTotal += workItem.Labour_Charge__c;
                        labourtaxValue += workItem.Labour_Charge__c;
                    }
                    if(workItem.IGST_Amount__c != null){
                        labourIGST += workItem.IGST_Amount__c;
                    }
                    if(workItem.CGST_Amount__c != null){
                        labourCGST += workItem.CGST_Amount__c;
                    }
                    if(workItem.SGST_Amount__c != null){
                        labourSGST += workItem.SGST_Amount__c;
                    }
                }
            }
            partsTotal      += parttaxValue + ((workOrderRecord.Vehicle__r.isCustomerStateSame__c == true) ? (partCGST + partSGST) : partIGST);
            laboursTotal    += labourtaxValue + ((workOrderRecord.Vehicle__r.isCustomerStateSame__c == true) ? (labourCGST + labourSGST) : labourIGST);
            invoiceTotal    = partsTotal + laboursTotal;
            invoiceTotalInWords = NumberToWords.convertNumberToText(invoiceTotal);
        }
    }
}