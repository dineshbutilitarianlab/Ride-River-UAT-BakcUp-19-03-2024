@isTest
public class form22ControllerTest {
    
    @testSetup
    static void setupData() {
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

        Software_Version__c testSoftwareVersion = new Software_Version__c(
            Name = '1.0.0'
        );
        insert testSoftwareVersion;

        Vehicle testVehicle = new Vehicle(
            Name = 'Test Vehicle',
            VehicleIdentificationNumber = 'VIN123456789',
            EngineNumber = 'ENG123456',
            AssetId = testAsset.Id,
            PDI_Status_Pass__c = true,
            VehicleDefinitionId = testVehicleDef.Id,
            Software_Version__c = testSoftwareVersion.Id,
            Charger_PC_Number__c = 'CHARGER123'
        );
        insert testVehicle;

        testOrder.Assigned_Vehicle__c = testVehicle.Id;
        update testOrder;
    }

    @isTest
    static void testHandleOrderUpdate() {
        Order testOrder = [SELECT Id, Status FROM Order LIMIT 1];

        testOrder.Status = 'Vehicle Delivered';
        Map<Id, Order> oldOrderMap = new Map<Id, Order>();
        oldOrderMap.put(testOrder.Id, new Order(Id = testOrder.Id, Status = 'Draft'));

        Test.startTest();
        form22Controller.handleOrderUpdate(new List<Order>{testOrder}, oldOrderMap);
        Test.stopTest();

        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :testOrder.Id];
    }
}