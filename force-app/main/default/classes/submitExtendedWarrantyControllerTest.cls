@IsTest
public class submitExtendedWarrantyControllerTest {
    @IsTest
    static void testsubmitExtendedWarrantyController(){
        
        EW_API_Details__c apiDetails = new EW_API_Details__c();
        apiDetails.Name='EW Integration';
        apiDetails.API_Endpoint__c = 'https://dummyendpoint.com';
        apiDetails.Token__c ='Token 12343221';
        apiDetails.API_Key__c ='12343431';
        apiDetails.Cookie__c ='PHD=1234321';
        
        insert apiDetails;
        
        Account testAccount = new Account(Name = 'Test Account',Type='Dealer',Center_Code__c='1234',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
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
        
        //updation
        String dataToPassInString = '{"dealerCode":"D123","purchaseDate":"2025-02-25","chassisNumber":"CH123","model":"ModelX","battery":"BATT001","engineNumber":"ENG456","charger":"CHG789","warrantyType":"Standard","saleOrigin":"Online"}';
        
       
        Map<String, Object> dataToPassToPayload = (Map<String, Object>) JSON.deserializeUntyped(dataToPassInString);
        
        
        String username = (String) dataToPassToPayload.get('dealerCode');
        String purchaseDateStr = (String) dataToPassToPayload.get('purchaseDate'); // Now properly assigned
        String ChassisNo = (String) dataToPassToPayload.get('chassisNumber');
        String Model = (String) dataToPassToPayload.get('model');
        String BatteryNo = (String) dataToPassToPayload.get('battery');
        String Motor = (String) dataToPassToPayload.get('engineNumber');
        String Charger = (String) dataToPassToPayload.get('charger');
        String WarrantyType = (String) dataToPassToPayload.get('warrantyType');
        String SoldFrom = (String) dataToPassToPayload.get('saleOrigin');
        
        
        Date purchaseDate;
        String formattedVehicleSaleDate;
        
        if (purchaseDateStr != null) {
            System.debug('purchaseDateStr ==> ' + purchaseDateStr);
            
           
            purchaseDate = Date.valueOf(purchaseDateStr);
            System.debug('purchaseDate ==> ' + purchaseDate);
            
           
            formattedVehicleSaleDate = DateTime.newInstance(purchaseDate.year(), purchaseDate.month(), purchaseDate.day(), 0, 0, 0).format('dd-MM-yyyy');
            System.debug('formattedVehicleSaleDate ==> ' + formattedVehicleSaleDate);
        } else {
            System.debug('purchaseDateStr is null!');
        }
        
        // Create a test vehicle
        Vehicle testVehicle = new Vehicle(
            Name = 'Test Vehicle',
            Account__c = testAccount.Id,
            AssetId = testAsset.Id,
            Dealer__c = testAccount.Id,
            VehicleDefinitionId = testVD.Id,
            VehicleIdentificationNumber = 'A2B3',
            Software_Version__c = testSV.Id,
            Charger_PC_Number__c = 'abcd',
            PDI_Status_Pass__c = true,
            EW_Submitted__c = false,
            ChassisNumber = '1234',
            EngineNumber = 'E1234',
            RR_Battery_Number__c = 'B1234',
            Purchased_Date__c = System.Today()
        );
        insert testVehicle;
        
        AssetMilestone asm = new AssetMilestone(Name = 'ASM1', MilestoneDate = Date.today().addMonths(2),  Stage = 'Active', AssetId = testAsset.Id, UsageType = 'Automotive', MilestoneType = 'PDI', VehicleId = testVehicle.Id);
        insert asm;
        
        
      
        
        // Create JSON payload similar to what LWC would send
        Map<String, Object> payload = new Map<String, Object>{
            'username' => testAccount.Center_Code__c,
                'VehicleSaleDate' => formattedVehicleSaleDate,
                'ChassisNo' => testVehicle.ChassisNumber,
                'Model' => testVehicle.Name,
                'BatteryNo' => testVehicle.RR_Battery_Number__c,
                'Motor' => testVehicle.EngineNumber,
                'Charger' => testVehicle.Charger_PC_Number__c,
                'WarrantyType' => 'Extended Warranty',
                'SoldFrom' => 'Workshop'
                };
                    System.debug('Payload==>'+JSON.serializePretty(payload));
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockForEW());
        
        String response;
        try {
            response=submitExtendedWarrantyController.callTheEWAPIQueueable(dataToPassInString, testVehicle.Id);
            System.assertEquals('SUCCESS', response, 'The API call should return SUCCESS');
        } catch (Exception e) {
            System.debug('Error during test execution: ' + e.getMessage());
            System.debug('Error Line Number==>'+e.getLineNumber());
            //System.assert(false, 'Exception occurred: ' + e.getMessage());
        }
        
        Test.stopTest();
        
    }
    public class HttpCalloutMockForEW implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            
            
            String body = req.getBody();
            Map<String, Object> requestBody = (Map<String, Object>)JSON.deserializeUntyped(body);
            
            
            
            HTTPResponse res = new HTTPResponse();
            res.setStatusCode(201);
            // res.setBody('{"Message":"Extended Warranty created."}'); 
            res.setBody('{"Policy No": "EW-02", "EW Start Date": "25-02-2025", "EW Expire Date": "18-10-2027", "Dealer Amount": "10.09", "Customer Amount": "100.09","Dealer Type": "FOFO - Sales","GST Number": "29ABGFP3442A1ZH","Dealer Name": "PARAS MOTORS", "State": "Karnataka"}');
            return res;
        }
        
    }
    
    
    @IsTest
    public static void testGetVehicleDetailsForEWForLWC() {
       
        Account testDealer = new Account(Name = 'Test Dealer', Type = 'Dealer', Center_Code__c = 'D1234');
        insert testDealer;
        
          Account testAccount = new Account(Name = 'Test Account',Type='Dealer',Center_Code__c='1234',Phone='0987654321');
        insert testAccount;
        
        Contact con = new Contact(LastName ='Dinesh',Phone = '7834878789',AccountId = testAccount.id);
        insert con;
        
        Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true,ProductCode='abcd',HSN_Code__c='abcd',Type__c='Vehicle');
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
        
        Vehicle testVehicle = new Vehicle(
            Name = 'Test Vehicle',
            AssetId = testAsset.Id,
            VehicleDefinitionId = testVD.Id,
            VehicleIdentificationNumber = 'A2B3',
            Software_Version__c = testSV.Id,
            Dealer__c = testDealer.Id,
            Purchased_Date__c = System.today(),
            ChassisNumber = 'CH1234',
            EngineNumber = 'ENG5678',
            RR_Battery_Number__c = 'BATT999',
            Charger_PC_Number__c = 'CHG1011',
            EW_Submitted__c = false
        );
        insert testVehicle;

        
        Test.startTest();
        submitExtendedWarrantyController.wrapperForEW vehicleDetails = submitExtendedWarrantyController.getVehicleDetailsForEW(testVehicle.Id);
        Test.stopTest();
        
        
    }
}