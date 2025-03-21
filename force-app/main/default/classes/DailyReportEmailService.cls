public class DailyReportEmailService implements Schedulable {

    public void execute(SchedulableContext SC) {
        sendDailyReportEmails();
    }

    public static void sendDailyReportEmails() {
        // Define the start and end of the current day
        DateTime startOfDay = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)); // 12:00 AM
        DateTime endOfDay = DateTime.newInstance(Date.today(), Time.newInstance(23, 59, 59, 999)); // 11:59:59.999 PM

        // Fetch all Lead Owners (Stores) and their respective ASMs (Managers)
        Map<Id, Id> leadOwnerToASM = new Map<Id, Id>();
        Map<Id, Set<Id>> asmToLeadOwners = new Map<Id, Set<Id>>();

        for (User u : [SELECT Id, ManagerId FROM User WHERE ManagerId != NULL]) {
            leadOwnerToASM.put(u.Id, u.ManagerId);
            if (!asmToLeadOwners.containsKey(u.ManagerId)) {
                asmToLeadOwners.put(u.ManagerId, new Set<Id>());
            }
            asmToLeadOwners.get(u.ManagerId).add(u.Id);
        }

        // Fetch Lead Owners' emails (Stores)
        Map<Id, String> leadOwnerEmails = new Map<Id, String>();
        for (User u : [SELECT Id, Email FROM User WHERE Id IN :leadOwnerToASM.keySet()]) {
            leadOwnerEmails.put(u.Id, u.Email);
        }

        // Fetch ASM Emails
        Map<Id, String> asmEmails = new Map<Id, String>();
        for (User u : [SELECT Id, Email FROM User WHERE Id IN :asmToLeadOwners.keySet()]) {
            asmEmails.put(u.Id, u.Email);
        }

        // HQ Email List
        List<HQ_Email_Settings__mdt> hqEmailRecords = [SELECT Email__c FROM HQ_Email_Settings__mdt WHERE Active__c = TRUE];
        List<String> hqEmails = new List<String>();
        for (HQ_Email_Settings__mdt record : hqEmailRecords) {
            if (record.Email__c != null) {
                hqEmails.add(record.Email__c);
            }
        }

        if (hqEmails.isEmpty()) {
            System.debug('No active HQ emails found in metadata.');
            return;
        }

        // Prepare bulk email list
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // Fetch all Test Drive data for the day
        Map<Id, Map<String, Integer>> leadOwnerTestRidePlanned = new Map<Id, Map<String, Integer>>();
        Map<Id, Map<String, Integer>> leadOwnerTestRideCompleted = new Map<Id, Map<String, Integer>>();
        for (AggregateResult ar : [
            SELECT OwnerId, Ride_Type__c, COUNT(Id) total
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay
            GROUP BY OwnerId, Ride_Type__c
        ]) {
            Id ownerId = (Id) ar.get('OwnerId');
            String rideType = (String) ar.get('Ride_Type__c');
            Integer total = (Integer) ar.get('total');
            if (!leadOwnerTestRidePlanned.containsKey(ownerId)) {
                leadOwnerTestRidePlanned.put(ownerId, new Map<String, Integer>());
            }
            leadOwnerTestRidePlanned.get(ownerId).put(rideType, total);
        }

        for (AggregateResult ar : [
            SELECT OwnerId, Ride_Type__c, COUNT(Id) completed
            FROM Test_Drive__c
            WHERE Test_Ride_Date__c >= :startOfDay AND Test_Ride_Date__c <= :endOfDay 
                  AND Test_Drive_Status__c = 'Completed'
            GROUP BY OwnerId, Ride_Type__c
        ]) {
            Id ownerId = (Id) ar.get('OwnerId');
            String rideType = (String) ar.get('Ride_Type__c');
            Integer completed = (Integer) ar.get('completed');
            if (!leadOwnerTestRideCompleted.containsKey(ownerId)) {
                leadOwnerTestRideCompleted.put(ownerId, new Map<String, Integer>());
            }
            leadOwnerTestRideCompleted.get(ownerId).put(rideType, completed);
        }

        // Fetch all Lead data for the day
        Map<Id, Integer> leadOwnerNewLeads = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT OwnerId, COUNT(Id) total
            FROM Lead
            WHERE CreatedDate >= :startOfDay AND CreatedDate <= :endOfDay
            GROUP BY OwnerId
        ]) {
            leadOwnerNewLeads.put((Id) ar.get('OwnerId'), (Integer) ar.get('total'));
        }

        // Fetch all Follow-Up data for the day
        Map<Id, Integer> leadOwnerPlannedFollowUps = new Map<Id, Integer>();
        Map<Id, Integer> leadOwnerCompletedFollowUps = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT OwnerId, COUNT(Id) total
            FROM Follow_Up__c
            WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay
            GROUP BY OwnerId
        ]) {
            leadOwnerPlannedFollowUps.put((Id) ar.get('OwnerId'), (Integer) ar.get('total'));
        }

        for (AggregateResult ar : [
            SELECT OwnerId, COUNT(Id) total
            FROM Follow_Up__c
            WHERE Follow_Up_Date__c >= :startOfDay AND Follow_Up_Date__c <= :endOfDay 
                  AND Status__c = 'Completed'
            GROUP BY OwnerId
        ]) {
            leadOwnerCompletedFollowUps.put((Id) ar.get('OwnerId'), (Integer) ar.get('total'));
        }

        // Send Reports to each Lead Owner (Store)
        for (Id leadOwner : leadOwnerToASM.keySet()) {
            Map<String, Integer> plannedTestRides = leadOwnerTestRidePlanned.containsKey(leadOwner) ? leadOwnerTestRidePlanned.get(leadOwner) : new Map<String, Integer>();
            Map<String, Integer> completedTestRides = leadOwnerTestRideCompleted.containsKey(leadOwner) ? leadOwnerTestRideCompleted.get(leadOwner) : new Map<String, Integer>();
            Integer newLeads = leadOwnerNewLeads.containsKey(leadOwner) ? leadOwnerNewLeads.get(leadOwner) : 0;
            Integer plannedFollowUps = leadOwnerPlannedFollowUps.containsKey(leadOwner) ? leadOwnerPlannedFollowUps.get(leadOwner) : 0;
            Integer completedFollowUps = leadOwnerCompletedFollowUps.containsKey(leadOwner) ? leadOwnerCompletedFollowUps.get(leadOwner) : 0;

            String htmlBody = generateStoreOwnerReport(plannedTestRides, completedTestRides, newLeads, plannedFollowUps, completedFollowUps);
            emailsToSend.add(prepareEmail(leadOwnerEmails.get(leadOwner), '📊 Your Daily Report: Planned vs Completed', htmlBody));
        }

        // Send Reports to each ASM (Consolidated for all their Stores)
        for (Id asmId : asmToLeadOwners.keySet()) {
            Set<Id> leadOwnerIds = asmToLeadOwners.get(asmId);
            Map<String, Integer> asmTestRidePlanned = new Map<String, Integer>();
            Map<String, Integer> asmTestRideCompleted = new Map<String, Integer>();
            Integer asmNewLeads = 0;
            Integer asmPlannedFollowUps = 0;
            Integer asmCompletedFollowUps = 0;

            for (Id leadOwner : leadOwnerIds) {
                if (leadOwnerTestRidePlanned.containsKey(leadOwner)) {
                    for (String rideType : leadOwnerTestRidePlanned.get(leadOwner).keySet()) {
                        Integer currentValue = asmTestRidePlanned.containsKey(rideType) ? asmTestRidePlanned.get(rideType) : 0;
                        asmTestRidePlanned.put(rideType, currentValue + leadOwnerTestRidePlanned.get(leadOwner).get(rideType));
                    }
                }
                if (leadOwnerTestRideCompleted.containsKey(leadOwner)) {
                    for (String rideType : leadOwnerTestRideCompleted.get(leadOwner).keySet()) {
                        Integer currentValue = asmTestRideCompleted.containsKey(rideType) ? asmTestRideCompleted.get(rideType) : 0;
                        asmTestRideCompleted.put(rideType, currentValue + leadOwnerTestRideCompleted.get(leadOwner).get(rideType));
                    }
                }
                asmNewLeads += leadOwnerNewLeads.containsKey(leadOwner) ? leadOwnerNewLeads.get(leadOwner) : 0;
                asmPlannedFollowUps += leadOwnerPlannedFollowUps.containsKey(leadOwner) ? leadOwnerPlannedFollowUps.get(leadOwner) : 0;
                asmCompletedFollowUps += leadOwnerCompletedFollowUps.containsKey(leadOwner) ? leadOwnerCompletedFollowUps.get(leadOwner) : 0;
            }

            String htmlBody = generateASMReport(asmTestRidePlanned, asmTestRideCompleted, asmNewLeads, asmPlannedFollowUps, asmCompletedFollowUps);
            emailsToSend.add(prepareEmail(asmEmails.get(asmId),'📊 ASM Report: All Your Stores', htmlBody));
        }

        // Send Report to HQ (Overall Data)
        Map<String, Integer> hqTestRidePlanned = new Map<String, Integer>();
        Map<String, Integer> hqTestRideCompleted = new Map<String, Integer>();
        Integer hqNewLeads = 0;
        Integer hqPlannedFollowUps = 0;
        Integer hqCompletedFollowUps = 0;

        for (Id leadOwner : leadOwnerToASM.keySet()) {
            if (leadOwnerTestRidePlanned.containsKey(leadOwner)) {
                for (String rideType : leadOwnerTestRidePlanned.get(leadOwner).keySet()) {
                    Integer currentValue = hqTestRidePlanned.containsKey(rideType) ? hqTestRidePlanned.get(rideType) : 0;
                    hqTestRidePlanned.put(rideType, currentValue + leadOwnerTestRidePlanned.get(leadOwner).get(rideType));
                }
            }
            if (leadOwnerTestRideCompleted.containsKey(leadOwner)) {
                for (String rideType : leadOwnerTestRideCompleted.get(leadOwner).keySet()) {
                    Integer currentValue = hqTestRideCompleted.containsKey(rideType) ? hqTestRideCompleted.get(rideType) : 0;
                    hqTestRideCompleted.put(rideType, currentValue + leadOwnerTestRideCompleted.get(leadOwner).get(rideType));
                }
            }
            hqNewLeads += leadOwnerNewLeads.containsKey(leadOwner) ? leadOwnerNewLeads.get(leadOwner) : 0;
            hqPlannedFollowUps += leadOwnerPlannedFollowUps.containsKey(leadOwner) ? leadOwnerPlannedFollowUps.get(leadOwner) : 0;
            hqCompletedFollowUps += leadOwnerCompletedFollowUps.containsKey(leadOwner) ? leadOwnerCompletedFollowUps.get(leadOwner) : 0;
        }

        String hqHtmlBody = generateHQReport(hqTestRidePlanned, hqTestRideCompleted, hqNewLeads, hqPlannedFollowUps, hqCompletedFollowUps);
        for (String email : hqEmails) {
            emailsToSend.add(prepareEmail(email,'📊 HQ Daily Report: Planned vs Completed', hqHtmlBody));
        }

        // Send all emails in a single transaction (avoiding the governor limit)
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }

    /** Generates a report for an individual Store Owner */
    private static String generateStoreOwnerReport(Map<String, Integer> plannedTestRides, Map<String, Integer> completedTestRides, 
                                                  Integer newLeads, Integer plannedFollowUps, Integer completedFollowUps) {
        return formatReportEmail(plannedTestRides, completedTestRides, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Generates a report for an ASM (aggregating data from multiple stores) */
    private static String generateASMReport(Map<String, Integer> plannedTestRides, Map<String, Integer> completedTestRides, 
                                            Integer newLeads, Integer plannedFollowUps, Integer completedFollowUps) {
        return formatReportEmail(plannedTestRides, completedTestRides, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Generates the overall HQ report */
    private static String generateHQReport(Map<String, Integer> plannedTestRides, Map<String, Integer> completedTestRides, 
                                          Integer newLeads, Integer plannedFollowUps, Integer completedFollowUps) {
        return formatReportEmail(plannedTestRides, completedTestRides, newLeads, plannedFollowUps, completedFollowUps);
    }

    /** Prepares an email object */
    private static Messaging.SingleEmailMessage prepareEmail(String recipientEmail, String subject, String htmlBody) {
        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.Label.OrgWideEmailAddress LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        String personalizedBody = '<p>Hello Team</p>' + htmlBody;
        mail.setHtmlBody(personalizedBody);
        if (!orgWideEmail.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
        }
        return mail;
    }

    private static String formatReportEmail(Map<String, Integer> plannedTestRides, Map<String, Integer> completedTestRides, 
                                           Integer newLeads, Integer plannedFollowUps, Integer completedFollowUps) {
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
        
        for (String rideType : plannedTestRides.keySet()) {
            Integer planned = plannedTestRides.get(rideType);
            Integer completed = completedTestRides.containsKey(rideType) ? completedTestRides.get(rideType) : 0;
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
                '<p style="color: #3498DB; font-weight: bold;"> Thank you,<br></p></div></body></html>';
        
        return html;
    }
}