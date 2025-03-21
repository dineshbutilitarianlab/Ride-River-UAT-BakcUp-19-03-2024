public class MissedLeadsEmailService implements Schedulable {

    public void execute(SchedulableContext SC) {
        sendMissedLeadsEmails();
    }

    public static void sendMissedLeadsEmails() {
        // Fetch leads that were created yesterday and still have status "New"
        List<Lead> missedLeads = [
            SELECT Id, Name, Company, Email, Phone, Status, Owner.Email, CreatedDate
            FROM Lead
            WHERE CreatedDate = YESTERDAY
            AND Status = 'New'
            AND IsConverted = FALSE
            ORDER BY CreatedDate ASC
        ];

        if (missedLeads.isEmpty()) {
            System.debug('No missed leads found. Email not sent.');
            return;
        }

        // Collect unique lead owners
        Set<Id> uniqueOwners = new Set<Id>();
        for (Lead lead : missedLeads) {
            if (lead.OwnerId != null) {
                uniqueOwners.add(lead.OwnerId);
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

        // Organizing missed leads by Store, ASM, and HQ
        Map<String, List<Lead>> storeLeads = new Map<String, List<Lead>>();
        Map<String, List<Lead>> asmLeads = new Map<String, List<Lead>>();
        List<Lead> hqLeads = new List<Lead>();

        for (Lead lead : missedLeads) {
            String storeEmail = lead.Owner.Email;
            String asmEmail = ownerToManagerEmail.get(lead.OwnerId);

            // Store Email Mapping
            if (storeEmail != null) {
                if (!storeLeads.containsKey(storeEmail)) {
                    storeLeads.put(storeEmail, new List<Lead>());
                }
                storeLeads.get(storeEmail).add(lead);
            }

            // ASM Email Mapping
            if (asmEmail != null) {
                if (!asmLeads.containsKey(asmEmail)) {
                    asmLeads.put(asmEmail, new List<Lead>());
                }
                asmLeads.get(asmEmail).add(lead);
            }

            // HQ receives all missed leads
            hqLeads.add(lead);
        }

        // Send Emails
        if (Label.Enable_Store_Email == 'True') {
            sendEmails(storeLeads, 'Team');
        }
        if (Label.Enable_ASM_Email == 'True') {
            sendEmails(asmLeads, 'Team');
        }
        if (Label.Enable_HQ_Email == 'True') {
            sendHQEmail(hqLeads);
        }
        // sendEmails(storeLeads, 'Team');
        // sendEmails(asmLeads, 'Team');
        // sendHQEmail(hqLeads);
    }

    private static void sendEmails(Map<String, List<Lead>> groupedLeads, String recipientType) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (String email : groupedLeads.keySet()) {
            List<Lead> leads = groupedLeads.get(email);
            if (email != null) {
                Messaging.SingleEmailMessage mail = prepareEmail(
                    email, 
                    '⚠️ Missed Lead Alert – ' + Date.today().format(),
                    formatLeadsData(leads, recipientType)
                );
                emailList.add(mail);
            }
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList); // Bulk sending in one call
        }
    }

    private static void sendHQEmail(List<Lead> hqLeads) {
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
                '⚠️ Missed Lead Alert for All Stores – ' + Date.today().format(),
                formatLeadsData(hqLeads, 'HQ')
            );
            emailList.add(mail);
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList); // Bulk sending in one call
        }
    }

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

    private static String formatLeadsData(List<Lead> leads, String recipientType) {
        String html = '<html><head><style>' +
                      'body {font-family: Arial, sans-serif; font-size: 14px;}' +
                      'table {width: 100%; border-collapse: collapse; margin-top: 10px;}' +
                      'th, td {border: 1px solid #ddd; padding: 8px; text-align: left;}' +
                      'th {background-color: #f4f4f4; font-weight: bold;}' +
                      '.header {font-size: 16px; font-weight: bold; color: #333;}' +
                      '.footer {margin-top: 20px; font-size: 12px; color: #555;}' +
                      '</style></head><body>' +
                      '<p class="header">Dear Team,</p>' +
                      '<p>🚨 These leads were created yesterday and have not been followed up yet (' + Date.today().format() + '):</p>';

        html += '<table><tr>' +
                '<th>#</th><th>Lead Name</th><th>Company</th><th>Email</th>' +
                '<th>Phone</th><th>Status</th><th>Created Date</th></tr>';

        Integer count = 1;
        for (Lead lead : leads) {
            html += '<tr><td>' + count + '</td>' +
                     '<td>' + lead.Name + '</td>' +
                     '<td>' + lead.Company + '</td>' +
                     '<td>' + lead.Email + '</td>' +
                     '<td>' + lead.Phone + '</td>' +
                     '<td>' + lead.Status + '</td>' +
                     '<td>' + lead.CreatedDate.format() + '</td></tr>';
            count++;
        }

        html += '</table>';
        html += '<p class="footer">🔹 If there are any discrepancies, please contact support.</p>' +
                '<p>📋 <b>Thank you,</b><br><b></b></p></body></html>';

        return html;
    }
}