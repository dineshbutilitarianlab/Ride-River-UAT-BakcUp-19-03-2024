/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger WorkOrderTrigger on WorkOrder (before insert, before update, after update, after Insert) {
    
    if(trigger.isBefore && trigger.isUpdate){
        for(WorkOrder wo : trigger.new){
            if(wo.Status == 'Completed' && trigger.oldMap.get(wo.Id).Invoice_Date__c == null){
                wo.Invoice_Date__c = Datetime.now();
            }
        }
    }
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {
        Set<String> vehicleSet = new Set<String>();
        map<id,set<id>> mapVehicleIdToWoIds = new map<id,set<id>>();
        Set<String> newVehicleSet = new Set<String>();
        
        for (WorkOrder wo : Trigger.new) {
            if (wo.Vehicle__c != null) {
                vehicleSet.add(wo.Vehicle__c);
            }
        }
        List<WorkOrder> existingWorkOrders = [
            SELECT Id, Vehicle__c, 
            Vehicle_Identification_number__c, Vehicle_registration_number__c 
            FROM WorkOrder 
            WHERE Vehicle__c IN :vehicleSet AND status NOT IN ('Completed', 'Canceled') 
        ];
        
        for(WorkOrder wo : existingWorkOrders){
            if(!mapVehicleIdToWoIds.containsKey(wo.Vehicle__c)){
                mapVehicleIdToWoIds.Put(wo.Vehicle__c, new set<id>());
            }
            mapVehicleIdToWoIds.Get(wo.Vehicle__c).add(wo.Id);
        }
        
        if (!existingWorkOrders.isEmpty()) {
            for (WorkOrder wo : Trigger.new) {
                
                If(trigger.isinsert){
                    If((mapVehicleIdToWoIds.containsKey(wo.Vehicle__c) && mapVehicleIdToWoIds.get(wo.Vehicle__c).size()>0) || newVehicleSet.contains(wo.Vehicle__c)){
                        wo.Vehicle__c.addError('A job card already exists for this vehicle with same VIN or VRN.');
                    }
                    newVehicleSet.add(wo.Vehicle__c);
                }else{
                    If(mapVehicleIdToWoIds.containsKey(wo.Vehicle__c) && mapVehicleIdToWoIds.get(wo.Vehicle__c).size()>0 && trigger.oldmap.get(wo.Id).Vehicle__c != wo.Vehicle__c){
                        if(!(mapVehicleIdToWoIds.get(wo.Vehicle__c).size() == 1 && mapVehicleIdToWoIds.get(wo.Vehicle__c).contains(wo.Vehicle__c))){
                            wo.Vehicle__c.addError('A job card already exists for this vehicle with same VIN or VRN.');
                        }
                    }
                    
                    if(!mapVehicleIdToWoIds.containsKey(wo.Vehicle__c)){
                        mapVehicleIdToWoIds.Put(wo.Vehicle__c, new set<id>());
                    }
                    mapVehicleIdToWoIds.Get(wo.Vehicle__c).add(wo.Id);
                }
            }
        }
    }
    
    if (trigger.isafter &&  trigger.isUpdate) {
        
        Set<String> vehicleSet = new Set<String>();
        list<Vehicle>vehicleList= new list<Vehicle>();
        
        for (WorkOrder wo : Trigger.new) {
            if (WO.Vehicle__c != null && WO.Odometer_Reading__c != null && WO.status=='Completed' && WO.status != trigger.oldMap.get(WO.Id).status) {
                
                If(!vehicleSet.contains(WO.Vehicle__c)){
                    
                    Vehicle vehicle = new Vehicle();
                    vehicle.Id = WO.Vehicle__c;
                    vehicle.LastOdometerReading = WO.Odometer_Reading__c;
                    vehicle.OdometerReadingDate = system.Today();
                    
                    vehicleList.add(vehicle);
                    vehicleSet.add(WO.Vehicle__c);
                }
            }
        }
        
        if(!vehicleList.isEmpty())
        {
            Database.update(vehicleList,false);
        }  
        
    }
    //code Added by Aniket on 14/02/2025
    if(Trigger.isAfter && Trigger.isUpdate){
       // WorkOrderTriggerHandler.updatePDIAfterCompetetion(Trigger.new,Trigger.oldMap);
    }
}