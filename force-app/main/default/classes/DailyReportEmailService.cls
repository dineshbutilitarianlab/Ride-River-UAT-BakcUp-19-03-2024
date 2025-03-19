public class DailyReportEmailService implements Schedulable {

    public void execute(SchedulableContext SC) {
        sendDailyReportEmails();
    }

    public static void sendDailyReportEmails() {
        // Define the start and end of the current day
        DateTime startOfDay = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)); // 12:00 AM
        DateTime endOfDay = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 999)); // 11:59:59.999 PM

        // Fetch all Lead Owners (Stores) and their respective ASMs (Managers)
        Map<Id, String> leadOwnerToASM = new Map<Id, String>();
        Map<String, Set<Id>> asmToLeadOwners = new Map<String, Set<Id>>();

        for (User u : [SELECT Id, Name, ManagerId FROM User WHERE ManagerId != NULL]) {
            leadOwnerToASM.put(u.Id, u.ManagerId);
            if (!asmToLeadOwners.containsKey(u.ManagerId)) {
                asmToLeadOwners.put(u.ManagerId, new Set<Id>());
            }
            asmToLeadOwners.get(u.ManagerId).add(u.Id);
        }

        // Fetch Lead Owners' emails (Stores)
        Map<Id, String> leadOwnerEmails = new Map<Id, String>();
        Map<Id, String> leadOwnerNames = new Map<Id, String>(); 
        for (User u : [SELECT Id, Email FROM User WHERE Id IN :leadOwnerToASM.keySet()]) {
            leadOwnerEmails.put(u.Id, u.Email);
        }

        // Fetch ASM Emails
        Map<Id, String> asmNames = new Map<Id, String>();  
        Map<Id, String> asmEmails = new Map<Id, String>();
        for (User u : [SELECT Id, Email FROM User WHERE Id IN :asmToLeadOwners.keySet()]) {
            asmEmails.put(u.Id, u.Email);
        }

        // HQ Email List
        List<String> hqEmails = new List<String>{'rohit.bisht@utilitarianlabs.com'}; // Update with actual HQ emails

        // Prepare bulk email list
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Send Reports to each Lead Owner (Store)
        for (Id leadOwner : leadOwnerToASM.keySet()) {
            String htmlBody = generateStoreOwnerReport(leadOwner, startOfDay, endOfDay);
            emailsToSend.add(prepareEmail(leadOwnerEmails.get(leadOwner),leadOwnerNames.get(leadOwner), '📊 Your Daily Report: Planned vs Completed', htmlBody));
        }

        // Send Reports to each ASM (Consolidated for all their Stores)
        for (Id asmId : asmToLeadOwners.keySet()) {
            String htmlBody = generateASMReport(asmId, asmToLeadOwners.get(asmId), startOfDay, endOfDay);
            emailsToSend.add(prepareEmail(asmEmails.get(asmId),asmNames.get(asmId), '📊 ASM Report: All Your Stores', htmlBody));
        }

        // Send Report to HQ (Overall Data)
        String hqHtmlBody = generateHQReport(startOfDay, endOfDay);
        for (String email : hqEmails) {
            emailsToSend.add(prepareEmail(email,'Rohit Singh Bisht', '📊 HQ Daily Report: Planned vs Completed', hqHtmlBody));
        }

        // Send all emails in a single transaction (avoiding the governor limit)
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    /** Generates a report for an individual Store Owner */
    private static String generateStoreOwnerReport(Id ownerId, DateTime startOfDay, DateTime endOfDay) {
        List<AggregateResult> testRidePlannedData = [
            SELECT Ride_Type__c, COUNT(Id) total
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay AND OwnerId = :ownerId
            GROUP BY Ride_Type__c
        ];

        List<AggregateResult> testRideCompletedData = [
            SELECT Ride_Type__c, COUNT(Id) completed
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay 
                  AND Test_Drive_Status__c = 'Completed' AND OwnerId = :ownerId
            GROUP BY Ride_Type__c
        ];

        Integer newLeads = [SELECT COUNT() FROM Lead WHERE CreatedDate >= :startOfDay AND CreatedDate <= :endOfDay AND OwnerId = :ownerId];

        Integer plannedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay AND OwnerId = :ownerId];

        Integer completedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay 
                                     AND Status__c = 'Completed' AND OwnerId = :ownerId];

        return formatReportEmail(testRidePlannedData, testRideCompletedData, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Generates a report for an ASM (aggregating data from multiple stores) */
    private static String generateASMReport(Id asmId, Set<Id> leadOwnerIds, DateTime startOfDay, DateTime endOfDay) {
        List<AggregateResult> testRidePlannedData = [
            SELECT Ride_Type__c, COUNT(Id) total
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay AND OwnerId IN :leadOwnerIds
            GROUP BY Ride_Type__c
        ];

        List<AggregateResult> testRideCompletedData = [
            SELECT Ride_Type__c, COUNT(Id) completed
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay 
                  AND Test_Drive_Status__c = 'Completed' AND OwnerId IN :leadOwnerIds
            GROUP BY Ride_Type__c
        ];

        Integer newLeads = [SELECT COUNT() FROM Lead WHERE CreatedDate >= :startOfDay AND CreatedDate <= :endOfDay AND OwnerId IN :leadOwnerIds];

        Integer plannedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay AND OwnerId IN :leadOwnerIds];

        Integer completedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay 
                                     AND Status__c = 'Completed' AND OwnerId IN :leadOwnerIds];

        return formatReportEmail(testRidePlannedData, testRideCompletedData, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Generates the overall HQ report */
    private static String generateHQReport(DateTime startOfDay, DateTime endOfDay) {
        List<AggregateResult> testRidePlannedData = [
            SELECT Ride_Type__c, COUNT(Id) total
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay
            GROUP BY Ride_Type__c
        ];

        List<AggregateResult> testRideCompletedData = [
            SELECT Ride_Type__c, COUNT(Id) completed
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay 
                  AND Test_Drive_Status__c = 'Completed'
            GROUP BY Ride_Type__c
        ];

        Integer newLeads = [SELECT COUNT() FROM Lead WHERE CreatedDate >= :startOfDay AND CreatedDate <= :endOfDay];

        Integer plannedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay];

        Integer completedFollowUps = [SELECT COUNT() FROM Follow_Up__c WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay 
                                     AND Status__c = 'Completed'];

        return formatReportEmail(testRidePlannedData, testRideCompletedData, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Prepares an email object */
    private static Messaging.SingleEmailMessage prepareEmail(String recipientEmail, String recipientName, String subject, String htmlBody) {
        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@rideriver.com' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        String personalizedBody = '<p>Hi ' + recipientName + ',</p>' + htmlBody;
        mail.setHtmlBody(personalizedBody);
        if (!orgWideEmail.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            }
        return mail;
    }

    private static String formatReportEmail(List<AggregateResult> plannedTestRides, List<AggregateResult> completedTestRides, Integer newLeads, Integer plannedFollowUps, Integer completedFollowUps) {
        String html = '<html><head><style>' +
                      'body {font-family: Arial, sans-serif; background-color: #F4F6F9; padding: 20px; color: #333;}' +
                      '.dashboard-container {background: white; padding: 20px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);}' +
                      '.dashboard-title {font-size: 24px; font-weight: bold; color: #0176D3;}' +
                      '.section-title {font-size: 18px; font-weight: bold; color: #2C3E50; margin-top: 20px;}' +
                      'table {width: 100%; border-collapse: collapse; margin-top: 10px; background: #fff; border-radius: 5px; overflow: hidden;}' +
                      'th, td {border: 1px solid #ddd; padding: 12px; text-align: center;}' +
                      'th {background-color: #0176D3; color: white;}' +
                      '</style></head><body>' +
                      '<div class="dashboard-container">' +
                      '<div class="dashboard-title">📊 Daily Planned vs Completed Report (' + Date.today().format() + ')</div>';
        
        // Test Ride Section
        html += '<div class="section-title">🚗 Test Rides</div><table><tr><th>Ride Type</th><th>Planned</th><th>Completed</th></tr>';
        
        Map<String, Integer> completedMap = new Map<String, Integer>();
        for (AggregateResult ar : completedTestRides) {
            completedMap.put((String) ar.get('Ride_Type__c'), (Integer) ar.get('completed'));
        }
        
        for (AggregateResult ar : plannedTestRides) {
            String rideType = (String) ar.get('Ride_Type__c');
            Integer planned = (Integer) ar.get('total');
            Integer completed = completedMap.containsKey(rideType) ? completedMap.get(rideType) : 0;
            html += '<tr><td>' + rideType + '</td><td><b>' + planned + '</b></td><td><b>' + completed + '</b></td></tr>';
        }
        html += '</table>';
        
        // Leads Section
        html += '<div class="section-title">📝 Leads</div><p><b>New Leads Today:</b> ' + newLeads + '</p>';
        
        // Follow-Ups Section
        html += '<div class="section-title">🔄 Follow-Ups</div><table><tr><th>Planned</th><th>Completed</th></tr>';
        html += '<tr><td><b>' + plannedFollowUps + '</b></td>' +
                '<td><b>' + completedFollowUps + '</b></td></tr>';
        html += '</table>'; 
        
        html += '<p style="color: #E74C3C; font-weight: bold;">📌 Please review and take necessary actions.</p>' +
                '<p style="color: #3498DB; font-weight: bold;">🚘 Thank you,<br>Ride River</p></div></body></html>';
        
        return html;
    }
}