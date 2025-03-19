public class productTransferTriggerHandler {
//     public static void rollUpOnDailyLedger(List<ProductTransfer> newProductTransfer){
//         try{
//             Set<Id> locationName = new Set<Id>();
//             Map<Id, Double> intakeQuantityByLocation = new Map<Id, Double>();
//             Map<Id, Double> transferQuantityByLocation = new Map<Id, Double>();
//             for(ProductTransfer pt : newProductTransfer){
//                 locationName.add(pt.DestinationLocationId);
//                 if(pt.RecordType.Name == 'Inward'){
//                     if(!intakeQuantityByLocation.containsKey(pt.DestinationLocationId)){
//                         intakeQuantityByLocation.put(pt.DestinationLocationId,pt.QuantitySent);
//                     }else{
//                         intakeQuantityByLocation.put(pt.DestinationLocationId, intakeQuantityByLocation.get(pt.DestinationLocationId) + pt.QuantitySent);
//                     }
                    
//                 }else if(pt.RecordType.Name == 'Transfer'){
//                     if(!transferQuantityByLocation.containsKey(pt.DestinationLocationId)){
//                         transferQuantityByLocation.put(pt.DestinationLocationId,pt.QuantitySent);
//                     } else{
//                         transferQuantityByLocation.put(pt.DestinationLocationId,transferQuantityByLocation.get(pt.DestinationLocationId) + pt.QuantitySent);
//                     }   
//                 }    
//             }
//             List<Daily_Ledger__c> dailyLedgerList = 
//             [Select id,Intake_Quantity__c,Transfer_Quantity__c,Location__c from Daily_Ledger__c where Location__c IN:locationName];
            
//             for(Daily_Ledger__c dl : dailyLedgerList){
//                 if(intakeQuantityByLocation.containsKey(dl.Location__c)){
//                     dl.Intake_Quantity__c = intakeQuantityByLocation.get(dl.Location__c);
//                 } if (transferQuantityByLocation.containsKey(dl.Location__c)){
//                     dl.Transfer_Quantity__c = transferQuantityByLocation.get(dl.Location__c);
//                 }
//             }
//             if(!dailyLedgerList.isEmpty()){
//                 update dailyLedgerList;
//             }
//         }
//         catch(Exception e){
//             System.debug('Error Occured ===>'+e.getMessage()+'Error Occured In Line Number ====>'+e.getLineNumber());
//         }
//     }
//    public static void createDailyLedger(List<ProductTransfer> productTransferList){
//     try{
//         System.debug('Code IN');
        
        
//         Map<Date, Id> checkDailyLedgerRecord = new Map<Date, Id>(); 
        
        
//         for(ProductTransfer pt : productTransferList){
//             if(pt.RecordTypeId == SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('Inward').getRecordTypeId()){
//                 Date createdDateOnly = pt.CreatedDate.date();  // Extract only the Date part
                
//                 if(!checkDailyLedgerRecord.containsKey(createdDateOnly)){
//                     checkDailyLedgerRecord.put(createdDateOnly, pt.Id);
//                     System.debug('checkDailyLedgerRecord==>' + checkDailyLedgerRecord);
//                 }
//             }
//         }
        
        
//         List<Daily_Ledger__c> existingDailyLedgers = [
//             SELECT Id, CreatedDate, Product_Transfer__c
//             FROM Daily_Ledger__c
//             WHERE CreatedDate IN :checkDailyLedgerRecord.keySet()  
//             AND Product_Transfer__c IN :checkDailyLedgerRecord.values()
//         ];  

        
//         Set<String> existingLedgerKeys = new Set<String>();
//         for (Daily_Ledger__c ledger : existingDailyLedgers) {
           
//             String key = ledger.CreatedDate.date() + '-' + ledger.Product_Transfer__c; 
//             existingLedgerKeys.add(key);
//         }
//         System.debug('existingLedgerKeys==>' + existingLedgerKeys);

        
//         List<Daily_Ledger__c> ledgersToInsert = new List<Daily_Ledger__c>();
        
        
//         for (Date createdDate : checkDailyLedgerRecord.keySet()) {
//             String key = createdDate + '-' + checkDailyLedgerRecord.get(createdDate);
            
            
//             if (!existingLedgerKeys.contains(key)) {
//                 Daily_Ledger__c newLedger = new Daily_Ledger__c(
//                     Product_Transfer__c = checkDailyLedgerRecord.get(createdDate),
//                     Product_Inventory__c = '0CoF4000000WAizKAG' // HardCoded for now
//                 );
//                 ledgersToInsert.add(newLedger);
//             }
//         }

        
//         if (!ledgersToInsert.isEmpty()) {
//             insert ledgersToInsert;
//             System.debug('Inserted Records: ' + ledgersToInsert);
//         }
//     }
//     catch(Exception e){
//         System.debug('Error Occurred ===>' + e.getMessage() + ' Error Line number is ===>' + e.getLineNumber());            
//     }
// }

    
}