public without sharing class Check_pdi_item_screen_pdf_controller {

    public List<PDIItemsWrapper> pdiItemWrapList {get; set;}
    public Vehicle vehicleRecord {get; set;}
    public Contact customer {get; set;}
    public Date Today { get { return Date.today(); }}
    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}
    public List<String> conditions {get; set;}

    public Check_pdi_item_screen_pdf_controller() {
        pdiItemWrapList = new List<PDIItemsWrapper>();
        vehicleRecord = new Vehicle();
        customer = new Contact();
        String vehicleId = Apexpages.currentPage().getParameters().get('id');
        conditions = new List<String>();

        List<Vehicle> vehicleList = [Select Id, Name, CurrentOwnerId, VehicleIdentificationNumber, VehicleRegistrationNumber, Colour__c, VehicleDefinition.ModelCode, Charger_PC_Number__c from Vehicle Where Id =:vehicleId];
        if(vehicleList != null && vehicleList.size() > 0){
            vehicleRecord = vehicleList[0];
        }

        if(vehicleRecord != null && vehicleRecord.CurrentOwnerId != null){
            List<Contact> contacts = [Select Id, Name, Customer_ID__c, Primary_Contact__c from Contact Where Primary_Contact__c=true AND AccountId =:vehicleRecord.CurrentOwnerId];
            if(contacts != null && contacts.size() > 0){
                customer = contacts[0];
            }
        }

        List<Pre_Delivery_Inspection_Item__c> allPDIItems = Check_PDI_Item_Screen_Controller.fetchPDIItems(vehicleId);
        Map<String, List<Pre_Delivery_Inspection_Item__c>> groupedPDIItemsMap = new Map<String, List<Pre_Delivery_Inspection_Item__c>>();
        if(allPDIItems != null && allPDIItems.size() > 0){
            for(Pre_Delivery_Inspection_Item__c item : allPDIItems){
                if(item.Pre_Delivery_Inspection__r != null && item.Pre_Delivery_Inspection__r.Attribute__c != null){
                    String key = item.Pre_Delivery_Inspection__r.Attribute__c;
                    if(groupedPDIItemsMap != null && groupedPDIItemsMap.containsKey(key)){
                        List<Pre_Delivery_Inspection_Item__c> existingList = groupedPDIItemsMap.get(key);
                        existingList.add(item);
                        groupedPDIItemsMap.put(key, existingList);
                    }
                    else {
                        List<Pre_Delivery_Inspection_Item__c> newList = new List<Pre_Delivery_Inspection_Item__c>();
                        newList.add(item);
                        groupedPDIItemsMap.put(key, newList);
                    }
                }
            }
        }
        if(groupedPDIItemsMap != null && groupedPDIItemsMap.values().size() > 0){
            for (String key : groupedPDIItemsMap.keySet()) {
                pdiItemWrapList.add(new PDIItemsWrapper(key, groupedPDIItemsMap.get(key)));                
            }
        }
        System.debug('allPDIItems :'+allPDIItems);
        System.debug('groupedPDIItemsMap :'+groupedPDIItemsMap);
        System.debug('pdiItemWrapList :'+pdiItemWrapList);

        conditions.add('The vehicle\'s features and specifications were well explained by the showroom team.');
        conditions.add('The warranty terms and conditions were briefed during the delivery of the vehicle.');
        conditions.add('The RSA, Extended Warranty claim process were informed.');
        conditions.add('Service schedule and maintenance period of the vehicle was informed & explained.');
        conditions.add('Operation of key components such as controls and safety features was well briefed by the sales person during the delivery.');
        conditions.add('Bike registration and insurance procedures have been informed at the time of delivery.');
        conditions.add('Safety precautions and riding guidelines were explained by the salesperson.');
        conditions.add('I acknowledge the receipt of the above-mentioned bike in satisfactory condition.');
        conditions.add('I acknowledge receiving the vehicle related documents & belongings.');
    }


    //Account Wrapper Class.
    //This wrapper class contains both the standard salesforce object Account and a Boolean value.
    public class PDIItemsWrapper {
        public String header {get; set;}
        public List<Pre_Delivery_Inspection_Item__c> data {get; set;}
        public PDIItemsWrapper(String parameter, List<Pre_Delivery_Inspection_Item__c> items) {
            header  = parameter;
            data    = items;
        }

    }
}