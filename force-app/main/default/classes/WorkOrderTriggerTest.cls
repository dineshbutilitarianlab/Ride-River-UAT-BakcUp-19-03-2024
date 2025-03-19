@isTest
public class WorkOrderTriggerTest {
	@testSetup
    static void setup() {
        Map<string,Sobject> mapnewRecords = TestDataFactory.createVehicle();
        
        List<AssetMilestone> milestoneList = new List<AssetMilestone>();
        
        AssetMilestone milestone = new AssetMilestone();
        milestone.Delivery_Date__c = System.today();
        milestone.MilestoneType = 'PDI';
        milestone.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone.MilestoneDate = System.today();
        milestone.AssetId = mapnewRecords.get('Asset').Id;
        milestone.Name = 'PDI';
        milestone.UsageType = 'Automotive';
        milestone.Stage = 'Active';
        
        Insert milestone;
        
        vehicle vh = (Vehicle)mapnewRecords.get('Vehicle');
        vh.PDI_Status_Pass__c = true;
        
        update vh;
        
        PriceBookEntry entry = (PriceBookEntry)mapnewRecords.get('PricebookEntry');
        Id PriceBookId = entry.PriceBook2Id;
        Account acc = (Account)mapnewRecords.get('Account');
        Product2 newProduct = (Product2)mapnewRecords.get('Product');
        
        // Create a Standard Order record
        Order standardOrder = new Order(
            AccountId = acc.Id,
            Website_Order_Id__c = 'RTYU456789',
            EffectiveDate = Date.today(),
            Status = 'Draft',
            Description = 'Nothing',
            pricebook2Id = PriceBookId,
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
            BillingCountry = 'india',
            Assigned_Vehicle__c = vh.Id
        );
        Insert standardOrder;
        
        OrderItem orderItem = new OrderItem(
            OrderId = standardOrder.Id,
            PricebookEntryId = entry.Id,
            Product2Id = newProduct.Id,
            Quantity = 1, 
            UnitPrice = 1056765,
            Type__c = 'Vehicle'
        );
        
        
        AssetMilestone milestone4 = new AssetMilestone();
        milestone4.Delivery_Date__c = System.today();
        milestone4.MilestoneType = 'Sold';
        milestone4.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone4.MilestoneDate = System.today();
        milestone4.AssetId = mapnewRecords.get('Asset').Id;
        milestone4.Name = 'Vehicle Sold';
        milestone4.UsageType = 'Automotive';
        milestone4.Stage = 'Active';
        
        Insert milestone4;
        
        AssetMilestone milestone1 = new AssetMilestone();
        milestone1.Delivery_Date__c = System.today();
        milestone1.MilestoneType = 'Customer Delivery';
        milestone1.VehicleId = mapnewRecords.get('Vehicle').Id;
        milestone1.MilestoneDate = System.today();
        milestone1.AssetId = mapnewRecords.get('Asset').Id;
        milestone1.Name = 'Vehicle Sold';
        milestone1.UsageType = 'Automotive';
        milestone1.Stage = 'Active';
        
        Insert milestone1;
        
        
        City__c city = new City__c(
            Name = 'Bengaluru',
            City_Masking_Name__c = 'Bengaluru',
            State__c = 'Karnataka',
            City_Pincode__c = '123456',
            Price_Book__c = PriceBookId
        );
        insert city;
        
        Account acc1 = new Account();
        acc1.name = 'partner';
        acc1.Email__c = 'partner@gmail.com';
        acc1.Phone = '6767656776';
        acc1.Type = 'Dealer';
        Insert acc1;
        
        List<contact> conList = [SELECT Id, Name , Email from contact where AccountId=:acc1.Id AND Primary_Contact__c = true];
        Contact testContact = new Contact();
        If(conList.size()>0){
            testContact = conList[0];
        }else{
            testContact = new Contact(
                FirstName = 'John',
                LastName = 'partner',
                Email = 'john.partner@test.com',
                Phone = '9011113046',
                MailingCity = 'Test City',
                MailingCountry = 'india',
                MailingPostalCode = '12345',
                MailingState = 'karnataka',
                MailingStreet = '123 Test Street',
                AccountId = acc1.Id,
                Primary_Contact__c = true
            );
            
            insert testContact;
        }
        
        acc1.IsPartner =true;
        update acc1;
        
        
        ServiceResource sr = new ServiceResource(name='Test Resource', RelatedRecordId = userinfo.GetUserId(), IsActive = true);
        Insert sr;
        
        // Create test data
        WorkOrder testWorkOrder = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            AccountId = vh.CurrentOwnerId,
            Odometer_Reading__c = 120,
            Pricebook2Id = PriceBookId,
            city__c = city.Id,
            Vehicle__c = vh.Id
        );
        insert testWorkOrder;
        
     }
    
    @isTest
    Public static void duplicateVINVRNInsertTest(){
        
        PriceBook2 pricebook = [SELECT Id from PriceBook2 LIMIT 1];
        City__c city = [SELECT Id from City__c LIMIT 1];
        Vehicle vehicle = [SELECT Id, CurrentOwnerId FROM Vehicle LIMIT 1];
        
        // Create test data
        WorkOrder testWorkOrder1 = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            Odometer_Reading__c = 120,
            Pricebook2Id = pricebook.Id,
            AccountId = vehicle.CurrentOwnerId,
            city__c = city.Id,
            Vehicle__c = vehicle.Id
        );
        
        Try{
             insert testWorkOrder1;
        }Catch(exception e){
            
        }
    }
    
    @isTest
    Public static void duplicateVINVRNUpdateTest(){
        
        PriceBook2 pricebook = [SELECT Id from PriceBook2 LIMIT 1];
        City__c city = [SELECT Id from City__c LIMIT 1];
        Vehicle vehicle = [SELECT Id, CurrentOwnerId FROM Vehicle LIMIT 1];
        
        // Create test data
        WorkOrder testWorkOrder1 = new WorkOrder(
            Status = 'New',
            Subject = 'Test Work Order',
            Odometer_Reading__c = 120,
            Pricebook2Id = pricebook.Id,
            AccountId = vehicle.CurrentOwnerId,
            city__c = city.Id
        );
        
             insert testWorkOrder1;
        
        try{
            testWorkOrder1.vehicle__c = vehicle.Id;
            Update testWorkOrder1;
        }catch(exception e){
            
        }
    }
    
    @isTest
    Public static void completedJCTest(){
        WorkOrder wo = [SELECT Id, Odometer_reading__c FROM WorkOrder];
        Contact con = new contact(lastName = 'technician', Phone = '6788767858', Email = 'test@gmail.com');
        Insert con;
        
        wo.Status = 'In Progress';
        Update wo;
            
		wo.Status = 'Ready For Delivery';
        wo.RR_Technician__c = con.Id;
        wo.Odometer_Reading__c = 1000;
        wo.RR_SOC_Level__c = true;
        wo.RR_Brake_Play__c = true;
        wo.RR_Front_Axle_Nut__c = true;
        wo.RR_Tyre_Pressure__c = true;
        wo.RR_GUI_Checks__c = true;
        wo.RR_Tyre_Condition__c = true;
        wo.RR_Socket_Cover_Opening__c = true;
        wo.RR_Tank_Badge__c= true;
        wo.RR_Suspnsion_Play__c = true;
        wo.RR_Fork_Seal__c = true;
        wo.RR_Brake_Oil_Level__c = true;
        wo.RR_Rear_Axle_Nut__c = true;
        wo.RR_Brake_Pads__c = true;
        wo.RR_Steering_Top_Nut__c = true;
        wo.RR_Brake_Sponginess__c = true;
        
        wo.RR_Customer_Rating__c = 5;
        wo.RR_Customer_Suggestions__c = 'test';
        wo.RR_Check_all_requested_work_completed__c = 'Done';
        wo.RR_Pending_Field_Fix__c= 'Done';
        wo.RR_Status_of_Side_Stand_switch_in_parked__c= 'Done';
        wo.RR_Electrical_Component_Functioning__c= 'Done';
        wo.RR_Check_for_outstanding_Fault_Codes__c= 'Done';
        wo.RR_Washing_Polishing__c= 'Done';
        
        Update wo;
        
        Try{
            wo.Status = 'Completed';
            Update wo;
        }catch(exception e){
            
        }
    }
}