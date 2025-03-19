trigger TestDriver on Test_Drive__c (After insert,After Update,After delete) {
   /* set<Id> idsss=new set<Id>();
    if(trigger.isafter && trigger.isinsert ||trigger.Isafter &&trigger.Isupdate){
        for(Test_Drive__c td:trigger.new){
            idsss.add(td.Lead__c);
            
        }
    }
    if(trigger.Isafter && trigger.isdelete){
        for(Test_Drive__c td :trigger.old){
            idsss.add(td.Lead__c);
        }
    }*/
    /*Integer count;
    list<Lead> lst=new list<Lead>();
    AggregateResult[] numb = [Select Lead__c, COUNT(Id)cc from Test_Drive__c where Lead__c IN :idsss GROUP BY Lead__c];
    for(AggregateResult n: numb){
        lead l = new Lead();
        l.Id = (Id)n.get('Lead__c');
        count = (integer)n.get('cc');
        l.testdrives_count__c=count;
        if(l.Id != null){
            lst.add(l);
        }
        
    }
    update lst;*/
    if(trigger.isafter &&trigger.isinsert){
        set<Id> leadIds=new set<Id>();
        for(Test_Drive__c td:trigger.new){
            leadIds.add(td.Lead__c);
        }
        system.debug('hsdjdsks'+leadIds);
        list<Lead> getlead=[select id ,Status from Lead where id IN:leadIds];
        list<Lead> upleadlst=new list<Lead>();
        for(Lead l:getlead){
            l.Status='Test Ride';
            l.Test_Ride_Given__c=true;
            l.SendIndemnityform__c=true;
            l.Out_come__c='Call Back';
          l.DLcopy__c='KA2345678765678';
            upleadlst.add(l);
        }
        update upleadlst;
    }
      
    
}