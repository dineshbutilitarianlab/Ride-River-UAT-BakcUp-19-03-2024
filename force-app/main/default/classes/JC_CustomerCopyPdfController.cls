public class JC_CustomerCopyPdfController {

    public String selectedValue { get; set; }
   	public List<Integer> numbers { get; set; }
    public List<Integer> termNumbers { get; set; }
    Public boolean AccessoriesAdded {get;set;}
    Public List<Term_Condition_JC__mdt> terms{get;set;}
    Public WorkOrder Jobcard {get;set;} 
    Public List<WorkPlan> plans {get;set;}
    Public List<RR_Customer_Voice__c> voices {get;set;}
    Public Date currentdate{get;set;}
    Public Company_Details__mdt compDetails{get;set;}
    public Decimal totalDurationHours { get; set; } 
    Public contact conDetails {get;set;}
    
    
    public JC_CustomerCopyPdfController(ApexPages.StandardController controller) {
        
        
        Id jobId = controller.getId();
        
        currentdate = system.Today();
        
        compDetails = [SELECT Id, DeveloperName,  Customer_Care_Email__c, Customer_HelpLine_Number__c, Company_Name__c, Timings__c
                       FROM Company_Details__mdt 
                       WHERE DeveloperName='River_Mobility_Private_Limited' LIMIT 1];
        
        terms = [SELECT Id, SI_No__c, Term_Condition__c FROM Term_Condition_JC__mdt ORDER BY SI_No__c ASC];
        
        Jobcard	= [SELECT Id, WorkOrderNumber, Vehicle__r.VehicleIdentificationNumber, Vehicle__r.VehicleRegistrationNumber, Vehicle__r.EngineNumber, Vehicle__r.ModelName, Vehicle__r.Purchased_Date__c, Vehicle__r.LastOdometerReading, Vehicle__r.CurrentOwnerId,
                   Contact.Name, Contact.Email, Contact.Phone, Contact.MailingState, contact.MailingStreet, Contact.MailingCountry, Contact.MailingPostalCode, Contact.Mailingcity,Vehicle__r.RR_Battery_Number__c,Vehicle__r.IgnitionKeyCode,
                   RR_Rear_View_Mirror__c, RR_Tool_Kit__c, RR_Battery_Number__c, RR_Key_Code__c, RR_Vehicle_Document__c, RR_First_Aid_Kit__c, RR_Charger__c, RR_Personal_Belongings__c, Odometer_Reading__c,
                   RR_Non_OE_Acc_Fitted_checkbox__c, RR_Non_OE_Acc_Fitted__c, RR_Job_Type__c, RR_Estimated_Delivery_Time__c, RR_SOC__c , RR_SOC_Level__c, RR_Other_Observations__c,
                   Service_Center__r.Name, Service_Center__r.BillingCity,  Service_Center__r.BillingState, Service_Center__r.BillingStreet, Service_Center__r.BillingCountry, Service_Center__r.BillingPostalCode,
                   RR_Service_Advisor__c, RR_Service_Advisor__r.Name, RR_Service_Advisor__r.RelatedRecord.Email, RR_Service_Advisor__r.RelatedRecord.Phone, Service_Center__r.RR_Customer_Care_Email__c, 
                   Service_Center__r.RR_Customer_HelpLine_Number__c, Service_Center__r.OperatingHours.Description, Estimation_Bill__c, RR_Technician__r.Name, RR_Estimated_Cost__c, (SELECT Duration_Hour__c FROM WorkPlans) 
                   FROM WorkOrder WHERE Id=:jobId];	
        
                 plans = [SELECT Duration_Hour__c, Duration_Min__c, Labour_Charge__c, RR_Labour_Code__r.Code, RR_Labour_Code__r.CodeDescription FROM WorkPlan WHERE WorkOrderId =: jobId];

        
        
        voices = [SELECT Id, RR_Concern_Category__c, RR_Description__c, RR_Observation_Action_Taken__c, RR_Related_Images__c, RR_Sub_Category__c, RR_Work_Order__c FROM RR_Customer_Voice__c WHERE RR_Work_Order__c = :jobId];
        
        //Fetch the Contact
        List<Contact> conlist = [SELECT Id, Name, Email, Phone, MailingState, MailingStreet, MailingCountry, MailingPostalCode, Mailingcity FROM Contact WHERE AccountId = :Jobcard.Vehicle__r.CurrentOwnerId AND Primary_Contact__c = True];
        
        If(conlist.size()>0){
            conDetails = conlist[0];
        }else{
            conDetails = new contact(LastName= Jobcard.Contact.Name, Email= Jobcard.Contact.Email, Phone = Jobcard.Contact.Phone, MailingState=Jobcard.Contact.MailingState, MailingStreet=Jobcard.contact.MailingStreet, MailingCountry=Jobcard.Contact.MailingCountry, MailingPostalCode=Jobcard.Contact.MailingPostalCode, Mailingcity=Jobcard.Contact.Mailingcity);
        }
            
        Integer Voicesize = voices.size();
        system.debug('voices.size()>>'+voices.size());
        
        List<RR_Customer_Voice__c> newVoiceList = new List<RR_Customer_Voice__c>();
        
        newVoiceList = voices;
        integer count = 0;
        integer voicecount = 0;
        
        If(voices.size()<10){
            count = 10- voices.size();
            voicecount=10;
            
            for (Integer i = 0; i < count; i++) {
                system.debug('test');
                newVoiceList.add(new RR_Customer_Voice__c());
            }
        }else{
            voicecount=voices.size();
        }
        
        system.debug('newVoiceList.size()>>'+newVoiceList.size());
        
        voices = newVoiceList;
        
        numbers = new List<Integer>();
        
        for (Integer i = 0; i < voicecount; i++) {
            numbers.add(i);
        }
        numbers = numbers;
       
        AccessoriesAdded = true;
        // Calculate the total duration hours
        totalDurationHours = 0;
        for (WorkPlan plan : plans) {
            totalDurationHours += plan.Duration_Hour__c != null ? plan.Duration_Hour__c : 0;
        }
        System.debug('Total Duration Hours: ' + totalDurationHours);
    }

}