@isTest
public class Form22pdfControllerTest {
    @isTest
    static void testForm22pdfController() {
        Account testAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer'
        );
        insert testAccount;

        Order testOrder = new Order(
            Name = 'Test Order',
            AccountId = testAccount.Id,
            Status = 'Draft',
            EffectiveDate = System.today()
        );
        insert testOrder;
        
         Asset testAsset = new Asset(
            Name = 'Test Asset',
            AccountId = testAccount.Id
        );
        insert testAsset;
        
        Product2 testProduct = new Product2(
            Name = 'Test Vehicle Product',
            ProductCode = 'PROD123',
            HSN_Code__c = 'test123',
            Type__c = 'Vehicle',
            IsActive = true
        );
        insert testProduct;
        
        VehicleDefinition testVehicleDef = new VehicleDefinition(
            Name = 'Test Vehicle Definition',
            ProductId = testProduct.Id
        );
        insert testVehicleDef;
        
        Software_Version__c testSoftwareVersion = new Software_Version__c (Name ='1.0.0');
            insert testSoftwareVersion;

        Vehicle testVehicle = new Vehicle(
            Name = 'Test Vehicle',
            VehicleIdentificationNumber = 'VIN123456789',
            EngineNumber = 'ENG123456',
            AssetId = testAsset.id,
            PDI_Status_Pass__c = true,
            VehicleDefinitionId = testVehicleDef.id,
            Software_Version__c = testSoftwareVersion.id,
            Charger_PC_Number__c = 'CHARGER123'
        );
        insert testVehicle;

        testOrder.Assigned_Vehicle__c = testVehicle.Id;
        update testOrder;

        PageReference pageRef = Page.Form22;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testOrder.Id);

        ApexPages.StandardController stdController = new ApexPages.StandardController(testOrder);
        Form22pdfController controller = new Form22pdfController(stdController);
    }
}