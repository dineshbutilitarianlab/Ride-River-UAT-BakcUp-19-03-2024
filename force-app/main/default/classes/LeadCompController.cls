/**
* @File Name : LeadCompController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : September 21, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 21, 2024 |   | Initial Version
**/

public with sharing class LeadCompController {
    
    public class leadWrapper{
        @AuraEnabled
        public list<Follow_Up__c> lstFollowUp{get;set;}
        @AuraEnabled
        public List<Lead> lstLead{get;set;}
        @AuraEnabled
        public list<Test_Drive__c> lstTestRide{get;set;}
        @AuraEnabled
        public  Map<Id,Follow_Up__History> oldValue{get;set;}
        @AuraEnabled
        public  Map<Id,Follow_Up__History> previousComment{get;set;}
        
    }
    public class summarrywrapper{
        @AuraEnabled
        public integer todayfolloups{get;set;}
        @AuraEnabled
        public integer notattenedfolloups{get;set;}
        @AuraEnabled
        public integer Newleads{get;set;}
        @AuraEnabled
        public  integer Notattendedleads{get;set;}
        @AuraEnabled
        public integer newstatusleads{get;set;}
        @AuraEnabled
        public integer testrideleads{get;set;}
        @AuraEnabled
        public integer followupLead{get;set;}
        @AuraEnabled
        public integer readyforbbokingleads{get;set;}
        @AuraEnabled
        public integer convertleads{get;set;}
        @AuraEnabled
        public integer clostlostleads{get;set;}
        @AuraEnabled
        public integer todayTestRide{get;set;}
        @AuraEnabled
        public integer notattendedTestRide{get;set;}   
    }
    
    public class LeadWrapper1 {
        @AuraEnabled public String id; 
        @AuraEnabled public String name;
        @AuraEnabled public Decimal age;
        @AuraEnabled public String phone;
        @AuraEnabled public String status;
        @AuraEnabled public Date createdDate;
        
        public LeadWrapper1(Lead lead) {
            this.id = lead.Id; 
            this.name = lead.Name;
            this.age = lead.Lead_Age__c	; 
            this.phone = lead.Phone;
            this.status = lead.Status;
            this.createdDate = lead.CreatedDate.date();
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<LeadWrapper1> getLeadsDetailsByDateRange(Date fromDate, Date toDate) {
        List<LeadWrapper1> leadList = new List<LeadWrapper1>();
    
        // Fetch the logged-in user's profile
        User currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Boolean isSysAdmin = (currentUser.Profile.Name == 'System Administrator');
        String currentUserId = UserInfo.getUserId(); // Store User ID in a variable
    
        // Convert Date to Datetime at 12:00 AM and 11:59 PM
        Datetime startDatetime = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
        Datetime endDatetime = Datetime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));

        System.debug('### Current User Profile: ' + currentUser.Profile.Name);
        
        List<Lead> leads;
        
        if (isSysAdmin) {
            leads = [SELECT Id, Name, Lead_Age__c, Phone,Status, CreatedDate, OwnerId 
                     FROM Lead 
                     WHERE CreatedDate >= :startDatetime AND CreatedDate <= :endDatetime
                     AND Status = 'New' ORDER BY CreatedDate DESC];
        } else {
            leads = [SELECT Id, Name, Lead_Age__c, Phone,Status, CreatedDate, OwnerId 
                     FROM Lead 
                     WHERE CreatedDate >= :startDatetime AND CreatedDate <= :endDatetime 
                     AND OwnerId = :currentUserId
                     AND Status = 'New' ORDER BY CreatedDate DESC]; // Use stored variable
        }
        
        System.debug('### Total Leads Retrieved: ' + leads.size());
    
        // Convert to wrapper class
        for (Lead l : leads) {
            System.debug('### Lead Name: ' + l.Name + ', Age: ' + l.Lead_Age__c + ', Phone: ' + l.Phone + ', CreatedDate: ' + l.CreatedDate);
            leadList.add(new LeadWrapper1(l));
        }
    
        return leadList;
    }
    
    

    @AuraEnabled
    public static leadWrapper TodaysFollowUp(Date fromDate, Date toDate) { // Integer pageSize, Integer pageNumber
        System.debug('### Inside TodaysFollowUp Method ###');
        System.debug('Received fromDate: ' + fromDate + ', toDate: ' + toDate);
    
        // Get the current logged-in User
        User currentUser = [SELECT Id ,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.debug('Current User Id: ' + currentUser.Id);
        Boolean isSysAdmin = (currentUser.Profile.Name == 'System Administrator');

        // Convert Date to Datetime at 12:00 AM and 11:59 PM
        Datetime startDatetime = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
        Datetime endDatetime = Datetime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));
    
        // Fetch Follow-Ups for these Leads within the specified date range

        // Integer offset = (pageNumber - 1) * pageSize;
        
    // Fetch Follow-Ups based on user role
    List<Follow_Up__c> followUps;
    
    if (isSysAdmin) {
        // System Administrator can view all follow-ups
        followUps = [
            SELECT Id, Due_Date__c, Lead__c, Lead__r.Name, Lead__r.Phone, Status__c, 
                   Subject__c, Lead__r.Lead_Age__c, Follow_Up_Date__c, 
                   Previous_Followup_date__c, Previous_Feedback__c, Feedback__c 
            FROM Follow_Up__c 
            WHERE Lead__r.IsConverted = false
            AND Lead__r.Status IN ('RNR', 'Follow Up', 'Ready For booking')
            AND Follow_Up_Date__c >= :startDatetime 
            AND Follow_Up_Date__c <= :endDatetime 
            AND Status__c != 'Completed' 
            ORDER BY Follow_Up_Date__c ASC
           // LIMIT :pageSize OFFSET :offset
        ];
    } else {
        // Other users can only see their own follow-ups
        followUps = [
            SELECT Id, Due_Date__c, Lead__c, Lead__r.Name, Lead__r.Phone, Status__c, 
                   Subject__c, Lead__r.Lead_Age__c, Follow_Up_Date__c, 
                   Previous_Followup_date__c, Previous_Feedback__c, Feedback__c 
            FROM Follow_Up__c 
            WHERE Lead__r.IsConverted = false
            AND Lead__r.Status IN ('RNR', 'Follow Up', 'Ready For booking')
            AND Follow_Up_Date__c >= :startDatetime 
            AND Follow_Up_Date__c <= :endDatetime 
            AND Status__c != 'Completed' 
            AND Lead__r.OwnerId = :currentUser.Id
            ORDER BY Follow_Up_Date__c ASC
           // LIMIT :pageSize OFFSET :offset
        ];
    }
    
        System.debug('Fetched Follow-Ups: ' + followUps.size());
        System.debug('Follow-Up Records: ' + JSON.serialize(followUps));
    
        // Extract unique Lead IDs from Follow-Up records
        Set<Id> leadIds = new Set<Id>();
        for (Follow_Up__c fup : followUps) {
            leadIds.add(fup.Lead__c);
        }
    
        // Fetch related Leads
        List<Lead> leads = [
            SELECT Id, OwnerId, Name, Phone, LeadSource, Lead_Age__c 
            FROM Lead 
            WHERE Id IN :leadIds
            AND Status != 'Close Lost'
        ];
    
        // Fetch Follow-Up History for these Leads
        Map<Id, Follow_Up__History> mapHistory = new Map<Id, Follow_Up__History>();
        List<Follow_Up__History> lstHistory = [
            SELECT OldValue, NewValue, Field, CreatedDate, ParentId 
            FROM Follow_Up__History  
            WHERE Field = 'Due_Date__c' 
            AND ParentId IN :leadIds 
            ORDER BY CreatedDate ASC
        ];
    
        for (Follow_Up__History objHis : lstHistory) {
            if (!mapHistory.containsKey(objHis.ParentId)) {
                mapHistory.put(objHis.ParentId, objHis);
            }
        }
    
        System.debug('Follow-Up History Map Size: ' + mapHistory.size());
    
        // Prepare wrapper response
        leadWrapper objWrapper = new leadWrapper();
        objWrapper.lstFollowUp = followUps;
        objWrapper.lstLead = leads;
        objWrapper.oldValue = mapHistory;
    
        System.debug('Final leadWrapper Response: ' + JSON.serialize(objWrapper));
        
        return objWrapper;
    }
    
    
    
    // @AuraEnabled
    // public static leadWrapper TodaysFollowUp() {
    //     // Get the current logged-in User
    //     User currentUser = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];

    //     if (currentUser.ContactId == null) {
    //         return new leadWrapper(); // Return empty wrapper if no contact is associated
    //     }

    //     // Get the Account associated with the User's Contact
    //     Contact userContact = [SELECT Id, AccountId FROM Contact WHERE Id = :currentUser.ContactId LIMIT 1];

    //     if (userContact.AccountId == null) {
    //         return new leadWrapper(); // Return empty wrapper if no account is found
    //     }

    //     Id accountId = userContact.AccountId;

    //     // Get all Pincodes related to the Account
    //     List<Pin_Code__c> relatedPincodes = [SELECT Id, Area_Pincode__c	 FROM Pin_Code__c WHERE Dealer_Service_Center__c = :accountId];

    //     if (relatedPincodes.isEmpty()) {
    //         return new leadWrapper(); // Return empty wrapper if no pincodes found
    //     }

    //     // Store Pincode values in a Set
    //     Set<String> pincodeValues = new Set<String>();
    //     for (Pin_Code__c pincode : relatedPincodes) {
    //         if (pincode.Area_Pincode__c != null) {
    //             pincodeValues.add(pincode.Area_Pincode__c);
    //         }
    //     }

    //     if (pincodeValues.isEmpty()) {
    //         return new leadWrapper(); // Return empty wrapper if no postal codes found
    //     }

    //     // Find Leads associated with these Pincodes
    //     List<Lead> leads = [SELECT Id, Name, Phone, LeadSource, Lead_Age__c 
    //                         FROM Lead 
    //                         WHERE PostalCode IN :pincodeValues 
    //                         AND IsConverted = false 
    //                         AND Status != 'Closed Lost'];

    //     if (leads.isEmpty()) {
    //         return new leadWrapper(); // Return empty wrapper if no leads found
    //     }

    //     Set<Id> leadIds = new Set<Id>();
    //     for (Lead lead : leads) {
    //         leadIds.add(lead.Id);
    //     }

    //     // Fetch Follow-Ups for these Leads
    //     List<Follow_Up__c> followUps = [SELECT Id, Due_Date__c, Lead__c, Lead__r.Name, Lead__r.Phone, 
    //                                            Status__c, Subject__c, Lead__r.Lead_Age__c, 
    //                                            Follow_Up__c, Previous_Followup_date__c, 
    //                                            Previous_Feedback__c, Feedback__c 
    //                                     FROM Follow_Up__c 
    //                                     WHERE Lead__c IN :leadIds 
    //                                     AND Follow_Up_Date__c = TODAY 
    //                                     AND Status__c != 'Completed' 
    //                                     ORDER BY CreatedDate DESC];

    // // Fetch Follow-Up History for these Leads
    // Map<Id, Follow_Up__History > mapHistory = new Map<Id, Follow_Up__History >();

    // List<Follow_Up__History > lstHistory = [SELECT OldValue , NewValue , Field , CreatedDate, ParentId 
    //                                           FROM Follow_Up__History  
    //                                           WHERE Field  = 'Due_Date__c' 
    //                                           AND ParentId IN :leadIds 
    //                                           ORDER BY CreatedDate DESC];

    // for (Follow_Up__History  objHis : lstHistory) {
    //     if (!mapHistory.containsKey(objHis.ParentId)) {
    //         mapHistory.put(objHis.ParentId, objHis);
    //     }
    // }                                
    //     // Prepare wrapper response
    //     leadWrapper objWrapper = new leadWrapper();
    //     objWrapper.lstFollowUp = followUps;
    //     objWrapper.lstLead = leads;
    //     objWrapper.oldValue = mapHistory;
    //     return objWrapper;
    // }

   /* @AuraEnabled
    Public static leadWrapper TodaysFollowUp(){
        //  list<Follow_Up__c> lstfollupactionfalse =[select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Folllow_Up1_Summary__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c from Follow_Up__c where  Follow_Up_Date__c = TODAY AND isAcctionCompleted__c = FALSE AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost' AND Lead__r.Status !='Test Ride'  ORDER BY CreatedDate DESC];
        
        list<Follow_Up__c> lstfollupactionfalse =[select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c from Follow_Up__c where  Follow_Up_Date__c = TODAY AND isAcctionCompleted__c = FALSE AND Status__c!='Completed' and Status__c!='Not Started' ORDER BY CreatedDate DESC];
        list<Follow_Up__c> updatefollUpDuedate = new list<Follow_Up__c>();
        if(lstfollupactionfalse.size()> 0 ){
            for(Follow_Up__c objfol:lstfollupactionfalse){
                objfol.Follow_Up_Date__c = Date.today();
                updatefollUpDuedate.add(objfol);
            }
            update updatefollUpDuedate;
        }
        
        //List<Follow_Up__c> Flist = [select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Folllow_Up1_Summary__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c from Follow_Up__c where  Follow_Up_Date__c= TODAY AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost' AND Lead__r.Status !='Test Ride' AND Lead__r.Lead_Age__c <= 21  ORDER BY CreatedDate DESC];
        List<Follow_Up__c> Flist = [select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c,Lead__r.City,Lead__r.State,Lead__r.Country,Lead__r.PostalCode,Lead__r.Street from Follow_Up__c where  Follow_Up_Date__c = TODAY AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost'   ORDER BY CreatedDate DESC];
        
        
        Set<Id> setLeadID = new Set<Id>(); 
        Set<Id> setFollowUpID = new Set<Id>(); 
        for(Follow_Up__c objFollow : Flist){
            if(objFollow.Lead__c != null){
                setLeadID.add(objFollow.Lead__c);
                setFollowUpID.add(objFollow.Id);
            }
        }
        system.debug('fpplowpids'+setFollowUpID);
        Map<Id,Follow_Up__History> mapHistory = new Map<Id,Follow_Up__History>();
        List<Follow_Up__History> lstHistory =[SELECT OldValue, NewValue, Field, CreatedDate,ParentId FROM Follow_Up__History WHERE Field = 'Due_Date__c' AND ParentId =:setLeadID Order BY CreatedDate DESC];
        for(Follow_Up__History objHis : lstHistory){
            if(!mapHistory.containsKey(objHis.ParentId)){
                mapHistory.put(objHis.ParentId,objHis);
            }
        }
        
        
        system.debug('oldvalue'+Flist);
        
        List<Lead> lstLead = [Select Id,Name, Phone, LeadSource,Lead_Age__c from Lead WHERE Id =:setLeadID AND IsConverted=false AND Status !='close lost' AND Lead_Age__c <= 21];
        leadWrapper objWrapper = new leadWrapper();
        objWrapper.lstFollowUp = Flist;
        objWrapper.lstLead = lstLead;
        objWrapper.oldValue = mapHistory;
        return objWrapper;
    } */
    @AuraEnabled
    public static List<Lead> getLeadsList(String searchKeyword){
        String key = '%' + searchKeyword + '%';
        List<Lead> SearchLeads = [Select id,Name, LeadSource,Status,MobilePhone, Customer_Age__c, Lead_Age__c from Lead WHERE Status ='New' AND IsConverted=false AND Status !='close lost' AND Status !='Test Ride'AND Status !='Follow Up'/* AND Lead_Age__c <= 21 */AND Status LIKE :key] ;
        
        return SearchLeads;
    }
    
    @AuraEnabled
    public static List<Lead> getLeads(Integer pageSize, Integer pageNumber){
        Integer offsetValue = (pageNumber - 1) * pageSize;
        
        List<Lead> LeadsList = [Select id,Name, Phone, CreatedDate ,Lead_Age__c,Status from Lead WHERE IsConverted=false  AND Status !='close lost' AND Status !='Test Ride' AND Status !='Follow Up'/* AND Lead_Age__c <= 21 */AND CreatedDate<=TODAY  ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offsetValue ];
        system.debug(LeadsList);
        return LeadsList;
        
    }
    @AuraEnabled
    public static List<Lead> newgetLeads(){
        
        List<Lead> LeadsList = [Select id,Name, Phone, CreatedDate ,Lead_Age__c,Status from Lead WHERE IsConverted=false  AND Status !='close lost' AND Status !='Test Ride' AND Status !='Follow Up'/* AND Lead_Age__c <= 21 */AND CreatedDate=TODAY ORDER BY CreatedDate DESC limit 50 ];
        system.debug('kkk'+LeadsList);
        
        return LeadsList;
        
    }
    @AuraEnabled
    public static Lead getLeaddeatails(Id leadid){
        Lead getLead = new Lead(); 
        try{
            getLead = [Select id,Name, LeadSource,Lost_Reason__c, Phone, Customer_Age__c, Lead_Age__c, city,country,postalCode,state,street,Status,Owner.Name,Email,PS_Name__c from Lead WHERE Id=:leadid AND IsConverted=false ];
        }catch(Exception e){
            getLead= null; 
        }
        
        
        return getLead;
    }
    
    /*   @AuraEnabled(cacheable=true)
public static List<Map<String, String>> getVehicleOptions() {
List<Map<String, String>> options = new List<Map<String, String>>();

// Query to get Vehicle__c records
List<Vehicle> vehicles = [SELECT Id, Name FROM Vehicle ORDER BY Name];

// Add each vehicle to the options list
for (Vehicle vehicle : vehicles) {
Map<String, String> option = new Map<String, String>();
option.put('label', vehicle.Name);
option.put('value', vehicle.Id);
options.add(option);
}

return options;
}
@auraenabled
public static void createtestdrive(String testdriveName,DateTime drivedate,Id leadiddd,string ridetype){
Test_Drive__c td=new Test_Drive__c();
td.Name=testdriveName;
td.Lead__c=leadiddd;
td.Test_Drive_Date__c=drivedate;
//td.Vehicle__c=vehicleid;
td.Ride_Type__c=ridetype;
insert td;


}
@auraenabled
public static void createfollowup(string followupName,id leadiddd){

Follow_Up__c newfollowup=new Follow_Up__c();
newfollowup.Name= followupName;
newfollowup.Lead__c=leadiddd;
insert newfollowup;
}*/
   
@AuraEnabled
public static List<Lead> getLeadsListBySearchKeyWord(String searchKeyword){
    String key = '%' + searchKeyword + '%';
    // List<Lead> SearchLeads = [Select id,Name, LeadSource, Phone, Customer_Age__c, Lead_Age__c from Lead WHERE (Name LIKE:key OR Phone LIKE:key) and isConverted = false AND Status !='close lost'AND Status!='Test Ride'AND Status !='Follow Up' AND CreatedDate<=TODAY] ;
    List<Lead> SearchLeads = [Select id,Name, LeadSource, Phone, Customer_Age__c, Lead_Age__c ,CreatedDate from Lead WHERE (Name LIKE:key OR Phone LIKE:key) and isConverted = false AND Status !='close lost' AND CreatedDate<=TODAY ORDER BY CreatedDate DESC] ;
    system.debug('hhhh='+SearchLeads);
    return SearchLeads;
}

    @auraenabled
    public static void updatelead(string id, string lead_source, string phone, Decimal Age,string email ,string city,string Country,string PostalCode,string State,string Street, string Status,string psname){
        system.debug('gggg='+Country);
        lead ul = new lead();
        ul.Id = id;
        ul.LeadSource = lead_source;
        ul.Phone = phone;
        ul.Customer_Age__c = age;
        ul.City=city;
        ul.Country=Country;
        ul.PostalCode=PostalCode;
        ul.State=State;
        ul.Street=Street;
        ul.Email=email;
        ul.Status=Status;
        ul.PS_Name__c=psname;
        
        update ul;
        
    }
    @AuraEnabled
    public static Follow_Up__c followupfeedback(Id followupId,String Feedback){
        Follow_Up__c fllist= new Follow_Up__c();
        fllist.Id = followupId;
        fllist.Feedback__c=Feedback;
        fllist.isAcctionCompleted__c=true;
        fllist.Status__c='Completed';
        update fllist;
        return fllist;
    }

    @AuraEnabled
    public static leadWrapper getTestDriveRecords(Date fromDate, Date toDate) {
        System.debug('### Inside getTestDriveRecords Method ###');
        System.debug('Received fromDate: ' + fromDate + ', toDate: ' + toDate);
    
        // Convert date to datetime
        Datetime startDatetime = Datetime.newInstance(fromDate, Time.newInstance(0, 0, 0, 0));
        Datetime endDatetime = Datetime.newInstance(toDate, Time.newInstance(23, 59, 59, 999));
    
        System.debug('Converted startDatetime: ' + startDatetime);
        System.debug('Converted endDatetime: ' + endDatetime);
    
        User currentUser = [SELECT Id ,Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Boolean isSysAdmin = (currentUser.Profile.Name == 'System Administrator');


        List<Test_Drive__c> newList;
            if(isSysAdmin){
                newList = [
                    SELECT Id, Name, MobilePhone__c, Lead__c, Lead__r.Name, Test_Drive_Date__c, Is_Reschedule__c, 
                           Ride_Type__c, Phone__c, Reschedule_Date__c, Test_Ride_Date__c, Test_Drive_Status__c, 
                           Start_Date__c, End_Date__c, Lead__r.Lead_Age__c, Drivers_License_Number__c, Indemnity__c
                    FROM Test_Drive__c 
                    WHERE Lead__r.isConverted = false 
                    AND Lead__r.Status != 'close lost'
                    AND Lead__r.Status = 'Test Ride' 
                    AND Test_Ride_Date__c >= :startDatetime 
                    AND Test_Ride_Date__c <= :endDatetime 
                    ORDER BY Test_Ride_Date__c ASC
                ];
            }else{
                newList = [
                    SELECT Id, Name, MobilePhone__c, Lead__c, Lead__r.Name, Test_Drive_Date__c, Is_Reschedule__c, 
                           Ride_Type__c, Phone__c, Reschedule_Date__c, Test_Ride_Date__c, Test_Drive_Status__c, 
                           Start_Date__c, End_Date__c, Lead__r.Lead_Age__c, Drivers_License_Number__c, Indemnity__c
                    FROM Test_Drive__c 
                    WHERE Lead__r.OwnerId = :currentUser.Id
                    AND Lead__r.isConverted = false 
                    AND Lead__r.Status != 'close lost'
                    AND Lead__r.Status = 'Test Ride' 
                    AND Test_Ride_Date__c >= :startDatetime 
                    AND Test_Ride_Date__c <= :endDatetime 
                    ORDER BY Test_Ride_Date__c ASC
                ];

            }

                // Extract unique Lead IDs from Follow-Up records
    Set<Id> leadIds = new Set<Id>();
    for (Test_Drive__c fup : newList) {
        leadIds.add(fup.Lead__c);
    }

        // Fetch related Leads
        List<Lead> leads = [
            SELECT Id, OwnerId, Name, Phone, LeadSource, Lead_Age__c 
            FROM Lead 
            WHERE Id IN :leadIds
            AND Status != 'Close Lost'
        ];



    
    
        // If no records found, re-run query without Lead Status filter
        if (newList.isEmpty()) {
            System.debug('No records found in first query, running fallback query...');
            newList = [
                SELECT Id, Name, MobilePhone__c, Lead__c, Lead__r.Name, Test_Drive_Date__c, Is_Reschedule__c, 
                       Ride_Type__c, Phone__c, Reschedule_Date__c, Test_Drive_Status__c, Start_Date__c, 
                       End_Date__c, Lead__r.Lead_Age__c, Drivers_License_Number__c, Indemnity__c, Test_Ride_Date__c
                FROM Test_Drive__c 
                WHERE Lead__c IN :leadIds
                AND Lead__r.isConverted = false 
                AND Lead__r.Status != 'close lost' 
                AND Test_Ride_Date__c >= :startDatetime 
                AND Test_Ride_Date__c <= :endDatetime 
                ORDER BY Test_Ride_Date__c ASC
            ];
            System.debug('Total newList records (fallback query): ' + newList.size());
        }
        
        // Creating response wrapper
        leadWrapper objWrapper = new leadWrapper();
        objWrapper.lstTestRide = newList;
        objWrapper.lstLead = leads;
    
        System.debug('### Returning leadWrapper object ###');
        return objWrapper;
    }
    

    // @Auraenabled
    // public static leadWrapper getTestDriveRecords(){
    //     list<Test_Drive__c> lsttestactionfalse =[select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c,Test_Ride_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c from Test_Drive__c where  Lead__r.isConverted = false and Test_Drive_Status__c!='Canceled' AND Test_Drive_Status__c!='Completed'  And  Lead__r.Status !='close lost' and isAcctionCompleted__c = FALSE AND  ((Test_Ride_Date__c = TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c = TODAY AND Test_Drive_Status__c='Reschedule'))  ORDER BY CreatedDate DESC ];
    //     list<Test_Drive__c> updateTestDuedate = new list<Test_Drive__c>();
    //     //// if(lsttestactionfalse.size()> 0 ){
    //     // for(Test_Drive__c objtest:lsttestactionfalse){
    //     //objtest.Test_Drive_Date__c = Date.today();
    //     //updateTestDuedate.add(objtest);
    //     //}
    //     // update updateTestDuedate;
    //     // }
    //     List<Test_Drive__c> newList = [select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c,Test_Ride_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c from Test_Drive__c where  Lead__r.isConverted = false and Lead__r.Status !='close lost'AND Lead__r.Status ='Test Ride' AND  ((Test_Ride_Date__c = TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c = TODAY AND Test_Drive_Status__c='Reschedule')) ORDER BY Test_Ride_Date__c ASC];
    //     //Uma made Changes in the query added two fields
    //     if(newList.size() == 0){
    //         newList = [select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c,Test_Ride_Date__c from Test_Drive__c where  Lead__r.isConverted = false and Lead__r.Status !='close lost' AND ((Test_Ride_Date__c = TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c = YESTERDAY AND Test_Drive_Status__c='Reschedule')) ORDER BY Test_Ride_Date__c ASC];
    //     }
    //     Set<Id> setLeadID = new Set<Id>(); 
    //     for(Test_Drive__c objTest : newList){
    //         if(objTest.Lead__c != null){
    //             setLeadID.add(objTest.Lead__c);
    //         }
    //     }
    //     system.debug('iii'+newList);
    //     List<Lead> lstLead = [Select Id,Name, Phone, LeadSource,Lead_Age__c from Lead WHERE Id =:setLeadID AND IsConverted=false AND Status !='close lost' AND Lead_Age__c <= 21];
    //     leadWrapper objWrapper = new leadWrapper();
    //     objWrapper.lstTestRide = newList;
    //     objWrapper.lstLead = lstLead;
    //     return objWrapper;
    // }
    
    
    @Auraenabled
    public static void rescheduledate(DateTime rescheduledate,Id testdriverid,String rideType){
        Test_Drive__c objtestDrive = new Test_Drive__c();
        objtestDrive.Id = testdriverid;
        objtestDrive.Reschedule_Date__c=rescheduledate;
        objtestDrive.Test_Ride_Date__c=rescheduledate;
        objtestDrive.Ride_Type__c = rideType;
        objtestDrive.Test_Drive_Status__c='Reschedule';
        
        
        update objtestDrive;
        
    }

    @Auraenabled
    public static void updateLeadStatusToClosedLost(Id testDriveId,string reason,string reasonfeedback){
       // System.debug('lead Id'+leadId)
        System.debug('lead Id'+testDriveId);
        Test_Drive__c testDrive = [SELECT Lead__c FROM Test_Drive__c WHERE Id = :testDriveId LIMIT 1];
        System.debug('lead Id'+testDrive);
        Lead leadToUpdate = [SELECT Id, Status,Lost_Reason__c,Lost_Feedback__c FROM Lead WHERE Id = :testDrive.Lead__c LIMIT 1];
        leadToUpdate.Lost_Reason__c=reason;
        leadToUpdate.Lost_Feedback__c=reasonfeedback;
        System.debug('lead Id'+leadToUpdate);
        leadToUpdate.Status = 'close lost';
        update leadToUpdate;
    }


    @Auraenabled
    public static void updateLeadStatus(Id leadId){
        Lead objLead = new Lead();
        objLead.Id = leadId;
        objLead.Status = 'close lost';
        update objLead;
    }
    
    @Auraenabled
    public static void leadstatuscancel(Id testrideId,string cancelreason){
        Test_Drive__c objtestDrive = new Test_Drive__c();
        objtestDrive.Id = testrideId;
        objtestDrive.Test_Drive_Status__c='Canceled';
        objtestDrive.Reason_For_Cancellation__c=cancelreason;
        update objtestDrive;
    }
    
    @auraenabled
    public static  Test_Drive__c leadstatuscomplete(Id testrideId,string feedback){
        
        Test_Drive__c testrideLeadId = [SELECT Id,Lead__c FROM Test_Drive__c WHERE Id = : testrideId];
        
        Test_Drive__c objtestDrive = new Test_Drive__c();
        objtestDrive.Id = testrideId;
        objtestDrive.Test_Drive_Status__c='Completed';
        objtestDrive.isAcctionCompleted__c= true;
        objtestDrive.Feedback__c=feedback;
        update objtestDrive;
        
        /*Follow_Up__c fllist= new Follow_Up__c();
fllist.Lead__c = testrideLeadId.Lead__c;
fllist.Status__c='Not Started';
fllist.Subject__c='Call';
fllist.Due_Date__c= Date.today();

insert fllist;*/
        
        Lead  updatelead = new Lead();
        updatelead.Id = testrideLeadId.Lead__c;
        updatelead.Status ='Follow Up';
        
        update updatelead;
        
        return objtestDrive;
        
    }
    
    @auraenabled
    public static Follow_Up__c getPreviousfollowUp(String currentFollowUpId) {
        
        Follow_Up__c currentFollowUp = [SELECT Id, CreatedDate,Lead__c FROM Follow_Up__c WHERE Id = :currentFollowUpId];
        
        return currentFollowUp; 
    }
    
    @auraenabled
    public static Id createnewfollowup(String testrideId, id leadid,datetime followupdate, string feedbackvalue){
        system.debug('enter'+leadid+followupdate+feedbackvalue);
        //  Follow_Up__c followUpObj =[SELECT Id, Name,Lead__c,Status__c FROM Follow_Up__c WHERE Lead__c = :leadid  AND Status__c != 'Completed' ORDER BY CreatedDate DESC LIMIT 1];
        Lead objlead = new Lead();
        objlead.Id = leadid;
        objlead.Status ='Follow Up';
        update objlead;
        
        if(testrideId != null){
            Test_Drive__c objTes = new Test_Drive__c();
            objTes.Id = testrideId;
            objTes.Feedback__c = feedbackvalue;
            objTes.isAcctionCompleted__c = true;
            objTes.Test_Drive_Status__c = 'Completed';
            update objTes;
        }
        else{
            System.debug('testrideId');
        }
        
        Follow_Up__c crfollowup=new Follow_Up__c();
        if(followupdate!=null&&feedbackvalue!=null){
            system.debug('enter'+leadid+followupdate+feedbackvalue);
            
            crfollowup.Lead__c=leadid;
            crfollowup.Follow_Up_Date__c=followupdate;
            crfollowup.Feedback__c =feedbackvalue;
            
        }
        insert crfollowup;
        
        
        return crfollowup.Id;
    }
    
    @auraenabled
    public static Id createnewfollowupFromFollowup(String followUpId, id leadid,datetime followupdate, string feedbackvalue){
        Lead objlead = new Lead();
        objlead.Id = leadid;
        objlead.Status ='Follow Up';
        update objlead;
        
        if(followUpId != null){
            Follow_Up__c objFollow = new Follow_Up__c();
            objFollow.Id = followUpId;
            objFollow.Feedback__c = feedbackvalue;
            objFollow.isAcctionCompleted__c=true;
            update objFollow;
        }
        else{
            System.debug('testrideId');
        }
        Follow_Up__c objprefollowUp =[SELECT Id,Name,CreatedDate FROM Follow_Up__c WHERE Id =: followUpId];
        Follow_Up__c crfollowup=new Follow_Up__c();
        if(followupdate!=null&&feedbackvalue!=null){
            system.debug('enter'+leadid+followupdate+feedbackvalue);
            
            crfollowup.Lead__c=leadid;
            crfollowup.Previous_Feedback__c = feedbackvalue;
            crfollowup.Follow_Up_Date__c=followupdate;
            crfollowup.Previous_Followup_date__c =objprefollowUp.CreatedDate;
            //crfollowup.Feedback__c =feedbackvalue;
            
        }
        insert crfollowup;
        
        
        return crfollowup.Id;
    }
    @auraenabled
    public static list<Follow_Up__c>  NotAttendedfllowups(){
        list<Follow_Up__c> NotAttendedfllowupslist=[select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c,Lead__r.City,Lead__r.State,Lead__r.Country,Lead__r.PostalCode,Lead__r.Street from Follow_Up__c where  Follow_Up_Date__c < TODAY AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost' AND Lead__r.Status !='Test Ride'  ORDER BY CreatedDate DESC];
        return NotAttendedfllowupslist;
    }
    @auraenabled
    public static list<Test_Drive__c>  NotAttendedtestdrives(){
        list<Test_Drive__c> NotAttendedtestdriveslist= [select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c,Test_Ride_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c from Test_Drive__c where  Lead__r.isConverted = false and Lead__r.Status !='close lost'AND Lead__r.Status ='Test Ride' AND Lead__r.Lead_Age__c <= 21 and ((Test_Ride_Date__c < TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c < TODAY AND Test_Drive_Status__c='Reschedule')) ORDER BY Lead__r.Lead_Age__c DESC];
        return NotAttendedtestdriveslist;
    }
    @auraenabled
    public static summarrywrapper summarrywrappersetcount(){
                System.debug('count');

        List<Lead> LeadsList = [Select id,Name, Phone, CreatedDate ,Lead_Age__c,Status from Lead WHERE IsConverted=false  AND Status !='close lost' AND Status !='Test Ride' AND Status !='Follow Up'/* AND Lead_Age__c <= 21 */AND CreatedDate<TODAY  ORDER BY CreatedDate DESC limit 50 ];
        List<Lead> newLeadsList = [Select id,Name, Phone, CreatedDate ,Lead_Age__c,Status from Lead WHERE IsConverted=false  AND Status !='close lost' AND Status !='Test Ride' AND Status !='Follow Up'/* AND Lead_Age__c <= 21 */AND CreatedDate=TODAY ORDER BY CreatedDate DESC limit 50 ];
        List<Follow_Up__c> Flist = [select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c,Lead__r.City,Lead__r.State,Lead__r.Country,Lead__r.PostalCode,Lead__r.Street from Follow_Up__c where  Follow_Up_Date__c = TODAY AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost' AND Lead__r.Status !='Test Ride'  ORDER BY CreatedDate DESC];
        List<Test_Drive__c> newList = [select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c,Test_Ride_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c from Test_Drive__c where  Lead__r.isConverted = false and Lead__r.Status !='close lost'AND Lead__r.Status ='Test Ride' AND  ((Test_Ride_Date__c = TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c = TODAY AND Test_Drive_Status__c='Reschedule')) ORDER BY Test_Ride_Date__c ASC];
        list<Follow_Up__c> NotAttendedfllowupslist=[select Id,Due_Date__c,Lead__c,Lead__r.Name,Lead__r.Phone__c,Status__c,Subject__c,Lead__r.Lead_Age__c,Follow_Up__c,Previous_Followup_date__c,Previous_Feedback__c,Feedback__c,Lead__r.City,Lead__r.State,Lead__r.Country,Lead__r.PostalCode,Lead__r.Street from Follow_Up__c where  Follow_Up_Date__c < TODAY AND Status__c!='Completed' and Lead__r.isConverted = false AND Lead__r.Status !='close lost' AND Lead__r.Status !='Test Ride'  ORDER BY CreatedDate DESC];
        list<Test_Drive__c> NotAttendedtestdriveslist= [select Id,Name,MobilePhone__c,Lead__c,Lead__r.Name,Test_Drive_Date__c ,Is_Reschedule__c,Ride_Type__c, Phone__c, Reschedule_Date__c,Test_Ride_Date__c, Test_Drive_Status__c,Start_Date__c,End_Date__c,Lead__r.Lead_Age__c,Drivers_License_Number__c,Indemnity__c from Test_Drive__c where  Lead__r.isConverted = false and Lead__r.Status !='close lost'AND Lead__r.Status ='Test Ride' AND  ((Test_Ride_Date__c < TODAY AND  Test_Drive_Status__c='Scheduled') OR(Reschedule_Date__c < TODAY AND Test_Drive_Status__c='Reschedule')) ORDER BY Test_Ride_Date__c ASC];
        list<lead> newstatusleads=[select Id,Status  from lead  where Status ='New' ];
        list<lead> testrideleads=[select Id,Status  from lead  where Status ='Test Ride' ];
        list<lead> followupleads=[select Id,Status  from lead  where Status ='Follow Up' ];
        list<lead> readyforbbokingleads=[select Id,Status  from lead  where Status ='Ready For booking' ];
        list<lead> convertleads=[select Id,Status  from lead  where Status ='Converted' ];
        list<lead> closelostleads=[select Id,Status  from lead  where Status ='Close lost' ];
        integer LeadsListcount=LeadsList.size();
        integer newLeadsListcount=newLeadsList.size();
        integer  Flistcount=Flist.size();
        integer  newListcount=newList.size();
        integer integerNotAttendedfllowupslistcount=NotAttendedfllowupslist.size();
        integer NotAttendedtestdriveslistcount=NotAttendedtestdriveslist.size();
        integer newstatusleadscount=newstatusleads.size();
        integer testrideleadscount=testrideleads.size();
        integer followupleadscount=followupleads.size();
        integer readyforbbokingleadscount=readyforbbokingleads.size();
        integer convertleadscount=convertleads.size();
        integer closelostleadscount=closelostleads.size();
        
        summarrywrapper summarrywrapperobject=new summarrywrapper();
        
        
            summarrywrapperobject.todayfolloups=Flistcount;
            summarrywrapperobject.notattenedfolloups=integerNotAttendedfllowupslistcount;
            summarrywrapperobject.Newleads=newLeadsListcount;
            summarrywrapperobject.Notattendedleads=LeadsListcount;
            summarrywrapperobject.newstatusleads=newstatusleadscount;
            summarrywrapperobject.testrideleads=testrideleadscount;
             summarrywrapperobject.followupLead=followupleadscount;
            summarrywrapperobject.readyforbbokingleads=readyforbbokingleadscount;
            summarrywrapperobject.convertleads=convertleadscount;
            summarrywrapperobject.clostlostleads=closelostleadscount;
            summarrywrapperobject.todayTestRide=newListcount;
            summarrywrapperobject.notattendedTestRide=NotAttendedtestdriveslistcount;
        System.debug('count'+summarrywrapperobject);
        return summarrywrapperobject;



            
        
        
        
        
        
        
        
        
    }
    
}