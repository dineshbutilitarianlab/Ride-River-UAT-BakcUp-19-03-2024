public class FollowUpEmailService implements Schedulable {

    public void execute(SchedulableContext SC) {
        sendFollowUpEmails();
    }

    public static void sendFollowUpEmails() {
        // Define the start and end of yesterday
        DateTime startOfYesterday = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(0, 0, 0, 0)); // 12:00 AM yesterday
        DateTime endOfYesterday = DateTime.newInstance(Date.today().addDays(-1), Time.newInstance(23, 59, 59, 999)); // 11:59:59.999 PM yesterday

        // Fetch yesterday's missed follow-ups
        List<Follow_Up__c> followUps = [
            SELECT Id, Due_Date__c, Lead__c, Lead__r.Name, Lead__r.Phone, Status__c, 
                   Subject__c, Lead__r.Lead_Age__c, Follow_Up_Date__c, 
                   Previous_Followup_date__c, Previous_Feedback__c, Feedback__c, 
                   Lead__r.Owner.Email
            FROM Follow_Up__c 
            WHERE Lead__r.IsConverted = false
            AND Lead__r.Status IN ('RNR', 'Follow Up', 'Ready For booking')
            AND Follow_Up_Date__c >= :startOfYesterday AND Follow_Up_Date__c <= :endOfYesterday
            AND Status__c != 'Completed' 
            ORDER BY CreatedDate DESC
        ];

        if (followUps.isEmpty()) {
            System.debug('No missed follow-ups from yesterday. Email not sent.');
            return;
        }

        // Collect unique lead owners
        Set<Id> uniqueOwners = new Set<Id>();
        for (Follow_Up__c fu : followUps) {
            if (fu.Lead__r.OwnerId != null) {
                uniqueOwners.add(fu.Lead__r.OwnerId);
            }
        }

        // Fetch ASMs for these Owners
        Map<Id, String> ownerToManagerEmail = new Map<Id, String>();
        List<User> ownersWithManagers = [
            SELECT Id, Manager.Email 
            FROM User 
            WHERE Id IN :uniqueOwners AND Manager.Email != null
        ];

        for (User owner : ownersWithManagers) {
            ownerToManagerEmail.put(owner.Id, owner.Manager.Email);
        }

        // Organizing follow-ups by Store, ASM, and HQ
        Map<String, List<Follow_Up__c>> storeFollowUps = new Map<String, List<Follow_Up__c>>();
        Map<String, List<Follow_Up__c>> asmFollowUps = new Map<String, List<Follow_Up__c>>();
        List<Follow_Up__c> hqFollowUps = new List<Follow_Up__c>();

        for (Follow_Up__c fu : followUps) {
            String storeEmail = fu.Lead__r.Owner.Email;
            String asmEmail = ownerToManagerEmail.get(fu.Lead__r.OwnerId);

            // Store Email Mapping
            if (storeEmail != null) {
                if (!storeFollowUps.containsKey(storeEmail)) {
                    storeFollowUps.put(storeEmail, new List<Follow_Up__c>());
                }
                storeFollowUps.get(storeEmail).add(fu);
            }

            // ASM Email Mapping
            if (asmEmail != null) {
                if (!asmFollowUps.containsKey(asmEmail)) {
                    asmFollowUps.put(asmEmail, new List<Follow_Up__c>());
                }
                asmFollowUps.get(asmEmail).add(fu);
            }

            // HQ receives all follow-ups
            hqFollowUps.add(fu);
        }

        // Send Emails in Bulk
        if (Label.Enable_Store_Email == 'True') {
            sendEmails(storeFollowUps, 'Team');
        }
        if (Label.Enable_ASM_Email == 'True') {
            sendEmails(asmFollowUps, 'Team');
        }
        if (Label.Enable_HQ_Email == 'True') {
            sendHQEmail(hqFollowUps);
        }
        // sendEmails(storeFollowUps, 'Team');
        // sendEmails(asmFollowUps, 'Team');
        // sendHQEmail(hqFollowUps);
    }

    /** Sends emails for Stores & ASMs */
    private static void sendEmails(Map<String, List<Follow_Up__c>> groupedFollowUps, String recipientType) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (String email : groupedFollowUps.keySet()) {
            List<Follow_Up__c> missedFollowUps = groupedFollowUps.get(email);
            if (email != null) {
                Messaging.SingleEmailMessage mail = prepareEmail(
                    email, 
                    '🔔 Missed Follow-Ups from Yesterday – ' + Date.today().format(),
                    formatFollowUpData(missedFollowUps, recipientType)
                );
                emailList.add(mail);
            }
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList); // Bulk sending in one call
        }
    }

    /** Sends HQ email with all follow-ups */
    private static void sendHQEmail(List<Follow_Up__c> hqFollowUps) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
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

        for (String email : hqEmails) {
            Messaging.SingleEmailMessage mail = prepareEmail(
                email, 
                '🔔 Missed Follow-Ups from Yesterday for All Stores – ' + Date.today().format(),
                formatFollowUpData(hqFollowUps, 'Team')
            );
            emailList.add(mail);
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList); // Bulk sending in one call
        }
    }

    /** Prepares an email message */
    private static Messaging.SingleEmailMessage prepareEmail(String recipientEmail, String subject, String htmlBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);

        // Set Org-Wide Email Address
        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :System.Label.OrgWideEmailAddress LIMIT 1];
        if (!orgWideEmail.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
        }

        return mail;
    }

    /** Generates an HTML table for missed follow-ups */
    private static String formatFollowUpData(List<Follow_Up__c> followUps, String recipientType) {
        String html = '<html><head><style>' +
                      'body {font-family: Arial, sans-serif; font-size: 14px;}' +
                      'table {width: 100%; border-collapse: collapse; margin-top: 10px;}' +
                      'th, td {border: 1px solid #ddd; padding: 8px; text-align: left;}' +
                      'th {background-color: #f4f4f4; font-weight: bold;}' +
                      '</style></head><body>' +
                      '<p>Hello ' + recipientType + ',</p>' +
                      '<p>Below is the list of follow-ups missed yesterday (' + Date.today().addDays(-1).format() + '):</p>';

        html += '<table><tr>' +
                '<th>#</th><th>Lead Name</th><th>Phone</th><th>Follow-Up Date</th>' +
                '<th>Previous Follow-Up</th><th>Previous Feedback</th><th>Current Feedback</th></tr>';

        Integer count = 1;
        for (Follow_Up__c fu : followUps) {
            html += '<tr><td>' + count + '</td>' +
                    '<td>' + fu.Lead__r.Name + '</td>' +
                    '<td>' + fu.Lead__r.Phone + '</td>' +
                    '<td>' + fu.Follow_Up_Date__c + '</td>' +
                    '<td>' + fu.Previous_Followup_date__c + '</td>' +
                    '<td>' + fu.Previous_Feedback__c + '</td>' +
                    '<td>' + fu.Feedback__c + '</td></tr>';
            count++;
        }

        html += '</table>' +
                '<p>🔹 Please review and take necessary actions.</p>' +
                '<p>📌 <b>Thank you,</b><br><b></b></p></body></html>';

        return html;
    }
}