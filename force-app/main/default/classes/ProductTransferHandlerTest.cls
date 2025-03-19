@isTest
public class ProductTransferHandlerTest {
    
    @testSetup
    static void setupTestData() {
        
        Schema.Location l1 = new Schema.Location(); 
        l1.Name = 'Warehouse 1';
        l1.LocationType = 'Secondary';
        l1.IsInventoryLocation = true;
        insert l1;
        
        Schema.Location l2 = new Schema.Location(); 
        l2.Name = 'Warehouse 1';
        l2.LocationType = 'Secondary';
        l2.IsInventoryLocation = true;
        insert l2;
        
        Product2 extendedWarrantyProduct = new Product2(Name = 'Extended Warranty', IsActive = true, ProductCode = 'abcd', HSN_Code__c = 'abcd', Type__c = 'Vehicle');
        insert extendedWarrantyProduct;
        
        Product2 p1 = new Product2(Name = 'Warranty', IsActive = true, ProductCode = 'abcd', HSN_Code__c = 'abcd', Type__c = 'Vehicle');
        insert p1;
        
        Daily_Ledger__c dLeder = new Daily_Ledger__c(
            Product__c = p1.Id, Source_Location__c = l2.Id, Destination_Location__c = l1.Id, Ledger_Date__c = Date.today(), Intake_Quantity__c =2, Transfer_Quantity__c =4
        );
        insert dLeder;
        
        // Create sample Product Items (Product Inventory)
        List<ProductItem> productItems = new List<ProductItem>{
            new ProductItem(Inward_Quantity__c = 100, Transfer_Quantity__c = 50, QuantityOnHand =101.00, Product2Id = extendedWarrantyProduct.Id, LocationId = l1.Id),
                new ProductItem(Inward_Quantity__c = 200, Transfer_Quantity__c = 75, QuantityOnHand = 102.00, Product2Id = p1.Id, LocationId = l2.Id)
                };
                    insert productItems;
        
        // Create sample Locations
        
    }
    
    @isTest
    static void testInsertProductTransfer() {
        
        
        // Fetch sample ProductItem and Location
        ProductItem productItem = [SELECT Id FROM ProductItem LIMIT 1];
        Schema.Location location = [SELECT Id FROM Location LIMIT 1];
        Schema.Location location1 = [SELECT Id FROM Location LIMIT 1];
        Product2 p2 = [select Id from Product2 LIMIT 1];
        Daily_Ledger__c ledgers = [SELECT Id FROM Daily_Ledger__c LIMIT 1];
        
        // Insert ProductTransfer records
        List<ProductTransfer> transfers = new List<ProductTransfer>{
            new ProductTransfer(
                Product_Inventory__c = productItem.Id,
                QuantityReceived = 10,
                
                DestinationLocationId = location.Id,
                Product2Id = p2.Id,
                QuantitySent =12, 
                LR_Number__c= 'LR-123', 
                Driver_Phone__c = '123456',
                Daily_Ledger__c = ledgers.Id
            ),
                new ProductTransfer(
                    Product_Inventory__c = productItem.Id,
                    QuantitySent = 5,
                    
                    DestinationLocationId = location.Id,
                    Product2Id = p2.Id,
                    LR_Number__c= 'LR-123', 
                    Driver_Phone__c = '123456',
                    Daily_Ledger__c = ledgers.Id
                )
                };
                    insert transfers;
        
        // Assert inventory updates
        ProductItem updatedItem = [SELECT Inward_Quantity__c, Transfer_Quantity__c FROM ProductItem WHERE Id = :productItem.Id];
        
        
        // Insert daily ledger
        Daily_Ledger__c dLeder = new Daily_Ledger__c(
            Product__c = p2.Id, Source_Location__c = location.Id, Destination_Location__c = location1.Id, 
            Ledger_Date__c = Date.today(), Intake_Quantity__c =2, Transfer_Quantity__c =4
        );
        
        // System.assertEquals(2, ledgers.size(), 'Two ledgers should be created.');
    }
    
    @isTest
    static void testUpdateProductTransfer() {
        
        ProductItem productItem = [SELECT Id FROM ProductItem LIMIT 1];
        Schema.Location location = [SELECT Id FROM Location LIMIT 1];
        Product2 p2 = [select Id from Product2 LIMIT 1];
        Daily_Ledger__c dL = [select Id from Daily_Ledger__c LIMIT 1];
        
        // Insert ProductTransfer record
        ProductTransfer transfer = new ProductTransfer(
            Product_Inventory__c = productItem.Id,
            QuantityReceived = 10,
            DestinationLocationId = location.Id,
            Product2Id = p2.Id,
            QuantitySent =0, 
            LR_Number__c= 'LR-123', 
            Driver_Phone__c = '123456',
            Daily_Ledger__c = dL.Id
        );
        insert transfer;
        
        // Update the ProductTransfer record
        transfer.QuantityReceived = 20;
        update transfer;
        
        // Assert inventory updates
        ProductItem updatedItem = [SELECT Inward_Quantity__c FROM ProductItem WHERE Id = :productItem.Id];
        // System.assertEquals(120, updatedItem.Inward_Quantity__c, 'Inward quantity should be updated after transfer update.');
    }
    
    @isTest
    static void testDeleteProductTransfer() {
        
        ProductItem productItem = [SELECT Id FROM ProductItem LIMIT 1];
        Schema.Location location = [SELECT Id FROM Location LIMIT 1];
        Product2 p2 = [select Id from Product2 LIMIT 1];
        Daily_Ledger__c dL = [select Id from Daily_Ledger__c LIMIT 1];
        
        // Insert ProductTransfer record
        ProductTransfer transfer = new ProductTransfer(
            Product_Inventory__c = productItem.Id,
            QuantityReceived = 10,	
            DestinationLocationId = location.Id,
            Product2Id = p2.Id,
            QuantitySent =12, 
            LR_Number__c= 'LR-123', 
            Driver_Phone__c = '123456',
            Daily_Ledger__c = dL.Id
        );
        insert transfer;
        
        delete transfer;
        
        // Assert inventory updates
        ProductItem updatedItem = [SELECT Inward_Quantity__c FROM ProductItem WHERE Id = :productItem.Id];
        //System.assertEquals(100, updatedItem.Inward_Quantity__c, 'Inward quantity should revert after transfer deletion.');
    }
    
    @isTest
    static void testUpdateExistingLedgerQuantities() {
        // Setup sample data
        Schema.Location sourceLocation = new Schema.Location(Name = 'Source Warehouse', LocationType = 'Secondary', IsInventoryLocation = true);
        Schema.Location destinationLocation = new Schema.Location(Name = 'Destination Warehouse', LocationType = 'Secondary', IsInventoryLocation = true);
        insert new List<Schema.Location>{sourceLocation, destinationLocation};
            
            Product2 product = new Product2(Name = 'Sample Product', IsActive = true, ProductCode = 'SP123', HSN_Code__c = 'HSN001', Type__c = 'Vehicle');
        insert product;
        
        Daily_Ledger__c existingLedger = new Daily_Ledger__c(
            Product__c = product.Id, 
            Source_Location__c = sourceLocation.Id, 
            Destination_Location__c = destinationLocation.Id, 
            Ledger_Date__c = Date.today(), 
            Intake_Quantity__c = 0, 
            Transfer_Quantity__c = 5
        );
        insert existingLedger;
        
        ProductItem productItem = new ProductItem(Inward_Quantity__c = 100, Transfer_Quantity__c = 50, QuantityOnHand = 101.00, Product2Id = product.Id, LocationId = sourceLocation.Id);
        insert productItem;
        
        // Create a ProductTransfer record to update the ledger
        ProductTransfer transfer = new ProductTransfer(
            Product_Inventory__c = productItem.Id,
            QuantityReceived = 10,
            DestinationLocationId = destinationLocation.Id,
            Product2Id = product.Id,
            QuantitySent = 15,
            LR_Number__c = 'LR-456',
            Driver_Phone__c = '1234567890',
            Daily_Ledger__c = existingLedger.Id
        );
        insert transfer;
        
        // Assert ledger updates
        Daily_Ledger__c updatedLedger = [SELECT Intake_Quantity__c, Transfer_Quantity__c FROM Daily_Ledger__c WHERE Id = :existingLedger.Id];
        System.assertEquals(10, updatedLedger.Intake_Quantity__c, 'Intake Quantity should be updated.');
        System.assertEquals(20, updatedLedger.Transfer_Quantity__c, 'Transfer Quantity should be updated.');
    }
    
}