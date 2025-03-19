/**
 * @description       : 
 * @author            : Sagar Kumar
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
public with sharing class ProductTransferHandler {
    
    public static void onInsertProductTransferUpdateInventory(List<ProductTransfer> newTransfers) {
        try {
            Set<Id> productInventoryIds                 = new Set<Id>();
            Map<Id, Decimal> inventoryUpdates           = new Map<Id, Decimal>(); 
            Map<Id, Decimal> inventoryUpdateRecieved    = new Map<Id, Decimal>();
            Map<String, Decimal> riverWarehouseUpdates  = new Map<String, Decimal>();
            Map<String, Decimal> riverWarehouseRec      = new Map<String, Decimal>();
            Set<Id> productsToUpdateInRiverWarehouse    = new Set<Id>();
            String riverWarehouseLocationId = System.Label.Default_River_Warehouse;
            System.debug(System.Label.Default_River_Warehouse);
            for (ProductTransfer transfer : newTransfers) {
                if (transfer.Product_Inventory__c != null) {
                    productInventoryIds.add(transfer.Product_Inventory__c);
                    Decimal currentInward = inventoryUpdates.containsKey(transfer.Product_Inventory__c) ? inventoryUpdates.get(transfer.Product_Inventory__c) : 0;
                    System.debug('currentInward === > #1'+ currentInward);
                    Decimal currentTransfer = inventoryUpdateRecieved.containsKey(transfer.Product_Inventory__c) ? inventoryUpdateRecieved.get(transfer.Product_Inventory__c) : 0;
                    System.debug('currentTransfer === > #2' + currentTransfer);
                    inventoryUpdates.put(transfer.Product_Inventory__c,  currentInward + (transfer.QuantityReceived != null ? transfer.QuantityReceived : 0));//10
                    inventoryUpdateRecieved.put(transfer.Product_Inventory__c,  currentTransfer + (transfer.QuantitySent != null ? transfer.QuantitySent : 0)); //0
                    
                    System.debug('inventoryUpdates == > #3'+ inventoryUpdates);  //4
                    System.debug('inventoryUpdateRecieved == > 4'+ inventoryUpdateRecieved); //5
                    
                    if (transfer.Product2Id != null) {
                        productsToUpdateInRiverWarehouse.add(transfer.Product2Id);
                        String riverKey = transfer.Product2Id + '_' + riverWarehouseLocationId;
                        String riverKeyrec = transfer.Product2Id + '_' + riverWarehouseLocationId;
                        System.debug('riverKey === > #4 ' + riverKey);
                        Decimal currentRiverValue = riverWarehouseUpdates.containsKey(riverKey)  ? riverWarehouseUpdates.get(riverKey) : 0;
                        Decimal currentRiverValueRec = riverWarehouseRec.containsKey(riverKeyrec)  ? riverWarehouseRec.get(riverKeyrec) : 0;
                        
                        System.debug('currentRiverValue === > #5 '+ currentRiverValue);
                        riverWarehouseUpdates.put(riverKey,  inventoryUpdateRecieved.get(transfer.Product_Inventory__c));
                        System.debug('riverWarehouseUpdates = > #6'+riverWarehouseUpdates);
                        
                        riverWarehouseRec.put(riverKeyrec, inventoryUpdates.get(transfer.Product_Inventory__c));
                        System.debug('riverWarehouseRec = > #6'+riverWarehouseRec);
                        
                    }
                }
            }            
            updateRiverWarehouseInventory(riverWarehouseUpdates, riverWarehouseRec, productsToUpdateInRiverWarehouse);
            
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + ' && Error Line: ' + e.getLineNumber());
        }
    }
    
    public static void onUpdateProductTransferUpdateInventory(Map<Id, ProductTransfer> newMap, Map<Id, ProductTransfer> oldMap) {
        try {
            Set<Id> productInventoryIds             = new Set<Id>();
            Map<Id, Decimal> inventoryUpdates       = new Map<Id, Decimal>(); 
            Map<Id, Decimal> inventoryRecUpdates    = new Map<Id, Decimal>();
            for (Id transferId : newMap.keySet()) {
                ProductTransfer newTransfer = newMap.get(transferId);
                ProductTransfer oldTransfer = oldMap.get(transferId);
                System.debug('Processing transferId: ' + transferId + ', newTransfer: ' + newTransfer + ', oldTransfer: ' + oldTransfer);
                if (newTransfer.Product_Inventory__c != null) {
                    productInventoryIds.add(newTransfer.Product_Inventory__c);
                    Decimal oldValueRec = oldTransfer.QuantityReceived != null ? oldTransfer.QuantityReceived : 0;
                    Decimal newValueRec = newTransfer.QuantityReceived != null ? newTransfer.QuantityReceived : 0;
                    Decimal oldValueSen = oldTransfer.QuantitySent != null ? oldTransfer.QuantitySent : 0; 
                    Decimal newValueSen = newTransfer.QuantitySent != null ? newTransfer.QuantitySent : 0;
                    Decimal currentValue = inventoryUpdates.containsKey(newTransfer.Product_Inventory__c) ? inventoryUpdates.get(newTransfer.Product_Inventory__c) : 0;                    
                    Decimal currentValueRec = inventoryRecUpdates.containsKey(newTransfer.Product_Inventory__c) ? inventoryRecUpdates.get(newTransfer.Product_Inventory__c) : 0;
                    inventoryUpdates.put(newTransfer.Product_Inventory__c, currentValue + (newValueRec - oldValueRec)); 
                    inventoryRecUpdates.put(newTransfer.Product_Inventory__c, currentValue + (newValueSen - oldValueSen));
                    System.debug('Updated inventoryInwardUpdates: ' + inventoryUpdates); 
                    System.debug('Updated inventoryRecivedUpdates: ' + inventoryRecUpdates); 
                }
            }
            System.debug('Final productInventoryIds == > ' + productInventoryIds);
            updateProductInventoryRecived(productInventoryIds, inventoryUpdates, inventoryRecUpdates); // check what goes in here 
        } catch (Exception e) {
            System.debug('Error Message == > ' +e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    public static void onDeleteProductTransferUpdateInventory(List<ProductTransfer> oldTransfers) {        
        try {
            Set<Id> productInventoryIds             = new Set<Id>();
            Map<Id, Decimal> inventoryUpdates       = new Map<Id, Decimal>();
            Map<Id, Decimal> inventoryRecUpdates    = new Map<Id, Decimal>();
            for (ProductTransfer transfer : oldTransfers) {
                System.debug('Processing transfer == > ' + transfer);
                if (transfer.Product_Inventory__c != null) {
                    productInventoryIds.add(transfer.Product_Inventory__c);
                    System.debug('Adding to productInventoryIds == > ' + productInventoryIds);
                    Decimal currentValue = inventoryUpdates.containsKey(transfer.Product_Inventory__c) ? inventoryUpdates.get(transfer.Product_Inventory__c) : 0;
                    inventoryUpdates.put(transfer.Product_Inventory__c, currentValue  - (transfer.QuantityReceived != null ? transfer.QuantityReceived : 0));
                    inventoryRecUpdates.put(transfer.Product_Inventory__c, currentValue  - (transfer.QuantitySent != null ? transfer.QuantitySent : 0));
                    System.debug('inventoryUpdates === > ' + inventoryUpdates);
                    System.debug('inventoryRecUpdates == >: ' + inventoryRecUpdates);
                }
            }            
            System.debug('Final productInventoryIds == >: ' + productInventoryIds);
            updateProductInventory(productInventoryIds, inventoryUpdates, inventoryRecUpdates);
        } catch (Exception e) {
            System.debug('Error Message ' +e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    private static void updateProductInventory(Set<Id> productInventoryIds, Map<Id, Decimal> inventoryUpdates,  Map<Id, Decimal> inventoryUpdateRecieved) {
        System.debug('productInventoryIds #12 === > ' + productInventoryIds+' && inventoryInwardUpdates == >' +inventoryUpdates +' && inventoryUpdateRecieved === >'+inventoryUpdateRecieved);
        try {
            if (productInventoryIds.isEmpty()){
                System.debug('No productInventoryIds to process.');
                return;
            } 
            List<ProductItem> productInventoryList = [SELECT Id, Inward_Quantity__c, Transfer_Quantity__c  FROM ProductItem WHERE Id IN :productInventoryIds];
            System.debug('productInventoryList == > #7 ' + productInventoryList);
            for (ProductItem inventory : productInventoryList) {
                if (inventoryUpdates.containsKey(inventory.Id)) { //0
                    inventory.Transfer_Quantity__c  = (inventory.Transfer_Quantity__c != null ? inventory.Transfer_Quantity__c : 0)  + inventoryUpdates.get(inventory.Id);
                    System.debug('Updated inventory.Id $ === > && ' + inventory.Id + ', inventory.Inward_Quantity__c == && ' + inventory.Inward_Quantity__c + ', inventory.trnasferQuantity == && ' + inventory.Transfer_Quantity__c);
                }
                if (inventoryUpdateRecieved.containsKey(inventory.Id)) { //20
                    inventory.Inward_Quantity__c = (inventory.Inward_Quantity__c != null ?  inventory.Inward_Quantity__c : 0)   + inventoryUpdateRecieved.get(inventory.Id);
                    System.debug('Updated inventory.Id  # === > && ' + inventory.Id +  'inventory.trnasferQuantity == && ' + inventory.Transfer_Quantity__c);
                }
            }
            if (!productInventoryList.isEmpty()) {
                update productInventoryList;
                System.debug('productInventoryList === >'+productInventoryList);
            }
        } catch (Exception e) {
            System.debug('Error Message == > ' +e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    private static void updateProductInventoryRecived(Set<Id> productInventoryIds, Map<Id, Decimal> inventoryUpdates,  Map<Id, Decimal> inventoryUpdateRecieved) {
        System.debug('productInventoryIds #12 === > ' + productInventoryIds+' && inventoryInwardUpdates == >' +inventoryUpdates +' && inventoryUpdateRecieved === >'+inventoryUpdateRecieved);
        try {
            if (productInventoryIds.isEmpty()){
                System.debug('No productInventoryIds to process.');
                return;
            } 
            List<ProductItem> productInventoryList = [SELECT Id, Inward_Quantity__c, Transfer_Quantity__c  FROM ProductItem WHERE Id IN :productInventoryIds];
            System.debug('productInventoryList == > #7 ' + productInventoryList);
            for (ProductItem inventory : productInventoryList) {
                if (inventoryUpdates.containsKey(inventory.Id)) { //8
                    inventory.Inward_Quantity__c  = (inventory.Inward_Quantity__c != null ? inventory.Inward_Quantity__c : 0)  + inventoryUpdates.get(inventory.Id);
                    System.debug('Updated inventory.Id $ === > && ' + inventory.Id + ', inventory.Inward_Quantity__c == && ' + inventory.Inward_Quantity__c + ', inventory.trnasferQuantity == && ' + inventory.Transfer_Quantity__c);
                }
                if (inventoryUpdateRecieved.containsKey(inventory.Id)) { //0
                    inventory.Transfer_Quantity__c = (inventory.Transfer_Quantity__c != null ?  inventory.Transfer_Quantity__c : 0)   + inventoryUpdateRecieved.get(inventory.Id);
                    System.debug('Updated inventory.Id  # === > && ' + inventory.Id +  'inventory.trnasferQuantity == && ' + inventory.Transfer_Quantity__c);
                }
            }
            if (!productInventoryList.isEmpty()) {
                update productInventoryList;
                System.debug('productInventoryList === >'+productInventoryList);
            }
        } catch (Exception e) {
            System.debug('Error Message == > ' +e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }   
    
    private static void updateRiverWarehouseInventory(Map<String, Decimal> riverWarehouseUpdates, Map<String, Decimal> riverWarehouseRec, Set<Id> products) {
        System.debug('riverWarehouseUpdates==>: ' + riverWarehouseUpdates +  ' | riverWarehouseRec:==> ' + riverWarehouseRec + ' | products:==> ' + products);

        try {
            if ((riverWarehouseUpdates == null || riverWarehouseUpdates.isEmpty()) && 
                (riverWarehouseRec == null || riverWarehouseRec.isEmpty())) {
                System.debug('No River Warehouse updates to process.');
                return;
            }
            if (products == null || products.isEmpty()) {
                System.debug('No products provided to process.');
                return;
            }

            String riverWarehouseLocationId = System.Label.Default_River_Warehouse;
            if (String.isBlank(riverWarehouseLocationId)) {
                System.debug('Default River Warehouse location ID is missing.');
                return;
            }
            System.debug('riverWarehouseLocationId==>: ' + riverWarehouseLocationId);

            List<ProductItem> riverWarehouseInventoryList = [SELECT Id, Product2Id, LocationId, Transfer_Quantity__c, Inward_Quantity__c FROM ProductItem WHERE Product2Id IN :products AND LocationId = :riverWarehouseLocationId];
            System.debug('riverWarehouseInventoryList==>: ' + riverWarehouseInventoryList);

            Map<String, ProductItem> riverWarehouseInventoryMap = new Map<String, ProductItem>();
            for (ProductItem item : riverWarehouseInventoryList) {
                String compositeKey = item.Product2Id + '_' + item.LocationId;
                riverWarehouseInventoryMap.put(compositeKey, item);
            }
            System.debug('riverWarehouseInventoryMap:==> ' + riverWarehouseInventoryMap);

            if (riverWarehouseUpdates != null && !riverWarehouseUpdates.isEmpty()) {
                for (String updateKey : riverWarehouseUpdates.keySet()) {
                    if (riverWarehouseInventoryMap.containsKey(updateKey)) {
                        ProductItem inventoryItem = riverWarehouseInventoryMap.get(updateKey);
                        Decimal transferUpdate = riverWarehouseUpdates.get(updateKey);
                        inventoryItem.Transfer_Quantity__c = (inventoryItem.Transfer_Quantity__c != null ? inventoryItem.Transfer_Quantity__c : 0) + transferUpdate;
                    }
                }
            }

            if (riverWarehouseRec != null && !riverWarehouseRec.isEmpty()) {
                for (String updateKey : riverWarehouseRec.keySet()) {
                    if (riverWarehouseInventoryMap.containsKey(updateKey)) {
                        ProductItem inventoryItem = riverWarehouseInventoryMap.get(updateKey);
                        Decimal inwardUpdate = riverWarehouseRec.get(updateKey);
                        inventoryItem.Inward_Quantity__c = 
                            (inventoryItem.Inward_Quantity__c != null ? inventoryItem.Inward_Quantity__c : 0) + inwardUpdate;
                    }
                }
            }

            if (!riverWarehouseInventoryMap.isEmpty()) {
                update riverWarehouseInventoryMap.values();
                System.debug('Updated riverWarehouseInventoryMap: ' + riverWarehouseInventoryMap);
            } else {
                System.debug('No inventory records updated.');
            }
        } catch (Exception e) {
            System.debug('Error Message: ' + e.getMessage() + ' | Error Line: ' + e.getLineNumber());
        }
    }
    
    public static void handleDailyLedgerCreationOrUpdate(List<ProductTransfer> transfers) {
        try {
            System.debug('transfers === > ' + transfers);
            Set<Id> locationIds                             = new Set<Id>();
            Set<Id> productIds                              = new Set<Id>();
            Set<Date> transferDates                         = new Set<Date>();   
            List<Daily_Ledger__c> ledgersToInsert           = new List<Daily_Ledger__c>();
            List<Daily_Ledger__c> ledgersToUpdate           = new List<Daily_Ledger__c>();
            Map<Id, Id> productTransferToLedgerMap          = new Map<Id, Id>();
            Map<String, Daily_Ledger__c> existingLedgerMap  = new Map<String, Daily_Ledger__c>();
            for (ProductTransfer transfer : transfers) {
                if (transfer.DestinationLocationId != null && transfer.Product2Id != null) {
                    locationIds.add(transfer.DestinationLocationId);
                    productIds.add(transfer.Product2Id);
                    transferDates.add(transfer.CreatedDate.date());
                }
            }
            System.debug('Location IDs == > ' + locationIds+' && productIds == >'+productIds+' && transferDates === >'+transferDates); 
            List<Daily_Ledger__c> existingLedgersList = [ SELECT Id, Ledger_Date__c, Product__c, Intake_Quantity__c, Transfer_Quantity__c, Destination_Location__c FROM Daily_Ledger__c  WHERE Ledger_Date__c IN :transferDates AND Destination_Location__c IN :locationIds AND Product__c IN :productIds ];
            for (Daily_Ledger__c ledger : existingLedgersList) {
                String key = ledger.Ledger_Date__c + '-' + ledger.Destination_Location__c + '-' + ledger.Product__c;
                System.debug('Found existing ledger with key: ' + key);
                existingLedgerMap.put(key, ledger);
            }  
            
            for (ProductTransfer transfer : transfers) {
                if (transfer.DestinationLocationId == null || transfer.Product2Id == null) continue;
                
                Date transferDate = transfer.CreatedDate.date();
                String key = transferDate + '-' + transfer.DestinationLocationId + '-' + transfer.Product2Id;
                
                Id sourceLocation = System.Label.Default_River_Warehouse;
                
                Daily_Ledger__c ledger = existingLedgerMap.get(key);
                if (ledger == null) {
                    ledger = new Daily_Ledger__c();
                    ledger.Ledger_Date__c = transferDate;
                    ledger.Destination_Location__c = transfer.DestinationLocationId;
                    ledger.Product__c = transfer.Product2Id;
                    ledger.Source_Location__c = sourceLocation;
                    ledger.Intake_Quantity__c = transfer.QuantityReceived != null ? transfer.QuantityReceived : 0;
                    ledger.Transfer_Quantity__c = transfer.QuantitySent != null ? transfer.QuantitySent : 0;
                    
                    System.debug('ledge.Intake_Quantity__c::::::::' + ledger.Intake_Quantity__c + 'ledger.Transfer_Quantity__c:::'+ ledger.Transfer_Quantity__c);
                    ledgersToInsert.add(ledger);
                } else {
                    if(ledger.Intake_Quantity__c == 0){
                        ledger.Intake_Quantity__c = 
                            (ledger.Intake_Quantity__c != null ? ledger.Intake_Quantity__c : 0) 
                            + (transfer.QuantityReceived != null ? transfer.QuantityReceived : 0);
                    }
                    else{
                        ledger.Intake_Quantity__c = 
                            (ledger.Intake_Quantity__c != null ? ledger.Intake_Quantity__c : 0) 
                            + (transfer.QuantityReceived != null ? transfer.QuantityReceived : 0);
                    }
                    ledger.Transfer_Quantity__c = (ledger.Transfer_Quantity__c != null ? ledger.Transfer_Quantity__c : 0) + (transfer.QuantitySent != null ? transfer.QuantitySent : 0);
                    ledgersToUpdate.add(ledger);
                }
            }
            
            if (!ledgersToInsert.isEmpty()) {
                insert ledgersToInsert;
                for (Daily_Ledger__c insertedLedger : ledgersToInsert) {
                    System.debug('Inserted ledger: ' + insertedLedger);
                    String key = insertedLedger.Ledger_Date__c + '-' +  insertedLedger.Destination_Location__c + '-' + insertedLedger.Product__c;
                    existingLedgerMap.put(key, insertedLedger);
                }
            }
            for (ProductTransfer transfer : transfers) {
                Date transferDate = transfer.CreatedDate.date();
                String key = transferDate + '-' + transfer.DestinationLocationId + '-' + transfer.Product2Id;
                System.debug('Searching for ledger with key == > ' + key);
                if (existingLedgerMap.containsKey(key)) {
                    Daily_Ledger__c matchingLedger = existingLedgerMap.get(key);
                    productTransferToLedgerMap.put(transfer.Id, matchingLedger.Id);
                }
            }
            if (!ledgersToUpdate.isEmpty()) {
                update ledgersToUpdate;
                System.debug('Updating ledgersToUpdate  === > ' + ledgersToUpdate);
            }
            List<ProductTransfer> transfersToUpdate = new List<ProductTransfer>();
            for (ProductTransfer transfer : transfers) {
                if (productTransferToLedgerMap.containsKey(transfer.Id)) {
                    ProductTransfer updatedTransfer = new ProductTransfer( Id = transfer.Id, Daily_Ledger__c = productTransferToLedgerMap.get(transfer.Id) );
                    transfersToUpdate.add(updatedTransfer);
                }
            }
            if (!transfersToUpdate.isEmpty()) {
                update transfersToUpdate; 
                System.debug('transfersToUpdate  === > ' + transfersToUpdate);
            }
        }
        catch (Exception e) {
            System.debug('Error Message ' +e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
}