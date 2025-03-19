@isTest
public class ClaimTriggerHandlerTest {
    @isTest
    static void testHandleAfterInsertPositive() {
        // Step 1: Create related objects
        Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
        insert testAccount;	

        Product2 testProduct = new Product2(
            Name = 'Test Accessory',
            IsActive = true,
            ProductCode = 'abcd',
            HSN_Code__c = 'abcd',
            Type__c = 'Accessories'
        );
        insert testProduct;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = testProduct.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pricebookEntry;

        VehicleDefinition vehicleDefinition = new VehicleDefinition(Name = 'Vehicle Def 1', ProductId = testProduct.Id);
        insert vehicleDefinition;

        Asset asset = new Asset(Name = 'Test Asset', IsCompetitorProduct = false, IsInternal = true, AccountId = testAccount.Id);
        insert asset;

        Software_Version__c testSV = new Software_Version__c(Name = 'Test Software Version');
        insert testSV;

        Vehicle vehicle = new Vehicle(
            Name = 'Test Vehicle',
            VehicleDefinitionId = vehicleDefinition.Id,
            AssetId = asset.Id,
            IsRecallOpen = false,
            IsTelematicsServiceActive = true,
            Approval_Status__c = true,
            Spare_Vehicle__c = false,
            PDI_Status_Pass__c = true,
            VehicleIdentificationNumber = 'A2B2',
            Software_Version__c = testSV.Id,
            Charger_PC_Number__c = '123'
        );
        insert vehicle;

        WorkOrder workOrder = new WorkOrder(
            Vehicle__c = vehicle.Id,
            IsStopped = false,
            Pricebook2Id = standardPricebook.Id
        );
        insert workOrder;

        Warranty_Prior__c warranty = new Warranty_Prior__c( Job_Card__c = workOrder.Id);
        insert warranty;
        
        //Id hardCoded = '1WLF40000000MFKOA2';

        // Fetch an existing WorkOrderLineItem
        //WorkOrderLineItem lineItem = [SELECT Id, Failure_Q__c FROM WorkOrderLineItem WHERE Id = hardCoded];
       

        WorkOrderLineItem lineItem = new WorkOrderLineItem(
            Warranty_Prior__c = warranty.Id,
            //TotalAmount__c = 500.00,
            Consequential_Part__c = 'Oil',
            Part_Description__c = 'Part A',
            Electrical_Value__c = '200',
            Hours__c = 4,
            WorkOrderId = workOrder.Id,
             PricebookEntryId = pricebookEntry.Id
        );
        insert lineItem;
        
        Claim claim = new Claim(Name = 'Test Claim', Warranty_Prior__c = warranty.Id, AccountId = testAccount.Id );
        insert claim;

        ClaimItem claimItem = new ClaimItem(
            Name = 'Test Claim Item',
            ClaimId = claim.Id,
            Amount__c = 500,
            FaultDate = Date.Today()
        );
        insert claimItem;
       
    }

    @isTest
    static void testHandleAfterInsertNegative() {
        // Scenario where Claim lacks Warranty_Prior__c
        Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
        insert testAccount;

        Claim claimWithoutWarranty = new Claim(Name = 'Invalid Claim', Warranty_Prior__c = null, AccountId = testAccount.Id);
        insert claimWithoutWarranty;
	
        
        // No ClaimItems should be created
        List<ClaimItem> claimItems = [SELECT Id FROM ClaimItem WHERE ClaimId = :claimWithoutWarranty.Id];
       
    }
}