/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-05-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger TestDriveTrigger on Test_Drive__c (before insert, after insert,after Update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Test_Drive__c td : trigger.new){
            td.Name = td.Lead__r.Name +'- Test Drive';
        }
    }
    
    if(trigger.isafter && trigger.isInsert){
        TestDriveTriggerHandler.afterInsert(Trigger.new);
        
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        //Once Test Ride is completed
        TestDriveTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap);
        TestDriveTriggerHandler.ifTestRideCancelled(Trigger.new,Trigger.oldMap);
    
     }     
}