public class DiscrepancyTriggerHandler {
    public static void updateShipment(List<Discrepancy__c> listOfDiscrepancy) {
        Set<Id> shipmentItemIds = new Set<Id>();
        
        for (Discrepancy__c discRec : listOfDiscrepancy) {
            if (discRec.Shipment_Item__c != null) {
                shipmentItemIds.add(discRec.Shipment_Item__c);
            }
        }
        
        Map<Id, ShipmentItem> mapOfShipMent = new Map<Id, ShipmentItem>(
            [SELECT Id, ShipmentId FROM ShipmentItem WHERE Id IN :shipmentItemIds]
        );
        
        List<Discrepancy__c> discrepancyToUpdate = new List<Discrepancy__c>();
        for (Discrepancy__c discRec : listOfDiscrepancy) {
            Discrepancy__c newrec = new Discrepancy__c();
            if (discRec.Shipment_Item__c != null && mapOfShipMent.containsKey(discRec.Shipment_Item__c)) {
                newrec.Id = discRec.Id;
                discRec.Shipment__c = mapOfShipMent.get(discRec.Shipment_Item__c).ShipmentId;
                newrec.Shipment__c = discRec.Shipment__c;
                discrepancyToUpdate.add(newrec);
            }
        }
        
        if (!discrepancyToUpdate.isEmpty()) {
            update discrepancyToUpdate;
        }
    }

}