global class DocCategoryHelper {
    
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {   
        system.debug('Running');
        displayPopup = true;    
    }
    
    public String blobData {
        get {
            try{
                return EncodingUtil.Base64Encode(docWrapperInstance.blobFile);
            }catch(Exception e){
                return '';
            }
            
        }
    }
    public docWrapper docWrapperInstance{get;set;}
    public DocCategoryHelper() {
        viewPDF();
    }
    
    @RemoteAction
    global static List<DocumentTreeWrapper> getDocuments(Id dealId) {
        String objectName = dealId.getSObjectType().getDescribe().getName();
        System.debug(objectName);
        if(String.isBlank(dealId)){
            return null;
        }
        
       
        
         if(objectName == 'Account'){
            Map<Id,DocumentTreeWrapper> uiWrapper = new Map<Id,DocumentTreeWrapper>();
            List<Document_Category__c> propAppList=  [Select id,Name from Document_Category__c where  Account__c=:dealId];
            String Obj = '';
            if(propAppList.size() > 0){
                for(Document_Category__c appDoc : [SELECT Id, Name,(SELECT Id, Name,Active__c FROM Documents_Attachments__r) FROM Document_Category__c WHERE Account__c =:dealId ORDER BY CreatedDate]) {
                    //Handle First level cat Here
                    DocumentTreeWrapper appDocWrapper;
                    
                    appDocWrapper = new DocumentTreeWrapper(appDoc.Id, appDoc.Name); 
                    if(!appDoc.Documents_Attachments__r.isEmpty()){
                        for(Documents_Attachment__c appAttachment : appDoc.Documents_Attachments__r) {
                            appDocWrapper.childNodes.add(new DocumentTreeWrapper(appAttachment.Id, appAttachment.Name));
                        }
                    }
                    
                    uiWrapper.put(appDoc.Id, appDocWrapper);
                }
            }
            return uiWrapper.values();             
        }
         return new List<DocumentTreeWrapper>();
    }
       
    public void viewPDF(){
        String appDocId = Apexpages.currentPage().getParameters().get('attachId');
        system.debug('para::'+appDocId);
        docWrapperInstance = new docWrapper();
        Documents_Attachment__c appDocAttach = new Documents_Attachment__c();
        if(appDocId != null){
            appDocAttach = [SELECT id,Name,Attachement_Id__c FROM Documents_Attachment__c WHERE id =: appDocId];
            if(appDocAttach != null && appDocAttach.Attachement_Id__c != null){
                try{
                    system.debug('appDocAttach.Attachement_Id__c'+appDocAttach.Attachement_Id__c);
                    Attachment att = [select id,name,body,contenttype  from attachment where id =: appDocAttach.Attachement_Id__c limit 1];
                    //if(att.contenttype !=null){
                    docWrapperInstance.contentType = att.contenttype;
                    docWrapperInstance.blobFile = att.body;
                    //}
                }catch(Exception e){
                    System.debug('e.getmshg'+e.getMessage());
                }
            }
        }else{
            //System.debug('e.getmshg'+e.getMessage());
            docWrapperInstance = new docWrapper();
            docWrapperInstance.contentType = 'application/';
            docWrapperInstance.blobFile = blob.valueOf('');
        }
    }
    
    @RemoteAction
    global static void deleteDoc(string selectedAttId){
        system.debug('attachId---'+selectedAttId);
        //String appDocId = Apexpages.currentPage().getParameters().get('attachId');
        system.debug('attachId---'+selectedAttId);
        Documents_Attachment__c appDocAttach = new Documents_Attachment__c();
        if(selectedAttId != null){
            appDocAttach = [SELECT id,Name,Attachement_Id__c FROM Documents_Attachment__c WHERE id =: selectedAttId];
            
        }
        delete appDocAttach;
    }
    
    global class DocumentTreeWrapper {
        public String documentID;
        public String documentName;
        public List<DocumentTreeWrapper> childNodes = new List<DocumentTreeWrapper>();
        
        public DocumentTreeWrapper(String documentID, String documentName) {
            this.documentID = documentID;
            this.documentName = documentName;
        }
    }
    
    global class docWrapper{
        public String contentType{get;set;}
        public blob blobFile{get;set;}
    }
    
     @RemoteAction
    global static void initiateApprovalProcess(Id recordId) {
        system.debug('recordId---'+recordId);
        // Query for the ProcessDefinitionId based on the process name
        //String processName = 'Monthly_Beat_Expense_Approval';
        Id currUserId = UserInfo.getUserId();
        Id managerId = [SELECT Id, ManagerId FROM User WHERE Id =: currUserId].ManagerId;
        if(managerId != null && !string.isBlank(managerId)){
            Approval.ProcessSubmitRequest  pass = new Approval.ProcessSubmitRequest();
            pass.setComments('Submitting request for approval automatically using Trigger');
            pass.setObjectId(recordId);
            pass.setProcessDefinitionNameOrId('Document_Approval');    
            pass.setNextApproverIds(new List<Id> {managerId});         // Submit the approval request for the Opportunity
            Approval.ProcessResult result = Approval.process(pass);
        }
    }
    
    
    
}