/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-06-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class OrderProductTriggerController {
    
    Public static boolean triggerRan = false;
    
    Public static void Updatehandler(List<OrderItem> newItems, Map<Id,OrderItem> oldMap){
        
        triggerRan = true;
        
        Set<Id> idSet = new Set<Id>();
        Set<Id> itemIdSet = new Set<Id>();
        
        Map<Id, Decimal> mapIdToQty = new Map<Id, Decimal>();        
        
        For(OrderItem item: newItems){
            
            //Outbound integration - Updating order item status to the Website.
            if(oldMap.get(Item.Id).Status__c != Item.Status__c && item.Is_Integration__c == oldMap.get(Item.Id).Is_Integration__c){
                If(!Test.isRunningTest()){
                    UpdateOrderToWebsite.executeDisplayOutput(Item.OrderId);
                }
                
            }            
            
            If((oldMap.get(Item.Id).Status__c != Item.Status__c) &&  Item.Status__c == 'REFUND_REQUESTED'){
                idSet.add(item.OrderId);
                If(item.Inventory_Lot__c != null ){
                    system.debug('inventory Id>>'+item);
                    If(!mapIdToQty.containsKey(item.Inventory_Lot__c)){
                        mapIdToQty.put(item.Inventory_Lot__c, item.Quantity);
                    }else {
                        mapIdToQty.put(item.Inventory_Lot__c, mapIdToQty.get(item.Inventory_Lot__c)+item.Quantity);
                        system.debug('else mapIdToQty>>>'+mapIdToQty);
                    }
                }
            }
            
        } 
        
        If(!mapIdToQty.isempty())
            // updateInventory(mapIdToQty);
            
            //Call Future Method
            // HandleCancellation(idSet);
            If(!idSet.isempty())
            System.enqueueJob(new OrderCancellationQueueable(idSet));
    }
    
    Public static void Deletehandler(List<OrderItem> newItems){
        
        Set<Id> idSet = new Set<Id>();
        Map<Id, Decimal> mapIdToQty = new Map<Id, Decimal>();
        
        For(OrderItem item: newItems){
            
            idSet.add(item.OrderId);
            
            If(item.Status__c != 'REFUND_REQUESTED' && item.Inventory_Lot__c != null){
                If(mapIdToQty.containsKey(item.Inventory_Lot__c)){
                    mapIdToQty.put(item.Inventory_Lot__c, item.Quantity);
                }else{
                    mapIdToQty.put(item.Inventory_Lot__c, mapIdToQty.get(item.Inventory_Lot__c)+item.Quantity);
                }
            }            
        }  
        
        updateInventory(mapIdToQty);
        
        //Call Future Method
        //HandleCancellation(idSet);
        System.enqueueJob(new OrderCancellationQueueable(idSet));
    }
    
    Public static void updateInventory(Map<Id, Decimal> mapIdToQty){
        
        List<Inventory_Lot__c> invListToUpdate = new List<Inventory_Lot__c>();
        
        //Update the Inventory
        List<Inventory_Lot__c> inventoryList = [SELECT Id, Available_quantity__c FROM Inventory_Lot__c WHERE Id in :mapIdToQty.keyset() ];
        
        For(Inventory_Lot__c inv : inventoryList){
            Inventory_Lot__c inv1 = inv;
            inv1.Available_Quantity__c = (inv1.Available_Quantity__c != null?inv1.Available_Quantity__c:0) + mapIdToQty.get(inv.Id);
            invListToUpdate.add(inv1);
        }
        
        Database.update(invListToUpdate, false);
    }
    
    //Update the total price 
    Public static void beforeHandler(List<OrderItem> orderItemList, Map<Id, OrderItem> oldmap){
        
        List<OrderItem> ol = new list<OrderItem> ();
        For(OrderItem o : orderItemList){
            If((oldmap != null && (o.Quantity != oldmap.get(o.Id).Quantity || o.UnitPrice != oldmap.get(o.Id).UnitPrice))|| (o.Quantity != null && o.UnitPrice != null) ){
                If(o.Offer_Amount__c == null)
                    o.Offer_Amount__c = 0;
                If(o.Total_Price__c == null)
                    o.Total_Price__c = 0;
                If(o.UnitPrice == null)
                    o.UnitPrice = 0;
                If(o.Quantity == null)
                    o.Quantity = 0;
                o.Total_Price__c = o.Quantity * o.UnitPrice - o.Offer_Amount__c;
            }
        }
        
        system.debug('oldmap>>'+oldmap);
        Set<Id> orderIds = new Set<Id>();
        Map<Id, Set<String>> orderProductTypes = new Map<Id, Set<String>>();
        List<String> restrictedTypes = new List<String>{'Vehicle', 'Extended Warranty'};
            
            for (OrderItem op : orderItemList) {
                if (op.OrderId != null && ((oldmap != null && (op.Product2Id != oldmap.get(op.Id).Product2Id || op.Type__c != oldmap.get(op.Id).Type__c)) || oldmap == null)) {
                    orderIds.add(op.OrderId);
                }
            }
        
        for (OrderItem op : [SELECT Id, OrderId, Product2.Type__c FROM OrderItem WHERE OrderId IN :orderIds AND Product2.Type__c IN :restrictedTypes]) {
            if (!orderProductTypes.containsKey(op.OrderId)) {
                orderProductTypes.put(op.OrderId, new Set<String>());
            }
            orderProductTypes.get(op.OrderId).add(op.Product2.Type__c);
        }
        
        for (OrderItem op : orderItemList) {
            If((oldmap != null && (op.Product2Id != oldmap.get(op.Id).Product2Id || op.Type__c != oldmap.get(op.Id).Type__c)) || oldmap == null){
                
                
                if (op.OrderId != null && op.Type__c != null && restrictedTypes.contains(op.Type__c)) {
                    if (orderProductTypes.containsKey(op.OrderId) && orderProductTypes.get(op.OrderId).contains(op.Type__c)) {
                        
                        //op.addError('Only one product of type Vehicle or Extended Warranty is allowed per order.');
                    } else {
                        if (!orderProductTypes.containsKey(op.OrderId)) {
                            orderProductTypes.put(op.OrderId, new Set<String>());
                        }
                        orderProductTypes.get(op.OrderId).add(op.Type__c);
                    }
                }
            }
        }
    }
}