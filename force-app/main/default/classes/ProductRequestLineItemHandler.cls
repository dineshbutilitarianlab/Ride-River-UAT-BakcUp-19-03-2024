public class ProductRequestLineItemHandler {
    private static Boolean isTriggerExecuted = false;
    
    public static void productLineItemUnitPrice(List<ProductRequestLineItem> newList) {
        try{
            if (isTriggerExecuted) {
                return;
            }
            isTriggerExecuted = true; 
            try {
                Set<Id> productRequestIds = new Set<Id>();
                Set<Id> product2Ids = new Set<Id>();
                for (ProductRequestLineItem item : newList) {
                    if (item.ParentId != null) { 
                        productRequestIds.add(item.ParentId);
                    }
                    if (item.Product2Id != null) {
                        product2Ids.add(item.Product2Id);
                    }
                }
                
                if (!productRequestIds.isEmpty()) {
                    List<ProductRequest> productRequests = [SELECT Id, Destination_Location__c, Destination_Location__r.State__c FROM ProductRequest WHERE Id IN :productRequestIds];
                    Set<String> stateNames = new Set<String>();
                    for (ProductRequest req : productRequests) {
                        if (req.Destination_Location__r != null && req.Destination_Location__r.State__c != null) {
                            stateNames.add(req.Destination_Location__r.State__c);
                        }
                    }
                    
                    if (!stateNames.isEmpty()) {
                        List<Pricebook2> matchingPriceBooks = [SELECT Id, Name, State__c FROM Pricebook2 WHERE State__c IN :stateNames];
                        if (!matchingPriceBooks.isEmpty()) {
                            Set<Id> pricebookIds = new Set<Id>();
                            for (Pricebook2 pb : matchingPriceBooks) {
                                pricebookIds.add(pb.Id);
                            }
                            List<PricebookEntry> pricebookEntries = [SELECT Id, Product2Id, Pricebook2Id,CGST__c,IGST__c,SGST__c,UnitPrice,Dealer_List_Price__c FROM PricebookEntry WHERE Pricebook2Id IN :pricebookIds AND Product2Id IN :product2Ids];
                            Map<Id, Decimal> productToUnitPriceMap = new Map<Id, Decimal>();
                            Map<Id, Decimal> productToIGSTMap = new Map<Id, Decimal>();
                            Map<Id, Decimal> productToCGSTMap = new Map<Id, Decimal>();
                            Map<Id, Decimal> productToSGSTMap = new Map<Id, Decimal>();
                            for (PricebookEntry entry : pricebookEntries) {
                                productToUnitPriceMap.put(entry.Product2Id, entry.Dealer_List_Price__c);
                                productToIGSTMap.put(entry.Product2Id, entry.IGST__c);
                                productToCGSTMap.put(entry.Product2Id, entry.CGST__c);
                                productToSGSTMap.put(entry.Product2Id, entry.SGST__c);
                            } 
                            List<ProductRequestLineItem> itemsToUpdate = new List<ProductRequestLineItem>();
                            for (ProductRequestLineItem item : newList) {
                                if (item.Product2Id != null && productToUnitPriceMap.containsKey(item.Product2Id)) {
                                    ProductRequestLineItem updateItem = new ProductRequestLineItem(
                                        Id = item.Id,
                                        Unit_Price__c = productToUnitPriceMap.get(item.Product2Id),
                                        IGST__c = productToIGSTMap.get(item.Product2Id),
                                        CGST__c = productToCGSTMap.get(item.Product2Id),
                                        SGST__c = productToSGSTMap.get(item.Product2Id)
                                    );
                                    itemsToUpdate.add(updateItem);
                                }
                            }
                            
                            if (!itemsToUpdate.isEmpty()) {
                                update itemsToUpdate; 
                                System.debug('Updated ProductRequestLineItem records: ' + itemsToUpdate);
                            } else {
                                System.debug('ProductRequestLineItem records Not Found :::::::');
                            }
                        } else {
                            System.debug('Pricebooks Not found for the Selected state::::::::');
                        }
                    } else {
                        System.debug('state Not found from ProductRequest records::::::::::::');
                    }
                } else {
                    System.debug('No valid ProductRequest IDs found:::::::');
                }
            } catch (Exception ex) {
                System.debug('Error in productLineItemUnitPrice: ' + ex.getMessage() +'&& Error Line == >'+ex.getLineNumber());
            } finally {
                isTriggerExecuted = false;
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
}