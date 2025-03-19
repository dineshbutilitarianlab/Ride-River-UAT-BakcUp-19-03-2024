public class JC_InternalCopyFrontController {

    public String selectedValue { get; set; } 
   	public List<Integer> numbers { get; set; }
    public List<Integer> termNumbers { get; set; }
    Public boolean AccessoriesAdded {get;set;}
    Public List<Term_Condition_JC__mdt> terms{get;set;}
    Public WorkOrder Jobcard {get;set;} 
    Public List<RR_Customer_Voice__c> voices {get;set;}
    Public Date currentdate{get;set;}
    Public Company_Details__mdt compDetails{get;set;}
    public Integer rating { get; set; }
    public Integer rowcount { get; set; }
    public Integer LaboursRowcount { get; set; }
    public List<integer> rectangles { get; set; }
    Public List<WorkOrderLineItem> parts {get;set;} 
    Public List<WorkPlan> plans {get;set;} 
    public List<RR_Additional_Job_Recommended__c> additionalJobs{get;set;}
    Public contact conDetails {get;set;}
    
    public JC_InternalCopyFrontController(ApexPages.StandardController controller) {
        
        Id jobId = controller.getId();
        
        rating = 0; 
        List<integer> rectangle = new List<integer>();
        for(Integer i=1; i<=10; i++) {
            rectangle.add(i);
        }
        rectangles = rectangle;
        currentdate = system.Today();
        
        compDetails = [SELECT Id, DeveloperName,  Customer_Care_Email__c, Customer_HelpLine_Number__c, Company_Name__c, Timings__c
                       FROM Company_Details__mdt 
                       WHERE DeveloperName='River_Mobility_Private_Limited' LIMIT 1];
        
        terms = [SELECT Id, SI_No__c, Term_Condition__c FROM Term_Condition_JC__mdt ORDER BY SI_No__c ASC];
        
        Jobcard	= [SELECT Id, WorkOrderNumber, Vehicle__r.VehicleIdentificationNumber, Vehicle__r.VehicleRegistrationNumber, Vehicle__r.EngineNumber, Vehicle__r.ModelName, Vehicle__r.Purchased_Date__c, Vehicle__r.LastOdometerReading, Vehicle__r.CurrentOwnerId,
                   Contact.Name, Contact.Email, Contact.Phone, Contact.MailingState, contact.MailingStreet, Contact.MailingCountry, Contact.MailingPostalCode, Contact.Mailingcity,Vehicle__r.RR_Battery_Number__c,Vehicle__r.IgnitionKeyCode,
                   RR_Rear_View_Mirror__c, RR_Tool_Kit__c, RR_Battery_Number__c, RR_Key_Code__c, RR_Vehicle_Document__c, RR_First_Aid_Kit__c, RR_Charger__c, RR_Personal_Belongings__c, Odometer_Reading__c,
                   RR_Non_OE_Acc_Fitted_checkbox__c, RR_Non_OE_Acc_Fitted__c, RR_Job_Type__c, RR_Estimated_Delivery_Time__c, RR_SOC__c , RR_SOC_Level__c, RR_Other_Observations__c,RR_Estimated_Cost__c,
                   Service_Center__r.Name, Service_Center__r.BillingCity,  Service_Center__r.BillingState, Service_Center__r.BillingStreet, Service_Center__r.BillingCountry, Service_Center__r.BillingPostalCode,
                   RR_Service_Advisor__c, RR_Service_Advisor__r.RelatedRecord.Name, RR_Service_Advisor__r.RelatedRecord.Email, RR_Service_Advisor__r.RelatedRecord.Phone, Service_Center__r.RR_Customer_Care_Email__c, 
                   Service_Center__r.RR_Customer_HelpLine_Number__c, Service_Center__r.OperatingHours.Description,Estimation_Bill__c, RR_Technician__c, StartDate, EndDate, RR_Technician__r.Name,
                   RR_Brake_Play__c, RR_Brake_Oil_Level__c, RR_Brake_Pads__c, RR_Brake_Sponginess__c, feedback_mail__c, RR_Fork_Seal__c, RR_GUI_Checks__c, Re_Work_Details__c, RR_Rear_Axle_Nut__c,
                   RR_Scratches_Damages__c, RR_Socket_Cover_Opening__c, RR_Steering_Top_Nut__c, RR_Suspnsion_Play__c, RR_Tank_Badge__c, RR_Tyre_Condition__c, RR_Tyre_Pressure__c, RR_Brake_Bedding_Operation__c,
                   RR_Charging_Status_bar_indication_check__c, RR_Check_all_requested_work_completed__c, RR_Check_for_outstanding_Fault_Codes__c, RR_Check_for_steering_wobble__c, RR_Electrical_Component_Functioning__c,
                   RR_Ensure_latest_Firmware_is_flashed__c, RR_Pending_Field_Fix__c, RR_SOC_Drop__c, RR_Speedometer_Function__c,RR_Status_of_Side_Stand_switch_in_parked__c,  RR_Steering_Suspension_NVH_levels__c, 
                   RR_Washing_Polishing__c, RR_Front_Axle_Nut__c, RR_Front_Wheel__c, RR_Front_Fender__c, RR_Front_Forks__c, RR_Headlight__c, RR_Front_Panel__c, RR_Customer_Suggestions__c,
                   RR_Mirrors__c, RR_Side_Panels__c, RR_Front_Seat__c, RR_Rear_Seat__c, RR_Rear_Panel__c, RR_Backlight__c, RR_Rear_Fender__c, RR_Rear_Wheel__c, RR_Rear_Shock_Absorber__c, RR_Customer_Rating__c
                   FROM WorkOrder WHERE Id=:jobId];	
        
        List<WorkOrderLineItem> parts1 = [SELECT Id, PricebookEntry.Product2.ProductCode, PricebookEntry.Product2.Name,Quantity, RR_Parts_Category__c  FROM WorkOrderLineItem WHERE WorkOrderId =:jobId ];
        
        //Fetch the Contact
        List<Contact> conlist = [SELECT Id, Name, Email, Phone, MailingState, MailingStreet, MailingCountry, MailingPostalCode, Mailingcity FROM Contact WHERE AccountId = :Jobcard.Vehicle__r.CurrentOwnerId AND Primary_Contact__c = True];
        
        If(conlist.size()>0){
            conDetails = conlist[0];
        }else{
            conDetails = new contact(LastName= Jobcard.Contact.Name, Email= Jobcard.Contact.Email, Phone = Jobcard.Contact.Phone, MailingState=Jobcard.Contact.MailingState, MailingStreet=Jobcard.contact.MailingStreet, MailingCountry=Jobcard.Contact.MailingCountry, MailingPostalCode=Jobcard.Contact.MailingPostalCode, Mailingcity=Jobcard.Contact.Mailingcity);
        }
        
        //Add the rating
        rating = integer.valueof(Jobcard.RR_Customer_Rating__c) != null ? integer.valueof(Jobcard.RR_Customer_Rating__c):0;
        
        Integer remainingRecords = 14 - parts1.size();
        
        // Add empty records if the list size is less than 10
        for (Integer i = 0; i < remainingRecords; i++) {
            parts1.add(new WorkOrderLineItem()); 
        }
        
        system.debug('the size of the parts>>'+parts1.size());
        
        parts = parts1;
        
        system.debug('the size of the parts>>'+parts.size());
        
        List<WorkPlan> plans1 = [SELECT Duration_Hour__c, Duration_Min__c, Labour_Charge__c, RR_Labour_Code__r.Code, RR_Labour_Code__r.CodeDescription FROM WorkPlan WHERE WorkOrderId =: jobId];
        
        Integer remainingPlans = 4-plans1.size();
        
        // Add empty records if the list size is less than 10
        for (Integer i = 0; i < remainingPlans; i++) {
            plans1.add(new WorkPlan()); 
        }
        
        plans = plans1;
        
        voices = [SELECT Id, RR_Concern_Category__c, RR_Description__c, RR_Observation_Action_Taken__c, RR_Related_Images__c, RR_Sub_Category__c, RR_Work_Order__c FROM RR_Customer_Voice__c WHERE RR_Work_Order__c = :jobId];
        
        rowcount = 0;
        LaboursRowcount = plans.size();
        Integer count = 0;
        Integer Voicesize = 0;
        system.debug('voices.size()>>'+voices.size());
        system.debug('voices.size()>>'+(10-voices.size()));
        If(voices.size()<10){
            count = 10-voices.size();
            Voicesize = 10;
            
            for (Integer i = 0; i < count; i++) {
                RR_Customer_Voice__c voice = new RR_Customer_Voice__c();
                voice.RR_Concern_Category__c = '';
                voice.RR_Sub_Category__c = '';
                voice.RR_Description__c = '';
                voice.RR_Related_Images__c = '';
                voices.add(voice);
            }
        }else{
            Voicesize = voices.size();
            
            rowcount = voices.size() - 10;
        }
        
        additionalJobs = [SELECT Id, RR_Description__c, RR_Labour_Code__r.Code,RR_Labour_Code__r.RR_Labour_Charge__c, RR_Labour_Code__r.RR_Efforts_Hours__c, RR_Quantity__c, RR_Sub_Total__c, RR_Unit_Price__c,
                          RR_Product__r.Name, RR_Product__r.ProductCode
                          FROM RR_Additional_Job_Recommended__c 
                          WHERE RR_Work_Order__c = :jobId];
        
        numbers = new List<Integer>();
        // Add numbers based on your requirement
        for (Integer i = 0; i < Voicesize; i++) {
            numbers.add(i);
        }
        numbers = numbers;
        
       
        AccessoriesAdded = true;
    }
   

}