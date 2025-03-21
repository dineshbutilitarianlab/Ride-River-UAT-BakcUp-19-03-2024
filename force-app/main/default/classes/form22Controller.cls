/**
* @description       : Form 22 PDF Generation
* @author            : Ram Kumar
* @group             : 
* @Created Date      : 19-03-2025
* @last modified on  : 
* @last modified by  : Ram Kumar
**/
public class form22Controller {
    
    public static void handleOrderUpdate(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        List<Id> orderIds = new List<Id>();
        
        for (Order ord : newOrders) {
            Order oldOrder = oldOrderMap.get(ord.Id);
            if (oldOrder != null && ord.Status == 'Vehicle Delivered' && oldOrder.Status != 'Vehicle Delivered') {
                orderIds.add(ord.Id);
            }
        }
        
        if (!orderIds.isEmpty()) {
            generateForm22PDF(orderIds);
        }
    }
    
    @future(callout=true)
    public static void generateForm22PDF(List<Id> orderIds) {
        System.debug('====> generateForm22PDF STARTED <====');
        System.debug('Order Ids: ' + orderIds);
        
        List<Attachment> attachments = new List<Attachment>();
        List<Order> orders = [
            SELECT Id, Assigned_Vehicle__c 
            FROM Order 
            WHERE Id IN :orderIds
        ];
        
        Map<Id, Vehicle> vehicleMap = new Map<Id, Vehicle>();
        Set<Id> vehicleIds = new Set<Id>();
        
        for (Order ord : orders) {
            if (ord.Assigned_Vehicle__c != null) {
                vehicleIds.add(ord.Assigned_Vehicle__c);
            }
        }
        
        if (!vehicleIds.isEmpty()) {
            vehicleMap = new Map<Id, Vehicle>([
                SELECT Id, VehicleIdentificationNumber, EngineNumber 
                FROM Vehicle 
                WHERE Id IN :vehicleIds
            ]);
        }
        
        for (Order ord : orders) {
            if (ord.Assigned_Vehicle__c != null && vehicleMap.containsKey(ord.Assigned_Vehicle__c)) {
                PageReference pdfPage = Page.Form22;
                pdfPage.getParameters().put('id', ord.Id);
                
                Blob pdfBlob = Test.isRunningTest() ? Blob.valueOf('Test') : pdfPage.getContentAsPDF();
                
                Attachment attachment = new Attachment(
                    Name = 'Form22.pdf',
                    Body = pdfBlob,
                    ParentId = ord.Id,
                    ContentType = 'application/pdf'
                );
                
                attachments.add(attachment);
            }
        }
        
        if (!attachments.isEmpty()) {
            insert attachments;
        }
        
        System.debug('====> generateForm22PDF COMPLETED <====');
    }
}