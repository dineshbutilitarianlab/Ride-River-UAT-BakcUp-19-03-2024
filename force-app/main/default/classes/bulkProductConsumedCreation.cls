public class bulkProductConsumedCreation {
    public static void bulkProductConsumption(List<OrderItem> orderItemList){
        
        List<ProductConsumed> productConsumedToInsert = new List<ProductConsumed>();
        
        for(OrderItem oi : orderItemList){
            ProductConsumed pc = new ProductConsumed();
            pc.Order_Product__c=oi.Id;
            
            
            
        }
    }
    
    
}