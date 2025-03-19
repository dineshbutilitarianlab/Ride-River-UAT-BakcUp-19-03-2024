trigger AssetTrigger on Asset (after insert) {
    if (Trigger.isAfter && Trigger.isInsert) {
        AssetTriggerHandler.handleAssetInsert(Trigger.new);
    }
}