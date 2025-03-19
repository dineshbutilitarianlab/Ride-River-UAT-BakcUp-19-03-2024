/**
 * Owner        : Rohit singh Bisht
 * Created Date : 13 feb 2025
 * Purpose: This class is responsible for assigning a Lead owner based on the provided postal code. 
 *          If no matching owner is found, the Lead is assigned to a default queue.
 */
public class LeadAssignmentService {
    public static Id getLeadOwnerByPincode(String postalCode) {
        System.debug('### Starting getLeadOwnerByPincode with postalCode: ' + postalCode);

        // Check if the postal code is blank
        if (String.isBlank(postalCode)) {
            return getQueueId(); // Return the default queue ID if postal code is blank
        }

        // Retrieve the Dealer Service Center IDs associated with the provided postal code
        List<Id> accountId = new List<Id>();
        for (Pin_Code__c pin : [
            SELECT Id, Dealer_Service_Center__c 
            FROM Pin_Code__c 
            WHERE Area_Pincode__c = :postalCode
        ]) {
            accountId.add(pin.Dealer_Service_Center__c);
        }
        System.debug('### Retrieved Pincode Ids: ' + accountId);

        // If no Dealer Service Centers are found, return the default queue ID
        if (accountId.isEmpty()) {
            return getQueueId();
        }

        // Retrieve the Contact IDs associated with the Dealer Service Centers
        List<Id> contactIds = new List<Id>();
        for (Contact con : [
            SELECT Id 
            FROM Contact 
            WHERE AccountId IN :accountId
        ]) {
            contactIds.add(con.Id);
        }
        System.debug('### Retrieved Contact Ids: ' + contactIds);

        // If no Contacts are found, return the default queue ID
        if (contactIds.isEmpty()) {
            System.debug('### No Contacts found. Returning null.');
            return getQueueId();
        }

        // Retrieve the most recently logged-in active User associated with the Contacts
        List<User> assignedUsers = [
            SELECT Id 
            FROM User 
            WHERE ContactId IN :contactIds 
            AND IsActive = TRUE 
            ORDER BY LastLoginDate DESC 
            LIMIT 1
        ];
        System.debug('### Retrieved User(s): ' + assignedUsers);

        // If no active User is found, return the default queue ID
        if (assignedUsers.isEmpty()) {
            System.debug('### No active User found. Returning null.');
            return getQueueId();
        }

        // Return the ID of the assigned User
        System.debug('### Assigned User Id: ' + assignedUsers[0].Id);
        return assignedUsers[0].Id;
    }

    /**
     * This method retrieves the ID of the default queue named 'Head_Quarter'.
     *
     * @return The ID of the 'Head_Quarter' queue.
     */
    private static Id getQueueId() {
        Group queue = [
            SELECT Id 
            FROM Group 
            WHERE Name = 'Head_Quarter' 
            AND Type = 'Queue' 
            LIMIT 1
        ];
        return queue.Id;
    }
}