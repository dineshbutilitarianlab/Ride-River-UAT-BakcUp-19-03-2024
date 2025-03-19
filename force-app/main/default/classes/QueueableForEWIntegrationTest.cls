@IsTest
public class QueueableForEWIntegrationTest {
    @IsTest
    static void testQueueableForEWIntegration(){
        EW_API_Details__c apiDetails = new EW_API_Details__c();
        apiDetails.Name='EW Integration';
        apiDetails.API_Endpoint__c='https://mock.com';
        apiDetails.API_Key__c='oiuytrewq';
        apiDetails.Cookie__c='PHD=t1432';    
        insert apiDetails;
        
        Account testAccount = new Account(Name = 'Test Account',Type='Customer',Phone='0987654321',Center_Code__c='292001');
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
        
        Vehicle testVehicle = new Vehicle(Name='Test Vehicle', Account__c=testAccount.Id, AssetId=testAsset.Id,  VehicleDefinitionId=testVD.Id, VehicleIdentificationNumber='A2B3',  Software_Version__c=testSV.Id, Charger_PC_Number__c='abcd',PDI_Status_Pass__c=true,Purchased_Date__c = System.Today(),ChassisNumber='5342',RR_Battery_Number__c='B123',EngineNumber='E321');
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        Order oldOrder = new Order( AccountId = testAccount.Id, Status__c = 'Processing',Status='Processing',Assigned_Vehicle__c = testVehicle.Id,EffectiveDate = Date.today(),Pricebook2Id = stdPrBk,Payment_Status__c = 'Completed', Contact__c = con.id,Booking_Form_File_URL__c='test.pdf',Website_Order_Id__c='TestABC!@#',Allotment_In_Process_File_URL__c='testInvoice.pdf');
        insert oldOrder;
       
        OrderItem testOrderItem = new OrderItem( OrderId = oldOrder.Id, Product2Id = testProduct.Id, UnitPrice = 100.0, Quantity = 1, PricebookEntryId = testPricebookEntry.Id,Type__c='Vehicle');
        insert testOrderItem;
        
        Order_Invoice__c o = new Order_Invoice__c (Invoice_Type__c='Vehicle Invoice',Order__c=oldOrder.Id,Name='test',Invoice_Number__c='ab1cd2');
        insert o;
        
        List<Id> orderIds = new List<Id>{oldOrder.Id};
         OrderTriggerHandler.wrapperForEWIntegration ww = new OrderTriggerHandler.wrapperForEWIntegration();
                            ww.vehicleId = testVehicle.Id;
                            ww.dealerCode = testAccount.Center_Code__c;
                            ww.purchaseDate = testVehicle.Purchased_Date__c;
                            ww.chassisNumber = testVehicle.ChassisNumber;
                            ww.model = testVehicle.Name;
                            ww.battery = testVehicle.RR_Battery_Number__c;
                            ww.engineNumber = testVehicle.EngineNumber;
                            ww.charger = testVehicle.Charger_PC_Number__c;
        Map<Id,OrderTriggerHandler.wrapperForEWIntegration> wrapperValues = new Map<Id,OrderTriggerHandler.wrapperForEWIntegration>();
        wrapperValues.put(oldOrder.Id,ww);
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImplEW());  

         Test.startTest();
        
        QueueableForEWIntegration queueableJob = new QueueableForEWIntegration(orderIds,wrapperValues);
        System.enqueueJob(queueableJob);
        
        Test.stopTest();        
        
    }
    public class HttpCalloutMockImplEW implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(201);
            res.setBody('{"Message":"Extended Warranty created.","Policy No":"EW050","ChassisNo":"1234567890123121","EW Start Date":"26-07-2027","EW Expire Date":"25-07-2029","Dealer Amount":"4623","Customer Amount":"7079","Warranty Type":"Extended Warranty","Dealer Type":"FOFO - Sales","GST Number":"29AAMCB5945L1ZY","Dealer Name":"BALAJI ELECTRIC VEHICLES PRIVATE LIMITED - Yelahanka","State":"Karnataka"}'); 
            return res;
        }
    }

}