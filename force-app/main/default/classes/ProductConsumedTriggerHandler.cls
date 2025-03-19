public class ProductConsumedTriggerHandler {
    public static void rollUpOfQuantityConsumed(List<ProductConsumed> newProductConsumedList,Map<Id,ProductConsumed> oldMapOfProductConsumed){
        try{
            Set<Id> productInventoryIds = new Set<Id>();
            for(ProductConsumed p : newProductConsumedList){
                if(p.ProductItemId!=null){
                    productInventoryIds.add(p.ProductItemId); 
                }
               // productInventoryIds.add(p.ProductItemId); 
                
                System.debug('productInventoryIds===>'+productInventoryIds);
                if (oldMapOfProductConsumed != null && oldMapOfProductConsumed.containsKey(p.Id)) {
                    if ( p.Quantity_Consumed__c != oldMapOfProductConsumed.get(p.Id).Quantity_Consumed__c) {
                        productInventoryIds.add(p.ProductItemId);
                        productInventoryIds.add(oldMapOfProductConsumed.get(p.Id).ProductItemId);
                    }
                }
            }  
            System.debug('productInventoryIds===>'+productInventoryIds);
            
            List<ProductItem> productInventoryList = [Select id,Consumed_Quantity__c from ProductItem Where Id=:productInventoryIds];
            List<ProductItem> productItemToUpdate = new List<ProductItem>();
            List<AggregateResult> totalQuantityCosumedCalculation = [Select ProductItemId,sum(Quantity_Consumed__c) totalCount from 
                                                                     ProductConsumed WHERE ProductItemId IN :productInventoryIds 
                                                                     Group by ProductItemId];
            System.debug('totalQuantityCosumedCalculation===>'+totalQuantityCosumedCalculation);
            
            Set<Id> productItemIdsWithValue = new Set<Id>();
            
            for (AggregateResult ag : totalQuantityCosumedCalculation) {
                Id productItemId = (Id)ag.get('ProductItemId');
                productItemIdsWithValue.add(productItemId);
                
                ProductItem pI = new ProductItem();
                pI.Id = productItemId;
                pI.Consumed_Quantity__c = (Double)ag.get('totalCount');
               // pI.Quantity_In_Hand__c = pI.Quantity_In_Hand__c - (Double)ag.get('totalCount');
                
                productItemToUpdate.add(pI);            
            }
            
            for (ProductItem pI : productInventoryList) {
                if (!productItemIdsWithValue.contains(pI.Id)) {
                    ProductItem zeroValueItem = new ProductItem();
                    zeroValueItem.Id = pI.Id;
                    zeroValueItem.Consumed_Quantity__c = 0;
                    productItemToUpdate.add(zeroValueItem);
                }
            }
            if(!productItemToUpdate.isEmpty()){
                update productItemToUpdate;
                
                System.debug('productItemToUpdate==>'+productItemToUpdate);   
            } 
        }
        catch(Exception e){
            System.debug('Error Message is===>'+e.getMessage()+'And   '+'Error Occured In Line Number===>'+e.getLineNumber());
        }
    }
   
}