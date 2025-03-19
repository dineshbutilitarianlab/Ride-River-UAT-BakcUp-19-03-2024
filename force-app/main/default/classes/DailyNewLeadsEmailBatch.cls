global class DailyNewLeadsEmailBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Map<String, List<Lead>> groupedLeads;
    private String recipientType;
    
    // Constructor to initialize the batch
    public DailyNewLeadsEmailBatch(Map<String, List<Lead>> groupedLeads, String recipientType) {
        this.groupedLeads = groupedLeads;
        this.recipientType = recipientType;
    }

    // Start method to query Lead records for processing
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Name, Company, Email, Phone, Status, Owner.Email, CreatedDate FROM Lead WHERE IsConverted = FALSE AND Status = \'New\' ORDER BY CreatedDate ASC'
        );
    }

    // Execute method to process each batch
    global void execute(Database.BatchableContext BC, List<SObject> leadRecords) {
        for (SObject obj : leadRecords) {
            Lead lead = (Lead) obj; // Cast SObject to Lead
            String email = lead.Owner.Email;

            if (email != null && groupedLeads.containsKey(email)) {
                sendEmail(email, '📋 Today’s New Lead List – ' + Date.today().format(),
                          formatLeadsData(groupedLeads.get(email), recipientType));
            }
        }
    }

    // Finish method for post-processing (optional)
    global void finish(Database.BatchableContext BC) {
        System.debug('Email sending batch completed.');
    }

    // Helper method to send email
    private static void sendEmail(String recipientEmail, String subject, String htmlBody) {
        try {
            OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@rideriver.com' LIMIT 1];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{recipientEmail});
            mail.setSubject(subject);
            mail.setHtmlBody(htmlBody);
            if (!orgWideEmail.isEmpty()) {
                mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        } catch (Exception e) {
            System.debug('Error sending email to ' + recipientEmail + ': ' + e.getMessage());
        }
    }

    // Helper method to format leads data into HTML
    private static String formatLeadsData(List<Lead> leads, String recipientType) {
        String html = '<html><head><style>' +
                      'body {font-family: Arial, sans-serif; font-size: 14px;}' +
                      'table {width: 100%; border-collapse: collapse; margin-top: 10px;}' +
                      'th, td {border: 1px solid #ddd; padding: 8px; text-align: left;}' +
                      'th {background-color: #f4f4f4; font-weight: bold;}' +
                      '.header {font-size: 16px; font-weight: bold; color: #333;}' +
                      '.footer {margin-top: 20px; font-size: 12px; color: #555;}' +
                      '</style></head><body>' +
                      '<p class="header">Hello ' + recipientType + ',</p>' +
                      '<p>Here is the list of new leads created today (' + Date.today().format() + '):</p>';

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