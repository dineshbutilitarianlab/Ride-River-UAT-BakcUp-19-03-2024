trigger FollowUpTrigger on Follow_Up__c (before insert,before update,after insert,after update) {
    if (Trigger.isBefore && Trigger.isInsert){
            FollowUpTriggerController.updateFollowUpName(Trigger.new);
          //  FollowUpTriggerController.Limitfolwupsforlead(trigger.new);
        FollowUpTriggerController.previousfeedback(trigger.new);
         FollowUpTriggerController.folowuptype(trigger.new);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        FollowUpTriggerController.updateFeedBack(Trigger.new,Trigger.oldMap);
         
        
    }
    if(trigger.isafter&&trigger.isinsert){
        FollowUpTriggerController.updateleadstatus(trigger.new);
    } 
    if(trigger.isafter && trigger.isUpdate){
        //FollowUpTriggerController.previousfeedback(trigger.new);
    }
    
}