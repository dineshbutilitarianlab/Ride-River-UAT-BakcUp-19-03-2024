public class CustomHighlightPanelController {
    @AuraEnabled(cacheable=true)
    public static buttonWrapper getWeblinks(String sobjectName, Id recordId){

        WorkOrder workOrderObj = [Select Id, WorkOrderNumber, Status, RR_Job_Type__c From WorkOrder Where Id =:recordId];

        Set<Id> pageIds = new Set<Id>();
        List<WebLink> weblinks = [SELECT Id , Name, MasterLabel, pageorsobjecttype, DisplayType, LinkType, ScontrolId 
                                    FROM WebLink Where PageOrSobjectType = :sobjectName AND DisplayType != 'M' 
                                    Order by CreatedDate];
        
        if(weblinks != null && weblinks.size() > 0){
            for(WebLink wl : weblinks){
                if(wl.LinkType == 'page'){
                    pageIds.add(wl.ScontrolId);
                }
            }
        }

        Map<Id, String> pageNames = new Map<Id, String>();
        List<ApexPage> apexPages = [Select Id,Name,NamespacePrefix from ApexPage Where Id IN :pageIds];
        if(apexPages != null && apexPages.size() > 0){
            for(ApexPage ap : apexPages){
                String pageName = ap.Name;
                // append namespace if page is packaged
                if(String.isNotEmpty(ap.NamespacePrefix)) {
                    pageName = ap.NamespacePrefix+'__' + pageName;
                }
                String partialPageUrl = '/apex/' + pageName;
                PageReference pdf = new PageReference(partialPageUrl);
                pdf.getParameters().put('id',recordId);
                pageNames.put(ap.Id, pdf.getUrl());
            }
        }
        System.debug('pageIds : '+pageIds);

        buttonWrapper buttonWrapperObj = new buttonWrapper();
        buttonWrapperObj.record = workOrderObj;
        buttonWrapperObj.buttons = weblinks;
        buttonWrapperObj.apexPages = apexPages;
        buttonWrapperObj.apexPageURL = pageNames;
       return buttonWrapperObj;
    }

    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class buttonWrapper{
        @AuraEnabled
        public WorkOrder record{get;set;}
        @AuraEnabled
        public List<WebLink> buttons{get;set;}
        @AuraEnabled
        public List<ApexPage> apexPages{get;set;}
        @AuraEnabled
        public Map<ID, String> apexPageURL{get;set;}
    }
}