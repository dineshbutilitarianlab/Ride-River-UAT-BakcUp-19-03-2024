public class CustomerFeedbackController {

    public Case currentCase{get; set;}
    public Vehicle caseVehicle{get; set;}
    public List<Customer_Feedback__c> customerFeedbacks{get; set;}
    public Account owner{get; set;}
    public List<AssetMilestone> assetMilestones {get; set;}
    public Date deliverDate{get;set;}
    public Date purchaseDate{get;set;}
    public String perfectDeliverTime{get;set;}
    public Boolean hasError { get; set; }
    public String VehicleReceviedBy {get; set;}
    public String caseCurrentDate {get; set;} 
    public Datetime perfectDeliverDate {get; set;} 
    //public String formattedAddress { get; set; }

    public CustomerFeedbackController(ApexPages.StandardController controller) {
        String caseId = ApexPages.currentPage().getParameters().get('id');
		hasError = false;

        try {
            currentCase = [SELECT Id,CaseNumber, ContactId, AccountId, Status, Subject, Priority, Description, ContactPhone, Case_Category__c, Case_Type__c, vehicle__c, CreatedDate from Case where Id = :caseId LIMIT 1];
    
            if(currentCase != NULL) {
                caseCurrentDate = formattedCreatedDate(currentCase.CreatedDate);
                if(currentCase.vehicle__c != NULL) {
                	caseVehicle = [SELECT VehicleIdentificationNumber, VehicleRegistrationNumber, LastOdometerReading, Purchased_Date__c, CurrentOwnerId, Dealer__r.name, Dealer__r.ShippingCity, Dealer__r.ShippingState,Dealer__r.Center_Code__c   from vehicle where id =: currentCase.vehicle__c limit 1];
                    
                    
                        owner = [SELECT id, Name, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry, Phone from Account where Id =: caseVehicle.CurrentOwnerId];
                        customerFeedbacks = [SELECT Issue_Type__c, Remarks__c, Resolution_Provided__c, Name, Case__c from Customer_Feedback__c where Case__c =: currentCase.Id];
                        assetMilestones = [SELECT id, VehicleId, MilestoneType, MilestoneDate, Delivery_Date__c,Vehicle_Received_By__c  from AssetMilestone where (MilestoneType = 'Customer Delivery' or MilestoneType = 'Sold') and VehicleId =: caseVehicle.Id];
        				/*formattedAddress = formatAddress(
                            owner.ShippingStreet,
                            owner.ShippingCity,
                            owner.ShippingPostalCode,
                            owner.ShippingState,
                            owner.ShippingCountry
                        );*/
                        if(assetMilestones.size() > 0) {
                            for(AssetMilestone assetMile : assetMilestones) {
                                if(assetMile.MilestoneType == 'Customer Delivery') {
                                    deliverDate = assetMile.MilestoneDate;
                                    perfectDeliverDate = assetMile.Delivery_Date__c;
                                    perfectDeliverTime = formattedPerfectDeliverTime(assetMile.Delivery_Date__c);
                                    VehicleReceviedBy = assetMile.Vehicle_Received_By__c;
                                    
                                }else if(assetMile.MilestoneType == 'Sold') {
                                    purchaseDate = assetMile.MilestoneDate;
                                }
                            }
                        } else {
                            //hasError = true;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Record Found.'));
                        }
                    } else {
                        hasError = True;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Current case does not contain any vehicle.'));
                    }
                                
                }else{
                    hasError = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Something went wrong. Please contact your administrator.'));
                }
        } catch (Exception e) {
            hasError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public String formattedPerfectDeliverTime(Datetime perfectDeliverTime) {
        return convertToUserTimezone(perfectDeliverTime, 'HH:mm:ss');
    }
    
    public String formattedCreatedDate(Datetime caseDate) {
        return convertToUserTimezone(caseDate, 'd MMMM yyyy HH:mm:ss');
    }
    
    public String convertToUserTimezone(Datetime gmtDatetime, String format) {
        if (gmtDatetime == null) {
            return 'N/A'; // Return a default value if datetime is null
        }
        
        // Get the user's time zone
        TimeZone tz = UserInfo.getTimeZone();
        
        // Format the date in the desired format in the user's time zone
        String formattedDate = gmtDatetime.format(format, tz.getID());
        System.debug(formattedDate);
        return formattedDate;
    }
    
    /*public static String formatAddress(String shippingStreet, String shippingCity, String shippingPostalCode, String shippingState, String shippingCountry) {
        String formattedAddress = '';
        Integer maxLength = 20;
        
        // Split the shipping street into lines with maximum 30 characters each
        List<String> streetLines = new List<String>();
        while (shippingStreet.length() > maxLength) {
            streetLines.add(shippingStreet.substring(0, maxLength));
            shippingStreet = shippingStreet.substring(maxLength);
        }
        streetLines.add(shippingStreet); // Add the remaining part
        
        // Concatenate the street lines with <br/> and add city, postal code, state, and country
        formattedAddress = String.join(streetLines, '<br/>') + '<br/>' + shippingCity + ' ' + shippingPostalCode + ', ' + shippingState + ', ' + shippingCountry;
        
        return formattedAddress;
    }*/

}