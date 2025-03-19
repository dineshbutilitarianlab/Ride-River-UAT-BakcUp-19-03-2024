@IsTest
public class PineLabsPaymentHelperTest {
    
    
    @testSetup
    static void setup() {
        // Insert a list custom setting record
        PineLabs_API_Config__c settingRecord = new PineLabs_API_Config__c(
            Name = 'TestSetting',
            Cancel_Txn_Endpoint_URL__c = 'https://www.plutuscloudserviceuat.in:8201/API/CloudBasedIntegration/V1/CancelTransaction'
        );
        insert settingRecord;
    }
    
    @IsTest
    public static void PineLabsPaymentHelperTestInfo(){
        List<Order> ordlist = new List<Order>(); 
        Account Acc = new Account();
        Acc.Name = 'test';
        Acc.Phone='1234567890';
        Acc.Email__c='test@gmail.com';
        Acc.Type='Partner';
        insert Acc;
        
        Account dealer = new Account();
        dealer.Name = 'dealer';
        dealer.Type='Dealer';
        dealer.Phone='0987654321';
        dealer.Email__c='test@gmail.com';
        
        insert dealer;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = Acc.Id;
        con.Phone = '0000000000';
        insert con;
        Asset a = new Asset();
        a.Name = 'Test';
        a.ContactId = con.Id;
        a.AccountId = Acc.Id;
        insert a;
        Product2 p = new Product2();
        p.ProductCode = 'testpro';
        p.Name = 'test';
        // p.Name = 'Road Side Assistance';
        p.Type__c = 'Accessories';
        p.HSN_Code__c = '00000000';
        insert p; 
        // Query Standard Pricebook
        VehicleDefinition vd = new VehicleDefinition();
        vd.Name = 'VehicleDefinitiontest';
        vd.ProductId = p.Id;
        insert vd;
        Software_Version__c sv = new Software_Version__c();
        insert sv;
        
        Vehicle v = new Vehicle();
        v.Name = 'test';
        v.VehicleIdentificationNumber = 'Test00001223';
        v.VehicleDefinitionId = vd.Id;
        v.Charger_PC_Number__c = '000000000';
        v.Software_Version__c = sv.Id;
        v.PDI_Status_Pass__c = true;
        v.AssetId = a.Id;
        v.CurrentOwnerId = Acc.Id; 
        v.RSA_Activation__c = false; 
        insert v;
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'test';
        insert pb; 
        
        Order o = new Order();
        o.Pricebook2Id = pb.Id;  
        o.Dealer__c = dealer.Id;
        o.AccountId = Acc.Id;
        o.Payment_Status__c = 'Pending';
        o.Status = 'Activated';
        o.EffectiveDate = Date.today();
        o.Assigned_Vehicle__c = v.Id;
        insert o; 
        
        Pinelabs_Machine_Info__c testMachineInfo = new Pinelabs_Machine_Info__c(
            
            Device_No__c = '12345',
            Bank__c = 'Test Bank'
        );
        insert testMachineInfo;
        
        Test.startTest();
        List<Pinelabs_Machine_Info__c> result = PineLabsPaymentHelper.getPinelabsMachineInfo(o.Id);
        List<Pinelabs_Machine_Info__c> result1 = PineLabsPaymentHelper.getPinelabsMachineInfo(UserInfo.getUserId());
        Test.stopTest();
    }
    
    @IsTest
    public static void testSavePaymentLogs() {
        Account dealer = new Account(Name = 'Test Dealer', Type='Dealer');
        insert dealer;
        
        Order o = new Order(Dealer__c = dealer.Id,AccountId=dealer.Id, Payment_Status__c = 'Pending', Status = 'Activated', EffectiveDate = Date.today());
        insert o;
        
        Pinelabs_Machine_Info__c testMachineInfo = new Pinelabs_Machine_Info__c(Device_No__c = '12345', Bank__c = 'Test Bank');
        insert testMachineInfo;
        
        List<Map<String, Object>> paymentSplits = new List<Map<String, Object>>{
            new Map<String, Object>{'Order__c' => o.Id, 'Payment_Mode__c' => 'Card', 'Pay_Amount__c' => '100.00', 'Remark__c' => 'Test payment', 'Transaction_Id__c' => 'TX1234'}
        };
            
            Test.startTest();
        PineLabsPaymentHelper.savePaymentLogs(paymentSplits, o.Id, testMachineInfo.Id);
        Test.stopTest();
    }
    
    @IsTest 
    public static void testUpdateTransactionDetailOnLogPayment() {
        
        Account dealer = new Account(Name = 'Test Dealer', Type='Dealer');
        insert dealer;
        
        Order o = new Order(Dealer__c = dealer.Id,AccountId=dealer.Id, Payment_Status__c = 'Pending', Status = 'Activated', EffectiveDate = Date.today());
        insert o;
        
        Pinelabs_Machine_Info__c testMachineInfo = new Pinelabs_Machine_Info__c(Device_No__c = '12345', Bank__c = 'Test Bank');
        insert testMachineInfo;
        
        Payment_Split__c paymentSplit = new Payment_Split__c(Order__c = o.Id, Payment_Mode__c = 'Card', Pay_Amount__c = 100.00, Status__c = 'Initiated', Pinelabs_Machine_Info__c = testMachineInfo.Id);
        insert paymentSplit;
        
        Map<String, String> responseMap = new Map<String, String>{
            'RRN' => '1234567890',
                'Acquirer Name' => 'Test Acquirer',
                'ApprovalCode' => '00',
                'Transaction Date' => '01012025',
                'Transaction Time' => '123045',
                'TransactionLogId' => 'TX1234',
                'MID' => 'MID1234',
                'TID' => 'MID1234'
                };
                    
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPineLabs(responseMap));
        PineLabsPaymentHelper.UpdateTransCationDetailOnLogPayment(paymentSplit.Id, responseMap.get('RRN'), responseMap.get('Acquirer Name'), responseMap.get('ApprovalCode'), responseMap.get('Transaction Date'), responseMap.get('Transaction Time'), responseMap.get('TransactionLogId'), responseMap.get('MID'),responseMap.get('TID'));
        Test.stopTest();
    }
     
    @IsTest
    public static void testGetPaymentStatusAPIWithCheckedPaymentStatus() {
        Account dealer = new Account(Name = 'Test Dealer', Type = 'Dealer');
        insert dealer;
        
        Order o = new Order(
            Dealer__c = dealer.Id,
            AccountId = dealer.Id,
            Payment_Status__c = 'Pending',
            Status = 'Activated',
            EffectiveDate = Date.today()
        );
        insert o;
        
        Pinelabs_Machine_Info__c testMachineInfo = new Pinelabs_Machine_Info__c(Device_No__c = '12345', Bank__c = 'Test Bank');
        insert testMachineInfo;
        
        Payment_Split__c paymentSplit = new Payment_Split__c(
            Order__c = o.Id,
            Payment_Mode__c = 'Card',
            Pay_Amount__c = 100.00,
            Status__c = 'Initiated',
            Pinelabs_Machine_Info__c = testMachineInfo.Id,
            IsPayment_Status_Checked__c = true 
        );
        insert paymentSplit;
        
        Map<String, String> responseMap = new Map<String, String>{
            'RRN' => '1234567890',
                'Acquirer Name' => 'Test Acquirer',
                'ApprovalCode' => '00',
                'Amount'=>'100',
                'Transaction Date' => '01012025',
                'Transaction Time' => '123045',
                'TransactionLogId' => 'TX1234',
                'MID' => 'MID1234'
                };
                    
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPineLabs(responseMap));
        Map<String, String> result = PineLabsPaymentHelper.GetPaymentStatusAPI(o.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testUpdateTransactionDetailWhenNotChecked() {
        Account dealer = new Account(Name = 'Test Dealer', Type = 'Dealer');
        insert dealer;
        
        Order o = new Order(
            Dealer__c = dealer.Id,
            AccountId = dealer.Id,
            Payment_Status__c = 'Pending',
            Status = 'Activated',
            EffectiveDate = Date.today()
        );
        insert o;
        
        Payment_Split__c paymentSplit = new Payment_Split__c(
            Order__c = o.Id,
            Payment_Mode__c = 'Card',
            Pay_Amount__c = 100.00,
            Status__c = 'Initiated',
            IsPayment_Status_Checked__c = false
        );
        insert paymentSplit;
        
        Map<String, String> responseMap = new Map<String, String>{
            'RRN' => '1234567890',
                'Acquirer Name' => 'Test Acquirer',
                'ApprovalCode' => '00',
                'Amount'=>'100',
                'Transaction Date' => '01012025',
                'Transaction Time' => '123045',
                'TransactionLogId' => 'TX1234',
                'MID' => 'MID1234'
                };
                    
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPineLabs(null));
        Map<String, String> result = PineLabsPaymentHelper.GetPaymentStatusAPI(o.Id);
        Test.stopTest();
    }
    
    @IsTest
    public static void testMockHttpResponseGenerator() {
        Map<String, String> responseMap = new Map<String, String>{
            'PlutusTransactionReferenceID' => '123',
                'ResponseCode' => '00',
                'ResponseMessage' => 'Success',
                'RRN' => '1234567890',
                'Acquirer Name' => 'Test Acquirer',
                'ApprovalCode' => '00',
                'Transaction Date' => '01012025',
                'Transaction Time' => '123045',
                'TransactionLogId' => 'TX1234',
                'MID' => 'MID1234'
                };
                    
                    MockHttpResponseGeneratorPineLabs mock = new MockHttpResponseGeneratorPineLabs(responseMap);
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint('https://test.com');
        req.setMethod('POST');
        
        Test.startTest();
        HTTPResponse res = mock.respond(req);
        Test.stopTest();
        
        System.assertEquals(200, res.getStatusCode());
        System.assert(res.getBody().contains('1234567890'), 'Response should contain the RRN.');
    }
    
    @IsTest
    public static void testcancelTransaction() {
        Account dealer = new Account(Name = 'Test Dealer', Type = 'Dealer');
        insert dealer;
        
        Order o = new Order(
            Dealer__c = dealer.Id,
            AccountId = dealer.Id,
            Payment_Status__c = 'Pending',
            Status = 'Activated',
            EffectiveDate = Date.today()
        );
        insert o;
        
        Pinelabs_Machine_Info__c testMachineInfo = new Pinelabs_Machine_Info__c(Device_No__c = '12345', Bank__c = 'Test Bank');
        insert testMachineInfo;
        
        Payment_Split__c paymentSplit = new Payment_Split__c(
            Order__c = o.Id,
            Payment_Mode__c = 'Card',
            Pay_Amount__c = 100.00,
            Status__c = 'Initiated',
            Pinelabs_Machine_Info__c = testMachineInfo.Id,
            IsPayment_Status_Checked__c = true 
        );
        insert paymentSplit;
        
        Map<String, String> responseMap = new Map<String, String>{
            'RRN' => '1234567890',
                'Acquirer Name' => 'Test Acquirer',
                'ApprovalCode' => '00',
                'Amount'=>'100',
                'Transaction Date' => '01012025',
                'Transaction Time' => '123045',
                'TransactionLogId' => 'TX1234',
                'MID' => 'MID1234'
                };
                    
                    Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorPineLabs(responseMap));
        String data=   PineLabsPaymentHelper.cancelTransaction(paymentSplit.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testDataMethod(){
        PineLabs_UploadTxn.testData();
        PineLabs_UploadTxn.testData1();
        PineLabs_UploadTxn.testData2();
        PineLabs_UploadTxn.testData3();
        PineLabs_UploadTxn.testData4();
        PineLabs_UploadTxn.testData5();
        PineLabsPaymentHelper.testData();
        PineLabsPaymentHelper.testData1();
    }
    
}