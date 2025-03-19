/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@IsTest
public class ProductConsumedTriggerHandlerTest {
    @IsTest
    static void testProductConsumedTriggerHandler(){
        
        Account acc = new Account(Name = 'Test data');
        insert acc;
        
        Schema.Location testLocation = new Schema.Location(Name = 'Test Location', LocationType = 'Secondary',State__c = 'Karnataka',IsInventoryLocation=true);
        insert testLocation;
        
        Contact con = new Contact(LastName ='Dinesh 1',Phone = '7834878789',AccountId = acc.id,Location__c =testLocation.id );
        insert con;
        
         Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            State__c = 'Karnataka',
            IsActive = true
        );
        update standardPricebook;
        
        Product2 product1 = new Product2(Name = 'Test Product 1', IsActive = true, ProductCode = 'SDFGH3456', HSN_Code__c = 'FGHJK367', Type__c = 'Parts');
        insert product1;
        
        
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = standardPricebook.Id, Product2Id = product1.Id, UnitPrice = 100, IsActive = true);
        insert pricebookEntry1;
        
        
        WorkOrder workOrder = new WorkOrder(AccountId = acc.Id, Status = 'New', Subject = 'Test Work Order');
        insert workOrder;
        
        ProductItem p = new ProductItem( LocationId=testLocation.Id, Product2Id=product1.Id,QuantityOnHand=10000);
        insert p;
        
        WorkOrderLineItem workOrderLineItem1 = new WorkOrderLineItem(
            WorkOrderId = workOrder.Id,  
            Quantity = 2, 
            UnitPrice = 120,  
           // Product2Id=product1.Id,
            PricebookEntryId = pricebookEntry1.Id 
        );
        
        insert workOrderLineItem1;
        
        ProductConsumed pc = new ProductConsumed();
        pc.WorkOrderId = workOrder.Id;
        pc.WorkOrderLineItemId = workOrderLineItem1.Id;
        pc.QuantityConsumed =workOrderLineItem1.Quantity;
        pc.Quantity_Consumed__c = workOrderLineItem1.Quantity;
        pc.PricebookEntryId = pricebookEntry1.Id;
        pc.Product__c=workOrderLineItem1.Product2Id;
        pc.ProductItemId =p.Id;
        insert pc;
        
        Test.startTest();
        pc.Quantity_Consumed__c = 3;
        update pc;
        delete pc;
        Test.stopTest();
    }

}