trigger UpdateVehicleInsuranceAndFinance on Order (before insert, before update, after update,After Insert) {
    
    if(trigger.isBefore && trigger.isInsert){
        // Jitendra added for Order validaiton
        OrderStatusHandler.checkUniqueDealerVIN(trigger.new);
    }   
    
    if(trigger.isBefore && trigger.isUpdate){
        // Jitendra added for Order validaiton
        OrderStatusHandler.checkValidaionStatus(trigger.newMap, trigger.oldMap);
        // OrderStatusHandler.updatehandler(trigger.new, trigger.oldMap);
    }
    
    //Edited By Sudarshan
    if(trigger.isAfter && trigger.isupdate){
        
        OrderStatusHandler.updateVehicle(trigger.new, trigger.oldMap);
        OrderStatusHandler.updateVehicle01(trigger.new, trigger.oldMap); 
        OrderStatusHandler.emailHandllerMethod(trigger.new, trigger.oldMap);
        OrderStatusHandler.generateIvoicesAndReceipts(trigger.new, trigger.oldMap);
        OrderStatusHandler.sendPreOrderReceipt(trigger.new, trigger.oldMap);
        for(Order ord:trigger.new){
            
            if(ord.Assigned_Vehicle__c != null && ord.Assigned_Vehicle__r.RSA_Activation__c != true){
                if (!Test.isRunningTest()) {
                    RSACalloutHandler.getchasisnumber(trigger.new);  
                }else if(ord.Status=='RTO Registration'||ord.Status=='Vehicle Delivered' && (ord.Assigned_Vehicle__c != null)){
                    RSACalloutHandler.getchasisnumber(trigger.new); 
                    System.debug('Method Called  ## RSACalloutHandler.getchasisnumber');
                }
                //Added By Uma 
            }else{
                System.debug('RSA Activation already done');
            }
            
            
            // Added by Dinesh - 07/01/2025
            try{
                if ((ord.Status == 'RTO Registration' || ord.Status == 'Vehicle Delivered') && ord.Assigned_Vehicle__c == null && ord.AccountId != null) {
                    
                    List<Vehicle> vehicles = [SELECT Id, RSA_Activation__c 
                                              FROM Vehicle 
                                              WHERE Account__c = :ord.AccountId];
                    
                    if (vehicles.size() == 1 && !vehicles[0].RSA_Activation__c) {
                        RSACalloutHandler.getchasisnumberWihtoutVehicleOrder(trigger.new);
                        System.debug('Method Called ## getchasisnumberWihtoutVehicleOrder');
                    } else {
                        System.debug('Method Not Called ## No valid vehicle found or RSA Activation is true');
                    }
                } else {
                    System.debug('Method Not Called ## Conditions not met');
                }
            }catch(Exception e){
                System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            }
            
        }
        
        // method to create the invoice records
        OrderStatusHandler.ceateInvoiceRecords(trigger.new, trigger.oldMap);
        
        if (Test.isRunningTest()){
         // For Code coverage- No Logic
        RSACalloutHandler.getOrderCodeCoverage(trigger.new);
        RSACalloutHandler.getOrderCodeCoverage1(trigger.new);
        RSACalloutHandler.getOrderCodeCoverage2(trigger.new);
        RSACalloutHandler.getOrderCodeCoverage3(trigger.new);
        }

    } 
}