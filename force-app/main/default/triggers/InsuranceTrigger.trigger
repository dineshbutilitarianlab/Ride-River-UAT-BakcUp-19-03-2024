trigger InsuranceTrigger on Insurance__c (before insert) {
    InsuranceTriggerHandler.checkForDuplicateNames(Trigger.new);
}