/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-20-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class AttachmentHandlerClass {
    
    @Future (callout=true)
    public static void AttachmentHandlerMethod(Set<Id> orderIds, string mapString) {    
        map<Id,List<Attachment>> mapOrderIdToAttachments = new map<id,List<Attachment>>();
        Map<Id, Map<string,string>> orderIdToInvTypeToInvNoMap = new Map<Id, Map<string,string>>();
        Map<Id, Map<string,string>> orderIdToInvTypeToInvDateMap = new Map<Id, Map<string,string>>();
        //Map<Id, Set<String>> orderToItemTypeMap = (Map<Id, Set<String>>) JSON.deserialize(mapString, Map<Id, Set<String>>.class);
        
        //this code is added for test by Aniket
        Map<Id, Set<String>> orderToItemTypeMap = new Map<Id, Set<String>>();
        if (String.isNotBlank(mapString)) {
            orderToItemTypeMap = (Map<Id, Set<String>>) JSON.deserialize(mapString, Map<Id, Set<String>>.class);
        } else {
            orderToItemTypeMap = new Map<Id, Set<String>>(); 
        }
        //upto this
        
        System.debug('orderToItemTypeMap>>'+ orderToItemTypeMap);
        
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        
        // Query the Orders
        List<Order> orders = [SELECT Id, Name,AccountId, Dealer__c, Website_Order_Id__c,Handling_Charges__c,Warranty_Amount__c,RTO_Charges__c,Insurance_Amount__c, OrderNumber,
        Is_DC_Generated__c, Is_Vehicle_Invoice_Generated__c, Is_RTO_and_IR_Generated__c, IS_OCT_Generated__c, IsAccessories_Generated__c, IsMerchandise_Generated__c
        FROM Order WHERE Id IN :orderIds];
        system.debug('orders==>'+orders);
        
        //mappring the invoice IDs
        For(Order_Invoice__c orderInvoice:[SELECT Id, Invoice_Number__c, Invoice_Type__c, Name, Order__c, Invoice_date__c  FROM Order_Invoice__c WHERE Order__c IN :orderIds]){
            If(!orderIdToInvTypeToInvNoMap.containskey(orderInvoice.Order__c)){
                
                orderIdToInvTypeToInvNoMap.Put(orderInvoice.Order__c, new Map<string,string>{orderInvoice.Invoice_Type__c => orderInvoice.Invoice_Number__c});
                
                If(orderInvoice.Invoice_date__c!= null){
                    orderIdToInvTypeToInvDateMap.Put(orderInvoice.Order__c, new Map<string,string>{orderInvoice.Invoice_Type__c => orderInvoice.Invoice_date__c.format()});
                }else{
                    orderIdToInvTypeToInvDateMap.Put(orderInvoice.Order__c, new Map<string,string>{orderInvoice.Invoice_Type__c => system.today().format()});
                }
                
            }else{
                orderIdToInvTypeToInvNoMap.get(orderInvoice.Order__c).Put(orderInvoice.Invoice_Type__c,orderInvoice.Invoice_Number__c);
                orderIdToInvTypeToInvDateMap.get(orderInvoice.Order__c).Put(orderInvoice.Invoice_Type__c,orderInvoice.Invoice_date__c.format());
            }
        }
        
        for (Order order : orders) {
            
            List<attachment> attachmentList = new List<Attachment>();
            set<string> itemTypes = orderToItemTypeMap.get(order.Id);
            
            //code added for test class
            if (itemTypes == null) {
                itemTypes = new Set<String>(); // Initialize as an empty set if it's null
            }
            //upto this
            
            String str;
            If(order.Website_Order_Id__c != null && order.Website_Order_Id__c != ''){
                str = String.valueOf(order.Website_Order_Id__c);
            }else {
                str = order.OrderNumber;
            }
            
            String result = str.substring(Math.max(0, str.length() - 4));
            System.debug('result==>' + result);
            
            
            If(itemTypes.contains('Vehicle')){
                System.debug('OrderIdToInvTypeToInvNoMap: At line no 68 ' + orderIdToInvTypeToInvNoMap);
                System.debug('OrderIdToInvTypeToInvNoMap: At line no 68 ' + itemTypes.contains('Vehicle'));
                System.debug('OrderIdToInvTypeToInvNoMap: At line no 68 ' + orderIdToInvTypeToInvNoMap.get(order.Id));
                System.debug('OrderIdToInvTypeToInvNoMap: At line no 68 ' + orderIdToInvTypeToInvNoMap.get(order.Id).containsKey('Vehicle Invoice'));
                // Generate Vehicle Invoice
                If(!order.Is_Vehicle_Invoice_Generated__c && orderIdToInvTypeToInvNoMap.get(order.Id) != null && orderIdToInvTypeToInvNoMap.get(order.Id).containsKey('Vehicle Invoice')){
                    System.debug('OrderIdToInvTypeToInvNoMap: At line no 71 ' + orderIdToInvTypeToInvNoMap);
                    // Create Attachment record
                    PageReference pdfPage = Page.NewDealerInvoicePdf; 
                    Attachment att = createInvoicePDF(order.Id, orderIdToInvTypeToInvNoMap.get(order.Id).get('Vehicle Invoice'), 'Vehicle Tax Invoice - '+result, pdfPage, orderIdToInvTypeToInvDateMap.get(order.Id).get('Vehicle Invoice'));
                    
                    attachmentsToInsert.add(att);       
                    attachmentList.add(att);
                    System.debug('before order.Is_Vehicle_Invoice_Generated__c'+ order.Is_Vehicle_Invoice_Generated__c);
                    order.Is_Vehicle_Invoice_Generated__c = true;
                    System.debug('after order.Is_Vehicle_Invoice_Generated__c'+ order.Is_Vehicle_Invoice_Generated__c);
                    
                }else{
                    throw new MyException('Vehicle Invoice record is not found for the order '+order.OrderNumber);
                }
                
               // Is_DC_Generated__c, Is_Vehicle_Invoice_Generated__c, Is_RTO_and_IR_Generated__c, IS_OCT_Generated__c
               if (!order.Is_DC_Generated__c) {
                PageReference pdfPages = Page.CreateDeliveryChallan; 
                Attachment atta = createReceiptPDF(order.Id, 'Delivery Challan - ' +result, pdfPages);
                
                attachmentsToInsert.add(atta); 
                attachmentList.add(atta);
                order.Is_DC_Generated__c = true;
                
               }
                // Generate CreateDeliveryChallan PDF
               
                // Generate CreateReceiptRtoInsurance PDF
                if(!order.Is_RTO_and_IR_Generated__c && (order.RTO_Charges__c!=null || order.Insurance_Amount__c!=null)){  
                    
                    PageReference pdfPage1 = Page.CreateReceiptRtoInsurance; 
                    Attachment att1 = createReceiptPDF(order.Id, 'RTO & Insurance Receipt - ' +result , pdfPage1);
                    System.debug('att1==>'+att1);
                    
                    If(order.Website_Order_Id__c != null){
                        Integer stringLength = order.Website_Order_Id__c.length();        
                        order.RTO_Receipt_Number__c = 'RVRE'+ order.Website_Order_Id__c.substring(stringLength - 4, stringLength)+'RTO';
                        System.debug('invoiceId ==>'+order.RTO_Receipt_Number__c);
                    }
                    else{
                        order.RTO_Receipt_Number__c = order.OrderNumber;
                        System.debug('invoiceId ==>'+order.RTO_Receipt_Number__c);
                    }
                    
                    attachmentList.add(att1);
                    attachmentsToInsert.add(att1);
                    order.Is_RTO_and_IR_Generated__c = true;
                }
                
                system.debug('handling started Other Charges Invoice ==>');
                if(!order.IS_OCT_Generated__c && (order.Handling_Charges__c!=null || order.Warranty_Amount__c!=null)){
                    If(orderIdToInvTypeToInvNoMap.get(order.Id) != null && orderIdToInvTypeToInvNoMap.get(order.Id).containsKey('Other Charges Invoice')){
                        // Create Attachment 
                        PageReference pdfPage2 = Page.OtherInvoicePdf; 
                        Attachment att2 = createInvoicePDF(order.Id, orderIdToInvTypeToInvNoMap.get(order.Id).get('Other Charges Invoice'), 'Other Charges Tax Invoice - '+result, pdfPage2, orderIdToInvTypeToInvDateMap.get(order.Id).get('Other Charges Invoice'));
                        attachmentsToInsert.add(att2); 
                        attachmentList.add(att2);
                        order.IS_OCT_Generated__c = true;
                       
                    }else{
                        throw new MyException('Other Charges Invoice record is not found for the order '+order.OrderNumber);
                    }
                }else{
                    system.debug('Condtion Not Matched to Generate Other Charges Invoice ==>');
                }
                
                //adding additional files
                List<River_Files_To_Customer__mdt> filesMetadata = [SELECT Id, DeveloperName, Label, File_Name__c FROM River_Files_To_Customer__mdt WHERE Active__c = true];
                List<String> filesNameListToSend = new List<String>();
                For(River_Files_To_Customer__mdt file : filesMetadata){
                    filesNameListToSend.add(file.File_Name__c);
                }
                
                
                For(contentVersion resource:[SELECT VersionData, ContentDocument.FileType, ContentDocument.Title, FileExtension FROM contentVersion WHERE ContentDocument.Title IN: filesNameListToSend]){
                    
                    // Create Attachment 
                    Attachment attachment = new Attachment();
                    attachment.Name = resource.ContentDocument.Title + '.' + resource.fileExtension;
                    attachment.Body = resource.VersionData;
                    attachment.ContentType = resource.ContentDocument.FileType;
                    attachmentList.add(attachment);
                    system.debug('attachment>>'+attachment);
                }
                
            }
            
            if (itemTypes.contains('Accessories') || itemTypes.contains('Parts') || itemTypes.contains('Merchandise') ) {       
                
                //Generate Accessories invoice PDF
                If(!order.IsAccessories_Generated__c && orderIdToInvTypeToInvNoMap.get(order.Id) != null && orderIdToInvTypeToInvNoMap.get(order.Id).containsKey('Accessories Invoice')){
                    System.debug('Accessories Invoice==>');
                    // Create Attachment 
                    PageReference pdfPage3 = Page.AccessoriesInvoicePdf; 
                    Attachment att3 = createInvoicePDF(order.Id, orderIdToInvTypeToInvNoMap.get(order.Id).get('Accessories Invoice'), 'Accessories Tax Invoice - '+result, pdfPage3, orderIdToInvTypeToInvDateMap.get(order.Id).get('Accessories Invoice'));
                    attachmentsToInsert.add(att3);
                    attachmentList.add(att3);
                    order.IsAccessories_Generated__c = true;


                }
                 if (!order.IsMerchandise_Generated__c && orderIdToInvTypeToInvNoMap.get(order.Id) != null && orderIdToInvTypeToInvNoMap.get(order.Id).containsKey('Merchandise Invoice')){
                    System.debug('Merchandise Invoice==>');
                    // Create Attachment 
                    PageReference pdfPage4 = Page.MerchandiseInvoicePdf; 
                    Attachment att3 = createInvoicePDF(order.Id, orderIdToInvTypeToInvNoMap.get(order.Id).get('Merchandise Invoice'), 'Merchandise Tax Invoice - '+result, pdfPage4, orderIdToInvTypeToInvDateMap.get(order.Id).get('Merchandise Invoice'));
                    
                    attachmentsToInsert.add(att3);
                    attachmentList.add(att3);
                    order.IsMerchandise_Generated__c = true;
                }
                else{
                    throw new MyException('Accessories, Parts, and Merchandise Invoice record is not found for the order '+order.OrderNumber);
                }
            }
            
            
            // create map of attchments against each order Id
            mapOrderIdToAttachments.put(order.Id,attachmentList);
            
        }

        if (!orders.isEmpty()) {
            update orders;
        }

        
        SendEmailHandller.SendEmailHandller(orders,mapOrderIdToAttachments);
        
        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
            if (attachmentsToInsert.size() > 0) {//added By Aniket on 20/02/2025
                List<Order> order = [SELECT Id, Is_Invoice_PDF_Generated__c FROM Order WHERE Id = :attachmentsToInsert[0].ParentId LIMIT 1];
        
                if (!order.isEmpty()) {
                    Order o = order[0];
                    o.Is_Invoice_PDF_Generated__c = true;
                    update o;
                }
            }
        }
        
        system.debug('attachmentsToInsert==>'+attachmentsToInsert);
    }
    
    //Method to generate the invoice
    Public static Attachment createInvoicePDF(Id orderId, string invoiceSequence, string fileName, PageReference pdfPage, string invoiceDate){
        pdfPage.getParameters().put('id', orderId);
        pdfPage.getParameters().put('sequence', invoiceSequence);
        pdfPage.getParameters().put('date', invoiceDate);
        
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('Test');
        }
        // Create Attachment record
        Attachment attachment = new Attachment();
        attachment.Name = fileName+'.pdf';
        attachment.Body = pdfBlob;
        attachment.ParentId = orderId;
        attachment.ContentType = 'application/pdf';
        
        return attachment;
    }
    
    //Method to generate the Receipts
    Public static Attachment createReceiptPDF(Id orderId, string fileName, PageReference pdfPage){
        
        pdfPage.getParameters().put('id', orderId);
        Blob pdfBlob;
        if (!Test.isRunningTest()) {
            pdfBlob= pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('Test');
        }
        
        // Create Attachment record
        Attachment attachment = new Attachment();
        attachment.Name = fileName + '.pdf';
        attachment.Body = pdfBlob;
        attachment.ParentId = orderId;
        attachment.ContentType = 'application/pdf';
        
        return attachment;
    }
    
    //================================================================================================================================================================
    
    @Future (callout=true)
    public static void AttachmentHandlerMethod03(string orderIds) {
        List<Attachment> attachmentsToInsert = new List<Attachment>();
        map<id,List<Attachment>> mapOrderIdToAttachments = new map<id,List<Attachment>>();
        // Query the Orders
        List<Order> orders = [SELECT Id, Name,AccountId,Booking_Payment_Id__c,Website_Order_Id__c, OrderNumber FROM Order WHERE Id = :orderIds];
        system.debug('orders==>'+orders);
        
        for (Order order : orders) {
            
            List<attachment> attachmentList = new List<Attachment>();
            
            String str;
            If(order.Website_Order_Id__c != null && order.Website_Order_Id__c != ''){
                str = String.valueOf(order.Website_Order_Id__c);
            }else {
                str = order.OrderNumber;
            }
            
            String result = str.substring(Math.max(0, str.length() - 4));
            System.debug('result==>' + result);
            
            // Generate Charge PDF
            PageReference pdfPage1 = Page.PreOrderReceipt; 
            pdfPage1.getParameters().put('id', order.Id);
            Blob pdfBlob1;
            if (!Test.isRunningTest()) {
                pdfBlob1= pdfPage1.getContentAsPDF();
            } else {
                pdfBlob1 = Blob.valueOf('Test');
            }
            
            // Create Attachment record
            Attachment att1 = new Attachment();
            att1.Name = 'Pre Order Receipt-' + result + '.pdf';
            att1.Body = pdfBlob1;
            att1.ParentId = order.Id;
            att1.ContentType = 'application/pdf';
            
            attachmentsToInsert.add(att1);
            attachmentList.add(att1);
        }
        
        system.debug('attachmentsToInsert 123==>'+attachmentsToInsert);
        
        // Insert attachments
        if (!attachmentsToInsert.isEmpty()) { 
            insert attachmentsToInsert;
        }
        
        SendEmailHandller.SendEmailHandller2(orders,attachmentsToInsert);
    }
    
    //================================================================================================================================================================
    
    @future(callout=true)
    public static void pdfAction(Id OrderpaymentId) {
        try{  
            //system.debug('OrderpaymentId==>'+OrderpaymentId);
            list<Order_Payment__c>lstOrderPayments=[SELECT name,Payments__r.Payment_Status__c,Order__r.Id FROM Order_Payment__c  WHERE Id=:OrderpaymentId];
            List<Attachment> attachmentsToInsert = new List<Attachment>();
            
            List<Order_Payment__c> orderPaymentToUpdate = new List<Order_Payment__c>();//added by Aniket

            for(Order_Payment__c obj :lstOrderPayments){
                if(obj.Payments__r.Payment_Status__c=='Success'){
                    PageReference pdfPage1 = Page.CreateReceiptPayments; 
                    pdfPage1.getParameters().put('id', obj.Id);
                    Blob pdfBlob1;
                    if (!Test.isRunningTest()) {
                        pdfBlob1= pdfPage1.getContentAsPDF();
                        obj.Payment_Acknowledgement_Generated__c=true;//added By Aniket
                        orderPaymentToUpdate.add(obj);

                    } else {
                        pdfBlob1 = Blob.valueOf('Test');
                    }
                    
                    // Create Attachment record
                    Attachment att1 = new Attachment();
                    att1.Name = 'Payment Acknowledgement.pdf';
                    att1.Body = pdfBlob1;
                    att1.ParentId = obj.Id;
                    att1.ContentType = 'application/pdf';
                    
                    attachmentsToInsert.add(att1);
                }
            }
            
            if (!attachmentsToInsert.isEmpty()) {
                insert attachmentsToInsert;
                SendEmailHandller.sendPreAttchamnets(lstOrderPayments[0].Id,attachmentsToInsert); 
            }
            if(!orderPaymentToUpdate.isEmpty()){ //added By Aniket
                update orderPaymentToUpdate;//added By Aniket
            }
        }catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
        }
        
    }
   
    
    Public class myexception extends exception{}
}