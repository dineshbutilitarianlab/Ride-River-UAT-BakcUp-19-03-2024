public with sharing class WarrantyTagPDFController {
    public ClaimItem claimItem { get; private set; }
    public String    warrantyClaimNumber { get; private set; }
    public Date      warrantyDate { get; private set; }
    public String   motorNumber { get; private set; }
    public String   vin { get; private set; }
    public String   registrationNumber { get; private set; }
    public Decimal  vehicleKilometer { get; private set; }
    public String   dealerName {get; set;}
    public String   modelName {get;set;}
    public Date     purchaseDate {get;set;}
    public String   partNumber {get;set;}
    public String   partDescription {get;set;}
    public String   dealerLocation {get;set;}
    public String   warrantyClaim {get;set;}
    public String   ElectricalValue {get;set;} 
    //public String ConsequentialParts {get;set;}
    public String   dealerObs {get;set;}
    public Decimal   VehicleKMS {get;set;}
    public Decimal   Quantity {get;set;}
    public DateTime   DOF {get;set;}
    public String ReplacementType {get;set;}
    
    public WarrantyTagPDFController() {
        try{
            String claimItemId = ApexPages.currentPage().getParameters().get('cid');
            System.debug('Claim Item ID: ' + claimItemId);
            
            if (claimItemId != null) {
                try {
                    System.debug('Fetching ClaimItem record...');
                    claimItem = [
                        SELECT Id, Name, 
                        Claim.Warranty_Prior__c,
                        Claim.AccountId,
                        Claim.Account.Name,
                        Claim.Account.AccountNumber,
                        Claim.Account.ShippingCountry,
                        Claim.Account.ShippingStreet,
                        Claim.Account.ShippingCity,
                        Claim.Account.ShippingState,
                        Claim.Account.ShippingPostalCode,
                        Claim.Warranty_Prior__r.Name, 
                        Claim.Warranty_Prior__r.Warranty_Prior_Date__c, 
                        Claim.Warranty_Prior__r.Odometer_Reading__c,
                        Claim.Job_Card__r.CreatedDate,
                        Claim.Job_Card__r.Dealer_Observation__c,
                        Part_Description__c,
                        Quantity__c, Claim.Vehicle__r.Dealer__r.Name,
                        Claim.Vehicle__r.ModelName,
                        Claim.Vehicle__r.LastOdometerReading,
                        Claim.Vehicle__r.Purchased_Date__c,
                        Claim.Vehicle__r.VehicleIdentificationNumber,
                        Claim.Vehicle__r.EngineNumber,
                        Claim.Vehicle__r.VehicleRegistrationNumber,
                        Part__r.Product_Code__c,
                        Part__r.Consequential_Parts__c,
                        Part__r.Electrical_Value__c,
                        Part__r.LineItemNumber,
                        Part__r.Description, 
                        Part__r.Replacement_Type__c,
                        Electrical_Value_Formula__c FROM ClaimItem WHERE Id = :claimItemId LIMIT 1];
                     
                    System.debug('Fetched ClaimItem record: ' + claimItem);
                    
                    warrantyClaimNumber = claimItem.Claim.Warranty_Prior__r.Name;
                    System.debug('Warranty Claim Number: ' + warrantyClaimNumber);
                    
                    warrantyDate = claimItem.Claim.Warranty_Prior__r.Warranty_Prior_Date__c;
                    System.debug('Warranty Date: ' + warrantyDate);
                    
                    motorNumber = claimItem.Claim.Vehicle__r.EngineNumber;
                    System.debug('Motor Number: ' + motorNumber);
                    
                    vin = claimItem.Claim.Vehicle__r.VehicleIdentificationNumber;
                    System.debug('VIN: ' + vin);
                    
                    registrationNumber = claimItem.Claim.Vehicle__r.VehicleRegistrationNumber;
                    System.debug('Registration Number: ' + registrationNumber);
                    
                    vehicleKilometer = claimItem.Claim.Vehicle__r.LastOdometerReading;
                    System.debug('Vehicle Kilometer: ' + vehicleKilometer);
                    
                    dealerName = claimItem.Claim.Vehicle__r.Dealer__r.Name;
                    System.debug('Dealer Name: ' + dealerName);
                    
                    modelName = claimItem.Claim.Vehicle__r.ModelName;
                    System.debug('Model Name: ' + modelName);
                    
                    purchaseDate = claimItem.Claim.Vehicle__r.Purchased_Date__c;
                    System.debug('Purchase Date: ' + purchaseDate);
                    
                    partNumber = claimItem.Part__r.Product_Code__c;
                    System.debug('Part Number: ' + partNumber);
                    
                    partDescription = claimItem.Part_Description__c;
                    System.debug('Part Description: ' + partDescription);
                    
                    dealerLocation = claimItem.Claim.Account.ShippingCity;
                    System.debug('Dealer Location: ' + dealerLocation);
                    
                    warrantyClaim = claimItem.Name;
                    System.debug('Warranty Claim: ' + warrantyClaim);
                    
                    ReplacementType = claimItem.Part__r.Replacement_Type__c;
                    System.debug('Consequential Parts: ' + ReplacementType);
                    
                    ElectricalValue = claimItem.Electrical_Value_Formula__c;
                    System.debug('Electrical Value: ' + ElectricalValue);
                    
                    Quantity = claimItem.Quantity__c != null ? claimItem.Quantity__c : 0;
                    
                    dealerObs = claimItem.Part_Description__c;
                    System.debug('Dealer Observation: ' + dealerObs);
                    
                    DOF = claimItem.Claim.Job_Card__r.CreatedDate;
                    System.debug('Date of Failure (DOF): ' + DOF);
                } catch (Exception ex) {
                    System.debug('Error fetching Claim Item:  ' + ex.getMessage());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error fetching Claim Item: ' + ex.getMessage()));
                } 
            } else {
                System.debug('No Claim Item found.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Claim Item found.'));
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
}