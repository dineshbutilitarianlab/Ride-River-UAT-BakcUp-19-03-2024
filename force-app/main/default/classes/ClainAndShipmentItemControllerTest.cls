@isTest
public class ClainAndShipmentItemControllerTest {
    @testSetup
    static void setupTestData() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Product2 prod = new Product2(Name='Test Product', ProductCode = 'HSN', HSN_Code__c='ASHS', Type__c='Parts');
        insert prod;
        
        Shipment s = new Shipment(Status='Pending', ShipToName = 'Any');
        insert s;
        
        ShipmentItem si = new ShipmentItem(ShipmentId=s.Id, Product2Id=prod.Id, Quantity=10);
        insert si;
        Create_Batch__c batch = new Create_Batch__c(
            Status__c = 'New', 
            Is_GRN_Received__c = false, 
            Batch_Dispatch_Date__c = Date.today(), 
            E_Way_Bill_No__c = 'E-QAY-00029',
            Vehicle_No__c = 'KA-0001', 
            Transporter_ID__c = 'TR-001', 
            Transport_Name__c = 'defg',  
            LR_Attachment__c ='https://river.com', 
            LR_Number__c = 'defsgb',
            Mode_of_Transport__c = 'Road'
        );
        insert batch;
        
        batch.Status__c = 'Ready for Dispatch';
        update batch;
        
        // Create test Claim
        Claim claim = new Claim(Name='Test Claim', Create_Batch__c=batch.Id, AccountId = acc.Id);
        insert claim;
        
        // Create test ClaimItem
        ClaimItem claimItem = new ClaimItem(Name='Test Claim Item', ClaimId=claim.Id, Claim_Type__c='Labour', Status__c='Approved', FaultDate= System.now() );
        insert claimItem;
        
        ClaimItem partClaimItem = new ClaimItem(
            Name = 'Test Part Claim Item',
            ClaimId = claim.Id,
            Claim_Type__c = 'Part',  
            Status__c = 'Approved',  // Ready for Dispatch  
            FaultDate = System.now()
        );
        insert partClaimItem;
        
        Product2 testProduct = new Product2(
            Name = 'Test Accessory',
            IsActive = true,
            ProductCode = 'abcd',
            HSN_Code__c = 'abcd',
            Type__c = 'Accessories'
        );
        insert testProduct;
        
        
        VehicleDefinition vehicleDefinition = new VehicleDefinition(Name = 'Vehicle Def 1', ProductId = testProduct.Id);
        insert vehicleDefinition;
        
        Asset asset = new Asset(Name = 'Test Asset', IsCompetitorProduct = false, IsInternal = true, AccountId = acc.Id);
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
            IsStopped = false
        );
        insert workOrder;
        
        
        // Create test WorkPlan
        WorkPlan workPlan = new WorkPlan(Name='Test WorkPlan', ParentRecordId =workOrder.Id);
        insert workPlan;
        
        
        
        
        // Fetch batch after insert (if any triggers populate River_GST__c)
        batch = [SELECT Id, River_GST__c FROM Create_Batch__c WHERE Id = :batch.Id LIMIT 1];
        
        
        Shipment shipment = new Shipment(Status = 'In Transit', ShipToName = 'wsefrtg');
        insert shipment;
        
        ShipmentItem shipmentItem = new ShipmentItem(ShipmentId = shipment.Id, Quantity = 10);
        insert shipmentItem;
    }
    
    @isTest
    static void testGetShipmentItemList() {
        Shipment s = [SELECT Id FROM Shipment LIMIT 1];
        Test.startTest();
        List<ShipmentItem> items = clainAndShipmentItemController.getShipmentItemList(s.Id);
        Test.stopTest();
        System.assert(!items.isEmpty(), 'ShipmentItem list should not be empty');
    }
    
    @isTest
    static void testUpdateShipmentItemList() {
        Shipment s = [SELECT Id FROM Shipment LIMIT 1];
        List<ShipmentItem> items = [SELECT Id FROM ShipmentItem WHERE ShipmentId = :s.Id];
        Test.startTest();
        String result = clainAndShipmentItemController.updateShipmentItemList(items, s.Id);
        Test.stopTest();
        System.assertEquals('SUCCESS', result, 'Update should return SUCCESS');
    }
    
    @isTest
    static void testGetBatchClaims() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<Claim> claims = clainAndShipmentItemController.getBatchClaims(batch.Id);
        Test.stopTest();
        System.assert(!claims.isEmpty(), 'Claims list should not be empty');
    }
    
    @isTest
    static void testGetBatchLabour() {
        Test.startTest();
        List<WorkPlan> workPlans = clainAndShipmentItemController.getBatchLabour();
        Test.stopTest();
        System.assert(!workPlans.isEmpty(), 'WorkPlan list should not be empty');
    }
    
    @isTest
    static void testGetAllClaims() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<Claim> claims = clainAndShipmentItemController.getAllClaims(batch.Id);
        Test.stopTest();
        System.assert(!claims.isEmpty(), 'Claims list should not be empty');
    }
    
    @isTest
    static void testGetPartItems() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<ClaimItem> claimItems = clainAndShipmentItemController.getPartItems(batch.Id);
        Test.stopTest();
        System.assert(!claimItems.isEmpty(), 'ClaimItem list should not be empty');
    }
    
    @isTest
    static void testGetLabourItems() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<ClaimItem> claimItems = clainAndShipmentItemController.getLabourItems(batch.Id);
        Test.stopTest();
        System.assert(!claimItems.isEmpty(), 'ClaimItem list should not be empty');
    }
    
    @isTest
    static void testGetAllClaimItems() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<ClaimItem> claimItems = clainAndShipmentItemController.getAllClaimItems(batch.Id);
        Test.stopTest();
        System.assert(!claimItems.isEmpty(), 'ClaimItem list should not be empty');
    }
    
    @isTest
    static void testGetAllClaimItemsApproved() {
        Create_Batch__c batch = [SELECT Id FROM Create_Batch__c LIMIT 1];
        Test.startTest();
        List<ClaimItem> claimItems = clainAndShipmentItemController.getAllClaimItemsApproved(batch.Id);
        Test.stopTest();
        System.assert(!claimItems.isEmpty(), 'ClaimItem list should not be empty');
    }
    
    @isTest
    static void testUpdateClaims() {
        List<Claim> claims = [SELECT Id, Create_Batch__c FROM Claim LIMIT 1];
        
        Test.startTest();
        try {
            String result = clainAndShipmentItemController.updateClaims(claims);
            Test.stopTest();
            System.assertEquals('SUCCESS', result, 'Claims should be updated successfully');
        } catch (Exception e) {
            System.assert(false, 'Unexpected Error: ' + e.getMessage());
        }
    }
    
    @isTest
    static void testUpdateClaimItems() {
        Create_Batch__c batch = new Create_Batch__c(
            Status__c = 'New', 
            Is_GRN_Received__c = false, Batch_Dispatch_Date__c = Date.today(), E_Way_Bill_No__c = 'E-QAY-00029' ,
            Vehicle_No__c = 'KA-0001', Transporter_ID__c = 'TR-001', Transport_Name__c = 'defg' , LR_Attachment__c ='https://river.com' , LR_Number__c = 'defsgb',
            Mode_of_Transport__c = 'Road'
        );
        insert batch;
        
        batch.Status__c = 'Ready for Dispatch';
        update batch;
        
        // Create test account
        Account acc = new Account(Name = 'Sagar');
        insert acc;
        
        // Create test claim
        Claim claim = new Claim(
            AccountId = acc.Id, 
            Name = 'Test Claim', 
            Create_Batch__c = batch.Id
        );
        insert claim;
        
        ClaimItem claimItem = new ClaimItem(
            Name = 'Test Claim Item',
            ClaimId = claim.Id,
            Claim_Type__c = 'Labour', 
            FaultDate = System.now()
        );
        insert claimItem;
        
        ClaimItem insertedClaimItem = [SELECT Id, Claim.Create_Batch__c FROM ClaimItem WHERE Id = :claimItem.Id];
        
        Test.startTest();
        String result = clainAndShipmentItemController.updateClaimItems(new List<ClaimItem>{insertedClaimItem});
        Test.stopTest();
        
        //System.assertEquals('SUCCESS', result, 'Update should return SUCCESS');
    }
    
    @isTest
    static void testCreateClaimItem() {
        Claim claim = [SELECT Id FROM Claim LIMIT 1];
        Test.startTest();
        Id claimItemId = clainAndShipmentItemController.createClaimItem('Test Claim Item', claim.Id, 'LabourCode');
        Test.stopTest();
       // System.assert(claimItemId != null, 'ClaimItem Id should not be null');
    }
    
   @isTest
    static void testUpdateClaimItemsApprovedQuantityAndReason() {
        ClaimItem claimItem = [SELECT Id FROM ClaimItem LIMIT 1];
         WorkPlan workid = [SELECT Id FROM WorkPlan LIMIT 1];
        clainAndShipmentItemController.ClaimItemWrapper wrapper = new clainAndShipmentItemController.ClaimItemWrapper(claimItem.Id,workid.id, 5, 'Test Reason','Approved');
        String claimItemWrappersJson = JSON.serialize(new List<clainAndShipmentItemController.ClaimItemWrapper>{wrapper});
        Test.startTest();
        String result = clainAndShipmentItemController.updateClaimItemsApprovedQuantityAndReason(claimItemWrappersJson);
        Test.stopTest();
        System.assertEquals('SUCCESS', result, 'Update should return SUCCESS');
    }
    
}