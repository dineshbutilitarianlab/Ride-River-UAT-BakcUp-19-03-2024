/**
 * @Author: Rohit Singh Bisht
 * @Description: This class handles operations related to PO Payments, including fetching and deleting payment records.
 * @used in: bulkInsertPoPayment LWC
 * @Created Date: 2024-12-12
 * @Last Modified Date: 2024-12-12
 */
public with sharing class POPaymentsController1 {

    @AuraEnabled
    public static void deletePaymentRecord(Id paymentId) {
        /*try {} catch (Exception e) {
            throw new AuraHandledException('Error deleting the payment record: ' + e.getMessage());
        }*/
            delete [SELECT Id FROM PO_Payments__c WHERE Id = :paymentId];
        
    }

    @AuraEnabled(cacheable=true)
    public static List<PO_Payments__c> getPayments() {
        // Debug log for input parameter
        System.debug('### [POPaymentsController] Fetching PO Payments for Purchase Order ID: ' + 'orderId');

        //try {
            // Query PO Payments
            List<PO_Payments__c> payments = [
                SELECT Id, Name,
                       Purchase_Order__c, 
                       Purchase_Order__r.ProductRequestNumber, 
                       Payment_reference__c, 
                       Order__c, 
                       Order__r.Name, 
                       Amount_Paid__c
                FROM PO_Payments__c
               // WHERE Order__c = :orderId
            ];

            // Debug log for the fetched payments
            System.debug('### [POPaymentsController] Fetched PO Payments: ' + payments);

            return payments;
        /*} catch (Exception e) {
            // Debug log for errors
            System.debug('### [POPaymentsController] Error fetching PO Payments: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching PO Payments: ' + e.getMessage());
        }*/
    }
}