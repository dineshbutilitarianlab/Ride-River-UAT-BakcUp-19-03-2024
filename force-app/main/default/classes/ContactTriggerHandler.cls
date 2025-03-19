public class ContactTriggerHandler {
    public static void handlActivitiesbeforeInsert(list<contact>newRecords){
           list<contact> existingConList = [SELECT Id, Email from Contact]; 
          for(contact exicon : existingConList){
               for(contact con : newRecords){
                if(exicon.Email == con.Email){
                   con.addError('duplicate found');
    }
  }
    
}
    }
}