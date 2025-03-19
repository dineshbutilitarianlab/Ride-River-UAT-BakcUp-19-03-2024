/**
 * @description       : 
 * @author            : Aniket Karmakar
 * @group             : 
 * @last modified on  : 03-03-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class IntegrationLogHelper {
    public static void createIntegrationLogs(integrationLogWrapper wrapper){
        System.debug('log Method was Called');
         try{
            Integration_Log__c i = new Integration_Log__c();
            i.Request_Payload__c = wrapper.requestBody != null ? wrapper.requestBody : '';
            i.Response_Payload__c = wrapper.responseBody != null ? wrapper.responseBody : '';
            i.Status__c = wrapper.status != null ? wrapper.status : '';
            i.Template_Name__c=wrapper.templateName != null ? wrapper.templateName : '';
            i.Status_Code__c = wrapper.statusCode != null ? String.valueOf(wrapper.statusCode) : '';
            i.Integration_Type__c='Ozontel WhatsApp';
            i.Template_Type__c = wrapper.templateName == 'new_lead_book_a_test_ride_03' ? 'New Lead' :wrapper.templateName == 'no_action_book_test_ride_03' ? 'Lead Age 2 Days' :
            wrapper.templateName == 'rnr_whatsapp_book_test_ride' ? 'RNR Stage' :wrapper.templateName == 'test_ride_booked_text2' ? 'Test Ride Scheduled' :
            wrapper.templateName == 'on_day_of_test_ride2' ? 'On Test Ride Day' : wrapper.templateName == 'test_ride_not_taken2' ? 'Test Ride Cancelled' :
            (wrapper.templateName == 'home_test_ride_done_with_form1' || wrapper.templateName == 'store_test_ride_done_with_form1') ? 'Test Ride Completed' :
            wrapper.templateName == 'test_ride_taken_indie_not_booked_followup1' ? 'Lead Unresponsive 4 Days' :
            wrapper.templateName == 'lead_unresponsive_test_ride_done_booking_not_done' ? 'Lead Unresponsive 7 Days' : wrapper.templateName == 'booking_done_with_receipt1' ? 'Order Creation' :
            wrapper.templateName == 'full_payment_done1' ? 'Allotment in Process(Order)' :wrapper.templateName == 'rto_with_invoice' ? 'RTO Stage(Order)' :
            wrapper.templateName == 'ready_for_delivery' ? 'Ready For Delivery(Order)' : wrapper.templateName == 'indie_deliverd_with_feedback_form' ? 'Vehicle Delivered(Order)' :
            wrapper.templateName == 'order_cancelled' ? 'Order Cancelled' : '';
            
            insert i;
            System.debug('Inserted Log===>'+i);

         }
         catch(Exception e){
            System.debug('Error Occured==>'+e.getMessage());
            System.debug('Error Line Number ==>'+e.getLineNumber());
            throw e;
         }
    }

    public class IntegrationLogWrapper {
        public String requestBody;
        public String responseBody;
        public String status;
        public String templateName;
        public String statusCode;
    }
}