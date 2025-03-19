global class createPurchaseOrderFormController {
    
    @AuraEnabled
    global static String createPurchaseorder(String shipmentType,String loggedInUserId){
        System.debug('shipmentType == >'+shipmentType+'  && loggedInUserId == >'+loggedInUserId);
        List<ProductRequest> newProductRequest  = new List<ProductRequest>();
        String userLocationId = '';
        User useRec = new User();
        if(loggedInUserId !=null){
            useRec = [SELECT Id,Contact.Name,ContactId,Contact.Location__c,Contact.AccountId  FROM User WHERE Id=:loggedInUserId LIMIT 1];
            System.debug('Contact : '+useRec.Contact+' && Account :'+useRec.Contact.AccountId);
            if(useRec.Contact.Location__c != null){
                userLocationId = useRec.Contact.Location__c;
            }else{
                System.debug('No Location Found !');
                return 'No Locaton Record Found !';
            }
        }
        ProductRequest productRequest = new ProductRequest();
        productRequest.Status='New';
        productRequest.ShipmentType=shipmentType;
        productRequest.Account__c= useRec.Contact != null && useRec.Contact.AccountId != null ? useRec.Contact.AccountId : null;
        productRequest.Destination_Location__c=userLocationId;
        newProductRequest.add(productRequest);
        try {
            if(!newProductRequest.isEmpty()){
                insert newProductRequest;
                if(newProductRequest !=null){
                    return newProductRequest[0].Id;     
                }
            }
        } catch (Exception e) {
            System.debug('Error Message == >'+e.getMessage()+' && Error Line =='+e.getLineNumber());
            return 'Error : '+e.getMessage();
        }
        return null;
    }
    
    @AuraEnabled 
    public static String getCurrentLogedUserAccountRecord(String loggedInUserId){
        User userRecord = [ SELECT Contact.Name, Contact.Account.Name FROM User WHERE Id = :loggedInUserId LIMIT 1 ];
        return userRecord.Contact != null && userRecord.Contact.Account != null  ? userRecord.Contact.Account.Name : 'No Account Found';
    }
}