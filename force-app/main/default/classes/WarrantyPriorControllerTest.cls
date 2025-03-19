@isTest
public class WarrantyPriorControllerTest {
    
    @testSetup
    static void setup() {
         Account testAccount = new Account(Name = 'Test Account', Type = 'Customer');
        insert testAccount;	

        WorkOrder testWorkOrder = new WorkOrder(
            AccountId = testAccount.Id
        );
        insert testWorkOrder;
        
        // Insert test data for Warranty Prior
        Warranty_Prior__c warranty = new Warranty_Prior__c(
            VIN__c = '1HGBH41JXMN109186',  // Sample VIN
            Registration_Number__c = 'ABC1234',  // Sample Registration Number
            Motor_Number__c = 'MN987654321',  // Sample Motor Number
            Odometer_Reading__c = 12000,  // Sample Odometer Reading
            Warranty_Prior_Date__c = Date.today(),  // Current date
            Type_of_Warranty__c = 'Parts',  // Example warranty type
            Job_Card__c = testWorkOrder.Id,  // Sample Job Card
            ASM_Feedback__c = 'Positive feedback',  // Example ASM feedback
            FFIR_Number__c = 'FFIR12345',  // Sample FFIR Number
            Dealer_Observation__c = 'No issues found',  // Sample dealer observation
            Media__c = 'Media uploaded',  // Example media field
            Total_Claim_Amount__c = 1500.0,  // Sample claim amount
            Standard_Values__c = 'Standard'  // Sample standard value
        );
        insert warranty;
        
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
            IsStopped = false
        );
        insert workOrder;
        
        List<WorkOrderLineItem> lineItems = new List<WorkOrderLineItem>();
        for (Integer i = 0; i < 3; i++) {
            lineItems.add(new WorkOrderLineItem(
                Warranty_Prior__c = warranty.Id,
                Tax__c = 10 + i,
                Amount_per_Hour__c = 20 + i,
                WorkOrderId = workOrder.Id,
                RR_Product__c = testProduct.Id
            ));
        }
        insert lineItems;   
        
        // Insert WorkPlan records
        List<WorkPlan> workPlans = new List<WorkPlan>();
        for (Integer i = 0; i < 3; i++) {
            workPlans.add(new WorkPlan(
                Warranty_Prior__c = warranty.Id,
                Tax__c = 10 + i,  // Sample tax values for testing
                ParentRecordId = workOrder.id,
                Name = 'test Work Plan',
                Amount_per_Hour__c = 15 + i  // Sample values for testing
            ));
        }
        insert workPlans;
    }
    
    @isTest
    static void testGetWarrantyPrior() {
        Warranty_Prior__c warranty = [SELECT Id,Job_Card__c FROM Warranty_Prior__c LIMIT 1];
        Test.startTest();
        Warranty_Prior__c fetchedWarranty = WarrantyPriorController.getWarrantyPrior(warranty.Job_Card__c);
        Test.stopTest();
        System.assertNotEquals(null, fetchedWarranty, 'Warranty Prior should not be null');
    }
    
    @isTest
    static void testGetRelatedWorkOrderLineItems() {
        // Query existing WorkOrderLineItem records
        Warranty_Prior__c warranty = [SELECT Id FROM Warranty_Prior__c LIMIT 1];
        List<WorkOrderLineItem> lineItems = [
            SELECT Id, Warranty_Prior__c, Tax__c, Amount_per_Hour__c, Quantity
            FROM WorkOrderLineItem
            WHERE Warranty_Prior__c = :warranty.Id
            LIMIT 3
        ];
        
        
        
        Test.startTest();
        List<WorkOrderLineItem> fetchedLineItems = WarrantyPriorController.getRelatedWorkOrderLineItems(warranty.Id);
        Test.stopTest();
        
        //  System.assertEquals(3, fetchedLineItems.size(), 'There should be 3 Work Order Line Items');
    }
    
    @isTest
    static void testGetRelatedWorkOrderLineItemsOnlyCausal(){
        Warranty_Prior__c warranty = [SELECT Id FROM Warranty_Prior__c LIMIT 1];
        List<WorkOrderLineItem> lineItems = [
            SELECT Id, Warranty_Prior__c, Tax__c, Amount_per_Hour__c, Quantity, Replacement_Type__c
            FROM WorkOrderLineItem
            WHERE Warranty_Prior__c = :warranty.Id AND Replacement_Type__c = 'Causal'
            LIMIT 3
        ];
        
        Test.startTest();
        List<WorkOrderLineItem> fetchedLineItems1 = WarrantyPriorController.getRelatedWorkOrderLineItemsOnlyCausal(warranty.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetRelatedWorkPlans() {
        // Query existing WorkPlan records
        Warranty_Prior__c warranty = [SELECT Id FROM Warranty_Prior__c LIMIT 1];
        List<WorkPlan> workPlans = [
            SELECT Id, Warranty_Prior__c, Tax__c, Amount_per_Hour__c
            FROM WorkPlan
            WHERE Warranty_Prior__c = :warranty.Id
            LIMIT 3
        ];
        
        // If not enough work plans exist, insert new ones for the test
        if (workPlans.size() < 3) {
            // Query additional WorkPlans from Salesforce
            List<WorkPlan> additionalWorkPlans = [
                SELECT Id, Warranty_Prior__c, Tax__c, Amount_per_Hour__c
                FROM WorkPlan
                WHERE Warranty_Prior__c = :warranty.Id
                LIMIT : (3 - workPlans.size())
            ];
            
        }
        
        
        Test.startTest();
        List<WorkPlan> fetchedWorkPlans = WarrantyPriorController.getRelatedWorkPlans(warranty.Id);
        Test.stopTest();
        
        // System.assertEquals(3, fetchedWorkPlans.size(), 'There should be 3 Work Plans');
    }
    
    @isTest
    static void testUpdateParts() {
        // Query existing WorkOrderLineItem records
        List<WorkOrderLineItem> lineItems = [
            SELECT Id, Tax__c, Amount_per_Hour__c FROM WorkOrderLineItem LIMIT 2
        ];
        
        List<Map<String, Object>> partsDraftValues = new List<Map<String, Object>>();
        
        WorkOrderLineItem item1 = lineItems[0];
        
        
        Map<String, Object> draftValue1 = new Map<String, Object>();
        draftValue1.put('Id', item1.Id);
        draftValue1.put('Tax__c', Decimal.valueOf(15)); // Pass Decimal
        draftValue1.put('Amount_per_Hour__c', Decimal.valueOf(20)); // Pass Decimal
        partsDraftValues.add(draftValue1);
        
        // Second part as String values
        WorkOrderLineItem item2 = lineItems[1];
        Map<String, Object> draftValue2 = new Map<String, Object>();
        draftValue2.put('Id', item2.Id);
        draftValue2.put('Tax__c', '12'); // Pass String
        draftValue2.put('Amount_per_Hour__c', '18'); // Pass String
        partsDraftValues.add(draftValue2);
        
        Test.startTest();
        WarrantyPriorController.updateParts(partsDraftValues);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateAdditionalParts() {
        List<WorkOrderLineItem> lineItems = [
            SELECT Id, Tax__c, Amount_per_Hour__c FROM WorkOrderLineItem LIMIT 2
        ];
        
        if (lineItems.isEmpty()) {
            System.assert(false, 'No WorkOrderLineItem records found to test updateAdditionalParts');
        }
        
        for (WorkOrderLineItem item : lineItems) {
            item.Tax__c = 12.5;
            item.Amount_per_Hour__c = 50.0;
        }
        
        Test.startTest();
        WarrantyPriorController.updateAdditionalParts(lineItems);
        Test.stopTest();
        
        List<WorkOrderLineItem> updatedItems = [SELECT Tax__c, Amount_per_Hour__c FROM WorkOrderLineItem WHERE Id IN :lineItems];
        for (WorkOrderLineItem updatedItem : updatedItems) {
            System.assertEquals(12.5, updatedItem.Tax__c, 'Tax should be updated to 12.5');
            System.assertEquals(50.0, updatedItem.Amount_per_Hour__c, 'Amount per Hour should be updated to 50.0');
        }
    }
    
    @isTest
    static void testGetUserProfile() {
        Test.startTest();
        String profileName = WarrantyPriorController.getUserProfile();
        Test.stopTest();
        
        String expectedProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        
        System.assertEquals(expectedProfileName, profileName, 'Returned Profile Name should match the logged-in user’s profile');
    }
    
    @isTest
    static void testUpdateLabours() {
        // Query existing WorkPlan records
        List<WorkPlan> workPlans = [
            SELECT Id, Tax__c, Amount_per_Hour__c FROM WorkPlan LIMIT 2
        ];
        
        List<Map<String, Object>> labourDraftValues = new List<Map<String, Object>>();
        
        for (WorkPlan plan : workPlans) {
            Map<String, Object> draftValue = new Map<String, Object>();
            draftValue.put('Id', plan.Id);
            draftValue.put('Tax__c', '8');
            draftValue.put('Amount_per_Hour__c', '22');
            labourDraftValues.add(draftValue);
        }
        
        Test.startTest();
        WarrantyPriorController.updateLabours(labourDraftValues);
        Test.stopTest();
        
        List<WorkPlan> updatedPlans = [SELECT Tax__c, Amount_per_Hour__c FROM WorkPlan WHERE Id IN :workPlans];
        for (WorkPlan plan : updatedPlans) {
            System.assertEquals(8, plan.Tax__c, 'Tax should be updated to 8');
            System.assertEquals(22, plan.Amount_per_Hour__c, 'Amount per Hour should be updated to 22');
        }
    }
    
    @isTest
    static void testUpdateWarrantyPrior() {
        // Query existing Warranty Prior record
        Warranty_Prior__c warranty = [SELECT Id FROM Warranty_Prior__c LIMIT 1];
        
        Test.startTest();
        WarrantyPriorController.updateWarrantyPrior(
            warranty.Id,
            'Parts'
            
        );
        Test.stopTest();
        
        Warranty_Prior__c updatedWarranty = [SELECT Type_of_Warranty__c, ASM_Feedback__c, FFIR_Number__c, Dealer_Observation__c, Media__c FROM Warranty_Prior__c WHERE Id = :warranty.Id];
        
        System.assertEquals('Parts', updatedWarranty.Type_of_Warranty__c, 'Type of Warranty should be updated');
        // System.assertEquals('Updated ASM Feedback', updatedWarranty.ASM_Feedback__c, 'ASM Feedback should be updated');
        //  System.assertEquals('FFIR123', updatedWarranty.FFIR_Number__c, 'FFIR Number should be updated');
        // System.assertEquals('Updated Dealer Observation', updatedWarranty.Dealer_Observation__c, 'Dealer Observation should be updated');
        //\ System.assertEquals('New Media', updatedWarranty.Media__c, 'Media should be updated');
    }
}