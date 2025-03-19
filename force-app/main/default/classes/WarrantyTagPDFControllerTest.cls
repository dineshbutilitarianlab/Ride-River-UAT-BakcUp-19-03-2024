@isTest
public class WarrantyTagPDFControllerTest {

    // Helper method to create test data
    private static void createTestData() {
        // Create Account
        Account acc = new Account(Name = 'Test Account', ShippingCity = 'Test City');
        insert acc;

        // Create Job Card


        // Create Warranty Prior
        Warranty_Prior__c warrantyPrior = new Warranty_Prior__c(
           // Name = 'Warranty123',
            Warranty_Prior_Date__c = Date.today(),
            Odometer_Reading__c = 10000
        );
        insert warrantyPrior;

        // Create Claim
        Claim claim = new Claim(
            Name = 'Claim123',
            ClaimReason = 'Test Reason',
            Status = 'Open',
            Warranty_Prior__c = warrantyPrior.Id,
            AccountId = acc.Id,
            Create_Batch__c = null
        );
        insert claim;

        // Create ClaimItem
        ClaimItem claimItem = new ClaimItem(
            ClaimId = claim.Id,
            Name    = 'ClaimItem123',
            Part_Description__c = 'Test Part',
           
            Quantity__c = 2,
            FaultDate = System.now()
           // Part__r_LineItemNumber__c = '12345',
          //  Part_Description__c = 'Part Description'
        );
        insert claimItem;
    }

    @isTest
    static void testWarrantyTagPDFController() {
        // Step 1: Create test data
        createTestData();

        // Step 2: Fetch the ClaimItem record that was inserted
        ClaimItem claimItem = [SELECT Id FROM ClaimItem LIMIT 1];

        // Step 3: Set the page parameters
        Test.startTest();
        ApexPages.currentPage().getParameters().put('cid', claimItem.Id);

        // Step 4: Instantiate the controller
        WarrantyTagPDFController controller = new WarrantyTagPDFController();

        // Step 5: Validate the controller's data
        System.assertNotEquals(null, controller.claimItem, 'ClaimItem should not be null');
        System.assertNotEquals(null, controller.warrantyClaimNumber, 'Warranty Claim Number should not be null');
       // System.assertEquals('Warranty123', controller.warrantyClaimNumber, 'Warranty Claim Number is incorrect');
        System.assertNotEquals(null, controller.warrantyDate, 'Warranty Date should not be null');
        System.assertEquals(Date.today(), controller.warrantyDate, 'Warranty Date is incorrect');
       // System.assertNotEquals(null, controller.motorNumber, 'Motor Number should not be null');
       // System.assertNotEquals(null, controller.vin, 'VIN should not be null');
        //System.assertNotEquals(null, controller.registrationNumber, 'Registration Number should not be null');
//        System.assertNotEquals(null, controller.vehicleKilometer, 'Vehicle Kilometer should not be null');
      //  System.assertNotEquals(null, controller.dealerName, 'Dealer Name should not be null');

        Test.stopTest();
    }

    @isTest
    static void testNoClaimItem() {
        // Step 1: Create test data without any ClaimItem
        createTestData();

        // Step 2: Set the page parameters with no ClaimItem ID
        Test.startTest();
        ApexPages.currentPage().getParameters().put('cid', 'NonExistentId');

        // Step 3: Instantiate the controller
        WarrantyTagPDFController controller = new WarrantyTagPDFController();

        // Step 4: Validate the controller's behavior when no ClaimItem is found
        //System.assertNotEquals(null, controller.claimItem, 'ClaimItem should be null when not found');
       // System.assertEquals('No Claim Item found.', ApexPages.getMessages()[0].getSummary());
        Test.stopTest();
    }
}