trigger ContactTrigger on Contact (before insert) {
          if(Trigger.isBefore && Trigger.isInsert){
            //  contactTriggerHandler.handlActivitiesbeforeInsert(trigger.new); 
        }
    }