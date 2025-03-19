trigger UpdateAllotmentQuantity on Quantity_Allotment__c (after insert, after update, after delete) {
    Set<Id> productOrderLineItemIds = new Set<Id>();
    
    // Get the ProductOrderLineItem IDs from the triggered PO_Allotment__c records
    for (Quantity_Allotment__c poAllotment : Trigger.New) {
        productOrderLineItemIds.add(poAllotment.PO_Line_Item__c);
    }
    
    // Get the ProductOrderLineItem records
    List<ProductRequestLineItem> productOrderLineItems = [SELECT Id, Alloted_Quantity__c 
                                                               FROM ProductRequestLineItem 
                                                               WHERE Id IN :productOrderLineItemIds];
    
    // Calculate the sum of Allotment_Quantity__c for each ProductOrderLineItem
    Map<Id, Decimal> allotmentQuantityMap = new Map<Id, Decimal>();
    for (ProductRequestLineItem productOrderLineItem : productOrderLineItems) {
        Decimal allotmentQuantity = 0;
        for (Quantity_Allotment__c poAllotment : [SELECT Alloted_Quantity__c 
                                                  FROM Quantity_Allotment__c 
                                                  WHERE PO_Line_Item__c = :productOrderLineItemIds]) {
            allotmentQuantity += poAllotment.Alloted_Quantity__c;
        }
        //test  allotmentQuantityMap.put(allotmentQuantityMap.Id, allotmentQuantity);
    }
    
    // Update the Allotment_Quantity__c field on the ProductOrderLineItem records
    for (ProductRequestLineItem productOrderLineItem : productOrderLineItems) {
   //test     productOrderLineItem.Alloted_Quantity__c = allotmentQuantityMap.get(productOrderLineItemIds);
    }
    update productOrderLineItems;
}