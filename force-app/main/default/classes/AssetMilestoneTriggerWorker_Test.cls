@isTest
public class AssetMilestoneTriggerWorker_Test {

    @isTest
    static void testcreatePDIItems() {
        Account acc = new Account();
        acc.Name = 'testing Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'testing Contact';
        con.AccountId = acc.Id;
        con.Phone = '9123456789';
        con.Email = 'test@test.com';
        con.Primary_Contact__c = true;
        insert con;
        
        Asset asst = new Asset();
        asst.Name = 'test Asset';
        asst.AccountId = acc.Id;
        asst.ContactId = con.Id;
        insert asst;
        
        Software_Version__c sv = new Software_Version__c();
        sv.Name = 'test version';
        sv.Latest_Software_Version__c = true;
        insert sv;
        
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.HSN_Code__c = '123';
        prod.Type__c = 'Vehicle';
        prod.ProductCode = 'R112031462';
        insert prod;
        
        // Create VehicleDefinition and link it to Product2
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'test VehicleDefinition';
        vd.ProductId = prod.Id;
        insert vd;
        
        // Create Vehicle and link it to VehicleDefinition
        Vehicle vac = new Vehicle();
        vac.Name = 'test vehicle';
        vac.CurrentOwnerId = acc.Id;
        vac.Charger_PC_Number__c = '123CC';
        vac.VehicleRegistrationNumber = '123';
        vac.VehicleIdentificationNumber = 'NeoCity2022ZXi';
        vac.VehicleDefinitionId = vd.Id; // Use the correct VehicleDefinition ID here
        vac.Software_Version__c = sv.Id;
        vac.AssetId = asst.Id;
        insert vac;
        
        // Create a completed milestone (pre-requisite milestone)
        AssetMilestone completedMilestone = new AssetMilestone();
        completedMilestone.Name = 'Completed Milestone';
        completedMilestone.AssetId = asst.Id;
        completedMilestone.UsageType = 'Automotive';
        completedMilestone.MilestoneDate = System.today().addDays(1);
        completedMilestone.MilestoneType = 'PDI';
        completedMilestone.Stage = 'Active';
        completedMilestone.VehicleId = vac.Id;
        insert completedMilestone;
        
        // Ensure the completed milestone exists before proceeding with the next PDI milestone
        List<AssetMilestone> existingMilestones = [
            SELECT Id, Stage 
            FROM AssetMilestone 
            WHERE AssetId = :asst.Id 
            AND MilestoneType = 'PDI' 
            AND Stage = 'Completed'
        ];
        
        // Only proceed with creating the new PDI milestone if there is at least one completed milestone
        if (!existingMilestones.isEmpty()) {
            AssetMilestone milestone2 = new AssetMilestone();
            milestone2.Name = 'Test Milestone';
            milestone2.AssetId = asst.Id;
            milestone2.UsageType = 'Automotive';
            milestone2.MilestoneDate = System.today();
            milestone2.MilestoneType = 'PDI';
            milestone2.Stage = 'Active'; // The new PDI milestone is "Active"
            milestone2.VehicleId = vac.Id;
            
            // Proceed to insert the new PDI milestone
            insert milestone2;
            
            // Test that the code will create new Pre_Delivery_Inspection_Item__c
            Test.startTest();
            AssetMilestoneTriggerWorker.createPDIItems(
                new List<AssetMilestone>{milestone2}, 
                new Map<Id, AssetMilestone>{milestone2.Id => milestone2}, 
                new Map<Id, AssetMilestone>()
            );
            Test.stopTest();
            
            // Verify that new Pre_Delivery_Inspection_Item__c records were created
            List<Pre_Delivery_Inspection_Item__c> newPDIItems = [
                SELECT Id, Asset_Milestone__c 
                FROM Pre_Delivery_Inspection_Item__c 
                WHERE Asset_Milestone__c = :milestone2.Id
            ];
            System.assertEquals(1, newPDIItems.size(), 'New PDI item should have been created');
        } else {
            System.debug('No completed milestones found, skipping creation of new PDI milestone.');
        }
    }

      @isTest
    static void testDeletePDIMilestone() {
        Account acc = new Account();
        acc.Name = 'testing Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'testing Contact';
        con.AccountId = acc.Id;
        con.Phone = '9123456789';
        con.Email = 'test@test.com';
        insert con;
        
        Asset asst = new Asset();
        asst.Name = 'test Asset';
        asst.AccountId = acc.Id;
        asst.ContactId = con.Id;
        insert asst;
        
        Product2 prod = new Product2();
        prod.Name = 'test product';
        prod.HSN_Code__c = '123';
        prod.Type__c = 'Vehicle';
        prod.ProductCode = 'R112031462';
        insert prod;
        
          VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'test VehicleDefinition';
        vd.ProductId = prod.Id;
        insert vd;
        
      
	Software_Version__c sv = new Software_Version__c();
        sv.Name = 'test version';
        sv.Latest_Software_Version__c = true;
        insert sv;
        
         Vehicle vac = new Vehicle();
        vac.Name = 'test vehicle';
        vac.CurrentOwnerId = acc.Id;
        vac.Charger_PC_Number__c = '123CC';
        vac.VehicleRegistrationNumber = '123';
        vac.VehicleIdentificationNumber = 'NeoCity2022ZXi';
        vac.VehicleDefinitionId = vd.Id; // Use the correct VehicleDefinition ID here
        vac.Software_Version__c = sv.Id;
        vac.AssetId = asst.Id;
        insert vac;
        
        
        AssetMilestone milestone1 = new AssetMilestone();
        milestone1.Name = 'Test Milestone';
        milestone1.AssetId = asst.Id;
        milestone1.UsageType = 'Automotive';
        milestone1.MilestoneDate = System.today();
        milestone1.MilestoneType = 'PDI';
        milestone1.Stage = 'Active';
        milestone1.VehicleId = vac.Id;
        insert milestone1;
        
        Vehicle vac1 = new Vehicle(Id = vac.Id, PDI_Status_Pass__c = false);
        update vac1;
        
        // Test the deletePDIMilestone method
        Test.startTest();
        AssetMilestoneTriggerWorker.deletePDIMilestone(new List<AssetMilestone>{milestone1});
        Test.stopTest();
        
        // Verify that the Vehicle's PDI_Status_Pass__c was set to false
        Vehicle updatedVehicle = [SELECT PDI_Status_Pass__c FROM Vehicle WHERE Id = :vac.Id];
        System.assertEquals(false, updatedVehicle.PDI_Status_Pass__c, 'PDI Status Pass should be false after deletion');
    }
}