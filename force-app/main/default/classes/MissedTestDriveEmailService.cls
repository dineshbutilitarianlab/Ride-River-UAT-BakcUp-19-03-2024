public class MissedTestDriveEmailService implements Schedulable {

    public void execute(SchedulableContext SC) {
        sendMissedTestDriveEmails();
    }

    public static void sendMissedTestDriveEmails() {
        Date yesterday = Date.today().addDays(-1);
        DateTime yesterdayStart = DateTime.newInstance(yesterday, Time.newInstance(0, 0, 0, 0));
        DateTime yesterdayEnd = DateTime.newInstance(yesterday, Time.newInstance(23, 59, 59, 999));

        // Fetch yesterday's missed Home Ride and Store Ride test drives
        List<Test_Drive__c> testDrives = [ 
            SELECT Id, Name, MobilePhone__c, Lead__c, Lead__r.Name, Test_Ride_Date__c, 
                   Ride_Type__c, Phone__c, Test_Drive_Status__c, Lead__r.Owner.Email
            FROM Test_Drive__c 
            WHERE Lead__r.isConverted = false 
            AND Lead__r.Status = 'Test Ride' 
            AND Test_Ride_Date__c >= :yesterdayStart AND Test_Ride_Date__c <= :yesterdayEnd
            AND Ride_Type__c IN ('Home Ride', 'Store Ride') 
            AND Test_Drive_Status__c != 'Completed' 
            ORDER BY Test_Ride_Date__c ASC
        ];

        if (testDrives.isEmpty()) {
            System.debug('No missed test drives from yesterday. Email not sent.');
            return;
        }

        // Collect unique lead owners
        Set<Id> uniqueOwners = new Set<Id>();
        for (Test_Drive__c td : testDrives) {
            if (td.Lead__r.OwnerId != null) {
                uniqueOwners.add(td.Lead__r.OwnerId);
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

        // Organizing test drives by Store, ASM, and HQ
        Map<String, List<Test_Drive__c>> storeTestDrives = new Map<String, List<Test_Drive__c>>();
        Map<String, List<Test_Drive__c>> asmTestDrives = new Map<String, List<Test_Drive__c>>();
        List<Test_Drive__c> hqTestDrives = new List<Test_Drive__c>();

        for (Test_Drive__c td : testDrives) {
            String storeEmail = td.Lead__r.Owner.Email;
            String asmEmail = ownerToManagerEmail.get(td.Lead__r.OwnerId);

            // Store Email Mapping
            if (storeEmail != null) {
                if (!storeTestDrives.containsKey(storeEmail)) {
                    storeTestDrives.put(storeEmail, new List<Test_Drive__c>());
                }
                storeTestDrives.get(storeEmail).add(td);
            }

            // ASM Email Mapping
            if (asmEmail != null) {
                if (!asmTestDrives.containsKey(asmEmail)) {
                    asmTestDrives.put(asmEmail, new List<Test_Drive__c>());
                }
                asmTestDrives.get(asmEmail).add(td);
            }

            // HQ receives all missed test drives
            hqTestDrives.add(td);
        }

        // Send Emails in Bulk
        sendEmails(storeTestDrives, 'Team');
        sendEmails(asmTestDrives, 'Team');
        sendHQEmail(hqTestDrives);
    }

    /** Sends emails for Stores & ASMs */
    private static void sendEmails(Map<String, List<Test_Drive__c>> groupedTestDrives, String recipientType) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        for (String email : groupedTestDrives.keySet()) {
            List<Test_Drive__c> testRides = groupedTestDrives.get(email);
            if (email != null) {
                Messaging.SingleEmailMessage mail = prepareEmail(
                    email, 
                    '🚗 Yesterday’s Missed Test Ride List – ' + Date.today().format(),
                    formatTestRideData(testRides, recipientType)
                );
                emailList.add(mail);
            }
        }

        if (!emailList.isEmpty()) {
            Messaging.sendEmail(emailList); // Bulk sending in one call
        }
    }

    /** Sends HQ email with all missed test drives */
    private static void sendHQEmail(List<Test_Drive__c> hqTestDrives) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<String> hqEmails = new List<String>{'rohit.bisht@utilitarianlabs.com'}; 

        for (String email : hqEmails) {
            Messaging.SingleEmailMessage mail = prepareEmail(
                email, 
                '🚗 Yesterday’s Missed Test Ride List for All Stores – ' + Date.today().format(),
                formatTestRideData(hqTestDrives, 'Team')
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
        OrgWideEmailAddress[] orgWideEmail = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'support@rideriver.com' LIMIT 1];
        if (!orgWideEmail.isEmpty()) {
            mail.setOrgWideEmailAddressId(orgWideEmail[0].Id);
        }

        return mail;
    }

    /** Generates an HTML table for missed Home Ride and Store Ride test drives */
    private static String formatTestRideData(List<Test_Drive__c> testDrives, String recipientType) {
        String html = '<html><head><style>' +
                      'body {font-family: Arial, sans-serif; font-size: 14px;}' +
                      'table {width: 100%; border-collapse: collapse; margin-top: 10px;}' +
                      'th, td {border: 1px solid #ddd; padding: 8px; text-align: left;}' +
                      'th {background-color: #f4f4f4; font-weight: bold;}' +
                      '</style></head><body>' +
                      '<p>Hello ' + recipientType + ',</p>' +
                      '<p>Below is the list of missed test rides from yesterday (' + Date.today().addDays(-1).format() + '):</p>';

        html += '<table><tr>' +
                '<th>#</th><th>Lead Name</th><th>Contact Person</th>' +
                '<th>Ride Type</th><th>Test Ride Date</th><th>Status</th></tr>';

        Integer count = 1;
        for (Test_Drive__c td : testDrives) {
            html += '<tr><td>' + count + '</td>' +
                    '<td>' + td.Lead__r.Name + '</td>' +
                    '<td>' + td.MobilePhone__c + '</td>' +
                    '<td>' + td.Ride_Type__c + '</td>' +
                    '<td>' + td.Test_Ride_Date__c + '</td>' +
                    '<td>' + td.Test_Drive_Status__c + '</td></tr>';
            count++;
        }

        html += '</table>' +
                '<p>🔹 Please follow up accordingly.</p>' +
                '<p>🚘 <b>Thank you,</b><br><b></b></p></body></html>';

        return html;
    }
}