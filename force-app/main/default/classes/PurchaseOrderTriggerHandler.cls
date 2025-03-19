/**
 * **********************************************************************************************
 * Class Name: PurchaseOrderTriggerHandler
 * Author: Rohit singh bisht
 * Created On: 22 December 2024
 * Last Modified By: ROHIT SINGH BISHT
 * Description: 
 *     This class contains the logic for handling Purchase Order triggers.
 *     Includes functionality to:
 *     - Notify the warehouse for allotment when a new purchase order is created.
 *     - Send notifications for high-value purchase orders exceeding the threshold amount.
 * **********************************************************************************************
 */

public class PurchaseOrderTriggerHandler {

    // Method to notify Store Manager for high-value purchase orders
    public static void sendHighValueNotification(List<ProductRequest> purchaseOrders) {
        if (purchaseOrders == null || purchaseOrders.isEmpty()) {
            return; // Exit early if no purchase orders are provided
        }

        try {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            Set<Id> accountIds = new Set<Id>();

            // Collect Account IDs from the Purchase Orders
            for (ProductRequest po : purchaseOrders) {
                if (po.Account__c != null) {
                    accountIds.add(po.Account__c);
                }
            }

            // Query related Accounts
            Map<Id, Account> accountMap = new Map<Id, Account>([
                SELECT Id, Name, Store_Manager_Email__c, Manager_Thresold_Amount__c 
                FROM Account 
                WHERE Id IN :accountIds
            ]);

            for (ProductRequest po : purchaseOrders) {
                try {
                    if (po.Account__c != null && accountMap.containsKey(po.Account__c)) {
                        Account acc = accountMap.get(po.Account__c);

                        // Check if Total Price exceeds Manager Threshold Amount
                        if (po.Total_Price__c > acc.Manager_Thresold_Amount__c) {
                            // Prepare the email body
                            String emailBody = 
                                '<div style="font-family: Arial, sans-serif; background-color: #f9f9f9; padding: 20px;">' +
                                    '<div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">' +
                                        '<div style="background-color: #28a745; color: #ffffff; padding: 20px; text-align: center;">' +
                                            '<h1 style="margin: 0; font-size: 24px;">High-Value Purchase Order Notification</h1>' +
                                        '</div>' +
                                        '<div style="padding: 20px;">' +
                                            '<p style="font-size: 16px; margin-bottom: 10px;">Dear ' + acc.Name + ',</p>' +
                                            '<p style="font-size: 14px; margin-bottom: 20px;">We wanted to notify you that a high-value Purchase Order associated with your account. The total amount of this Purchase Order exceeds the Manager Threshold Amount of <b>' + acc.Manager_Thresold_Amount__c + '</b>. Below are the details:</p>' +
                                            '<div style="padding: 15px; background-color: #d4edda; border-radius: 5px; margin-bottom: 20px; border: 1px solid #28a745;">' +
                                                '<h3 style="margin: 0; font-size: 18px; color: #28a745;">Purchase Order Details</h3>' +
                                                '<p style="margin: 5px 0; font-size: 14px;">PO Number: <b>' + po.ProductRequestNumber + '</b></p>' +
                                                '<p style="margin: 5px 0; font-size: 14px;">Total Price: <b>' + po.Total_Price__c + '</b></p>' +
                                            '</div>' +
                                            '<p style="font-size: 14px; margin-bottom: 20px;">You can view the approved Purchase Order details using the link below:</p>' +
                                            '<div style="text-align: center; margin-bottom: 20px;">' +
                                                '<a href="https://your-org.lightning.force.com/lightning/r/ProductRequest/' + po.Id + '/view" style="display: inline-block; background-color: #28a745; color: #ffffff; text-decoration: none; padding: 10px 20px; border-radius: 5px; font-size: 16px;">View Purchase Order</a>' +
                                            '</div>' +
                                        '</div>' +
                                        '<div style="background-color: #f9f9f9; padding: 10px; text-align: center; color: #555555; font-size: 12px;">' +
                                            '<p style="margin: 0;">Thank you for your order.</p>' +
                                            '<p style="margin: 0;">Ride River</p>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>';

                            // Create and add the email to the list
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(new String[] { acc.Store_Manager_Email__c });
                            mail.setSubject('High-Value Purchase Order Notification');
                            mail.setHtmlBody(emailBody);
                            emails.add(mail);
                        }
                    }
                } catch (Exception innerEx) {
                    System.debug('Error while preparing high-value notification for Purchase Order ID: ' + po.Id + ' - ' + innerEx.getMessage());
                }
            }

            // Send emails
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }

        } catch (Exception ex) {
            System.debug('Error in sendHighValueNotification: ' + ex.getMessage());
        }
    }
}