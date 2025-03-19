public class PortalUserRecordSharing {

    public static void sharePortalUserRecords() {
        // Query records owned by portal users with the specified profile
        List<Order> recordsToShare = [SELECT Id, OwnerId FROM Order WHERE Owner.Profile.Name = 'Sales Manager (Partner)'];

        // Get the Id of the System Administrator role
        Id sysAdminRoleId = [SELECT Id FROM UserRole WHERE Name = 'System Administrator' LIMIT 1].Id;

        List<OrderShare> shares = new List<OrderShare>();

        for (Order record : recordsToShare) {
            // Create a new OrderShare record
            OrderShare share = new OrderShare();

            // Set the shared record ID (Order ID)
            share.OrderId = record.Id;

            // Set the ID of the user or group with whom the record is shared
            share.UserOrGroupId = sysAdminRoleId;

            // Set the access level for the shared record ('Edit' or 'Read')
            share.OrderAccessLevel = 'Edit'; // or 'Read'

            // Set the row cause for the manual sharing ('Manual' is standard)
            share.RowCause = Schema.OrderShare.RowCause.Manual;

            // Add the OrderShare record to the list
            shares.add(share);
        }

        if (!shares.isEmpty()) {
            // Insert the list of OrderShare records
            Database.SaveResult[] results = Database.insert(shares, false);
            for (Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    // Log any errors encountered during sharing
                    System.debug('Error sharing record: ' + result.getErrors()[0].getMessage());
                }
            }
        }
    }
}