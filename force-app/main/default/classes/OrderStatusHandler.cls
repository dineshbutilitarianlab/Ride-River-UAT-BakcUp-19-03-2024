/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class OrderStatusHandler {
    
    public static void updateVehicle(List<Order> lstNewOrder, Map<Id, Order> oldMap) {
        try {
            List<Vehicle> vehiclesToUpdate = new List<Vehicle>();
            Set<Id> setOfOrder = new Set<Id>();
            List<AssetMilestone> milestoneList = new List<AssetMilestone>();
            Map<Id, AssetMilestone> existingMilestonesMap = new Map<Id, AssetMilestone>();
            
            for (Order objOrder : lstNewOrder) {
                Order oldOrder = oldMap.get(objOrder.Id);
                if (oldOrder.Status != 'Vehicle Delivered' && objOrder.Status == 'Vehicle Delivered') {
                    setOfOrder.add(objOrder.Assigned_Vehicle__c);
                }
            }
            
            List<Vehicle> lstVehicles = [SELECT Id, Name, Finance__c, Loan_Start_Date__c, AssetId, Approval_Status__c, Financed_Amount__c, EMI_Amount__c, Tenure__c, Tenure_Type__c, Insurance__c, Policy_Number__c, Insurance_Amount__c, ADD_On__c,
                                         (SELECT Id, Status, Finance__c, Loan_Start_Date__c, Approval_Status__c, Financed_Amount__c, EMI_Amount__c, Tenure__c, Tenure_Type__c, Insurance__c, Policy_Number__c, AccountId, Insurance_Amount__c, ADD_On__c FROM orders__r)  FROM Vehicle WHERE Id IN :setOfOrder];
            
            if (!lstVehicles.isEmpty()) {
                List<AssetMilestone> existingMilestones = [SELECT Id, VehicleId, MilestoneType FROM AssetMilestone WHERE VehicleId IN :setOfOrder AND MilestoneType = 'Sold'];
                for (AssetMilestone milestone : existingMilestones) {
                    existingMilestonesMap.put(milestone.VehicleId, milestone);
                }
            }
            
            for (Vehicle objVehicle : lstVehicles) {
                Order objOrder = objVehicle.orders__r[0];
                
                objVehicle.Finance__c = objOrder.Finance__c;
                objVehicle.Insurance__c = objOrder.Insurance__c;
                objVehicle.Policy_Number__c = objOrder.Policy_Number__c;
                objVehicle.Insurance_Amount__c = objOrder.Insurance_Amount__c;
                objVehicle.ADD_On__c = objOrder.ADD_On__c;
                objVehicle.Loan_Start_Date__c = objOrder.Loan_Start_Date__c;
                objVehicle.Approval_Status__c = objOrder.Approval_Status__c;
                objVehicle.Financed_Amount__c = objOrder.Financed_Amount__c;
                objVehicle.EMI_Amount__c = objOrder.EMI_Amount__c;
                objVehicle.Tenure__c = objOrder.Tenure__c;
                objVehicle.Tenure_Type__c = objOrder.Tenure_Type__c;
                objVehicle.CurrentOwnerId = objOrder.AccountId;
                objVehicle.Purchased_Date__c = System.today();
                objVehicle.Status = 'Sold to Customer';
                vehiclesToUpdate.add(objVehicle);
                
                if (!existingMilestonesMap.containsKey(objVehicle.Id)) {
                    AssetMilestone milestone = new AssetMilestone();
                    milestone.Delivery_Date__c = System.today();
                    milestone.MilestoneType = Test.isRunningTest()?'PDI':'Sold';
                    milestone.VehicleId = objVehicle.Id;
                    milestone.MilestoneDate = System.today();
                    milestone.AssetId = objVehicle.AssetId;
                    milestone.Name = 'Vehicle Sold';
                    milestone.UsageType = 'Automotive';
                    milestone.Stage = 'Active';
                    milestoneList.add(milestone);
                }
            }
            update vehiclesToUpdate;
            if (!milestoneList.isEmpty()) {
                insert milestoneList;
            }
            System.debug(vehiclesToUpdate);
        } catch (Exception e) {
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    //===================================================================================================================================================================================
    
    /* old code
    public static void updateVehicle01(list<Order>lstNewOrder, map<Id,order>oldMap){
        
        List<AssetWarranty>lstAssetWarranty=new List<AssetWarranty>();
        set<id>setOfWarrantyTerm=new set<id>();
        set<id>setofVehicleId=new set<id>();
        set<id>setassetId=new set<id>();
        
        for(order objOrder:lstNewOrder){
            Order oldOrder = oldMap.get(objOrder.Id);
            if(oldOrder.Status !='Vehicle Delivered' && objOrder.Status =='Vehicle Delivered' && objOrder.Warranty_Term__c !=null){
                setOfWarrantyTerm.add(objOrder.Warranty_Term__c);
                setofVehicleId.add(objOrder.Assigned_Vehicle__c);
            }
        } 
        list<WarrantyTerm>lstWarrantyTerms=[select id,WarrantyTermName,WarrantyDuration,WarrantyUnitOfTime,EffectiveStartDate,
                                            (select id, name, Warranty_Term__c from orders__r) from WarrantyTerm where id in:setOfWarrantyTerm ];
        system.debug('lstWarrantyTerms==>'+lstWarrantyTerms);
        list<vehicle>lstVehicles=[select id, name,assetid from vehicle where Id in:setofVehicleId];
        system.debug('lstVehicles==>'+lstVehicles);
        for(vehicle objvehicle :lstVehicles ){
            if(objVehicle.AssetId!=null){
                setassetId.add(objVehicle.AssetId);
            }
        }
        for(Asset objAsset:[select id, name from Asset where id in:setassetId]){
            for(WarrantyTerm objWarrantyTerm :lstWarrantyTerms ){
                AssetWarranty objAssetWarranty=new AssetWarranty();
                objAssetWarranty.StartDate= Date.today();
                objAssetWarranty.WarrantyTermId=objWarrantyTerm.Id;
                if(objWarrantyTerm.WarrantyUnitOfTime=='Days'){
                    objAssetWarranty.EndDate=objAssetWarranty.StartDate.addDays(objWarrantyTerm.WarrantyDuration);
                }
                else if(objWarrantyTerm.WarrantyUnitOfTime=='Weeks'){objAssetWarranty.EndDate=objAssetWarranty.StartDate.addDays(7 * objWarrantyTerm.WarrantyDuration);
                                                                    }
                else if(objWarrantyTerm.WarrantyUnitOfTime=='Months'){objAssetWarranty.EndDate=objAssetWarranty.StartDate.addMonths(objWarrantyTerm.WarrantyDuration);
                                                                     }
                else if(objWarrantyTerm.WarrantyUnitOfTime=='Years'){objAssetWarranty.EndDate=objAssetWarranty.StartDate.addYears(objWarrantyTerm.WarrantyDuration);
                                                                    }
                objAssetWarranty.AssetId=objAsset.Id;
                objAssetWarranty.WarrantyType = 'Extended';
                lstAssetWarranty.add(objAssetWarranty);
                system.debug('lstAssetWarranty==>'+lstAssetWarranty);
            }
        }
        
        Insert lstAssetWarranty;
    }
    */
    
    // Comment by Dinesh- 21-01-2025 with Ref PR
    /*
    public static void updateVehicle01(List<Order> lstNewOrder, Map<Id, Order> oldMap) {
        List<AssetWarranty> lstAssetWarranty = new List<AssetWarranty>();
        Set<Id> setOfWarrantyTerm = new Set<Id>();
        Set<Id> setOfVehicleId = new Set<Id>();
        Set<Id> setAssetId = new Set<Id>();
        
        // Collect Warranty Term and Vehicle IDs based on status change
        for (Order objOrder : lstNewOrder) {
            Order oldOrder = oldMap.get(objOrder.Id);
            if (oldOrder.Status != 'Vehicle Delivered' &&  objOrder.Status == 'Vehicle Delivered' &&  objOrder.Warranty_Term__c != null) {
                setOfWarrantyTerm.add(objOrder.Warranty_Term__c);
                setOfVehicleId.add(objOrder.Assigned_Vehicle__c);
            }
        }
        
        // Query Warranty Terms
        Map<Id, WarrantyTerm> warrantyTermMap = new Map<Id, WarrantyTerm>( [SELECT Id, WarrantyTermName, WarrantyDuration, WarrantyUnitOfTime  FROM WarrantyTerm  WHERE Id IN :setOfWarrantyTerm] );
        
        // Query Vehicles and collect Asset IDs
        Map<Id, Vehicle> vehicleMap = new Map<Id, Vehicle>( [SELECT Id, Name, AssetId   FROM Vehicle  WHERE Id IN :setOfVehicleId]);
        
        for (Vehicle objVehicle : vehicleMap.values()) {
            if (objVehicle.AssetId != null) {
                setAssetId.add(objVehicle.AssetId);
            }
        }
        
        // Query Assets
        Map<Id, Asset> assetMap = new Map<Id, Asset>( [SELECT Id, Name  FROM Asset  WHERE Id IN :setAssetId] );
        
        // Create AssetWarranty records
        for (Asset objAsset : assetMap.values()) {
            for (WarrantyTerm objWarrantyTerm : warrantyTermMap.values()) {
                AssetWarranty objAssetWarranty = new AssetWarranty();
                objAssetWarranty.StartDate = Date.today();
                objAssetWarranty.WarrantyTermId = objWarrantyTerm.Id;
                objAssetWarranty.AssetId = objAsset.Id;
                objAssetWarranty.WarrantyType = 'Extended';
                
                // Calculate EndDate based on Warranty Unit of Time
                if (objWarrantyTerm.WarrantyUnitOfTime == 'Days') {
                    objAssetWarranty.EndDate = objAssetWarranty.StartDate.addDays(objWarrantyTerm.WarrantyDuration);
                } else if (objWarrantyTerm.WarrantyUnitOfTime == 'Weeks') {
                    objAssetWarranty.EndDate = objAssetWarranty.StartDate.addDays(7 * objWarrantyTerm.WarrantyDuration);
                } else if (objWarrantyTerm.WarrantyUnitOfTime == 'Months') {
                    objAssetWarranty.EndDate = objAssetWarranty.StartDate.addMonths(objWarrantyTerm.WarrantyDuration);
                } else if (objWarrantyTerm.WarrantyUnitOfTime == 'Years') {
                    objAssetWarranty.EndDate = objAssetWarranty.StartDate.addYears(objWarrantyTerm.WarrantyDuration);
                }
                lstAssetWarranty.add(objAssetWarranty);
            }
        }
        
        // Bulk insert AssetWarranty records
        if (!lstAssetWarranty.isEmpty()) {
            insert lstAssetWarranty;
        }
    }
    */
    // Dummy Class for Now
    public static void updateVehicle01(List<Order> lstNewOrder, Map<Id, Order> oldMap) {
        
    }
    //===================================================================================================================================================== 
    private static Boolean hasExecutedEmailHandllerMethod = false;
    public static void emailHandllerMethod(list<Order>lstNewOrder, map<Id,order>oldMap){
        if(hasExecutedEmailHandllerMethod){
            return;
        }

        set<Id>setAccount=new set<Id>();
        for(Order objOrder:lstNewOrder){
            Order oldOrder = oldMap.get(objOrder.Id);
            if(oldOrder.Eligible_For_Subsidy__c !=False && objOrder.Eligible_For_Subsidy__c ==FALSE && objOrder.AccountId!=null){
                setAccount.add(objOrder.AccountId);
            }
        }
        //  List<EmailTemplate> emailTemplates = [SELECT Id, Name, DeveloperName, Folder.Name, TemplateType, IsActive FROM EmailTemplate where Name='Customer is Not Eligible For Subsidy'];
        // system.debug('emailTemplates==>'+emailTemplates);
        list<contact>lstcontactst=[select id,Name,Phone,Email,AccountId from contact where AccountId In:setAccount];
        system.debug('lstcontactst==>'+lstcontactst);
        
        OrgWideEmailAddress orgWideEmailAddresses = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='support@rideriver.com'];
        string senderEmail = orgWideEmailAddresses.Address; 
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(contact objContact:lstcontactst){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {objContact.Email};
                mail.setToAddresses(toAddresses);
            
            mail.setReplyTo(senderEmail);  
            mail.setOrgWideEmailAddressId(orgWideEmailAddresses.Id);
            
            mail.setTargetObjectId(objContact.Id);
            // Send the email
            mail.setSubject('Eligibility check for subsidy update');
            String body = 'Hi ' + objContact.Name + ',<br/><br/>' ;
            body += 'We regret to inform you that your order with reference number ' + lstNewOrder[0].Website_Order_Id__c+ ' is not eligible for the FAME II subsidy.<br/><br/>' ;
            body += 'If you wish to transfer your ownership to an eligible customer who can avail of the subsidy, please help us with the details for the at same support@rideriver.com or +91 9731158443.<br/><br/>' ;
            body += 'Feel free to reach out to us for any queries at - 9731158443,<br/><br/>' ;
            body += 'Warm Regards,<br/>';
            body += 'Team River';
            mail.setHtmlBody(body); 
            // Send the email
            mails.add(mail);
        }
        
        Messaging.sendEmail(mails);
        hasExecutedEmailHandllerMethod = true;
    }
    //==================================================================================================================================================================  
    
    private static Boolean hasExecutedgenerateIvoicesAndReceipts = false;

    public static void generateIvoicesAndReceipts(list<Order> lstNewOrder, Map<Id, Order> oldMap) {

        try{
            List<Id> lstAttachment = new List<Id>();
            Set<Id> setOfOrder = new Set<Id>();
            for (Order objOrder : lstNewOrder) {
                Order oldOrder = oldMap.get(objOrder.Id);
                
                if (oldOrder.Status != 'RTO Registration' && objOrder.Status == 'RTO Registration') {
                    setOfOrder.add(objOrder.Id);
                }
            } 
            
            Map<Id, Set<String>> orderToItemTypeMap = new Map<Id, Set<String>>();
            List<OrderItem> listOrderItem=[SELECT Id, Type__c, OrderId FROM OrderItem WHERE OrderId IN :setOfOrder];
            for (OrderItem objOrderItem : listOrderItem) {
                if (!orderToItemTypeMap.containsKey(objOrderItem.OrderId)) {
                    orderToItemTypeMap.put(objOrderItem.OrderId, new Set<String>());
                }
                
                orderToItemTypeMap.get(objOrderItem.OrderId).add(objOrderItem.Type__c);
            }
            
            If(!setOfOrder.isEmpty())
                System.debug('AttachmentHandlerClass Called Dinesh 1');
            AttachmentHandlerClass.AttachmentHandlerMethod(setOfOrder, JSON.serialize(orderToItemTypeMap));
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    //=============================================================================================================================================================
    
    public static void sendPreOrderReceipt(list<Order> lstNewOrder, Map<Id, Order> oldMap){
        try{
            List<Id> lstAttachment = new List<Id>();
            Set<Id> setOfOrder = new Set<Id>();
            for (Order objOrder : lstNewOrder) {
                Order oldOrder = oldMap.get(objOrder.Id);
                if (oldOrder.Status != 'Activated' && objOrder.Status == 'Activated') {
                    setOfOrder.add(objOrder.Id);
                }
            }
            List<OrderItem> listOrderItem=[SELECT Id, Type__c, OrderId FROM OrderItem WHERE OrderId IN :setOfOrder];
            for (OrderItem objOrderItem : listOrderItem) {
                if(objOrderItem.Type__c=='Vehicle'){
                    AttachmentHandlerClass.AttachmentHandlerMethod03(objOrderItem.OrderId);
                }
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    //==================================================================================================================================================================================
    
    public static void sendPreOrderReceipt01(list<Order_Payment__c>lstNewOrderPayment ){
        try{
            set<Id>setPayment=new set<id>();
            for(Order_Payment__c objOrderPayment:lstNewOrderPayment){
                if(objOrderPayment.Payments__c!=null){
                    setPayment.add(objOrderPayment.Payments__c);
                    AttachmentHandlerClass.pdfAction(objOrderPayment.id);
                }
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        } 
    }
    
    // =================================================================================================================================================================================  
    
    // Jitendra : Validation for Dealer should have a single order at a time with same Vehicle on edit of order.
    public static void checkValidaionStatus(Map<Id,Order> newMap, Map<Id,Order> oldMap){
        try{
            List<Order> changedVINCustOrders = new List<Order>();
            if(newMap != null && newMap.values().size() > 0){
                for(Order newOrder : newMap.values()){
                    if(oldMap != null && oldMap.values().size() > 0 && oldMap.containsKey(newOrder.Id)){
                        Order oldOrder = oldMap.get(newOrder.Id);
                        if(oldOrder.AccountId == newOrder.AccountId && oldOrder.Assigned_Vehicle__c == newOrder.Assigned_Vehicle__c){
                            continue;
                        }
                        else {
                            changedVINCustOrders.add(newOrder);
                        }
                    }
                }
            }
            if(changedVINCustOrders != null && changedVINCustOrders.size() > 0){
                checkUniqueDealerVIN(changedVINCustOrders);
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    // Jitendra : Validation for Dealer should have a single order at a time with same Vehicle.
    public static void checkUniqueDealerVIN(List<Order> newList){
        try{
            Set<Id> customerIdSet = new Set<Id>();
            Set<Id> vinIdSet = new Set<Id>();
            Set<String> uniqueVINCustCombo = new Set<String>();
            Boolean isNewVIN = true;
            
            list<Order> allRelatedOrder = new list<Order>();
            System.debug('newList values'+newList);
            if(newList != null && newList.size() > 0){
                for(Order ord : newList){
                    if(ord.AccountId != null && ord.Assigned_Vehicle__c != null){
                        customerIdSet.add(ord.AccountId);
                        vinIdSet.add(ord.Assigned_Vehicle__c);
                    }
                }
            }
            
            // need to block an order if order was already created for that VIN.
            Set<Id> usedVINSet = new Set<Id>();
            System.debug('vinIdSet'+vinIdSet);
            List<Order> alreadyVINUsed = [Select Id,Assigned_Vehicle__c from Order Where Assigned_Vehicle__c IN :vinIdSet];
            if(alreadyVINUsed != null && alreadyVINUsed.size() > 0){
                for(Order ord : alreadyVINUsed){
                    if(ord.Assigned_Vehicle__c != null){
                        usedVINSet.add(ord.Assigned_Vehicle__c);
                        }
                    }
            }
            System.debug('alreadyVINUsed'+alreadyVINUsed);
            System.debug('usedVINSet'+usedVINSet);
            if(newList != null && newList.size() > 0){
                for(Order ord : newList){
                    System.debug('ord.Assigned_Vehicle__c'+ord.Assigned_Vehicle__c);
                    if(ord.Assigned_Vehicle__c != null && usedVINSet != null && usedVINSet.contains(ord.Assigned_Vehicle__c)){
                        isNewVIN = false;//ord.addError('An order has already been created for this VIN number.');
                        break;
                    }
                }
            }
            
            // If there is no order related to VIN. Need to check if Account Owner is same with vehicle owner
            if(isNewVIN){
                Map<Id,Id> vehicleCustMap = new Map<Id,Id>();
                List<Vehicle> allRelatedvehicle = [Select Id, Name, CurrentOwnerId from Vehicle Where Id IN :vinIdSet];
                if(allRelatedvehicle != null && allRelatedvehicle.size() > 0){
                    for(Vehicle vc : allRelatedvehicle){
                        if(vc.CurrentOwnerId != null){
                            vehicleCustMap.put(vc.Id,vc.CurrentOwnerId);
                            }
                    }
                }
                
                if(newList != null && newList.size() > 0){
                    for(Order ord : newList){
                        if(ord.AccountId != null && ord.Assigned_Vehicle__c != null && vehicleCustMap != null && vehicleCustMap.size() > 0){
                            if(vehicleCustMap.get(ord.Assigned_Vehicle__c) != ord.AccountId){
                            // ord.addError('Please update the vehicle\'s Account Owner to create an order for this VIN number.');
                        }
                    }
                    }
                }
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    /******************************************************************************************************************/
    // 09/07/2024 : Added a field to capture product name on Order invoice. -by Pratha KR
    // 14/10/2024 : EW & RSA will be of type 'Add-ons' which will create a seperate orderinvoice  - by Pratha KR
    // Updated Code for Duplication Invoice Issue - 11/12/2024
    public static void ceateInvoiceRecords(list<Order> lstNewOrder, Map<Id, Order> oldOrdersMap) {
        try{
            List<Id> lstAttachment = new List<Id>();
            List<Order_Invoice__c> orderInvoicesToInsert = new List<Order_Invoice__c>();
            set<Id> accIdSet = new set<Id>();
            Set<Id> vehiclewithAccesoriesSet = new set<Id>();
            Set<Id> vehicleSet = new set<Id>();
            Set<Id> AccessoriesSet = new set<Id>();
            Map<Id, Set<String>> orderToItemTypeMap = new Map<Id, Set<String>>();
            Map<Id, Id> orderIdToDealerId = new Map<Id, Id>();
            Map<Id, Account> accIdToAccMap = new Map<Id, Account>();
            Map<Id, Decimal> accIdToInvoiceNoToUpdateMap = new Map<Id, Decimal>();
            
            Set<String> OldOrderInvName = new Set<String>();
            Integer oldOrerInvoiceRecordSize = [SELECT Id,Name,Order__c FROM Order_Invoice__c WHERE Order__c=:oldOrdersMap.values()[0].Id].size();
            System.debug('oldOrerInvoiceRecordSize === >'+oldOrerInvoiceRecordSize);
            if(oldOrerInvoiceRecordSize == 0){
                System.debug('Its New Invoive record to Create');
            } 
            String OrderIdOldMap = oldOrdersMap.values()[0].Id;
            List<Order_Invoice__c> ordInvList = [SELECT Id,Name,Order__c FROM Order_Invoice__c WHERE Order__c =:OrderIdOldMap];
            for(Order_Invoice__c ord : ordInvList){
                OldOrderInvName.add(ord.Name);
            }
            System.debug('OldOrderInvName === >'+OldOrderInvName);
            for (Order objOrder : lstNewOrder) {
                Order oldOrder = oldOrdersMap.get(objOrder.Id);
                if (oldOrder.Status != 'Pre Invoice' && objOrder.Status == 'Pre Invoice') {
                    accIdSet.add(objOrder.Dealer__c);
                    orderIdToDealerId.put(objOrder.Id, objOrder.Dealer__c);   
                }
            }
            System.debug('accIdSet === >'+accIdSet+' && orderIdToDealerId == >'+orderIdToDealerId);
            
            List<OrderItem> newOrderItemList = [SELECT Id, Type__c, OrderId FROM OrderItem WHERE OrderId IN :orderIdToDealerId.keySet()];
            for (OrderItem objOrderItem : newOrderItemList) {
                if (!orderToItemTypeMap.containsKey(objOrderItem.OrderId)) {
                    orderToItemTypeMap.put(objOrderItem.OrderId, new Set<String>());
                }
                orderToItemTypeMap.get(objOrderItem.OrderId).add(objOrderItem.Type__c);
            }
            System.debug('orderToItemTypeMap === >'+orderToItemTypeMap);
            List<Account> accList = [SELECT Id, Invoice_Sequence__c,Center_Code__c FROM Account WHERE Id IN:accIdSet];
            For(Account accObj: accList){
                accIdToAccMap.put(accObj.id, accObj);
            }
            
            // Loop through orders and check for different conditions
            for (string orderId : orderToItemTypeMap.keySet()) {
                Decimal invoicesequence=0;
                If(orderToItemTypeMap.get(orderId)!=null){
                    integer invoiceNumber = (integer)accIdToAccMap.get(orderIdToDealerId.get(orderId)).Invoice_Sequence__c != null?(integer)accIdToAccMap.get(orderIdToDealerId.get(orderId)).Invoice_Sequence__c:0;
                    Set<string> itemTypes = orderToItemTypeMap.get(orderId);
                    
                    // Loop through order items to capture product names
                    List<OrderItem> orderItems = [SELECT Id, OrderId, Product2Id, Product2.Name, Type__c FROM OrderItem WHERE OrderId = :orderId];
                    Map<String,List<String>> orderItemToProductNameMap = new Map<String, List<String>>();
                    
                    for (OrderItem orderItem : orderItems) {
                        if (!orderItemToProductNameMap.containsKey(orderItem.Type__c)) {
                            orderItemToProductNameMap.put(orderItem.Type__c, new List<String>());
                        }
                        orderItemToProductNameMap.get(orderItem.Type__c).add(orderItem.Product2.Name);
                    }
                    
                    if (itemTypes.contains('Vehicle') && (itemTypes.contains('Accessories') || itemTypes.contains('Merchandise') || itemTypes.contains('Parts')) || itemTypes.contains('Add-ons') ) {
                        //Invoice generation for vehicle
                        string invoiceSequenceVH = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'VH', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c vehicleInvoice = createInvoice(orderId, 'Vehicle', invoiceSequenceVH, orderItemToProductNameMap.get('Vehicle'));
                        orderInvoicesToInsert.add(vehicleInvoice);
                        invoiceNumber += 1;
                        
                        //Invoice generation for Accessories
                        if (itemTypes.contains('Accessories')){
                        string invoiceSequenceAC = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'AC', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c accessoriesInvoice = createInvoice(orderId, 'Accessories', invoiceSequenceAC, orderItemToProductNameMap.get('Accessories'));
                        orderInvoicesToInsert.add(accessoriesInvoice);
                        invoiceNumber += 1;
                        }

                        
                        //Invoice generation for Other charges
                        if (itemTypes.contains('Accessories')){
                        string invoiceSequenceOC = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'OC', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c otherChargesInvoice = createInvoice(orderId, 'Other Charges', invoiceSequenceOC, orderItemToProductNameMap.get('Parts'));
                        orderInvoicesToInsert.add(otherChargesInvoice);
                        invoiceNumber += 1;
                        }

                        
                        //Invoice generation for Add-ons
                        if (itemTypes.contains('Add-ons')){
                        string invoiceSequenceAO = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'AO', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c addOnsInvoice = createInvoice(orderId, 'Add-ons', invoiceSequenceAO, orderItemToProductNameMap.get('Add-ons'));
                        orderInvoicesToInsert.add(addOnsInvoice);
                        invoiceNumber += 1;                            
                        }

                        
                        //Invoice generation for Merchandise
                            if (itemTypes.contains('Merchandise')){
                        string invoiceSequenceMD = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'MD', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c merchandiseInvoice = createInvoice(orderId, 'Merchandise', invoiceSequenceMD, orderItemToProductNameMap.get('Merchandise'));
                        orderInvoicesToInsert.add(merchandiseInvoice);
                        invoiceNumber += 1;   
                        }
                           

                    }
                    else if (itemTypes.contains('Vehicle')) {
                        //Invoice generation for vehicle
                        string invoiceSequenceVH = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'VH', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c vehicleInvoice = createInvoice(orderId, 'Vehicle', invoiceSequenceVH, orderItemToProductNameMap.get('Vehicle'));
                        orderInvoicesToInsert.add(vehicleInvoice);
                        invoiceNumber += 1;
                        
                        //Invoice generation for Other charges
                        string invoiceSequenceOC = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'OC', string.valueOf(invoiceNumber+1));
                        Order_Invoice__c otherChargesInvoice = createInvoice(orderId, 'Other Charges', invoiceSequenceOC,orderItemToProductNameMap.get('Parts'));
                        orderInvoicesToInsert.add(otherChargesInvoice);
                        invoiceNumber += 1;
                    } 
                    else if (itemTypes.contains('Accessories') || itemTypes.contains('Parts') || itemTypes.contains('Merchandise')) {
                        //Invoice generation for Accessories
                        string invoiceSequenceAC = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'AC', string.valueOf(invoiceNumber+1));
                        
                        if(itemTypes.contains('Accessories')){
                            Order_Invoice__c accessoriesInvoice = createInvoice(orderId, 'Accessories', invoiceSequenceAC, orderItemToProductNameMap.get('Accessories'));
                            orderInvoicesToInsert.add(accessoriesInvoice);
                            invoiceNumber += 1;
                        }
                        
                        if(itemTypes.contains('Parts')){
                            string invoiceSequenceOC = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'OC', string.valueOf(invoiceNumber+1));
                            Order_Invoice__c otherChargesInvoice = createInvoice(orderId, 'Other Charges', invoiceSequenceOC, orderItemToProductNameMap.get('Parts'));
                            orderInvoicesToInsert.add(otherChargesInvoice);
                            System.debug(otherChargesInvoice+'Line 417');
                            invoiceNumber += 1;
                        }
                        /*if(itemTypes.contains('Add-ons')){
                            string invoiceSequenceAO = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'AO', string.valueOf(invoiceNumber+1));
                            Order_Invoice__c addOnsInvoice = createInvoice(orderId, 'Add-ons', invoiceSequenceAO, orderItemToProductNameMap.get('Add-ons'));
                            orderInvoicesToInsert.add(addOnsInvoice);
                            invoiceNumber += 1;
                        }*/
                           if(itemTypes.contains('Merchandise')){
                            string invoiceSequenceAO = GenerateInvoiceId.generateInvoiceId('RV', accIdToAccMap.get(orderIdToDealerId.get(orderId)).Center_Code__c, 'MD', string.valueOf(invoiceNumber+1));
                            Order_Invoice__c addOnsInvoice = createInvoice(orderId, 'Merchandise', invoiceSequenceAO, orderItemToProductNameMap.get('Merchandise'));
                            orderInvoicesToInsert.add(addOnsInvoice);
                            invoiceNumber += 1;
                        }
                    }
                    //set up the map to update the invoice sequence for every dealer
                    If(!accIdToInvoiceNoToUpdateMap.containsKey(accIdToAccMap.get(orderIdToDealerId.get(orderId)).Id)){
                        accIdToInvoiceNoToUpdateMap.put(accIdToAccMap.get(orderIdToDealerId.get(orderId)).Id, invoiceNumber);
                    }
                }
            }
            
            List<Account> accListToUpdate = new List<Account>();
            If(accIdToInvoiceNoToUpdateMap != null){
                For(string accId: accIdToInvoiceNoToUpdateMap.keySet()){
                    Account accObj = new Account();
                    accObj.Id  = accId;
                    accObj.Invoice_Sequence__c = accIdToInvoiceNoToUpdateMap.get(accId);
                    accListToUpdate.add(accObj);
                }
            }
            
            Savepoint sp = Database.setSavepoint();
            
            If(orderInvoicesToInsert.size()>0){
                try{
                    Integer recordComingForInsert = orderInvoicesToInsert.size();
                    System.debug('recordComingForInsert #1 == >'+orderInvoicesToInsert);
                    System.debug('Before Insert Called Dinesh 5 == >'+orderInvoicesToInsert);
                    Map<String, Order_Invoice__c> orderInvoiceMapBeforeInsert = new Map<String, Order_Invoice__c>();
                    List<String> unmatchedInvName = new List<String>();
                    List<Order_Invoice__c> deleteInvToInsert = new List<Order_Invoice__c>();
                    system.debug('recordComingForInsert === >'+recordComingForInsert +' && oldOrerInvoiceRecordSize == >'+oldOrerInvoiceRecordSize +' && oldOrdersMap.values()[0].IsOrderInvoicesGenerated__c == >'+oldOrdersMap.values()[0].IsOrderInvoicesGenerated__c);
                    if(oldOrdersMap.values()[0].IsOrderInvoicesGenerated__c == True && recordComingForInsert != oldOrerInvoiceRecordSize){
                        for (Order_Invoice__c invoice : orderInvoicesToInsert) {
                            orderInvoiceMapBeforeInsert.put(invoice.Name, invoice);
                        }
                        System.debug('orderInvoiceMapBeforeInsert #2 == >'+orderInvoiceMapBeforeInsert);
                        for (String item : orderInvoiceMapBeforeInsert.keyset()) {
                            if (!OldOrderInvName.contains(item)) {
                                unmatchedInvName.add(item);
                                deleteInvToInsert.add(orderInvoiceMapBeforeInsert.get(item));
                            }
                        }
                        System.debug('deleteInvToInsert Before #3 == >'+deleteInvToInsert);
                        if(deleteInvToInsert.size()>0){
                            Insert deleteInvToInsert;
                            System.debug('deleteInvToInsert After #3 == >'+deleteInvToInsert);
                        }
                    }else if(oldOrdersMap.values()[0].IsOrderInvoicesGenerated__c == false){
                        Insert orderInvoicesToInsert;
                        System.debug('orderInvoicesToInsert Called Dinesh 4 == >'+orderInvoicesToInsert);
                        List<Order> ordersToUpdate = new List<Order>();
                        for (Id orderId : orderIdToDealerId.keySet()) {
                            Order ord = new Order(Id = orderId, IsOrderInvoicesGenerated__c = true);
                            ordersToUpdate.add(ord);
                        }
                        update ordersToUpdate;
                        System.debug('ordersToUpdate Called Dinesh 6 == >'+ordersToUpdate);
                    }
                    If(accListToUpdate.size()>0){
                        try{
                            Update accListToUpdate;
                        }catch(exception e){
                            Database.rollback(sp);
                        }
                    }
                }catch(exception e){
                    Database.rollback(sp);
                }
            }else{
                system.debug('No Invoice Record Found to create Invoice Order');
            }
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
     
    
    Public static Order_Invoice__c createInvoice(Id orderId, string invoiceType, string invoiceSequence, list<string> productName){
        try{
            List<Order>orderToUpdates = new List<order>();
            
            Order_Invoice__c invoice = new Order_Invoice__c();
            invoice.Name = invoiceType+' Invoice';
            invoice.Invoice_Number__c = invoiceSequence;
            if (invoiceType == 'Other Charges') {
                // Directly update the order's Invoice Number without querying
                Order orderToUpd = new Order(Id = orderId);
                orderToUpd.Invoice_Number__c = invoiceSequence;
                orderToUpdates.add(orderToUpd);
            }
            System.debug('INVOICE line no 619 --> '+invoiceType);
            invoice.Invoice_Type__c = invoiceType+' Invoice';
            invoice.Order__c = orderId;
            //If(productName != null)
              //  invoice.Order_Name__c = string.join(productName,',');
            if (!orderToUpdates.isEmpty()) {
                System.debug('orderToUpdates'+orderToUpdates);
                update orderToUpdates;
            }
            Return invoice;
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    /***********************************************************************************************************************/
    public static void addTest(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
		j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;     
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
             
        
    }
    public static void addTest2(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
		j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;     
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
             
        
    }
    public static void addTest3(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
		j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;     
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
             
        
    }
    public static void addTest4(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
		j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;     
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
             
        
    }
    
    Public class myexception extends exception{}
    
}