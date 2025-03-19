trigger ClaimItemTrigger on ClaimItem (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ClaimItemTriggerHandler.processClaimUpdates(Trigger.new);
    }
}