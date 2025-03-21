/**
 * @description       : Form 22 pdf
 * @author            : Ram Kumar
 * @group             : 
 * @Created Date      : 19-03-2025
 * @last modified on  : 
 * @last modified by  : Ram Kumar
**/


public class Form22pdfController {
    public Vehicle vehicle { get; set; }

    public Form22pdfController(ApexPages.StandardController controller) { 
        Id orderId = ApexPages.currentPage().getParameters().get('id');
        if (orderId != null) {
            List<Order> orders = [
                SELECT Id, Assigned_Vehicle__c 
                FROM Order 
                WHERE Id = :orderId
            ];
            
            Set<Id> vehicleIds = new Set<Id>();
            for (Order ord : orders) {
                if (ord.Assigned_Vehicle__c != null) {
                    vehicleIds.add(ord.Assigned_Vehicle__c);
                }
            }
            
            if (!vehicleIds.isEmpty()) {
                Map<Id, Vehicle> vehicleMap = new Map<Id, Vehicle>(
                    [SELECT Id, VehicleIdentificationNumber, EngineNumber 
                     FROM Vehicle 
                     WHERE Id IN :vehicleIds]
                );

                if (!orders.isEmpty() && vehicleMap.containsKey(orders[0].Assigned_Vehicle__c)) {
                    vehicle = vehicleMap.get(orders[0].Assigned_Vehicle__c);
                }
            }
        }
    }
}