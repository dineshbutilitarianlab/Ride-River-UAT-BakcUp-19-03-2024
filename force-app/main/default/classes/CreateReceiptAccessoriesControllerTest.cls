@isTest
public class CreateReceiptAccessoriesControllerTest {

    @isTest
    static void testController() {
        
       Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        
        Account dealerAccount = new Account(Name = 'Test Name',Type = 'Dealer',Phone='9011113286', Email__c = 'dealer@test.com' );
        dealerAccount.Account_Number__c = '47723745723457';
        dealerAccount.Bank_Name__c = 'Canara';
        dealerAccount.Center_Code__c = 'BR';
        dealerAccount.Invoice_Sequence__c = 0;
        insert dealerAccount;
        
        Order__c invcount = new Order__c(InvoiceNumber__c=1, name='testCount');
        insert invcount;
        
        mapnewRecords = TestDataFactory.CreateOrder();
        system.debug(JSON.serializePretty(mapnewRecords));
        
        Order order = (Order)mapnewRecords.get('OrderId');
        order.Dealer__c = dealerAccount.Id;
        
        Update order;
        
        Test.startTest();
        
		// Create a PageReference for the controller
        PageReference pageRef = Page.CreateReceiptVehicle;
        Test.setCurrentPage(pageRef);

		pageRef.getParameters().put('id', order.Id);

        ApexPages.StandardController stdController = new ApexPages.StandardController(order);

        CreateReceiptAccessoriesController controller = new CreateReceiptAccessoriesController(stdController);

        System.assertEquals(order.Id, controller.order.Id);

        Test.stopTest();
    }
}