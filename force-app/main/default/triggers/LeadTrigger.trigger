trigger LeadTrigger on Lead (before Insert, after insert,after update) {
    if(trigger.isafter && trigger.Isinsert){
        LeadTriggerHandler.callQueableMethodForNewLead(Trigger.new);
        LeadTriggerHandler.checkLeadStatus(trigger.new);
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        LeadTriggerHandler.callQueableMethodForAfterUpdate(Trigger.new,Trigger.oldMap);
        LeadTriggerHandler.callQueueableAfterRNR(Trigger.new,Trigger.oldMap);
    }
    
    if(Trigger.IsBefore && Trigger.IsInsert){
        
        LeadTriggerHandler.updatePreferredSeller(Trigger.new);
        
    }
}