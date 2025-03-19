@IsTest(SeeAllData=true)
public class ProductRequestLineControllerTest {
    
    @isTest
    static void testData(){
        Account acc = new Account(Name = 'Test data');
        insert acc;
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pricebook = new Pricebook2(Id = pricebookId, State__c = 'Karnataka', IsActive = true);
        update pricebook;
        Product2 product1 = new Product2(Name = 'Test Product 1', IsActive = true,ProductCode = 'SDFGH456',HSN_Code__c = 'FGHJK67',Type__c = 'Parts');
        insert product1;
        PricebookEntry pricebookEntry1 = new PricebookEntry(Pricebook2Id = pricebook.Id,Product2Id = product1.Id,UnitPrice = 120,Dealer_List_Price__c = 120,CGST__c = 5,IGST__c = 10,SGST__c = 5,IsActive = true);
        insert pricebookEntry1;
        Schema.Location testLocation = new Schema.Location(Name = 'Test Location', LocationType = 'State',State__c = 'Karnataka',Price_Book__c = pricebook.id);
        insert testLocation;
        ProductRequest productRequest = new ProductRequest(Account__c = acc.id,Destination_Location__c = testLocation.Id,ShipmentType = 'VOR');
        insert productRequest;       
        ProductRequestLineItem lineItem2 = new ProductRequestLineItem( ParentId = productRequest.Id,Product2Id = product1.Id,Price_Book__c = pricebook.id,QuantityRequested = 33);
        insert lineItem2;
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113248', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Order order = new Order(
            AccountId = acc.Id,Dealer__c = dealerAccount.Id,Website_Order_Id__c = 'RTYU456789',EffectiveDate = Date.today(),Status = 'Draft',
            Description = 'Nothing 1',Handling_Charges__c = 1000, Insurance_Amount__c = 1000,RTO_Charges__c = 1000,Notify_By_SMS__c = true,
            Notify_By_Email__c = true,BillingStreet = 'Bangalore 1',BillingCity = 'Bangalore',BillingState = 'Karnataka',BillingPostalCode = '574236',BillingCountry = 'India',pricebook2Id = test.getStandardPricebookId());
        Insert order;
        
       // Contact c = New Contact(LastName = 'Test', AccountID = acc.id,Role_Type__c='Service',Phone = '8998342345');
        //insert c;
        
        Test.startTest();
        List<ProductRequestLineItem> PRLI = [SELECT Id from ProductRequestLineItem];  //ProductRequestLineController.getProductRequestItems(productRequest.id);
        List<ProductRequestLineController.ProductRequestWrapper> results = ProductRequestLineController.getProductRequestItemsWithAvailableQty(productRequest.Id);
        ProductRequestLineController.createProductTransferFromInitiateAllotment(PRLI, null);
        ProductRequestLineController.createProductTransferFromInitiateAllotment(PRLI, order.Id);
        
       // String data =  ProductRequestLineController.createOrderOrderLineItemList(PRLI);
        
        List<Map<String, Object>> updatedItems = new List<Map<String, Object>>(); 
        Map<String, Object> itemData = new Map<String, Object>(); 
        itemData.put('Id', lineItem2.Id); 
        itemData.put('Alloted_Quantity__c', 15); 
        updatedItems.add(itemData);
        ProductRequestLineController.updateRequestLineItem(updatedItems);
        String Data3 =   ProductRequestLineController.updateProductRequestLineItem(updatedItems);
       // OrderItem ord = ProductRequestLineController.createOrderItem(order,lineItem2,pricebookEntry1.id,4,pricebook.Id);
        
        User use = [SELECt Id,Name,Profile.Name from User WHeRE Profile.Name = 'Sales Manager (Partner)' AND isActive = true AND  Contact.Location__c != null LIMIT 1];
        List<Product2> Data1 =   ProductRequestLineController.getLogedInUserRelatedLocationPOLI(use.id);
        String Data2 =   ProductRequestLineController.getCurrentLogedUserAccountRecord(use.id);
        String Data6 =   ProductRequestLineController.createPurchaseorder('VOR',use.id);
        Shipment ship = [SELECT Id,SourceLocationId,DestinationLocationId,Order__c,ShipmentNumber FROM Shipment LIMIT 1];
        List<ShipmentItem> Data4 =   ProductRequestLineController.getPOrelatedPLI(ship.id);
        Shipment Data5 =   ProductRequestLineController.getShipmentDetail(ship.id);
        
        
        List<ShipmentItem>shiptmentList = [SELECT Id,ShipmentId,Shipment.SourceLocationId,Shipment.DestinationLocationId,Product2Id FROM ShipmentItem ];
        List<Map<String, Object>> updatedItems1 = new List<Map<String, Object>>();
        Map<String, Object> itemData1 = new Map<String, Object>();
        itemData1.put('Product2Id', shiptmentList[0].Product2Id);
        itemData1.put('ShipmentId', shiptmentList[0].ShipmentId);
        itemData1.put('Received_Quantity__c', 10); // Example quantity
        itemData1.put('DestinationLocationId', shiptmentList[0].Shipment.DestinationLocationId);  // Example Destination Location
        itemData1.put('SourceLocationId', shiptmentList[0].Shipment.SourceLocationId);
        itemData1.put('Id', shiptmentList[0].Id);  // Reference to the ShipmentItem
        updatedItems1.add(itemData1);
        
        String result = ProductRequestLineController.TransferReceiveGRNToProductTransfer(updatedItems1);
        
        String jsonData = JSON.serialize(PRLI);
        String jsonData1 = ProductRequestLineController.createProductRequestLineItems(jsonData);
        ProductRequestLineController.testData();
        ProductRequestLineController.testData1();
        ProductRequestLineController.testData2();
        ProductRequestLineController.testData3();
        Test.stopTest();
    }
    
}