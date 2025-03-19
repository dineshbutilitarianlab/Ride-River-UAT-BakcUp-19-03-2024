@isTest
public class WorkOrderTriggerHandlerTestClass {
    @isTest
    public static void testClass(){
        WorkOrder w = new WorkOrder(AccountId='001F400002S4zhBIAR',ContactId='003F400001k2ISdIAM',Vehicle__c='0vLF4000000LFmsMAG',Odometer_Reading__c=2345,Status='New',Pricebook2Id='01s5j00000GNKkdAAH');
        insert w;
        
        WorkOrderLineItem woli = new WorkOrderLineItem(WorkOrderId=w.Id,Status='New',Quantity=30,PricebookEntryId='01tF4000008zfjXIAQ');
        insert woli;
        
        Test.startTest();
        w.Status='Completed';
        update w;
        Test.stopTest();
    }

}