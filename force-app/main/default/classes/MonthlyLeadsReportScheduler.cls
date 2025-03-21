global class MonthlyLeadsReportScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        Date today = Date.today();
        DateTime monthStart = DateTime.newInstance(today.toStartOfMonth(), Time.newInstance(0, 0, 0, 0)); 
        DateTime monthEnd = DateTime.newInstance(today, Time.newInstance(23, 59, 59, 999)); 
        sendLeadsReport(monthStart, monthEnd,'Monthly Leads Report');

        DateTime startDateTime = DateTime.newInstance(today.addDays(-1), Time.newInstance(10, 0, 0, 0)); 
        DateTime endDateTime = DateTime.newInstance(today, Time.newInstance(10, 0, 0, 0)); 
        sendLeadsReport(startDateTime, endDateTime,'Today\'s Lead Report');
    }

    public static void sendLeadsReport(DateTime  firstDay, DateTime  lastDay,String reportHeading) {
        // Date firstDay = Date.today().addYears(-1).toStartOfMonth(); // Get first day of the same month from last year
        Date today = Date.today();
        
        List<Lead> leadsList = [
            SELECT Id, LeadSource, UTM_Source__c, ConvertedAccountId 
            FROM Lead
            WHERE CreatedDate >= :firstDay AND CreatedDate <= :lastDay
        ];

        Map<String, AggregateData> reportData = new Map<String, AggregateData>();

        for (Lead ld : leadsList) {
            String source = categorizeSource(ld.LeadSource, ld.UTM_Source__c);

            // if (ld.UTM_Source__c == 'Google' && (ld.LeadSource == 'Web' || ld.LeadSource == 'Google')) {
            //     source = 'Google Ads';
            // } else if ((ld.UTM_Source__c == 'Meta_FB' || ld.UTM_Source__c == 'Meta') && 
            //            (ld.LeadSource == 'Facebook' || ld.LeadSource == 'Meta Calls')) {
            //     source = 'Meta Ads';
            // } else {
            //     source = ld.LeadSource != null ? ld.LeadSource : (ld.UTM_Source__c != null ? ld.UTM_Source__c : 'Unknown');
            // }

            if (!reportData.containsKey(source)) {
                reportData.put(source, new AggregateData(source));
            }
            reportData.get(source).LeadsCount++;
        }

        List<Test_Drive__c> testDrives = [
            SELECT Lead__c, Test_Drive_Status__c, Test_Drive_Date__c, Lead__r.LeadSource ,Lead__r.UTM_Source__c
            FROM Test_Drive__c 
            WHERE Test_Drive_Status__c IN ('Scheduled', 'Reschedule', 'Completed')
            AND Test_Drive_Date__c >= :firstDay
            AND Test_Drive_Date__c <= :lastDay
        ];

        for (Test_Drive__c td : testDrives) {
            String source = categorizeSource(td.Lead__r.LeadSource, td.Lead__r.UTM_Source__c);

            if (!reportData.containsKey(source)) {
                reportData.put(source, new AggregateData(source));
            }

            AggregateData data = reportData.get(source);

            if (td.Test_Drive_Status__c == 'Scheduled' || td.Test_Drive_Status__c == 'Reschedule') {
                data.TestRideScheduled++;
            } else if (td.Test_Drive_Status__c == 'Completed') {
                data.TestRideCompleted++;
            }
        }

        List<Order> orders = [
            SELECT AccountId, Account.AccountSource,Account.Utm_Source__c, CreatedDate, Website_Order_Id__c, Status 
            FROM Order 
            WHERE CreatedDate >= :firstDay
            AND CreatedDate <= :lastDay
        ];

        for (Order order : orders) {
            String key = categorizeSource(order.Account.AccountSource, order.Account.Utm_Source__c);
            // String key = order.AccountId != null && order.Account.AccountSource != null ? 
            //              order.Account.AccountSource : 'Unknown';

            if (!reportData.containsKey(key)) {
                reportData.put(key, new AggregateData(key));
            }

            AggregateData data = reportData.get(key);

            if (order.Website_Order_Id__c != null) {
                data.Bookings++;
            }
        }

        List<Order> invoices = [
            SELECT AccountId, Account.AccountSource, Account.Utm_Source__c,LastModifiedDate, Status 
            FROM Order 
            WHERE LastModifiedDate >= :firstDay
            AND LastModifiedDate <= :lastDay
            AND Status = 'Vehicle Delivered'
        ];

        for (Order invoice : invoices) {
            String key = categorizeSource(invoice.Account.AccountSource, invoice.Account.Utm_Source__c);
         //   String key = invoice.Account.AccountSource != null ? invoice.Account.AccountSource : 'Unknown';

            if (!reportData.containsKey(key)) {
                reportData.put(key, new AggregateData(key));
            }

            AggregateData data = reportData.get(key);
            data.Invoices++;
        }


        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@rideriver.com' LIMIT 1];

        // Generate HTML Email Body
        String emailBody = '<html><body>';
        emailBody += '<h2 style="color: #0056b3;">📊 ' + reportHeading + ' (' + firstDay.format() + ' - ' + today.format() + ')</h2>';
        emailBody += '<table style="border-collapse: collapse; width: 100%;">';
        emailBody += '<tr style="background-color: #0056b3; color: #ffffff;">';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px; text-align: left;">Source</th>';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px;">Leads</th>';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px;">Test Ride Scheduled</th>';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px;">Test Ride Completed</th>';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px;">Bookings</th>';
        emailBody += '<th style="border: 1px solid #ddd; padding: 10px;">Invoices</th>';
        emailBody += '</tr>';

        for (String key : reportData.keySet()) {
            AggregateData data = reportData.get(key);
            emailBody += '<tr style="background-color: #f9f9f9;">';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px;">' + key + '</td>';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px; text-align: center;">' + data.LeadsCount + '</td>';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px; text-align: center;">' + data.TestRideScheduled + '</td>';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px; text-align: center;">' + data.TestRideCompleted + '</td>';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px; text-align: center;">' + data.Bookings + '</td>';
            emailBody += '<td style="border: 1px solid #ddd; padding: 10px; text-align: center;">' + data.Invoices + '</td>';
            emailBody += '</tr>';
        }

        emailBody += '</table>';
        emailBody += '</body></html>';

        // Send email with HTML Body
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
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

        email.setToAddresses(hqEmails); // Change to actual recipient
        email.setSubject('📢 '+reportHeading);
        email.setHtmlBody(emailBody);
        if (!orgWideEmail.isEmpty()) {
            email.setOrgWideEmailAddressId(orgWideEmail[0].Id);
            }

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
    }

    // Helper class for aggregating data
    public class AggregateData {
        public String Source;
        public Integer LeadsCount = 0;
        public Integer TestRideScheduled = 0;
        public Integer TestRideCompleted = 0;
        public Integer Bookings = 0;
        public Integer Invoices = 0;

        public AggregateData(String source) {
            this.Source = source;
        }
    }

    public static String categorizeSource(String leadSource, String utmSource) {
        Set<String> googleAdsSources = new Set<String>{'Google', 'Web'};
        
        Set<String> metaAdsSources = new Set<String>{'Facebook', 'm.facebook.com', 'Meta Calls', 'OzoneTel WhatsApp'};
    
        String source = leadSource != null ? leadSource : (utmSource != null ? utmSource : 'Unknown');
    
        if (googleAdsSources.contains(source)) {
            return 'Google Ads';
        } else if (metaAdsSources.contains(source)) {
            return 'Meta Ads';
        }
        
        return source;
    }

}