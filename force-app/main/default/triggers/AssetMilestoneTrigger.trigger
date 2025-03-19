trigger AssetMilestoneTrigger on AssetMilestone (before insert, before delete, after insert) {

    if (Trigger.isAfter && Trigger.isInsert) {
        AssetMilestoneTriggerWorker.createPDIItems(Trigger.new, Trigger.newMap, Trigger.oldmap);
        AssetMilestoneTriggerWorker.checkMilestoneSequenceRecord(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isInsert) {
        AssetMilestoneTriggerWorker.checkMilestoneRecord(Trigger.new);
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        AssetMilestoneTriggerWorker.deletePDIMilestone(Trigger.old);
    }
    
}