public class JobCardComponentHelper {  
    @AuraEnabled(cacheable=true)
    public static VehicleWrapper fetchVehicleDetails(String vehicleIdentifier, String inputType) {
        
        VehicleWrapper vw = new VehicleWrapper();
        
        List<Vehicle> vh = new List<Vehicle>();
        try {
            if (inputType == 'VIN') {
                
                vh = [SELECT Id, VehicleIdentificationNumber, VehicleRegistrationNumber, EngineNumber, ModelName, Purchased_Date__c, LastOdometerReading, RR_Battery_Number__c, IgnitionKeyCode, CurrentOwnerId,
                      (SELECT Id, MilestoneType FROM AssetMilestones WHERE MilestoneType='Sold')
                      FROM Vehicle 
                      WHERE Id IN (SELECT VehicleId FROM AssetMilestone WHERE MilestoneType='Sold') 
                      AND PDI_Status_Pass__c = TRUE 
                      AND VehicleIdentificationNumber = :vehicleIdentifier 
                      LIMIT 1]; 
                
            } else if (inputType == 'RegistrationNumber') {
                vh = [SELECT Id, VehicleIdentificationNumber, VehicleRegistrationNumber, EngineNumber, ModelName, Purchased_Date__c, LastOdometerReading, RR_Battery_Number__c, IgnitionKeyCode, CurrentOwnerId,
                      (SELECT Id, MilestoneType FROM AssetMilestones WHERE MilestoneType='Sold')
                      FROM Vehicle 
                      WHERE Id IN (SELECT VehicleId FROM AssetMilestone WHERE MilestoneType='Sold') 
                      AND PDI_Status_Pass__c = TRUE 
                      AND VehicleRegistrationNumber = :vehicleIdentifier 
                      LIMIT 1];
            }
            
            if (vh.size() >= 1) {
                Vehicle vehicle = vh[0];
                vw.vehicle = vehicle; //activeJobCardPresent
                
                // Fetch the primary contact related to the vehicle owner's account
                List<Contact> primaryContacts = [
                    SELECT Id, Phone 
                    FROM Contact 
                    WHERE AccountId = :vehicle.CurrentOwnerId 
                    AND Primary_Contact__c = TRUE 
                    LIMIT 1
                ];
                
                // Check if there is a primary contact
                if (!primaryContacts.isEmpty()) {
                    vw.primaryContactPhone = primaryContacts[0].Phone;
                } else {
                    throw new CustomException('The primary contact for the vehicle owner is not set!');
                }
                
                List<WorkOrder> activeJobcards = [
                    SELECT Id, Status, Vehicle__c
                    FROM WorkOrder 
                    WHERE Vehicle__c =:vehicle.Id
                    AND Status NOT IN ('Completed', 'Canceled')
                ];
                
                if (!activeJobcards.isEmpty()) {
                    throw new CustomException('An active jobcard is present with same Vehicle!');
                }
            }
            
            else {
                throw new CustomException('Vehicle not found!');
            }
            
            return vw;
            
        } catch (Exception e) {
            
            String errorStr = 'Error: ' + e.getMessage();
            throw new AuraHandledException(errorStr);
        }
    }
    
    @Auraenabled
    public static contactDetails validateOTP(string phoneNumber, vehicle vehicleDetails)
    {
        
        If(vehicleDetails == null){
            throw new AuraHandledException('Missing Vehicle details');
        }else If(vehicleDetails.CurrentOwnerId == null){
            throw new AuraHandledException('Vehicle dont have owner details');
        }else{
            try{                
                List<Contact> conList = [SELECT Id, FirstName, LastName, Phone, Email, AccountId, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet,Name, Primary_Contact__c, account.Phone FROM Contact WHERE AccountId =:vehicleDetails.CurrentOwnerId];
                Contact conObj= new contact();
                contactDetails condetails = new contactDetails();
                
                condetails.isPrimary = false;
                condetails.isSecondaryPresent = false;
                
                
                For(contact con:conList){
                    If(con.phone == phoneNumber){
                        If(con.primary_Contact__c){
                            condetails.isPrimary = true;
                            condetails.primaryCon = con;
                        }
                        
                        condetails.isSecondaryPresent = true;
                        condetails.secondarycon = con;
                        
                    }else If(con.primary_Contact__c){
                        condetails.primaryCon = con;
                    }
                }
                
                If(condetails.primaryCon == null){
                    throw new CustomException('Add atleast one primary contact for owner account');
                }
                
                If(!condetails.isSecondaryPresent) {
                    
                    conObj.Phone = phoneNumber;
                    conObj.AccountId = vehicleDetails.CurrentOwnerId;
                    conObj.Email = '';
                    conObj.MailingCity = '';
                    conObj.MailingCountry = '';
                    conObj.MailingState = '';
                    conObj.MailingPostalCode = '';
                    conObj.MailingStreet = '';
                    
                    condetails.secondarycon = conObj;
                    
                }
                
                return condetails;
            }catch (Exception e) {
                
                string errorStr= 'Error: '+e.getmessage();
                throw new AuraHandledException(errorStr);
            }
            
        }
    }
    
     
    //Fetching the email
    @AuraEnabled
    public static List<ServiceResource> fetchServiceAdvisors(string searchKey) {
        List<ServiceResource> saList = new List<ServiceResource>();
        
        User user = [SELECT Id, AccountId, UserType
                     FROM User 
                     WHERE Id = : userInfo.getUserId()];
        
        string str = '%'+searchKey+'%';
        System.debug('str ===>'+str);
        System.debug('user ===>'+user);
        
        // string query = 'SELECT Id, Name, RelatedRecord.Name, RelatedRecord.Email, RelatedRecord.Phone FROM ServiceResource';
        
        If(user.UserType == 'PowerPartner'){
            saList = [SELECT Id, Name, RelatedRecord.Name, RelatedRecord.Email, RelatedRecord.Phone  
                      FROM ServiceResource 
                      WHERE RelatedRecord.AccountId =: user.AccountId 
                      AND Name LIKE :str 
                      AND RelatedRecordId != null];
                      System.debug('saList ==>'+saList);
        }else{
            saList = [SELECT Id, Name, RelatedRecord.Name, RelatedRecord.Email, RelatedRecord.Phone  
                      FROM ServiceResource 
                      WHERE Name LIKE :str 
                      AND RelatedRecordId != null];  
                      System.debug('saList ==>'+saList);          
        }
        
        System.debug('saList ==>'+saList);
        return saList;
    }
    
    
    //fetching the service centers
    
 /*   @AuraEnabled
    public static List<Account> fetchServiceCenters(string searchKey) {
        List<Account> scList = new List<Account>();
        
        User user = [SELECT Id, AccountId, UserType
                     FROM User 
                     WHERE Id = : userInfo.getUserId()];
        
        string str = '%'+searchKey+'%';
        
        If(user.UserType == 'PowerPartner'){
            scList = [SELECT Id, Name, Center_Code__c, BillingCity
                      FROM Account 
                      WHERE (Id =: user.AccountId 
                             OR ParentId = :user.AccountId)
                      AND Name LIKE :str 
                      AND Type IN ('Service Center', 'COCO Store', 'Dealer')];
        }else{
            scList = [SELECT Id, Name, Center_Code__c, BillingCity
                      FROM Account 
                      WHERE Name LIKE :str 
                      AND Type IN ('Service Center', 'COCO Store', 'Dealer')];            
        }
        
        return scList;
    } */

    @AuraEnabled
    public static List<Account> fetchServiceCenterrs() {
        List<Account> scList = new List<Account>();
    
        try {
            // Fetch the logged-in user details
            User user = [SELECT Id, AccountId, UserType 
                         FROM User 
                         WHERE Id = :UserInfo.getUserId()];
    
            System.debug('Logged-in User: ' + user.Id + ', AccountId: ' + user.AccountId + ', UserType: ' + user.UserType);
    
            if (user.UserType == 'PowerPartner') {
                System.debug('Fetching Service Centers for PowerPartner user...');
                scList = [SELECT Id, Name, Center_Code__c, BillingCity
                          FROM Account 
                          WHERE (Id = :user.AccountId 
                                 OR ParentId = :user.AccountId)
                          AND Type IN ('Service Center', 'COCO Store', 'Dealer')];
            } else {
                System.debug('Fetching Service Centers for a non-PowerPartner user...');
                scList = [SELECT Id, Name, Center_Code__c, BillingCity
                          FROM Account 
                          WHERE Type IN ('Service Center', 'COCO Store', 'Dealer')];
            }
    
            System.debug('Total Service Centers Found: ' + scList.size());
            
        } catch (Exception e) {
            System.debug('Error occurred in fetchServiceCenters: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching service centers: ' + e.getMessage());
        }
    
        return scList;
    }
    




    
    //fetching the cities
    
    @AuraEnabled
    public static List<City__c> fetchCities(string searchKey) {
        List<City__c> cityList = new List<City__c>();
        
        User user = [SELECT Id, AccountId, UserType
                     FROM User 
                     WHERE Id = : userInfo.getUserId()];
        
        string str = '%'+searchKey+'%';
        
        If(user.UserType == 'PowerPartner'){
            cityList = [SELECT Id, City_Masking_Name__c, Name, State__c, City_Pincode__c
                        FROM City__c 
                        WHERE /*(Id IN (SELECT City__c FROM Pin_Code__c WHERE Dealer_Service_Center__c  = :user.AccountId))
                        AND */(City_Masking_Name__c LIKE :str OR Name LIKE :str)];
        }else{
            cityList = [SELECT Id, City_Masking_Name__c, Name, State__c, City_Pincode__c
                        FROM City__c 
                        WHERE City_Masking_Name__c LIKE :str OR Name LIKE :str OR City_Pincode__c LIKE :str /*OR State__c LIKE :str*/];            
        }
        
        return cityList;
    }
    
    
    //Creating Job card
    @AuraEnabled
    public static string saveCardDetails(JobCardDetails jobCardDetails) {
        
        try{
            Contact conObj = new Contact();
            conObj.LastName = jobCardDetails.contactName;
            conObj.Phone = jobCardDetails.phoneNumber;
            conObj.AccountId = jobCardDetails.vehicle.CurrentOwnerId;
            conObj.Email = jobCardDetails.email;
            
            conObj.MailingCity = jobCardDetails.address.city;
            conObj.MailingStreet = jobCardDetails.address.street;
            conObj.MailingCountry = jobCardDetails.address.country;
            conObj.MailingPostalCode = jobCardDetails.address.postalCode;
            conObj.MailingState = jobCardDetails.address.province;
            
            List<Contact> exContact = [SELECT Id from Contact WHERE Phone =:jobCardDetails.phoneNumber AND AccountId = :jobCardDetails.vehicle.CurrentOwnerId LIMIT 1];
            
            If(exContact.size()>=1){
                conObj.Id = exContact[0].Id;
            }else{
                insert conObj;
            }
            
            WorkOrder jobCard = new WorkOrder();
            jobCard.Vehicle__c = jobCardDetails.vehicle.Id;
            jobCard.ContactId = conObj.Id;
            jobCard.RR_Service_Advisor__c = jobCardDetails.ServiceAdvisor;
           // jobCard.Service_Center__c = jobCardDetails.ServiceCenter;
            jobCard.Odometer_Reading__c= jobCardDetails.KmsCovered;
            // jobCard.RR_Technician__c = jobCardDetails.Technician;
            jobCard.RR_Job_Type__c = jobCardDetails.TypeOfJob;
            jobCard.RR_Periodic_Maintenance_Type__c = jobCardDetails.subType;
            jobCard.AccountId = jobCardDetails.vehicle.CurrentOwnerId;
            jobCard.RR_Rear_View_Mirror__c = jobCardDetails.RearViewMirror;
            jobCard.RR_Vehicle_Document__c = jobCardDetails.VehicleDocument;
            jobCard.RR_Charger__c = jobCardDetails.Charger;
            jobCard.RR_Personal_Belongings__c = jobCardDetails.PersonalBelongings;
            jobCard.RR_Tool_Kit__c = jobCardDetails.ToolKit;
            jobCard.RR_First_Aid_Kit__c = jobCardDetails.FirstAidKit;
            jobCard.RR_Non_OE_Acc_Fitted_checkbox__c = jobCardDetails.NonOEAccFitted;
            jobCard.RR_Non_OE_Acc_Fitted__c = jobCardDetails.AllNonOEAccFitted;
            jobCard.RR_SOC__c = jobCardDetails.SOC;
            jobCard.RR_Estimated_Delivery_Time__c = jobCardDetails.EstimatedDeliveryTime;
            jobCard.RR_Estimated_Cost__c = jobCardDetails.EstimatedCost;
            jobCard.RR_Other_Observations__c = jobCardDetails.OtherObservations; 
            jobCard.City__c = jobCardDetails.city; 

            List<Account> serviceCenters = fetchServiceCenterrs();
            System.debug('Fetched Service Centers: ' + serviceCenters);
            
            if (!serviceCenters.isEmpty()) {
                jobCard.Service_Center__c = serviceCenters[0].Id;
                System.debug('Assigned Service Center: ' + jobCard.Service_Center__c);
            } else {
                throw new AuraHandledException('No Service Centers found!');
            }
            
            
            List<City__c> cityList = [SELECT Id, Price_Book__c, Price_Book__r.isActive  FROM City__c WHERE Id = :jobCardDetails.city];
            
            If(cityList.size()>0){
                
                If(cityList[0].Price_Book__c == null){
                    throw new CustomException('The selected city does not have a pricebook linked. Please choose a city with an associated pricebook to continue.');
                }else If(cityList[0].Price_Book__r.isActive == false){
                    throw new CustomException('The selected city does not have an active pricebook associated. Please choose a city with an active pricebook to proceed.');
                }else{
                    jobCard.Pricebook2Id = [SELECT Id FROM Pricebook2 WHERE Id IN (SELECT Price_Book__c FROM City__c WHERE Id = :jobCardDetails.city)].Id;
                    
                }
            }else{
                throw new CustomException('City not found!');
            }
            
            System.debug('jobCard ==>'+jobCard);
            insert jobCard;
            
            //update vehicle odometer reading
           /* Vehicle vh = new Vehicle();
            vh.LastOdometerReading = jobCardDetails.KmsCovered;
            vh.Id = jobCardDetails.vehicle.Id;
            
            update vh;*/
            
            //insert Customer voices
            
           
                List<RR_Customer_Voice__c> voiceList = new List<RR_Customer_Voice__c>();
                System.debug('jobCardDetails'+jobCardDetails);
                System.debug('jobCardDetails'+jobCardDetails.concernNoList);
    
                for (ConcernWrapper item : jobCardDetails.concernNoList) {
                    RR_Customer_Voice__c voice = new RR_Customer_Voice__c();
                    voice.RR_Work_Order__c = jobCard.Id;
                    voice.RR_Concern_Category__c = item.RRConcernCategory;
                    voice.RR_Sub_Category__c = item.RRSubCategory;
                    voice.RR_Description__c = item.RRDescription;
    
                    voiceList.add(voice);
                }
    
                if (!voiceList.isEmpty()) {
                    System.debug('voice list ==>'+voiceList);
                    insert voiceList;
                }
            
            
            
            Return jobCard.Id;
        }catch (Exception e) {
            
            string errorStr= 'Error: '+e.getmessage();
            throw new AuraHandledException(errorStr);
        }
        
    }
    
    
    
    public class contactDetails {
        
        @AuraEnabled
        public Contact primaryCon { get; set; }
        @AuraEnabled
        public Contact secondarycon { get; set; } 
        @AuraEnabled
        public boolean isPrimary { get; set; }
        @AuraEnabled
        public boolean isSecondaryPresent { get; set; }
        
    }
    
    public class JobCardDetails {
        
        @AuraEnabled
        public String inputType { get; set; }
        @AuraEnabled
        public String vehicleIdentifier { get; set; } 
        @AuraEnabled
        public Vehicle vehicle { get; set; }
        @AuraEnabled
        public String phoneNumber { get; set; }
        @AuraEnabled
        public contact contact { get; set; }
        @AuraEnabled
        public decimal KmsCovered { get; set; }
        @AuraEnabled
        public String contactName { get; set; }
        @AuraEnabled
        public boolean ToolKit { get; set; }
        @AuraEnabled
        public boolean RearViewMirror { get; set; }
        @AuraEnabled
        public boolean VehicleDocument { get; set; }
        @AuraEnabled
        public boolean FirstAidKit { get; set; }
        @AuraEnabled
        public boolean Charger { get; set; }
        @AuraEnabled
        public AddressWrapper address { get; set; }
        @AuraEnabled
        public String email { get; set; }
        @AuraEnabled
        public boolean NonOEAccFitted { get; set; }
        @AuraEnabled
        public String TypeOfJob { get; set; }
        @AuraEnabled
        public String subType { get; set; }
        @AuraEnabled
        public String PersonalBelongings { get; set; }
        @AuraEnabled
        public String AllNonOEAccFitted { get; set; }
        @AuraEnabled
        public decimal EstimatedCost { get; set; }
        
        @AuraEnabled
        public datetime EstimatedDeliveryTime { get; set; }
        @AuraEnabled
        public string Technician { get; set; }
        @AuraEnabled
        public string OtherObservations { get; set; }  
        @AuraEnabled
        public string ServiceAdvisor { get; set; }
        @AuraEnabled
        public string ServiceCenter { get; set; }
        @AuraEnabled
        public string city { get; set; }
        @AuraEnabled
        public List<ConcernWrapper> concernNoList { get; set; }
        @AuraEnabled
        public decimal SOC { get; set; } 
        
        /*public JobCardDetails(String inputType, String vehicleIdentifier, String phoneNumber) {
this.inputType = inputType;
this.vehicleIdentifier = vehicleIdentifier;
this.phoneNumber = phoneNumber;
}*/
    } 
    public class VehicleWrapper {
        @AuraEnabled public Vehicle vehicle;
        @AuraEnabled public String primaryContactPhone;
        @AuraEnabled public Boolean activeJobCardPresent;
    }
    
    public class AddressWrapper {
        @AuraEnabled
        public String street { get; set; }
        
        @AuraEnabled
        public String city { get; set; }
        
        @AuraEnabled
        public String province { get; set; }
        
        @AuraEnabled
        public String country { get; set; }
        
        @AuraEnabled
        public String postalCode { get; set; }
        
        // Constructor
        public AddressWrapper(){}
        
    }
    
    public class ConcernWrapper {
        @AuraEnabled
        public Integer id { get; set; }
        
        @AuraEnabled
        public String Name { get; set; }
        
        @AuraEnabled
        public String RRConcernCategory { get; set; }
        
        @AuraEnabled
        public String RRSubCategory { get; set; }
        
        @AuraEnabled
        public String RRDescription { get; set; }
        
        // Constructor
        public ConcernWrapper() {}
    }
    
    public class CustomException extends Exception {}
}