@IsTest
public class QueueableOnOrderCreationAfterBookingTest {
    @IsTest
    public static void testQueueableOnOrderCreationAfterBooking(){
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key'
        );
        insert mockIntegration;
        
        Account testAccount = new Account(Name = 'Test Account',Type='Customer',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle',Colour__c='Black');
        insert testProduct;
        
        Id stdPrBk = Test.getStandardPricebookId();
        PricebookEntry testPricebookEntry = new PricebookEntry(
            Product2Id = testProduct.Id,
            Pricebook2Id = stdPrBk,
            UnitPrice = 100.0,	
            IsActive = true
        );
        insert testPricebookEntry;
        
        Asset testAsset = new Asset(Name='Test Asset',AccountId=testAccount.Id,	Product2Id=testProduct.Id);
        insert testAsset;
        
        VehicleDefinition testVD = new VehicleDefinition(Name='Test VehicleDefinition',ProductId=testProduct.Id);
        insert testVD;
        
        Software_Version__c testSV = new Software_Version__c(Name='Test Software Version');
        insert testSV;
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true);
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Completed', Contact__c = con.id,Booking_Form_File_URL__c='test.pdf',Website_Order_Id__c='TestABC!@#');
        insert oldOrder;
        
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0, Quantity = 1, PricebookEntryId = testPricebookEntry.Id,Type__c='Vehicle');
        insert testOrderItem;
        
        Order_Invoice__c o = new Order_Invoice__c (Invoice_Type__c='Vehicle Invoice',Order__c=oldOrder.Id,Name='test',Invoice_Number__c='ab1cd2');
        insert o;
        
        Payment__c p = new Payment__c(Mode_Of_Payment__c='UPI',Payment_Status__c='Success',Source_Of_Payment__c='Website',Transaction_Id__c='test21234');
        insert p;
        
        Order_Payment__c op = new Order_Payment__c(Order__c=oldOrder.Id,Payments__c=p.Id,Type__c='Booking Amount');
        insert op;
        
        List<Id> orderIdsToProcess = new List<Id>{oldOrder.Id};
        OrderTriggerHandler.wrapperForBooking testWrapper = new OrderTriggerHandler.wrapperForBooking();
        testWrapper.phoneNumber = '0987654321';
        testWrapper.bookingId='rt1324';
        testWrapper.color='Black';
        testWrapper.fileName = 'dummy';
        testWrapper.pdfLink = 'dummy.pdf';
        
        Map<Id, OrderTriggerHandler.wrapperForBooking> toPassToQueueable = new Map<Id, OrderTriggerHandler.wrapperForBooking>();
        toPassToQueueable.put(oldOrder.Id, testWrapper);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl());    
        
        Test.startTest();
        
        QueueableOnOrderCreationAfterBooking queueableJob = new QueueableOnOrderCreationAfterBooking(orderIdsToProcess,toPassToQueueable);
        System.enqueueJob(queueableJob);
        
        Test.stopTest();
        
    }
     private static void insertMockWhatsappIntegration() {
        WhatsappIntegration__c mockIntegration = new WhatsappIntegration__c(
            Name = 'WhatsApp API',
            API_Endpoint__c = 'https://api.whatsapp.com/send',
            API_Key__c = 'mock-api-key'
        );
        insert mockIntegration;
    }
    
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(200);
            res.setBody('{"status":"success"}'); // Simulate a successful API response
            return res;
        }
    }

}