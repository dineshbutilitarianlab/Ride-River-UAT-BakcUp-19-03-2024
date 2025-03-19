public class OrderController {


    public static Id OrderRecordTypeMerchAccess;
    
    static {
        OrderRecordTypeMerchAccess = Schema.SObjectType.Order.getRecordTypeInfosByName().get('Merchandise').getRecordTypeId();
        }

    public class OrderProductLineItemWrapper {
        public String Product2Id { get; set; }
        public String ParentId { get; set; }
        public Decimal QuantityRequested { get; set; }
    }

    // @AuraEnabled(Cacheable = true)
    // public static List<Product2> getLogedInUserRelatedLocationPOLI(){
    //     System.debug('Fetching Merchandise Products');
    //         try {
    //             return [
    //                 SELECT Id, Name, ProductCode, Type__c FROM Product2 
    //                 WHERE IsActive = TRUE AND (Type__c = 'Merchandise' OR Type__c = 'Accessories')
    //             ];
    //         } catch (Exception e) {
    //             System.debug('Error in getMerchandiseProducts: ' + e.getMessage());
    //             throw new AuraHandledException('An error occurred while fetching products.');
    //         }
    // }


    @AuraEnabled(Cacheable = true)
    public static List<Product2> getLogedInUserRelatedLocationPOLI() {
        try {
            String loggedInUserId = UserInfo.getUserId();
            User userRec = [
                SELECT Contact.Location__c 
                FROM User 
                WHERE Id = :loggedInUserId 
                LIMIT 1
            ];

            if (userRec.Contact.Location__c == null) {
                throw new AuraHandledException('No Location Record Found for the User.');
            }

            String priceBookId = [
                SELECT Price_Book__c 
                FROM Location 
                WHERE Id = :userRec.Contact.Location__c 
                LIMIT 1
            ].Price_Book__c;

            if (priceBookId == null) {
                throw new AuraHandledException('No Pricebook Found for the User\'s Location.');
            }

            return [
                SELECT Id, Name, ProductCode, Type__c ,(SELECT Product2Id,UnitPrice,Discount__c,IGST__c
                        FROM PricebookEntries where IsActive = true)
                FROM Product2 
                WHERE IsActive = TRUE 
                    AND (Type__c = 'Merchandise' OR Type__c = 'Accessories') 
                    AND Id IN (
                        SELECT Product2Id
                        FROM PricebookEntry 
                        WHERE Pricebook2Id = :priceBookId AND IsActive = TRUE
                    )
            ];
        } catch (Exception e) {
            System.debug('Error in getLogedInUserRelatedLocationPOLI: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while fetching products.');
        }
    }



    @AuraEnabled
    public static String createOrderProductLineItems(String jsonData) {
        System.debug('jsonData === >' + jsonData);
        try {
            // Deserialize the JSON input into a list of wrapper objects
            List<OrderProductLineItemWrapper> lineItems = 
                (List<OrderProductLineItemWrapper>) JSON.deserialize(jsonData, List<OrderProductLineItemWrapper>.class);

            System.debug('Deserialized Line Items === >' + lineItems);

            String loggedInUserId = UserInfo.getUserId();
            User userRec = [
                SELECT Contact.Location__c  FROM User WHERE Id = :loggedInUserId LIMIT 1];
            
            if (userRec.Contact.Location__c == null) {
                System.debug('No Location Found!');
                return 'Error: No Location Record Found!';
            }
            
            Id userLocationId = userRec.Contact.Location__c;

            // Fetch the pricebook associated with the user's location
            String priceBookId = [
                SELECT Price_Book__c FROM Location WHERE Id = :userLocationId LIMIT 1].Price_Book__c;

            if (priceBookId == null) {
                System.debug('No Pricebook Found!');
                return 'Error: No Pricebook Found for the User\'s Location!';
            }

            // Extract Product2Ids from the wrapper list
            List<Id> product2Ids = new List<Id>();
            for (OrderProductLineItemWrapper item : lineItems) {
                if (item.Product2Id != null) {
                    product2Ids.add(item.Product2Id);
                }
            }
            // Fetch PricebookEntry records for all provided Product2Ids
            Map<Id, PricebookEntry> productToPricebookEntryMap = new Map<Id, PricebookEntry>();
            if (!product2Ids.isEmpty()) {
                List<PricebookEntry> pricebookEntries = [
                    SELECT Id, Product2Id, UnitPrice FROM PricebookEntry 
                    WHERE Pricebook2Id = :priceBookId AND Product2Id IN :product2Ids
                ];

                for (PricebookEntry pbe : pricebookEntries) {
                    productToPricebookEntryMap.put(pbe.Product2Id, pbe);
                }
            }

            System.debug('Product to PricebookEntry Map === >' + productToPricebookEntryMap);

            // Create OrderItem records
            List<OrderItem> recordsToInsert = new List<OrderItem>();
            for (OrderProductLineItemWrapper item : lineItems) {
                if (productToPricebookEntryMap.containsKey(item.Product2Id)) {
                    PricebookEntry pbe = productToPricebookEntryMap.get(item.Product2Id);

                    OrderItem newRecord = new OrderItem(
                        Product2Id = item.Product2Id,
                        OrderId = item.ParentId,
                        Quantity = item.QuantityRequested,
                        PricebookEntryId = pbe.Id,
                        UnitPrice = pbe.UnitPrice != null ? pbe.UnitPrice : 0.00 
                    );
                    recordsToInsert.add(newRecord);
                } else {
                    System.debug('No Pricebook Entry Found for Product: ' + item.Product2Id);
                    return 'Error: No Pricebook Entry Found for One or More Products!';
                }
            }

            // Insert OrderItem records if any exist
            if (!recordsToInsert.isEmpty()) {
                System.debug('Inserting Order Items: ' + recordsToInsert);
                insert recordsToInsert;
                System.debug('Successfully Inserted Order Items: ' + recordsToInsert);
                return 'SUCCESS';
            }
        } catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line ==>' + e.getLineNumber());
            return 'Error: ' + e.getMessage();
        }
        return null;
    }

    @AuraEnabled
    public static String createOrderRecord(String shipmentType,Integer additonal) {
        System.debug('Shipment Type ==>' + shipmentType);
    
        String loggedInUserId = UserInfo.getUserId();
        System.debug('Logged-in User Id ==>' + loggedInUserId);
    
        try {
            User useRec = [
                SELECT Id, Contact.Name, ContactId, 
                       Contact.Location__c, Contact.AccountId, 
                       Contact.Role_Type__c 
                FROM User 
                WHERE Id = :loggedInUserId 
                LIMIT 1
            ];
            System.debug('Contact : ' + useRec.Contact + ' && Account : ' + useRec.Contact.AccountId);
    
            // Check if the user's contact has a location
            if (useRec.Contact.Location__c == null) {
                System.debug('No Location Found!');
                return 'Error: No Location Record Found!';
            }
    
            // Get location and price book
            Id userLocationId = useRec.Contact.Location__c;
            String takingPb = [
                SELECT Price_Book__c 
                FROM Location
                WHERE Id = :userLocationId 
                LIMIT 1
            ].Price_Book__c;
    
            // Create the order
            Order newOrder = new Order();
            newOrder.Status = 'New';
            newOrder.RecordTypeId = OrderRecordTypeMerchAccess; 
            newOrder.AccountId = useRec.Contact.AccountId;
            newOrder.EffectiveDate = System.today();
            newOrder.Pricebook2Id = takingPb;
            newOrder.Contact__c = useRec.ContactId;
            //newOrder.additional__c = additonal;
            insert newOrder;
    
            System.debug('Order Created: ' + newOrder.Id);
            return newOrder.Id;
    
        } catch (Exception e) {
            System.debug('Error Message ==>' + e.getMessage() + ' && Error Line ==>' + e.getLineNumber());
            return 'Error: ' + e.getMessage();
        }
    }
}