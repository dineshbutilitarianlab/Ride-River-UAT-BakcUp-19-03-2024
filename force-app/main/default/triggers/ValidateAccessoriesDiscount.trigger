trigger ValidateAccessoriesDiscount on Order ( before update) {
    
   
    // along with any other product, then do not allow Accessories discount on order
    
    Set<Id> orderIds = new Set<Id>();
    for (Order ord : Trigger.New) {
        orderIds.add(ord.id);
    }
    
    List<OrderItem> orderItems = [SELECT Id, OrderId, Product2.Name, Product2.Type__c 
                                  FROM OrderItem 
                                  WHERE OrderId IN :orderIds];
    
    for (Order ord : Trigger.New) {
        Boolean hasVehicle = false;
        Boolean hasExtendedWarranty = false;
        Boolean hasRoadsideAssistance = false;
        Boolean hasOtherProduct = false;
        
        for (OrderItem item : orderItems) {
            if (item.OrderId == ord.Id) {
                if (item.Product2.Type__c == 'Vehicle') {
                    hasVehicle = true;
                }/* else if (item.Product2.Name == 'Extended Warranty') {
                    hasExtendedWarranty = true;
                } else if (item.Product2.Name == 'Roadside Assistance') {
                    hasRoadsideAssistance = true;
                } else {
                    hasOtherProduct = true;
                }*/
            }
        }
        
        // Check conditions
        if (ord.Accessories_Discount_Amount__c != null) {
            if (!(hasVehicle)) {
               // ord.addError('Accessories discount can only be applied if order contains Vehicle product');
                ord.Accessories_Discount_Amount__c = null;
            }
        }
    }
}