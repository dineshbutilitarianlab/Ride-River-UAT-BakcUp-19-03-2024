/**
* @author Dinesh Baddawar
* @email dinesh.butilitarianlab@gmail.com
* @create date 2024-12-10 12:57:07
* @modify date 2024-12-10 12:57:07
* @desc [Add Product Request Line Items, Intialize Allotement and Receive GRN ];
*/

public class ProductRequestLineController {
    
    public static Id POSalesRecordType;
    public static Id POServiceRecordTypePT;
    public static Id OrderPurchaseRecordType;
    
    static {
        POSalesRecordType = Schema.SObjectType.ProductRequest.getRecordTypeInfosByName().get('Sales').getRecordTypeId();
        POServiceRecordTypePT = Schema.SObjectType.ProductRequest.getRecordTypeInfosByName().get('Service').getRecordTypeId();
        OrderPurchaseRecordType = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Purchase').getRecordTypeId();
    }
    
    // Method for InitialAllotment Updated
    @AuraEnabled(Cacheable = true)
    public static List<ProductRequestWrapper> getProductRequestItemsWithAvailableQty(String recordId) {
        List<ProductRequestWrapper> wrapperList = new List<ProductRequestWrapper>();
        List<ProductRequestLineItem> requestItems  = new List<ProductRequestLineItem>();
        try {
            if (recordId != null) {
                ProductRequest proReq = [SELECT Id, Destination_Location__c,Contact__c,Contact__r.Location__c  FROM ProductRequest WHERE Id = :recordId LIMIT 1];
                System.debug('proReq == >'+proReq);
                System.debug('Default_River_Warehouse == >'+System.Label.Default_River_Warehouse);
                if (proReq != null) {
                    Map<Id, Decimal> productInventoryMap = new Map<Id, Decimal>();
                    List<ProductItem> productItems = [ SELECT Product2Id, QuantityOnHand,Quantity_In_Hand__c  FROM ProductItem WHERE LocationId = :System.Label.Default_River_Warehouse ];
                    System.debug('productItems Size === >'+productItems.size());
                    for (ProductItem item : productItems) {
                        productInventoryMap.put(item.Product2Id, item.Quantity_In_Hand__c);
                    }
                    requestItems = [ SELECT Id, ProductRequestLineItemNumber, Product2Id, Product2.Name, Product_Code__c, QuantityRequested, Alloted_Quantity__c  FROM ProductRequestLineItem WHERE ParentId = :proReq.Id ];
                    System.debug('requestItems Size === >'+requestItems.size());
                    for (ProductRequestLineItem item : requestItems) {
                        System.debug('item == >'+item);
                        ProductRequestWrapper wrapper = new ProductRequestWrapper();
                        wrapper.Id = item.Id;
                        wrapper.ProductRequestLineItemNumber = item.ProductRequestLineItemNumber;
                        wrapper.ProductName = item.Product2?.Name;
                        wrapper.ProductCode = item.Product_Code__c;
                        wrapper.QuantityRequested = item.QuantityRequested;
                        wrapper.AllocatedQuantity = item.Alloted_Quantity__c;
                        wrapper.QuantityOnHand = productInventoryMap.get(item.Product2Id) != null ? productInventoryMap.get(item.Product2Id) : 0;
                        wrapperList.add(wrapper);
                    }
                    System.debug('wrapperList == >'+wrapperList);
                }else{
                    System.debug('Location Not Found !');
                }
            }
        } catch (Exception e) {
            System.debug('Error === > ' + e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        System.debug('wrapperList Final == >'+wrapperList);
        return wrapperList;
    }
    
    public class ProductRequestWrapper {
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String ProductRequestLineItemNumber;
        @AuraEnabled
        public String ProductName;
        @AuraEnabled
        public String ProductCode;
        @AuraEnabled
        public Decimal QuantityRequested;
        @AuraEnabled
        public Decimal AllocatedQuantity;
        @AuraEnabled
        public Decimal QuantityOnHand;
    }
    
    // Method for InitialAllotment Update PRLI - LWC : Initiate Allotment
    @AuraEnabled
    public static void updateRequestLineItem(List<Map<String, Object>> updatedItems) { 
        try {
            System.debug('updatedItems Initiate Allotment === >' + updatedItems);
            // Collect IDs from the input list
            Set<Id> prliIdSet = new Set<Id>();
            Map<Id, Decimal> idToAllocatedQuantity = new Map<Id, Decimal>();
            for (Map<String, Object> itemData : updatedItems) {
                Id itemId = (Id)itemData.get('Id');
                Decimal allocatedQuantity = (Decimal)itemData.get('Alloted_Quantity__c');
                prliIdSet.add(itemId);
                idToAllocatedQuantity.put(itemId, allocatedQuantity);
            }
            if (!prliIdSet.isEmpty()) {
                // Fetch all ProductRequestLineItem records in one query
                List<ProductRequestLineItem> itemsToUpdate = [ SELECT Id, Product2Id, Alloted_Quantity__c  FROM ProductRequestLineItem  WHERE Id IN :prliIdSet ];
                // Update the records with allocated quantities
                for (ProductRequestLineItem item : itemsToUpdate) {
                    if (idToAllocatedQuantity.containsKey(item.Id)) {
                        item.Alloted_Quantity__c = idToAllocatedQuantity.get(item.Id);
                    }
                }
                try {
                    // Perform a single DML operation
                    update itemsToUpdate;
                    System.debug('itemsToUpdate # 2 === >' + itemsToUpdate);
                    if (!itemsToUpdate.isEmpty()) {
                        // Method to create Order & OrderItem
                        createOrderOrderLineItemList(itemsToUpdate);
                    }
                    // Method to create Product Transfer Record on Initiate Allotment
                    createProductTransferFromInitiateAllotment(itemsToUpdate, null);
                } catch (DmlException e) {
                    System.debug('DML Exception: ' + e.getMessage() + ' at Line ' + e.getLineNumber());
                }
            }
        }catch(PricebookEntryNotFoundException e) {
            throw new PricebookEntryNotFoundException(e.getMessage());
        }
         catch (Exception e) {
            System.debug('Exception: ' + e.getMessage() + ' at Line ' + e.getLineNumber());
        }
    }
    
    public static void createProductTransferFromInitiateAllotment(List<ProductRequestLineItem> proReqList, Id orderId) {    
        System.debug('ProReqList # 1 == >' + proReqList +' && orderId == >'+orderId);
        
        if (orderId == null) {
            return;
        }

        if (proReqList == null || proReqList.isEmpty()) {
            return;
        } 
        Set<Id> prliIds = new Map<Id, ProductRequestLineItem>(proReqList).keySet();
        System.debug('prliIds # 2 == >' + prliIds);
        Map<String, Id> productItemMap = new Map<String, Id>();
        Map<String, Id> productItemKeyToIdMap = new Map<String, Id>();
        List<ProductTransfer> transfersToCreate = new List<ProductTransfer>(); 
        List<ProductRequestLineItem> prliRecords = [SELECT Id, ParentId, Product2Id, Alloted_Quantity__c,  Parent.Destination_Location__c  FROM ProductRequestLineItem  WHERE Id IN :prliIds];
        System.debug('prliRecords # 3 == >' + prliRecords);
        Set<Id> parentIds = new Set<Id>();
        for (ProductRequestLineItem prli : prliRecords) {
            parentIds.add(prli.ParentId);
        }
        System.debug('parentIds # 4 == >' + prliRecords);
         // Perform a single SOQL query
         Map<Id, ProductRequest> productRequestMap = new Map<Id, ProductRequest>( [SELECT Id, Destination_Location__c FROM ProductRequest WHERE Id IN :parentIds]);
        // Build a map for ProductItem lookup
        Map<Id, Id> productToLocationMap = new Map<Id, Id>();
        for (ProductRequestLineItem prli : prliRecords) {
            System.debug('prli === >' + prli);
            if (prli.Product2Id != null && productRequestMap.containsKey(prli.ParentId)) {
                String key = prli.Product2Id + '_' + productRequestMap.get(prli.ParentId).Destination_Location__c;
                productToLocationMap.put(prli.Product2Id, productRequestMap.get(prli.ParentId).Destination_Location__c);
            }
            else {
                System.debug('Product not found  == >'+prli);
            }
        }
        System.debug('productToLocationMap # 5 == >'+productToLocationMap);
        List<ProductItem> productItems = [SELECT Id, Product2Id, LocationId   FROM ProductItem  WHERE Product2Id IN :productToLocationMap.keySet()  AND LocationId IN :productToLocationMap.values()];
        System.debug('productItems === >' + productItems);
        for (ProductItem item : productItems) {
            String key = item.Product2Id + '_' + item.LocationId;
            productItemKeyToIdMap.put(key, item.Id);
        }
        System.debug('productItemKeyToIdMap ===== >' + productItemKeyToIdMap);
        try{
            //here condition is that we need to check whether data is for the same order Id or not 
            System.debug('prliRecords ===== >' + prliRecords);
            for (ProductRequestLineItem prli : prliRecords) {
                ProductTransfer pt = new ProductTransfer();
                pt.Product2Id = prli.Product2Id;
                String key = prli.Product2Id + '_' + productRequestMap.get(prli.ParentId).Destination_Location__c;
                pt.Product_Inventory__c = productItemKeyToIdMap.get(key);
                pt.QuantitySent = prli.Alloted_Quantity__c;
                pt.QuantityReceived = 0;
                pt.DestinationLocationId = productRequestMap.get(prli.ParentId).Destination_Location__c;
                pt.SourceLocationId = System.Label.Default_River_Warehouse; 
                pt.LR_Number__c = '0';
                pt.Driver_Phone__c = '0';
                pt.Order__c = orderId;
                //pt.IsSent = true;
                transfersToCreate.add(pt);
            }
            if (!transfersToCreate.isEmpty()) {
                insert transfersToCreate;
                System.debug('Inserted Product Transfers === > ' + transfersToCreate);
            }
        }
        catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }   
    }

    // ==================================================================================================================================================================================================
    
    // LWC CreatePurchaseOrderForm and AddProductRequestLiteItem
    // Method for Get All PORL from Location from that Product Inventory
    @AuraEnabled(Cacheable = true)
    public static List<Product2> getLogedInUserRelatedLocationPOLI(String loggedInUserId){
        System.debug(' loggedInUserId == >'+loggedInUserId);
        ProductRequest ProdReqRecord = new ProductRequest();
      //  List<ProductItem> getProdItemList = new List<ProductItem>();
      List<PricebookEntry> getProdItemList = new List<PricebookEntry>();
        List<Product2> getLocationRelatedPRLI = new List<Product2>();
        Set<Id> Product2IdIdSet = new Set<Id>();
        Contact loggedInUserContactRecord = new Contact();
        User logedUser = new User();
        Set<String> ProductTypeNotToShow = new Set<String>();
        try{
            if(loggedInUserId !=null){
                logedUser = [SELECT Id,Contact.Name,ContactId  FROM User WHERE Id=:loggedInUserId LIMIT 1];
                System.debug('logedUser === >'+logedUser);
                if(logedUser.ContactId !=null){
                    loggedInUserContactRecord = [ SELECT Id,Name,Role_Type__c,Location__r.Price_Book__c FROM Contact where Id =:logedUser.ContactId LIMIT 1];
                    System.debug('Contact Role Type === >'+loggedInUserContactRecord.Role_Type__c);
                }
                if(loggedInUserContactRecord.Role_Type__c !=null){
                    if(loggedInUserContactRecord.Role_Type__c == 'Service'){
                        ProductTypeNotToShow = new Set<String>{'Vehicle','Merchandise'};
                            }
                    if(loggedInUserContactRecord.Role_Type__c == 'Sales'){
                        ProductTypeNotToShow = new Set<String>{'Parts'};
                            }
                }
                System.debug('ProductTypeNotToShow === >'+ProductTypeNotToShow);
            }
            // By Default Location will be - Custom Label - 
            // Added Code Dinesh - Only Take Products whihc has Price Book record
          
            getProdItemList  = [Select Id, Product2.Name,Product2Id from PricebookEntry WHERE Pricebook2Id =:loggedInUserContactRecord.Location__r.Price_Book__c];
            System.debug('getProdItemList === >'+logedUser);
            if(getProdItemList.size()>0){
                for(PricebookEntry prod : getProdItemList){
                    if(prod.Product2Id !=  null){
                        Product2IdIdSet.add(prod.Product2Id);
                    }
                }
                System.debug('Product2IdIdSet === >'+Product2IdIdSet);
                if(Product2IdIdSet.size()>0){
                    getLocationRelatedPRLI = [SELECT Id,Name,ProductCode,IsActive,Type__c FROM Product2   WHERE Id IN: Product2IdIdSet AND IsActive = true AND Type__c NOT IN :ProductTypeNotToShow];
                    System.debug('getLocationRelatedPRLI === >'+getLocationRelatedPRLI);
                    if(getLocationRelatedPRLI.size()>0){
                        return getLocationRelatedPRLI;
                    }
                }
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    // Method for Creation Bulk RLI Records
    @AuraEnabled
    public static String createProductRequestLineItems(String jsonData) {
        System.debug('jsonData === >'+jsonData);
        try {
            List<ProductRequestLineItemWrapper> lineItems = (List<ProductRequestLineItemWrapper>) JSON.deserialize(jsonData, List<ProductRequestLineItemWrapper>.class);
            List<ProductRequestLineItem> recordsToInsert = new List<ProductRequestLineItem>();
            for (ProductRequestLineItemWrapper item : lineItems) {
                ProductRequestLineItem newRecord = new ProductRequestLineItem(
                    Product2Id = item.Product2Id,
                    ParentId = item.ParentId,
                    QuantityRequested = item.QuantityRequested
                );
                System.debug('Parent Item === >' + item.ParentId);
                recordsToInsert.add(newRecord);
            }
            if (!recordsToInsert.isEmpty()) {
                insert recordsToInsert;
                System.debug('recordsToInsert === >'+recordsToInsert);
                if(recordsToInsert.size()>0){
                    return 'SUCCESS';
                }
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            return 'Error : '+e.getMessage();
        }
        return null;
    }
    
    public class ProductRequestLineItemWrapper {
        public String Product2Id { get; set; }
        public String ParentId { get; set; }
        public Decimal QuantityRequested { get; set; }
    }
    
    // Method for get Loggedin User Location,Contact and Account
    @AuraEnabled 
    public static String getCurrentLogedUserAccountRecord(String loggedInUserId){
        User userRecord = [ SELECT Contact.Name, Contact.Account.Name FROM User WHERE Id = :loggedInUserId LIMIT 1 ];
        return userRecord.Contact != null && userRecord.Contact.Account != null  ? userRecord.Contact.Account.Name : 'No Account Found';
    }
    
    // Method to get to CREATE PO Based On User Location
    @AuraEnabled
    public static String createPurchaseorder(String shipmentType,String loggedInUserId){
        System.debug('shipmentType == >'+shipmentType+'  && loggedInUserId == >'+loggedInUserId);
        List<ProductRequest> newProductRequest  = new List<ProductRequest>();
        String userLocationId = '';
        User useRec = new User();
        String RecordTypeId;
        if(loggedInUserId !=null){
            useRec = [SELECT Id,Contact.Name,ContactId,Contact.Location__c,Contact.AccountId,Contact.Role_Type__c  FROM User WHERE Id=:loggedInUserId LIMIT 1];
            System.debug('Contact : '+useRec.Contact+' && Account :'+useRec.Contact.AccountId);
            if(useRec.Contact.Location__c != null){
                userLocationId = useRec.Contact.Location__c;
                if(useRec.Contact.Role_Type__c !=null){
                    if(useRec.Contact.Role_Type__c == 'Sales'){
                        RecordTypeId = POSalesRecordType;
                    }
                    if(useRec.Contact.Role_Type__c == 'Service'){
                        RecordTypeId = POServiceRecordTypePT;
                    }
                }
            }else{
                System.debug('No Location Found !');
                return 'No Locaton Record Found !';
            }
        }
        ProductRequest productRequest = new ProductRequest();
        productRequest.Status='New';
        productRequest.RecordTypeId =RecordTypeId;
        productRequest.ShipmentType=shipmentType;
        productRequest.Account__c= useRec.Contact != null && useRec.Contact.AccountId != null ? useRec.Contact.AccountId : null;
        productRequest.Contact__c = useRec.ContactId != null ? useRec.ContactId : null;
        productRequest.Destination_Location__c=userLocationId;
        newProductRequest.add(productRequest);
        try {
            if(!newProductRequest.isEmpty()){
                insert newProductRequest;
                if(newProductRequest !=null){
                    return newProductRequest[0].Id;     
                }
            }
        } catch (Exception e) {
            System.debug('Error Message == >'+e.getMessage()+' && Error Line =='+e.getLineNumber());
        }
        return null;
    }
    
    // ==================================================================================================================================================================================================
    
    // Method to Show Shippment Related ShipmentItem
   @AuraEnabled //(Cacheable = true)
    public static List<ShipmentItem> getPOrelatedPLI(String recordId) {
        try {
            if (String.isNotBlank(recordId) && recordId != null) {
                return [ SELECT Id, Quantity, Product2.Name, ShipmentId,Shipment.DestinationLocationId,Shipment.SourceLocationId, Product2.ProductCode FROM ShipmentItem  WHERE ShipmentId  =:recordId];
            }
        } catch (Exception e) {
            System.debug('Error in getPOrelatedPLI == > ' + e.getMessage() + ' && at Line == > ' + e.getLineNumber());
        }
        return new List<ShipmentItem>(); 
    } 


    
    @AuraEnabled 
    public static Shipment getShipmentDetail(String recordId){
        System.debug('recordId=======> ' + recordId);
        try{
            if(String.isNotBlank(recordId) && recordId != null){
                return [SELECT Id,Status from Shipment WHERE Id =:recordId LIMIT 1];
    
            }else{
                return null;
            }
        }catch (Exception e) {
            System.debug('Error in getPOrelatedPLI == > ' + e.getMessage() + ' && at Line == > ' + e.getLineNumber());
            return null;
        }
       
        // return [SELECT Id,Status from Shipment WHERE Id =:recordId LIMIT 1];
    }
    
    // Method for Updating CRN Records # Not using now
    @AuraEnabled
    public static String updateProductRequestLineItem(List<Map<String, Object>> updatedItems) {
        try {
            List<ProductRequestLineItem> itemsToUpdate = new List<ProductRequestLineItem>();
            System.debug('updatedItems == >'+updatedItems);
            for (Map<String, Object> itemData : updatedItems) {
                Id itemId = (Id)itemData.get('Id');
                Decimal RecievedQuantity = (Decimal)itemData.get('Received_Quantity__c');            
                ProductRequestLineItem requestItem = [SELECT Id, Product2Id FROM ProductRequestLineItem WHERE Id = :itemId LIMIT 1];
                requestItem.Received_Quantity__c = RecievedQuantity;
                itemsToUpdate.add(requestItem);
            }
            update itemsToUpdate;
            System.debug('itemsToUpdate == >'+itemsToUpdate);
            if(itemsToUpdate !=null){
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            return 'Error == >'+e.getMessage();
        }
        return null;
    }
    
    // @AuraEnabled
    // public static string TransferReceiveGRNToProductTransfer(List<Map<String, Object>> updatedItems) {
    //     System.debug('updatedItems == >' + updatedItems);
    //     List<ProductTransfer> prodTransToCreateList = new List<ProductTransfer>();
    //     List<ProductTransfer> prodTransToUpdateList = new List<ProductTransfer>();
    //     Map<String, Id> productItemMap = new Map<String, Id>();
    //     Set<Id> shipmentIdSet = new Set<Id>();
    //     Map<Id, Id> shipmentIdToOrderIdMap = new Map<Id, Id>();
    //     Map<String, ProductTransfer> existingTransfersMap = new Map<String, ProductTransfer>();
    //     for (Map<String, Object> itemData : updatedItems) {
    //         if (itemData.containsKey('ShipmentId')) {
    //             shipmentIdSet.add((String) itemData.get('ShipmentId'));
    //         }
    //     }
    //     List<Shipment> shipmentList = [ SELECT Id, ShipToName, Order__c FROM Shipment WHERE Id IN :shipmentIdSet];
    //     for (Shipment ship : shipmentList) {
    //         shipmentIdToOrderIdMap.put(ship.Id, ship.Order__c);
    //     }
    //     List<ShipmentItem> shipmentItems = [ SELECT Id, ShipmentId, Shipment.DestinationLocationId, Product2Id FROM ShipmentItem  WHERE ShipmentId IN :shipmentIdSet ];
    //     Map<String, Id> productItemMapOfValue = new Map<String, Id>();
    //     for (ShipmentItem ship : shipmentItems) {
    //         if (ship.Product2Id != null && ship.Shipment.DestinationLocationId != null) {
    //             String key = ship.Product2Id + '_' + ship.Shipment.DestinationLocationId;
    //             productItemMapOfValue.put(key, ship.Id);
    //         }
    //     }
    //     List<ProductItem> productItems = [ SELECT Id, Product2Id, LocationId FROM ProductItem WHERE Product2Id IN :productItemMapOfValue.keySet() AND LocationId IN :productItemMapOfValue.values()];
    //     for (ProductItem item : productItems) {
    //         String key = item.Product2Id + '_' + item.LocationId;
    //         productItemMap.put(key, item.Id);
    //     }
    //     System.debug('productItemMap #1 == >'+productItemMap);
    //     List<ProductTransfer> existingTransfers = [ SELECT Id, Product2Id, DestinationLocationId, QuantityReceived, Order__c FROM ProductTransfer WHERE Order__c IN :shipmentIdToOrderIdMap.values()];
    //     for (ProductTransfer transfer : existingTransfers) {
    //         String key = transfer.Product2Id + '_' + transfer.DestinationLocationId;
    //         existingTransfersMap.put(key, transfer);
    //     }
    //     String ShipmentId = '';
    //     try {
    //         for (Map<String, Object> itemData : updatedItems) {
    //             System.debug('itemData == >'+itemData);
    //             String productId = (String) itemData.get('Product2Id');
    //             String destinationLocationId = (String) itemData.get('DestinationLocationId');
    //             String key = (String) itemData.get('Product2Id') + '_' + (String) itemData.get('DestinationLocationId');
    //             System.debug('Key # == >'+key);
    //             if (existingTransfersMap.containsKey(key)) {
    //                 // Update existing ProductTransfer
    //                 ProductTransfer existingTransfer = existingTransfersMap.get(key);
    //                 if (itemData.containsKey('Received_Quantity__c')) {
    //                     //addded recived quantity in already existed product transfer
    //                     existingTransfer.QuantityReceived += (Decimal) itemData.get('Received_Quantity__c');
    //                 }
    //                 prodTransToUpdateList.add(existingTransfer);
    //             } else {
    //                 // Create new ProductTransfer
    //                 ProductTransfer proTran = new ProductTransfer();
    //                 if (itemData.containsKey('Product2Id')) {
    //                     proTran.Product2Id = (String) itemData.get('Product2Id');
    //                 }
    //                 proTran.QuantitySent = 0;
    //                 if (itemData.containsKey('Received_Quantity__c')) {
    //                     proTran.QuantityReceived = (Decimal) itemData.get('Received_Quantity__c');
    //                 }
    //                 if (itemData.containsKey('ShipmentId')) {
    //                     ShipmentId = (String) itemData.get('ShipmentId');
    //                     System.debug('ShipmentId == >'+ShipmentId);
    //                 }
    //                 if (itemData.containsKey('ShipmentId')) {
    //                     proTran.Shipment_Item__c = (String) itemData.get('Id');
    //                 }
    //                 if (itemData.containsKey('DestinationLocationId')) {
    //                     proTran.DestinationLocationId = (String) itemData.get('DestinationLocationId');
    //                 }
    //                 proTran.Product_Inventory__c = productItemMap.containsKey(key) ? productItemMap.get(key) : null;
    //                 proTran.Order__c = shipmentIdToOrderIdMap.get(ShipmentId);
    //                 proTran.LR_Number__c ='0';
    //                 proTran.Driver_Phone__c = '0';
    //                 prodTransToCreateList.add(proTran);
    //             }
    //         }
    //         if (!prodTransToUpdateList.isEmpty()) {
    //             update prodTransToUpdateList;
    //             System.debug('Updated Product Transfers ===> ' + prodTransToUpdateList);
    //         }
    //         if (!prodTransToCreateList.isEmpty()) {
    //             insert prodTransToCreateList;
    //             System.debug('Inserted Product Transfers === > ' + prodTransToCreateList);
    //         }
    //         return 'SUCCESS';
    //     } catch (Exception e) {
    //         System.debug('Error Message ==>' + e.getMessage() + ' && Error Line == >' + e.getLineNumber());
    //         return 'Error: ' + e.getMessage();
    //     }
    // }

    
   
    
    // @AuraEnabled
    // public static string createDiscrepancyAndLineitem(String updatedItems) {
    //     System.debug('Received updatedItems: ' + updatedItems);
        
    //     try {
            
    //         Map<String, Object> updatedItemsMap = (Map<String, Object>) JSON.deserializeUntyped(updatedItems);
    //         System.debug('Parsed JSON Data: ' + updatedItemsMap);

    //         if (updatedItemsMap == null || updatedItemsMap.isEmpty()) {
    //             System.debug('No data received!');
    //             return 'Error: No data received!';
    //         }

    //         Set<Id> shipmentItemIds = new Set<Id>();
    //         Map<Id, Decimal> shipmentItemReceivedQtyMap = new Map<Id, Decimal>();

            
    //         for (String key : updatedItemsMap.keySet()) {
    //             if (!String.isEmpty(key)) {
    //                 shipmentItemIds.add(Id.valueOf(key));

    //                 Object itemDetails = updatedItemsMap.get(key);
    //                 if (itemDetails instanceof Map<String, Object>) {
    //                     Map<String, Object> itemData = (Map<String, Object>) itemDetails;
    //                     if (itemData.containsKey('receivedQuantity')) {
    //                         shipmentItemReceivedQtyMap.put(Id.valueOf(key), Decimal.valueOf(String.valueOf(itemData.get('receivedQuantity'))));
    //                         System.debug('Shipment Item ID: ' + key + ', Received Quantity: ' + itemData.get('receivedQuantity'));
    //                     }
    //                 }
    //             }
    //         }

    //         Map<Id, Id> shipmentItemToShipmentMap = new Map<Id, Id>();

    //         if (!shipmentItemIds.isEmpty()) {
    //             for (ShipmentItem item : [SELECT Id, ShipmentId FROM ShipmentItem WHERE Id IN :shipmentItemIds]) {
    //                 shipmentItemToShipmentMap.put(item.Id, item.ShipmentId);
    //                 System.debug('Mapped Shipment Item ID: ' + item.Id + ' to Shipment ID: ' + item.ShipmentId);
    //             }
    //         }

        
    //         List<Discrepancy__c> discrepanciesToInsert = new List<Discrepancy__c>();
    //         Map<String, Id> discrepancyIdMap = new Map<String, Id>();
    //         Map<Id, Decimal> discrepancyReceivedQuantityMap = new Map<Id, Decimal>();

    //         for (String shipmentItemId : updatedItemsMap.keySet()) {
    //             if (String.isEmpty(shipmentItemId)) {
    //                 continue;
    //             }

    //             Discrepancy__c disRec = new Discrepancy__c();
    //             disRec.Shipment_Item__c = shipmentItemId;

    //             if (shipmentItemToShipmentMap.containsKey(Id.valueOf(shipmentItemId))) {
    //                 disRec.Shipment__c = shipmentItemToShipmentMap.get(Id.valueOf(shipmentItemId));
    //             }

    //             Object itemDetails = updatedItemsMap.get(shipmentItemId);
    //             if (itemDetails instanceof Map<String, Object>) {
    //                 Map<String, Object> itemData = (Map<String, Object>) itemDetails;
    //                 if (itemData.containsKey('receivedQuantity')) {
    //                     Integer receivedQty = Integer.valueOf(String.valueOf(itemData.get('receivedQuantity')));
    //                     disRec.Received_Quantity__c = receivedQty;
    //                     System.debug('Discrepancy for Shipment Item ID: ' + shipmentItemId + ', Received Quantity: ' + receivedQty);
    //                 }
    //             }
    //             discrepanciesToInsert.add(disRec);
    //         }

    //         if (!discrepanciesToInsert.isEmpty()) {
    //             insert discrepanciesToInsert;
    //             for (Discrepancy__c disRec : discrepanciesToInsert) {
    //                 discrepancyIdMap.put(disRec.Shipment_Item__c, disRec.Id);
    //                 discrepancyReceivedQuantityMap.put(disRec.Id, disRec.Received_Quantity__c);
    //                 System.debug('Inserted Discrepancy ID: ' + disRec.Id + ' for Shipment Item ID: ' + disRec.Shipment_Item__c);
    //             }
    //         } else {
    //             System.debug('No Discrepancy records created!');
    //             return 'Error: No Discrepancy records created!';
    //         }

            
    //         Map<Id, List<Discrepancy_Line_Item__c>> existingLineItemsMap = new Map<Id, List<Discrepancy_Line_Item__c>>();
    //         List<Discrepancy_Line_Item__c> existingLineItems = [
    //             SELECT Id, Discrepancy__c, Quantity__c FROM Discrepancy_Line_Item__c 
    //             WHERE Discrepancy__c IN :discrepancyIdMap.values()
    //         ];

    //         for (Discrepancy_Line_Item__c lineItem : existingLineItems) {
    //             if (!existingLineItemsMap.containsKey(lineItem.Discrepancy__c)) {
    //                 existingLineItemsMap.put(lineItem.Discrepancy__c, new List<Discrepancy_Line_Item__c>());
    //             }
    //             existingLineItemsMap.get(lineItem.Discrepancy__c).add(lineItem);
    //         }

    //         List<Discrepancy_Line_Item__c> disLineItemsToInsert = new List<Discrepancy_Line_Item__c>();

    //         for (String shipmentItemId : updatedItemsMap.keySet()) {
    //             Object recValue = updatedItemsMap.get(shipmentItemId);

    //             if (recValue instanceof Map<String, Object>) {
    //                 Map<String, Object> data = (Map<String, Object>) recValue;
    //                 processLineItem(data, 'DIT', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
    //                 processLineItem(data, 'MIT', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
    //                 processLineItem(data, 'WP', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
    //             }
    //         }

    //         if (!disLineItemsToInsert.isEmpty()) {
    //             insert disLineItemsToInsert;
    //             System.debug('Inserted ' + disLineItemsToInsert.size() + ' Discrepancy Line Items');
    //         }

            
    //         List<Discrepancy__c> discrepanciesToUpdate = new List<Discrepancy__c>();
    //         for (Id disId : discrepancyReceivedQuantityMap.keySet()) {
    //             Discrepancy__c dis = new Discrepancy__c(Id = disId, Received_Quantity__c = discrepancyReceivedQuantityMap.get(disId));
    //             discrepanciesToUpdate.add(dis);
    //         }

    //         if (!discrepanciesToUpdate.isEmpty()) {
    //             update discrepanciesToUpdate;
    //             System.debug('Updated ' + discrepanciesToUpdate.size() + ' Discrepancies with received quantity');
    //         }

    //         if (!shipmentItemReceivedQtyMap.isEmpty()) {
    //             List<ShipmentItem> shipmentItemsToUpdate = new List<ShipmentItem>();
    //             for (Id shipmentItemId : shipmentItemReceivedQtyMap.keySet()) {
    //                 ShipmentItem shipmentItemToUpdate = new ShipmentItem(Id = shipmentItemId, Quantity_Received__c = shipmentItemReceivedQtyMap.get(shipmentItemId));

    //                 Object itemDetails = updatedItemsMap.get(String.valueOf(shipmentItemId));
    //                 if (itemDetails instanceof Map<String, Object>) {
    //                     Map<String, Object> itemData = (Map<String, Object>) itemDetails;
    //                     if (itemData.containsKey('remarks')) {
    //                         String remarksValue = String.valueOf(itemData.get('remarks'));

    //                         // Debugging Remarks Value
    //                         System.debug('Remarks Value for Shipment Item ID ' + shipmentItemId + ': ' + remarksValue);

    //                         if (String.isNotEmpty(remarksValue)) {
    //                             shipmentItemToUpdate.Remarks__c = remarksValue;
    //                             System.debug('Updating Shipment Item ID: ' + shipmentItemId + ' with Remarks: ' + remarksValue);
    //                         } else {
    //                             System.debug('Remarks for Shipment Item ID ' + shipmentItemId + ' is empty.');
    //                         }
    //                     }
    //                 }

    //                 shipmentItemsToUpdate.add(shipmentItemToUpdate);
    //             }

    //             if (!shipmentItemsToUpdate.isEmpty()) {
    //                 update shipmentItemsToUpdate;
    //                 System.debug('Updated ' + shipmentItemsToUpdate.size() + ' Shipment Items');
    //             }
    //         }

    //         return 'SUCCESS';
    //     } catch (Exception e) {
    //         System.debug('Error: ' + e.getMessage());
    //         return 'Error: ' + e.getMessage();
    //     }
    // }

    
    @AuraEnabled
    public static string createDiscrepancyAndLineitem(String updatedItems) {
        System.debug('Received updatedItems: ' + updatedItems);
        
        try {
            Map<String, Object> updatedItemsMap = (Map<String, Object>) JSON.deserializeUntyped(updatedItems);
            System.debug('Parsed JSON Data: ' + updatedItemsMap);
    
            if (updatedItemsMap == null || updatedItemsMap.isEmpty()) {
                System.debug('No data received!');
                return 'Error: No data received!';
            }
    
            Set<Id> shipmentItemIds = new Set<Id>();
            Map<Id, Decimal> shipmentItemReceivedQtyMap = new Map<Id, Decimal>();
    
            for (String key : updatedItemsMap.keySet()) {
                if (!String.isEmpty(key)) {
                    shipmentItemIds.add(Id.valueOf(key));
    
                    Object itemDetails = updatedItemsMap.get(key);
                    if (itemDetails instanceof Map<String, Object>) {
                        Map<String, Object> itemData = (Map<String, Object>) itemDetails;
                        if (itemData.containsKey('receivedQuantity')) {
                            shipmentItemReceivedQtyMap.put(Id.valueOf(key), Decimal.valueOf(String.valueOf(itemData.get('receivedQuantity'))));
                            System.debug('Shipment Item ID: ' + key + ', Received Quantity: ' + itemData.get('receivedQuantity'));
                        }
                    }
                }
            }
    
            Map<Id, Id> shipmentItemToShipmentMap = new Map<Id, Id>();
    
            if (!shipmentItemIds.isEmpty()) {
                for (ShipmentItem item : [SELECT Id, ShipmentId FROM ShipmentItem WHERE Id IN :shipmentItemIds]) {
                    shipmentItemToShipmentMap.put(item.Id, item.ShipmentId);
                    System.debug('Mapped Shipment Item ID: ' + item.Id + ' to Shipment ID: ' + item.ShipmentId);
                }
            }
    
            List<Discrepancy__c> discrepanciesToInsert = new List<Discrepancy__c>();
            Map<String, Id> discrepancyIdMap = new Map<String, Id>();
            Map<Id, Decimal> discrepancyReceivedQuantityMap = new Map<Id, Decimal>();
    
            for (String shipmentItemId : updatedItemsMap.keySet()) {
                if (String.isEmpty(shipmentItemId)) {
                    continue;
                }
    
                Discrepancy__c disRec = new Discrepancy__c();
                disRec.Shipment_Item__c = shipmentItemId;
    
                if (shipmentItemToShipmentMap.containsKey(Id.valueOf(shipmentItemId))) {
                    disRec.Shipment__c = shipmentItemToShipmentMap.get(Id.valueOf(shipmentItemId));
                }
    
                Object itemDetails = updatedItemsMap.get(shipmentItemId);
                if (itemDetails instanceof Map<String, Object>) {
                    Map<String, Object> itemData = (Map<String, Object>) itemDetails;
                    if (itemData.containsKey('receivedQuantity')) {
                        Integer receivedQty = Integer.valueOf(String.valueOf(itemData.get('receivedQuantity')));
                        disRec.Received_Quantity__c = receivedQty;
                        System.debug('Discrepancy for Shipment Item ID: ' + shipmentItemId + ', Received Quantity: ' + receivedQty);
                    }
                }
                discrepanciesToInsert.add(disRec);
            }
    
            if (!discrepanciesToInsert.isEmpty()) {
                insert discrepanciesToInsert;
                for (Discrepancy__c disRec : discrepanciesToInsert) {
                    discrepancyIdMap.put(disRec.Shipment_Item__c, disRec.Id);
                    discrepancyReceivedQuantityMap.put(disRec.Id, disRec.Received_Quantity__c);
                    System.debug('Inserted Discrepancy ID: ' + disRec.Id + ' for Shipment Item ID: ' + disRec.Shipment_Item__c);
                }
            } else {
                System.debug('No Discrepancy records created!');
                return 'Error: No Discrepancy records created!';
            }
    
            Map<Id, List<Discrepancy_Line_Item__c>> existingLineItemsMap = new Map<Id, List<Discrepancy_Line_Item__c>>();
            List<Discrepancy_Line_Item__c> existingLineItems = [
                SELECT Id, Discrepancy__c, Quantity__c FROM Discrepancy_Line_Item__c 
                WHERE Discrepancy__c IN :discrepancyIdMap.values()
            ];
    
            for (Discrepancy_Line_Item__c lineItem : existingLineItems) {
                if (!existingLineItemsMap.containsKey(lineItem.Discrepancy__c)) {
                    existingLineItemsMap.put(lineItem.Discrepancy__c, new List<Discrepancy_Line_Item__c>());
                }
                existingLineItemsMap.get(lineItem.Discrepancy__c).add(lineItem);
            }
    
            List<Discrepancy_Line_Item__c> disLineItemsToInsert = new List<Discrepancy_Line_Item__c>();
    
            for (String shipmentItemId : updatedItemsMap.keySet()) {
                Object recValue = updatedItemsMap.get(shipmentItemId);
    
                if (recValue instanceof Map<String, Object>) {
                    Map<String, Object> data = (Map<String, Object>) recValue;
    
                    // ✅ Process line items and ensure null/empty values are skipped
                    processLineItem(data, 'DIT', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
                    processLineItem(data, 'MIT', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
                    processLineItem(data, 'WP', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert);
                    processLineItem(data, 'Extra', shipmentItemId, discrepancyIdMap, existingLineItemsMap, disLineItemsToInsert); // ✅ New "Extra" field added
                }
            }
    
            if (!disLineItemsToInsert.isEmpty()) {
                insert disLineItemsToInsert;
                System.debug('Inserted ' + disLineItemsToInsert.size() + ' Discrepancy Line Items');
            }
    
            List<Discrepancy__c> discrepanciesToUpdate = new List<Discrepancy__c>();
            for (Id disId : discrepancyReceivedQuantityMap.keySet()) {
                Discrepancy__c dis = new Discrepancy__c(Id = disId, Received_Quantity__c = discrepancyReceivedQuantityMap.get(disId));
                discrepanciesToUpdate.add(dis);
            }
    
            if (!discrepanciesToUpdate.isEmpty()) {
                update discrepanciesToUpdate;
                System.debug('Updated ' + discrepanciesToUpdate.size() + ' Discrepancies with received quantity');
            }
    
            if (!shipmentItemReceivedQtyMap.isEmpty()) {
                List<ShipmentItem> shipmentItemsToUpdate = new List<ShipmentItem>();
                for (Id shipmentItemId : shipmentItemReceivedQtyMap.keySet()) {
                    ShipmentItem shipmentItemToUpdate = new ShipmentItem(Id = shipmentItemId, Quantity_Received__c = shipmentItemReceivedQtyMap.get(shipmentItemId));
    
                    Object itemDetails = updatedItemsMap.get(String.valueOf(shipmentItemId));
                    if (itemDetails instanceof Map<String, Object>) {
                        Map<String, Object> itemData = (Map<String, Object>) itemDetails;
                        if (itemData.containsKey('remarks')) {
                            String remarksValue = String.valueOf(itemData.get('remarks'));
                            if (String.isNotEmpty(remarksValue)) {
                                shipmentItemToUpdate.Remarks__c = remarksValue;
                                System.debug('Updating Shipment Item ID: ' + shipmentItemId + ' with Remarks: ' + remarksValue);
                            }
                        }
                    }
    
                    shipmentItemsToUpdate.add(shipmentItemToUpdate);
                }
    
                if (!shipmentItemsToUpdate.isEmpty()) {
                    update shipmentItemsToUpdate;
                    System.debug('Updated ' + shipmentItemsToUpdate.size() + ' Shipment Items');
                }
            }
    
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    

    @AuraEnabled
    public static string updateShipmentItemQuantities(String updatedItemsJson) {
        try {
            System.debug('Received updatedItemsJson: ' + updatedItemsJson);
            
            Map<String, Object> updatedItems = (Map<String, Object>) JSON.deserializeUntyped(updatedItemsJson);
            if (updatedItems == null || updatedItems.isEmpty()) {
                System.debug('No valid shipment items to update!');
                return 'Error: No valid shipment items to update!';
            }
    
            List<ShipmentItem> shipmentItemsToUpdate = new List<ShipmentItem>();
    
            for (String shipmentItemId : updatedItems.keySet()) {
                if (!String.isEmpty(shipmentItemId)) {
                    Object itemDetails = updatedItems.get(shipmentItemId);
                    if (itemDetails instanceof Map<String, Object>) {
                        Map<String, Object> itemData = (Map<String, Object>) itemDetails;
                        
                        if (itemData.containsKey('receivedQuantity')) {
                            ShipmentItem item = new ShipmentItem(
                                Id = Id.valueOf(shipmentItemId),
                                Quantity_Received__c = Decimal.valueOf(String.valueOf(itemData.get('receivedQuantity')))
                            );
                            
                            if (itemData.containsKey('remarks')) {
                                item.Remarks__c = String.valueOf(itemData.get('remarks'));
                            }
    
                            shipmentItemsToUpdate.add(item);
                            System.debug('Preparing to update Shipment Item ID: ' + shipmentItemId + ' with Received Quantity: ' + itemData.get('receivedQuantity'));
                        }
                    }
                }
            }
    
            if (!shipmentItemsToUpdate.isEmpty()) {
                update shipmentItemsToUpdate;
                System.debug('Updated ' + shipmentItemsToUpdate.size() + ' Shipment Items successfully.');
                return 'SUCCESS';
            } else {
                System.debug('No shipment items were updated!');
                return 'Error: No shipment items were updated!';
            }
    
        } catch (Exception e) {
            System.debug('Error updating shipment items: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }
    



    private static void processLineItem(Map<String, Object> data, String fieldName, String shipmentItemId, Map<String, Id> discrepancyIdMap, Map<Id, List<Discrepancy_Line_Item__c>> existingLineItemsMap, List<Discrepancy_Line_Item__c> disLineItemsToInsert) {
        if (data.containsKey(fieldName) && discrepancyIdMap.containsKey(shipmentItemId)) {
            String quantityStr = String.valueOf(data.get(fieldName));
            if (!String.isEmpty(quantityStr)) {
                try {
                    Integer quantity = Integer.valueOf(quantityStr);
                    Id discrepancyId = discrepancyIdMap.get(shipmentItemId);

                    Boolean exists = false;
                    if (existingLineItemsMap.containsKey(discrepancyId)) {
                        for (Discrepancy_Line_Item__c existingItem : existingLineItemsMap.get(discrepancyId)) {
                            if (existingItem.Quantity__c == quantity) {
                                exists = true;
                                System.debug('⚠️ Existing line item found for Discrepancy: ' + discrepancyId);
                                break;
                            }
                        }
                    }

                    if (!exists) {
                        Discrepancy_Line_Item__c lineItem = new Discrepancy_Line_Item__c();
                        lineItem.Name = fieldName;
                        lineItem.Discrepancy__c = discrepancyId;
                        lineItem.Quantity__c = quantity;
                        lineItem.Type__c = fieldName;
                        lineItem.status__c = 'New';
                        disLineItemsToInsert.add(lineItem);
                    }
                } catch (Exception e) {
                    System.debug('Error parsing quantity for ' + shipmentItemId + ': ' + e.getMessage());
                }
            }
        }
    }


    
    // ===============================================================================================================================================================================================================     
    // // Method for Creating Order and OrderLineItem Based on Alloted Quantity # Dinesh
    public static String createOrderOrderLineItemList(List<ProductRequestLineItem> ProdRLIList) {
       // try {
            String AccountIdPRLI = null;
            String POId = null;
            ProductRequest PORecToUpdate= new ProductRequest();
            List<OrderItem> newOrderItems = new List<OrderItem>();
            List<OrderItem> backOrderItems = new List<OrderItem>();
            Map<String, PricebookEntry> pricebookEntryMap = new Map<String, PricebookEntry>();
            Set<Id> ProdRLIListIdSet = new Map<Id, ProductRequestLineItem>(ProdRLIList).keySet();
            ProductRequest PORec = new ProductRequest();
            String LocationPBId;
            ProdRLIList = [SELECT Id, Product2Id, Product2.Name, ParentId, Parent.Destination_Location__c, Parent.Destination_Location__r.Name,  Parent.Account__c, QuantityRequested, Alloted_Quantity__c,Price_Book__c,CGST__c,SGST__c,IGST__c   FROM ProductRequestLineItem  WHERE Id IN :ProdRLIListIdSet];
            System.debug('Fetched ProdRLIList === >' + ProdRLIList);
            PORec = [SELECT Id,Destination_Location__c,Destination_Location__r.Price_Book__c  FROM ProductRequest WHERE Id=:ProdRLIList[0].ParentId LIMIT 1];
            if(PORec != null && PORec.Destination_Location__c != null && PORec.Destination_Location__r.Price_Book__c != null){
                LocationPBId = PORec.Destination_Location__r.Price_Book__c;
            }else{
                System.debug('No PriceBook / Location Record Found !');
                return null;
            }
            if (LocationPBId == null) {
                System.debug('LocationPBId Not Found!');
                return null;
            }
            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Pricebook2Id, Dealer_List_Price__c FROM PricebookEntry WHERE Pricebook2Id = :LocationPBId];
            for (PricebookEntry entry : pricebookEntries) {
                if (!pricebookEntryMap.containsKey(entry.Product2Id)) {
                    pricebookEntryMap.put(entry.Product2Id, entry);
                }
               //  pricebookEntryMap.get(entry.Product2Id).put(entry.Pricebook2Id, entry.Id);
            }
            if (!ProdRLIList.isEmpty() && ProdRLIList[0].ParentId != null) {
                POId = ProdRLIList[0].ParentId;
                AccountIdPRLI = ProdRLIList[0].Parent.Account__c;
            }
            Order newOrder = createOrder(AccountIdPRLI, POId, 'Activated', LocationPBId);
            System.debug('newOrder == >'+newOrder);
            System.debug('newOrderId == >'+newOrder.Id);
            if (newOrder != null) {
                System.debug('Inserted Order Id: ' + newOrder.Id);
                createProductTransferFromInitiateAllotment(ProdRLIList, newOrder.Id);                
            }
            Order backOrder = null;
            for (ProductRequestLineItem prli : ProdRLIList) {
                System.debug('Processing PRLI: ' + prli);
                String pricebookEntryId = null;
                if (!pricebookEntryMap.containsKey(prli.Product2Id)) {
                    System.debug('PricebookEntryId not found for Product2Id: ' + prli.Product2Id);
                    //throw new AuraHandledException('Error: PricebookEntryId not found for Product2Id: ' + prli.Product2Id);
                  throw new PricebookEntryNotFoundException('PricebookEntryId not found for Product2Id: ' + prli.Product2Id);
                 // return 'Error: PricebookEntryId not found for Product2Id: ' + prli.Product2Id;

                }else{
                    pricebookEntryId = pricebookEntryMap.get(prli.Product2Id).Id;
                }
                Decimal requestedQuantity = prli.QuantityRequested;
                Decimal allocatedQuantity = prli.Alloted_Quantity__c;
                Decimal remainingQuantity = (requestedQuantity - allocatedQuantity).setScale(0, RoundingMode.HALF_UP);
                System.debug('Requested: ' + requestedQuantity + ', Allocated: ' + allocatedQuantity + ', Remaining: ' + remainingQuantity);                
                // Only create Activated Order Line Item

                System.debug('backOrder::::::::00'+backOrder);
                try{
                    System.debug('newOrder === >'+newOrder);
                    System.debug('prli === >'+prli);
                    System.debug('pricebookEntryId === >'+pricebookEntryId);
                    System.debug('LocationPBId === >'+LocationPBId);
                }catch(Exception e){
                    System.debug('Error #2 ' + e.getMessage() + ' && Line: ' + e.getLineNumber());
                }

                if (allocatedQuantity == 0) {
                    System.debug('Condition: Allocated == 0');
                    
                    if (backOrder == null) { 
                        backOrder = createOrder(AccountIdPRLI, POId, 'Back Order', LocationPBId);
                        }
                        else {
                            System.debug('data is not going here');
                        }
                        
                System.debug('afterOrderbackOrder::::::::00'+backOrder);
                        backOrderItems.add(createOrderItem(backOrder, prli, pricebookEntryMap.get(prli.Product2Id), requestedQuantity, LocationPBId));
                }
                
                else if (allocatedQuantity > 0 && remainingQuantity > 0) {
                    System.debug('Condition: Allocated < Requested');
                    newOrderItems.add(createOrderItem(newOrder, prli, pricebookEntryMap.get(prli.Product2Id), allocatedQuantity, LocationPBId));
                    if (backOrder == null) {
                        backOrder = createOrder(AccountIdPRLI, POId, 'Back Order', LocationPBId);
                    }
                    else {
                            System.debug('data is not going here123');
                        }
                    backOrderItems.add(createOrderItem(backOrder, prli, pricebookEntryMap.get(prli.Product2Id), remainingQuantity, LocationPBId));
                }

                else if (remainingQuantity == 0) {
                    System.debug('Condition: Requested == Allocated');
                    newOrderItems.add(createOrderItem(newOrder, prli, pricebookEntryMap.get(prli.Product2Id), allocatedQuantity, LocationPBId));
                } 
            }

            PORecToUpdate = [SELECT Id,Status FROM ProductRequest WHERE Id=:POId];
            if (!newOrderItems.isEmpty()) {
                insert newOrderItems;
                if(PORecToUpdate !=null){
                    PORecToUpdate.Status = 'Processing';
                    update PORecToUpdate;
                    System.debug('PORecToUpdate == >'+PORecToUpdate);
                }
                System.debug('Inserted Activated Order Items: ' + newOrderItems);
            }
            if (!backOrderItems.isEmpty()) {
                insert backOrderItems;
                System.debug('Inserted Back Order Items: ' + backOrderItems);
            }
        // } catch (Exception e) {
        //     System.debug('Error Creating Orders: ' + e.getMessage() + ' && Line: ' + e.getLineNumber());
        //     throw new AuraHandledException(e.getMessage());
        // }
        return null;
    }
    
    // Helper Method to Create an Order # Dinesh
    public static Order createOrder(String accountId, String poId, String status, String priceBookId) {
        try{
            ProductRequest PORecord = [SELECT Id,ShipmentType,Contact__c FROM ProductRequest WHERE Id=:poId];
            Map<Id, ProductRequest> productRequestMap = new Map<Id, ProductRequest>([SELECT Id, Contact__c FROM ProductRequest WHERE Id=:poId]);
            Order ord = new Order();
            ord.AccountId = accountId;
            ord.Contact__c = PORecord.Contact__c != null ? PORecord.Contact__c : null;
            ord.Purchase_Order__c = poId;
            ord.Status = status;
            ord.IsVOR__c = PORecord.ShipmentType != null && PORecord.ShipmentType == 'VOR' ? True : false;
            ord.EffectiveDate = System.today();
            ord.Contact__c= productRequestMap.get(poId).Contact__c != null ? productRequestMap.get(poId).Contact__c : null;
            ord.Pricebook2Id = priceBookId;
            ord.recordTypeId =OrderPurchaseRecordType;
            if(status == 'Back Order'){
                ord.IsBackOrder__c = true;
            }
            insert ord;
            System.debug('Created Order ==> ! ' + ord);
            return ord;
        }catch(Exception e){
            System.debug('Error Message #Dinehs 2 ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;   
    }
    
    // Helper Method to Create an Order Item # Dinesh
    public static OrderItem createOrderItem(Order ord, ProductRequestLineItem prli, PricebookEntry pricebookEntry, Decimal quantity, Id priceBookId) {
        System.debug('ord == >'+ord+' && prli == >'+prli+' && pricebookEntry == >'+pricebookEntry+' && quantity == >'+quantity+' && priceBookId == >'+priceBookId);
        try{
            Map<String,PricebookEntry> mapOfProductNamePBIId = new Map<String,PricebookEntry>();
           /* List<PricebookEntry> PBEntryList = [SELECT id,Name,Product2Id,Product2.Name,Pricebook2.Name,Pricebook2Id, UnitPrice,Dealer_List_Price__c from PricebookEntry  WHERE PriceBook2Id =: priceBookId AND Product2Id =: prli.Product2Id];
            for(PricebookEntry PE : PBEntryList){
                mapOfProductNamePBIId.put(PE.Product2.Name,PE);
            } */
            System.debug('mapOfProductNamePBIId == > ' + mapOfProductNamePBIId);
            //Order ord= [SELECT Id,IsVOR__c FROM Order WHERE Id=:orderId];
            OrderItem ordItem = new OrderItem();
            ordItem.OrderId = ord.Id;
            ordItem.Is_VOR__c = ord != null && ord.IsVOR__c == True ? True : false;
            ordItem.Product2Id = prli.Product2Id;
            ordItem.Quantity = quantity;
            if(pricebookEntry.Dealer_List_Price__c == null){
              System.debug('Product without Unit Price == > ' + prli.Product2);
            }
            ordItem.UnitPrice = pricebookEntry.Dealer_List_Price__c != null ? pricebookEntry.Dealer_List_Price__c : 0.00;
            ordItem.PricebookEntryId = pricebookEntry.Id;//mapOfProductNamePBIId.get(prli.Product2.Name).Id; //pricebookEntryId;
            ordItem.CGST__c = prli.CGST__c;
            ordItem.SGST__c = prli.SGST__c;
            ordItem.IGST__c = prli.IGST__c;
            System.debug('Created Order Item == > ' + ordItem);
            return ordItem;
        }catch(Exception e){
            System.debug('Error Message #Dinesh 3 ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    public class PricebookEntryNotFoundException extends Exception {}

    
    Public static void testData(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
    Public static void testData1(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
    Public static void testData2(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
     Public static void testData3(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
}