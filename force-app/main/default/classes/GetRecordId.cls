public without sharing class GetRecordId {

    @AuraEnabled(cacheable = true)
    public static List<Account> getAccounts() {
        return [SELECT Id FROM Account WHERE Name LIKE '%Eniac%' LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getAnyAccount() {
        return [SELECT Id FROM Account ORDER BY LastModifiedDate DESC NULLS LAST LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ListView> getSAview() {
        return [SELECT Id, Name FROM ListView WHERE Name LIKE '%All Sales Agreements%' LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<AdvAcctForecastSetUse> getAAFPartner() {
        return [SELECT Id, Name FROM AdvAcctForecastSetUse WHERE Name LIKE '%Eniac Cars Auto Dealer Industrial_Set%' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<AdvAcctForecastSetPartner> getAAFPartner2() {
        return [SELECT Id, Name FROM AdvAcctForecastSetPartner WHERE Name LIKE '%Dream%' LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<WarrantyTerm> getWarrantyTerm() {
        return [SELECT Id, WarrantyTermName FROM WarrantyTerm WHERE WarrantyTermName LIKE '%Neo Care%' LIMIT 1];
    } 

    @AuraEnabled(cacheable = true)
    public static List<SalesAgreement> getSalesAgreement() {
        return [SELECT Id, Name FROM SalesAgreement WHERE Name LIKE '%Eniac%' LIMIT 1];
    } 
    
    @AuraEnabled(cacheable = true)
    public static List<Contact> getContact() {
        return [SELECT Id, FirstName FROM Contact WHERE FirstName LIKE '%Carole%' LIMIT 1];
    } 
      
    @AuraEnabled(cacheable = true)
    public static List<Visit> getVisit() {
        return [SELECT Id, Name FROM Visit WHERE Name = '00000003' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<ProductCategory> getProductCategory() {
        return [SELECT Id, Name FROM ProductCategory WHERE Name = 'Hybrid Electric' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<VehicleDefinition> getVehicleDefinition() {
        return [SELECT Id, Name FROM VehicleDefinition WHERE Name = 'Neo Ionic EV CD4 2022 VXi' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Lead> getLead() {
        return [SELECT Id, Name FROM Lead WHERE Name like '%Adrian James%' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Opportunity> getOpportunity() {
        return [SELECT Id, Name FROM Opportunity WHERE Name like '%Simon%' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Vehicle> getVehicle() {
        return [SELECT Id, Name FROM Vehicle WHERE Name like '%Electra%' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<Product2> getProduct() {
        return [SELECT Id, Name FROM Product2 WHERE Name like '%Neo%' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<ManufacturingProgram> getManufacturingProgram() {
        return [SELECT Id, Name FROM ManufacturingProgram WHERE Name like '%Eniac%' LIMIT 1];
    }
    
    @AuraEnabled(cacheable = true)
    public static List<ListView> getProductView() {
        return [SELECT Id, Name FROM ListView WHERE Name = 'All Products' LIMIT 1];
    }

    @AuraEnabled(cacheable = true)
    public static List<FlowDefinitionView> getFlowDefinitionView() {
        return [SELECT  ActiveVersionId, ApiName FROM FlowDefinitionView WHERE ApiName like '%CreateForecastSetforRevenueMeasures%' LIMIT 1];
    }   

}