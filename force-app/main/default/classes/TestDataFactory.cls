public class TestDataFactory {
    
    Public static  Map<string,Sobject> CreateOrder(){
        
        Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Customer', Phone = '9011113246', Email__c = 'testemail@testmail.com' );
        insert acc;
        
        // Create a test Contact related to the test Account
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:acc.Id AND Primary_Contact__c = true];
        Contact testContact = new Contact();
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'india',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test Street',
            AccountId = acc.Id,
            Primary_Contact__c = true
        );
        insert testContact;
        } 
        
        //Fetch standard pricebook
        Id standardPricebookId = test.getStandardPricebookId();
        
        Product2 newProduct = new Product2(
            Name = 'Bike',
            Description = 'Vehicle',
            IsActive = true,
            HSN_Code__c ='Test',
            Type__c ='Vehicle',
            ProductCode = 'TP-002'
        );
        //insert newProduct;
        
        Product2 newProduct1 = new Product2(
            Name = 'Bike',
            Description = 'Accessories',
            IsActive = true,
            HSN_Code__c ='Test',
            Type__c ='Accessories',
            ProductCode = 'TP-001'
        );
        insert new List<Product2>{newProduct1, newProduct};
        
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = newProduct.Id,
            UnitPrice = 1000000,
            IsActive = true // You can set other fields as needed
        );
        //insert newPricebookEntry;
        
        PricebookEntry newPricebookEntry1= new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = newProduct1.Id,
            UnitPrice = 1000000,
            IsActive = true // You can set other fields as needed
        );
        insert new List<PricebookEntry>{newPricebookEntry1, newPricebookEntry};
        
        // Create a Standard Order record
        Order standardOrder = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            pricebook2Id = standardPricebookId,
            Handling_Charges__c = 1000,
            Insurance_Amount__c = 1000,
            RTO_Charges__c = 1000,
            //Payment_Type__c = itemPaymentType,
            Notify_By_SMS__c = true,
            Notify_By_Email__c = true,
            BillingStreet = 'Bangalore',
            BillingCity = 'Bangalore',
            BillingState = 'Karnataka',
            BillingPostalCode = '574216',
            BillingCountry = 'india'
        );
        Insert standardOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = standardOrder.Id,
            PricebookEntryId = newPricebookEntry.Id,
            Product2Id = newProduct.Id,
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Vehicle'
        );
        
        OrderItem orderItem1 = new OrderItem(
            OrderId = standardOrder.Id,
            PricebookEntryId = newPricebookEntry1.Id,
            Product2Id = newProduct1.Id,
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Accessories'
        );
        
        Insert new List<OrderItem>{orderItem1,orderItem};
        
        
        Payment__c payment = new Payment__c(
            Amount__c = 1000.00,           
            Payment_Status__c = 'Success',
            Mode_Of_Payment__c = 'Credit Card',
            Transaction_Id__c= 'RTYU456789'
        );
        insert payment;
        
        // Create related Order Payment records for the test Payments
        
        Order_Payment__c op = new Order_Payment__c(
            Payments__c = payment.Id,
            Order__c = standardOrder.Id,
            Type__c = 'Down Payment',
            Amount1__c = 1000
        );
        
        insert op;
        
        mapnewRecords.put('OrderId',standardOrder);
        mapnewRecords.put('AccountId',acc);
        mapnewRecords.put('ContactId',testContact);
        mapnewRecords.put('OrderProductId',orderItem);
        //mapnewRecords.put('OrderProductId1',orderItem1);
        mapnewRecords.put('ProductId',newProduct);
        mapnewRecords.put('PaymentId',payment);
        mapnewRecords.put('OrderPaymentId',op);
        mapnewRecords.put('PricebookEntryId',newPricebookEntry);
              
        
        return mapnewRecords;
        
    }
    
    Public static Map<string,Sobject> CreateAccountWithProduct(){
        
        Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        
        Account acc = new Account(Name = 'Test Name',Type = 'Customer', Phone = '9011113246', Email__c = 'testemail@testmail.com' );
        insert acc;
        
        // Create a test Contact related to the test Account
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:acc.Id AND Primary_Contact__c = true];
        Contact testContact = new Contact();
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            Phone = '9011113246',
            MailingCity = 'Test City',
            MailingCountry = 'india',
            MailingPostalCode = '12345',
            MailingState = 'karnataka',
            MailingStreet = '123 Test Street',
            AccountId = acc.Id,
            Primary_Contact__c = true
        );
        insert testContact;
        }
        
        //Fetch standard pricebook
        Id standardPricebookId = test.getStandardPricebookId();
        
        Product2 newProduct = new Product2(
            Name = 'Bike',
            Description = 'Vehicle',
            IsActive = true,
            HSN_Code__c = '2BIKE',
            Type__c = 'Vehicle',
            ProductCode = 'TP-001'
        );
        insert newProduct;
        
        PricebookEntry newPricebookEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = newProduct.Id,
            UnitPrice = 1000000,
            IsActive = true // You can set other fields as needed
        );
        insert newPricebookEntry;
        
        Pricebook2 priceBook = new Pricebook2();
        priceBook.Id = standardPricebookId;
        priceBook.IsActive = true;
        update priceBook;
        
        //add every records to map
        mapnewRecords.put('Account',acc);
        mapnewRecords.put('Contact',testContact);
        mapnewRecords.put('Product',newProduct);
        mapnewRecords.put('PricebookEntry',newPricebookEntry);
        
        return mapnewRecords;
    }
    
    Public static Map<string,Sobject> createVehicle(){
        Map<string,Sobject> mapnewRecords = new  Map<string,Sobject>();
        Map<string,Sobject> mapAccProduct = CreateAccountWithProduct();
        
        VehicleDefinition v1 = new VehicleDefinition(
            Name = 'newVehicleDefinition',
            ProductId = mapAccProduct.get('Product').Id
        );
        insert v1;
        Asset a1 = new Asset(
            Name = 'newAsset',
            AccountId = mapAccProduct.get('Account').Id,
            ContactId= mapAccProduct.get('Contact').Id
        );
        insert a1;
        
        Software_version__c sft = new Software_version__c();
        sft.Name = 'sft1';
        sft.Latest_Software_Version__c = true;
        sft.Firmware_Version__c = '1.2';
        sft.Hardware_Version__c = '26.22.2';
        insert sft;
        
        
        Vehicle vehicle = new Vehicle(
            Name='newVehicle',
            VehicleDefinitionId = v1.Id,
            AssetId = a1.Id,
            VehicleIdentificationNumber = '111S',
            VehicleRegistrationNumber = 'REG1235',
            CurrentOwnerId = mapAccProduct.get('Account').Id,
            Charger_PC_Number__c = 'PC123',
            Software_Version__c = sft.Id
        );
        insert vehicle;
        
        WarrantyTerm warrantyTerm = new WarrantyTerm(	
            WarrantyTermName = 'standardWarranty',
            WarrantyDuration = 7889,
            WarrantyUnitOfTime = 'Days',
            EffectiveStartDate = 'Install Date',
            WarrantyType = 'Repair');
        insert warrantyTerm;
        
        AssetWarranty newAssetWarranty= new AssetWarranty(
            AssetId = a1.Id,
            WarrantyType = 'Standard',
            WarrantyTermId = warrantyTerm.Id
        );
           
        //add every records to map
        mapnewRecords.put('Account',mapAccProduct.get('Account'));
        mapnewRecords.put('Contact',mapAccProduct.get('Contact'));
        mapnewRecords.put('Product',mapAccProduct.get('Product'));
        mapnewRecords.put('PricebookEntry',mapAccProduct.get('PricebookEntry'));
        mapnewRecords.put('VehicleDefinition',v1);
        mapnewRecords.put('Asset',a1);
        mapnewRecords.put('Vehicle',vehicle);
        mapnewRecords.put('WarrantyTerm',warrantyTerm);
        mapnewRecords.put('AssetWarranty',newAssetWarranty);
        
        return mapnewRecords;
    }
    
    public static void getRequiredFields(String objectName) {
    // Fetch the SObject schema
    Schema.DescribeSObjectResult objSchema = Schema.getGlobalDescribe().get(objectName).getDescribe();
    Map<String, Schema.SObjectField> fields = objSchema.fields.getMap();

    List<Object> requiredFields = new List<Object>();
    System.debug('Required Fields for Object: ' + objectName);

    for (String fieldName : fields.keySet()) {
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        // A field is required if it's not nillable (cannot be null) and createable (can be set during insert)
        if (!fieldResult.isNillable() && fieldResult.isCreateable()) {
            // Create a map to store field info
            Map<String, String> fieldInfo = new Map<String, String>();
            fieldInfo.put('FieldName', fieldResult.getName()); // Use getName() for exact API name
            fieldInfo.put('FieldType', fieldResult.getType().name());

            // Add map to the list
            requiredFields.add(fieldInfo);

            System.debug('Field: ' + fieldResult.getName() + ', Type: ' + fieldResult.getType().name() + ' is Required');
        }
    }

      system.debug('list of records' + requiredFields); 
}
     
}