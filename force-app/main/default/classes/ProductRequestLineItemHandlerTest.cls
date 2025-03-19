@isTest
public class ProductRequestLineItemHandlerTest {
    
    @isTest
    static void testProductLineItemUnitPrice() {
        Account acc = new Account(Name = 'Test data');
        insert acc;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pricebook = new Pricebook2(Id = pricebookId, State__c = 'Karnataka', IsActive = true);
        update pricebook;
        
        Product2 product1 = new Product2(Name = 'Test Product 1', IsActive = true,ProductCode = 'SDFGH456',HSN_Code__c = 'FGHJK67',Type__c = 'Parts');
        insert new List<Product2>{product1};
            
            PricebookEntry pricebookEntry1 = new PricebookEntry(
                Pricebook2Id = pricebook.Id,
                Product2Id = product1.Id,
                UnitPrice = 120,
                Dealer_List_Price__c = 120,
                CGST__c = 5,
                IGST__c = 10,
                SGST__c = 5,
                IsActive = true
            );
        insert new List<PricebookEntry>{pricebookEntry1};
            // Create a ProductRequest with Destination Location
            Schema.Location testLocation = new Schema.Location(Name = 'Test Location', LocationType = 'State',State__c = 'Karnataka');
        insert testLocation;
        
        ProductRequest productRequest = new ProductRequest(
            Account__c = acc.id,
            Destination_Location__c = testLocation.Id,
            ShipmentType = 'VOR'
        );
        insert productRequest;
        // Create ProductRequestLineItem records        
        ProductRequestLineItem lineItem2 = new ProductRequestLineItem(
            ParentId = productRequest.Id,
            Product2Id = product1.Id,
            Price_Book__c = pricebook.id,
            QuantityRequested = 33
        );
        insert new List<ProductRequestLineItem>{ lineItem2};
            }
}