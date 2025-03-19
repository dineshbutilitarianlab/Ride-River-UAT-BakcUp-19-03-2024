/**
* @author Salesforce.com Foundation
* @date Feb 2022
* @mfcSomDataProvider - For all Data Processing of Object Hierarchy UI
* @description-  Apex Controller for RetriverMetadata, DynamicRowParent Aura Component. 
* This class calls mfcSomMetadatService API's , Create XML file , also deploy and retrive it.
*/

public with sharing class mfcSomDataProvider {
    @AuraEnabled public mfcSomMetadatService.AsyncResult AsyncResult {get; set;}
    
    /*******************************************************************************************************
    * @description Create Package.Xml file
    * returns -  String
    */
    @AuraEnabled 
    public static String getPackageXml()
    {
        return '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
            '<types>' + 
            '<members>*</members>' +
            '<name>ObjectHierarchyRelationship</name>' + 
            '</types>' + 
            '<version>53.0</version>' + 
            '</Package>';       
    }
    
    /*******************************************************************************************************
    * @description - Recieve data from RetriveMetadata aura component, process it to check if Field API is exist if not append Id to it.
    * @param data - JSON string of retrived file.
    * returns -  "xmlWrapper" wrapper class
    */
    @AuraEnabled
    public static xmlWrapper getFieldNameAPI(string data){
        xmlWrapper strList = (xmlWrapper) JSON.deserialize(data, xmlWrapper.class);
        map<String,String > inputObjFields = getAllfields(strList.InputObject);
        map<String,String > outputObjFields = getAllfields(strList.OutputObject);
        if (strList.Mapping != null || !strList.Mapping.isEmpty()) {
        for(String key: strList.Mapping.keySet()){
            if(key =='inputField'){
                list<String> inputList = strList.Mapping.get(key);
                for (Integer i = 0; i < inputList.size(); i++) {
                     if(inputObjFields.containskey(inputList[i].toLowerCase()))
                        continue;
                    else{
                        inputList[i] = inputList[i]+'id';
                        
                     }
                } 
            }
            
            if(key =='outputField'){
                list<String> outputList = strList.Mapping.get(key);
                for (Integer i = 0; i < outputList.size(); i++) {
                    if(outputObjFields.containskey(outputList[i].toLowerCase()))
                        continue;
                    else{
                        outputList[i] = outputList[i]+'id';
                        
                    }
                        
                }  
            }
                
        }
        }
        
        if (strList.childMapping != null ) {
        map<String,String > childInpObjFields = getAllfields(strList.childInputObject);
        map<String,String > childOutObjFields = getAllfields(strList.childOutputObject);

        for(String key: strList.childMapping.keySet()){
           if(key =='inputField'){
                list<String> inputList = strList.childMapping.get(key);
                for (Integer i = 0; i < inputList.size(); i++) {
                    if(childInpObjFields.containskey(inputList[i].toLowerCase()))
                        continue;
                    else{
                         inputList[i] = inputList[i]+'id';
                     }
                 }   
            }
            
            if(key =='outputField'){
                list<String> outputList = strList.childMapping.get(key);
                for (Integer i = 0; i < outputList.size(); i++) {
                    if(childOutObjFields.containskey(outputList[i].toLowerCase()))
                        continue;
                    else{
                        outputList[i] = outputList[i]+'id';
                     }
                 }  
            }
        }
        }
        return strList;
    }
    
    /*******************************************************************************************************
    * @description - Method to get all Objects details.
    * returns -  Map<String, String>
    */
    @AuraEnabled//Method to get the List of All Objects
    public static Map<String, String> getAllObject(){
        
        Map<String,String> returnObjectMap = new Map<String,String>();
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        
        //get List of all sObject
        List<Schema.SObjectType> objectMapValues = objectMap.Values();
        System.debug('All Objects '+ objectMapValues);
        //sort List
        List<String> allObj = new List<String>();
        for(Schema.SObjectType objType : objectMapValues){
             String name = objType.getDescribe().getName();
             //Removed isCreateable and isUpdateable
             if (!objType.getDescribe().isCustomSetting() &&
                !name.containsignorecase('history') &&!name.containsignorecase('share') &&!name.containsignorecase('__tag')   && !name.containsignorecase('feed')) {
                    allObj.add(objType.getDescribe().getName()+'@!@'+objType.getDescribe().getName());
                   
            }
        }
        allObj.sort();
                
        for(string s : allObj){
            list<string> objName = s.split('@!@');
            returnObjectMap.put(objName[1],objName[0]);
        }
        if(returnObjectMap != null && returnObjectMap.size() > 0){
            return returnObjectMap;
        }else{
            return null;
        }
    }
    
    /*******************************************************************************************************
    * @description - Method to get all the fields of a particular Object.
    * @param ObjectName- the name of the object to look up
    * returns -  Map<String, String>
    */
    @AuraEnabled 
    public static Map<String, String> getAllfields(String objectName){
        Map<String, String> allFields = new  Map<String, String>();
        Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
        SObjectType objType = objectMap.get(objectName);
        
        // Map of fields with api name and Api name as value
        Map<String,Schema.SObjectField> objTypeFields = objType.getDescribe().fields.getMap();
        if(!objTypeFields.isEmpty()){
            list<String> fieldNames = new list<String>();
            for(String fieldName : objTypeFields.keySet()){
                fieldNames.add(objTypeFields.get(fieldName).getDescribe().getLabel()+'@!@'+fieldName);

            }
            fieldNames.sort();
            for (String name: fieldNames) {
                //getting labels of the fields
                list<string> fName = name.split('@!@');
                allFields.put(fName[1],fName[0]);
            }
        }
        System.debug(allFields);
        return allFields;
    }
    
    /*******************************************************************************************************
    * @description - Method to deploy ZIP file into Org using mfcSomMetadatService API's.
    * @param data - ZIP file zipped using JSZIP.
    * returns -  "deploymentResultWrapper" wrapper class
    */
    @AuraEnabled
    public static deploymentResultWrapper deployZIP(String data) {
        deploymentResultWrapper resultWrapper = new deploymentResultWrapper();
        mfcSomMetadatService.MetadataPort service = createService();
        mfcSomMetadatService.DeployOptions deployOptions = new mfcSomMetadatService.DeployOptions();
        deployOptions.allowMissingFiles = false;
        deployOptions.autoUpdatePackage = false;
        deployOptions.checkOnly = false;
        deployOptions.ignoreWarnings = false;
        deployOptions.performRetrieve = false;
        deployOptions.purgeOnDelete = false;
        deployOptions.rollbackOnError = true;
        deployOptions.testLevel = 'NoTestRun';
        deployOptions.singlePackage = true;     
        mfcSomMetadatService.AsyncResult AsyncResult = service.deploy(data, DeployOptions); 
        mfcSomMetadatService.DeployResult deployResult = service.checkDeployStatus(AsyncResult.Id, true);
        if(deployResult.done)
        {
            resultWrapper.isSuccess = 'Deployment Completed';
            // Deployment errors?
            if(deployResult.details!=null && deployResult.details.componentFailures!=null)
                for(mfcSomMetadatService.DeployMessage deployMessage : deployResult.details.componentFailures)
                if(deployMessage.problem!=null)
                resultWrapper.errorMessage = deployMessage.fileName + 
                ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
                deployMessage.problem;
        }
        else{
            resultWrapper.isSuccess = 'Deploying';
        }   
        resultWrapper.data = data;
        resultWrapper.dataId = AsyncResult.Id;
        return resultWrapper;
        
    }
    
    /*******************************************************************************************************
    * @description - Check the status of deployment.
    * @param Id - result Id received from Service.deploy
    * returns -  "deploymentResultWrapper" wrapper class
    */
    @AuraEnabled
    public static deploymentResultWrapper checkAsyncRequest(Id resultId)
    {   
        deploymentResultWrapper resultWrapper = new deploymentResultWrapper();
        // Check the status of the retrieve request
        mfcSomMetadatService.MetadataPort service = createService();
        mfcSomMetadatService.DeployResult deployResult = service.checkDeployStatus(resultId, true);
        if(deployResult.done)
        {
            resultWrapper.isSuccess = 'Deployment was completed.';
            // Deployment errors?
            if(deployResult.details!=null && deployResult.details.componentFailures!=null)
                for(mfcSomMetadatService.DeployMessage deployMessage : deployResult.details.componentFailures)
                if(deployMessage.problem!=null){
                    resultWrapper.isError = true;
                    resultWrapper.errorMessage = deployMessage.fileName + 
                        ' (Line: ' + deployMessage.lineNumber + ': Column:' + deployMessage.columnNumber + ') : ' + 
                        deployMessage.problem;
                }
            
        }
        else{
            resultWrapper.isSuccess = 'Deployment is in progress.';
        }   
        
        return resultWrapper;
    }
    
    /*******************************************************************************************************
    * @description - Create session header to call Metadata API's
    * returns -  mfcSomMetadatService.MetadataPort class
    */
    private static mfcSomMetadatService.MetadataPort createService()
    { 
		string restUrl ='callout:ApexMDAPI/services/data/v53.0/sobjects/Account';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(restUrl);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        mfcSomMetadatService.MetadataPort service = new mfcSomMetadatService.MetadataPort();
        service.SessionHeader = new mfcSomMetadatService.SessionHeader_element();
        /* Named credential*/
        service.SessionHeader.sessionId='{!$Credential.OAuthToken}';
        return service;     
    }
    
    /*******************************************************************************************************
    * @description - Method to get the list of pre-Created Object Hirerchy relationship.
    * returns - List<String> 
    */
    @AuraEnabled
    public static List<String> getOBMfiles(){
        List<String> data = new List<String>();
        Integer METADATA_API_VERSION = 53;
        mfcSomMetadatService.MetadataPort service = createService();                
        List<mfcSomMetadatService.ListMetadataQuery> queries = new List<mfcSomMetadatService.ListMetadataQuery>();      
        mfcSomMetadatService.ListMetadataQuery queryLayout = new mfcSomMetadatService.ListMetadataQuery();
        queryLayout.folder = '';
        queryLayout.type_x = 'ObjectHierarchyRelationship';
        queries.add(queryLayout);       
        mfcSomMetadatService.FileProperties[] fileProperties = service.listMetadata(queries, METADATA_API_VERSION);
        
        // Sort
        List<String> fullNames = new List<String>();
        if(fileProperties!=null)
        {
            for(mfcSomMetadatService.FileProperties fileProperty : fileProperties)
                fullNames.add(fileProperty.fullName);
                fullNames.sort();
                for(String fullName : fullNames)
                    data.add(fullName);
        }
        return data;
    }
    
    /*******************************************************************************************************
    * @description - Retrive the selected Object Hierarchy file details.
    * @param MetaDataItem - Selected File name.
    * returns - "deploymentResultWrapper" wrapper class
    */
    @AuraEnabled
    public static deploymentResultWrapper retrieveMetadataItem(string MetaDataItem)
    {       
        
        //Integer METADATA_API_VERSION = Integer.valueOf(new mfcSomMetadatService.MetadataPort().endpoint_x.substringAfterLast('/'));
        Integer METADATA_API_VERSION = 53;
        deploymentResultWrapper resultWrapper = new deploymentResultWrapper();
        // Construct unmanaged package with list of desired components to retrieve in zip
        mfcSomMetadatService.MetadataPort service = createService();                
        mfcSomMetadatService.RetrieveRequest retrieveRequest = new mfcSomMetadatService.RetrieveRequest();
        retrieveRequest.apiVersion = METADATA_API_VERSION;
        retrieveRequest.packageNames = null;
        retrieveRequest.singlePackage = true;
        retrieveRequest.specificFiles = null;
        retrieveRequest.unpackaged = new mfcSomMetadatService.Package_x();
        retrieveRequest.unpackaged.types = new List<mfcSomMetadatService.PackageTypeMembers>();
        mfcSomMetadatService.PackageTypeMembers packageType = new mfcSomMetadatService.PackageTypeMembers();
        packageType.name = 'ObjectHierarchyRelationship'; 
        // packageType.name = 'ApexClass'; 
        packageType.members = new String[] { '', MetaDataItem };
        retrieveRequest.unpackaged.types.add(packageType);
        try{
            mfcSomMetadatService.AsyncResult AsyncResult = service.retrieve(retrieveRequest);   
            resultWrapper.dataId = AsyncResult.Id;
            resultWrapper.isSuccess = 'Success';
        }catch(Exception e){
            System.debug('Error from ApexController Method' + e.getMessage());
        }
        
        return resultWrapper;   
    }
    
    /*******************************************************************************************************
    * @description - Check the status of retrive request.
    * @param Id - result Id received from Service.retrieve
    * returns -  "deploymentResultWrapper" wrapper class
    */
    @AuraEnabled
    public static deploymentResultWrapper checkAsyncRetriveRequest(Id asyncId)
    {
        deploymentResultWrapper resultWrapper = new deploymentResultWrapper();
        // Check the status of the retrieve request
        mfcSomMetadatService.MetadataPort service = createService();
        mfcSomMetadatService.RetrieveResult retrieveResult = service.checkRetrieveStatus(asyncId, true);
        if(retrieveResult.done)
        {
            // Errors?
            if(retrieveResult.status != 'Succeeded')
            {
                resultWrapper.isError = true;
                resultWrapper.errorMessage = retrieveResult.errorMessage;
            }
            else
            {
                // Place Base64 encoded zip data onto the page for the JSZip library to handle
                String MetaDataRetrieveZip = retrieveResult.zipFile;
                resultWrapper.data = MetaDataRetrieveZip;
                resultWrapper.isSuccess = 'Expanding...';
                
            }
        }
        else
        {
            resultWrapper.isSuccess = 'Retrieving metadata...';
        }   
        
        return resultWrapper;
    }
    
    /*******************************************************************************************************
    * @description - Create XML file for retrived pre-created Object Hierechy file.
    * @param Data - data retrived using JSZIP. 
    * returns -  "xmlWrapper" wrapper class
    */    
    @AuraEnabled 
    public static xmlWrapper parseXMLFile(String data){
        List<String> dataXml = new List<String>();
        xmlWrapper xmldata = new xmlWrapper();
        
        Dom.Document doc = new Dom.Document();  
        doc.load( data );  
        Dom.XMLNode rootElement = doc.getRootElement();  
    
        for ( Dom.XMLNode childElement : rootElement.getChildElements() ) {  
            if( childElement.getName() =='childObjectMapping'){
                map<string,list<string>>mymap=new map<string,list<string>>();
                for ( Dom.XMLNode detailElement : childElement.getChildElements() )  {
                    if(detailElement.getName() == 'inputObject')
                        xmldata.childInputObject = detailElement.getText();
                    if(detailElement.getName() == 'outputObject')
                        xmldata.childOutputObject = detailElement.getText();
                    if(detailElement.getName() == 'mappingFields'){
                        for(Dom.XMLNode childdetailElement : detailElement.getChildElements() ){
                            if(childdetailElement.getName() == 'inputField'){
                                list<String> fieldNames = new list<String>();
                                if(mymap.containsKey(childdetailElement.getName())){
                                    fieldNames= mymap.get(childdetailElement.getName());
                                    
                                }
                                fieldNames.add(childdetailElement.getText());
                                mymap.put(childdetailElement.getName(),fieldNames);
                            }
                            if(childdetailElement.getName() == 'outputField'){
                                list<String> fieldNames = new list<String>();
                                if(mymap.containsKey(childdetailElement.getName())){
                                    fieldNames= mymap.get(childdetailElement.getName());
                                 }
                                fieldNames.add(childdetailElement.getText());
                                mymap.put(childdetailElement.getName(),fieldNames);
                            }
                         }
                    }
                    
                    xmldata.childMapping = mymap;
                }
            }
            
            
            if( childElement.getName() =='parentObjectMapping'){
                map<string,list<string>>mymap=new map<string,list<string>>();
                for ( Dom.XMLNode detailElement : childElement.getChildElements() )  {
                    if(detailElement.getName() == 'inputObject')
                        xmldata.InputObject = detailElement.getText();
                    if(detailElement.getName() == 'outputObject')
                        xmldata.OutputObject = detailElement.getText();
                    
                    if(detailElement.getName() == 'mappingFields'){
                        for(Dom.XMLNode childdetailElement : detailElement.getChildElements() ){
                            if(childdetailElement.getName() == 'inputField'){
                                list<String> fieldNames = new list<String>();
                                if(mymap.containsKey(childdetailElement.getName())){
                                    fieldNames= mymap.get(childdetailElement.getName());
                                    
                                }
                                fieldNames.add(childdetailElement.getText());
                                mymap.put(childdetailElement.getName(),fieldNames);
                            }
                            if(childdetailElement.getName() == 'outputField'){
                                 list<String> fieldNames = new list<String>();
                                if(mymap.containsKey(childdetailElement.getName())){
                                    fieldNames= mymap.get(childdetailElement.getName());
                                    
                                }
                                fieldNames.add(childdetailElement.getText());
                                mymap.put(childdetailElement.getName(),fieldNames);
                            }
                            
                        }
                    }
                    
                    xmldata.Mapping = mymap;
                }
            }
            if(childElement.getName() == 'usageType')
            {   
                xmlData.UsageType = childElement.getText();
            }
            
        }  
        return xmldata;
    }
    
    /*******************************************************************************************************
    * @description - Delete Pre-created Object Hierarchy relationship file.
    * @param Name -Name of the file to delete
    */  
    @AuraEnabled 
    public static void deleteOBR(string name)
    {
        mfcSomMetadatService.MetadataPort service = createService();
        List<mfcSomMetadatService.DeleteResult> results =service.deleteMetadata('ObjectHierarchyRelationship', new String[] { name });
        handleDeleteResults(results[0]);}
    
    
    /*******************************************************************************************************
    * @description - helper method to interpret a SaveResult, throws an exception if errors are found
    * @param deleteResult - Result received from service.deleteMetadata().
    */
    public static void handleDeleteResults(mfcSomMetadatService.DeleteResult deleteResult)
    {
        // Nothing to see?
        if(deleteResult==null || deleteResult.success){
            return ;
          }
        // Construct error message and throw an exception
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                'occured processing component ' + deleteResult.fullName + '.');
            for(mfcSomMetadatService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                     ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new mfcSomMetadatServiceExamplesException(String.join(messages, ' '));
            
        }
        
     }
    
    public class mfcSomMetadatServiceExamplesException extends Exception { }
    
    public class deploymentResultWrapper{
        @AuraEnabled public string errorMessage{get;set;}
        @AuraEnabled public boolean isError = false;
        @AuraEnabled public string isSuccess{get;set;}
        @AuraEnabled public string data{get;set;}
        @AuraEnabled public string dataId{get;set;}
    }
    
    public class xmlWrapper{
        @AuraEnabled public string childInputObject{get;set;}
        @AuraEnabled public string childOutputObject  {get;set;}
        @AuraEnabled public string InputObject {get;set;}
        @AuraEnabled public string OutputObject {get;set;}
        @AuraEnabled public string UsageType {get;set;}
        @AuraEnabled public Map<string,list<String>> childMapping{get;set;}
        @AuraEnabled public Map<string,list<String>>  Mapping{get;set;}
    }
    
    /*******************************************************************************************************
    * @description - Create XML file based on Selected option from Screen.
    * @param parentData - Get Parent Object Mapping details
    * @param childData - Get Child Object Mapping details
    * @param usageType - UsageType Selected from Screen
    * @param File - FileName selected from Screen
    * return - Map<String, String> - FileName with XML contents.
    */
    @AuraEnabled 
    public static  Map<String, String> updateFieldDatav1(String parentData,String childData,String usageType,String fileName){
        List<dataWrapper>  wraperClassVar  = (list<dataWrapper>) System.JSON.deserialize(parentData,List<dataWrapper>.class);
        string data;
        Map<String, String> resultsData = new Map<String, String>();
        XmlStreamWriter writer = new XmlStreamWriter();
        writer.writeStartDocument('UTF-8', '1.0');  
        writer.writeStartElement(null,'ObjectHierarchyRelationship', null);
        writer.writeAttribute(null,null,'xmlns','http://soap.sforce.com/2006/04/metadata');
        writer.writeStartElement(null, 'parentObjectMapping', null);
        for(dataWrapper indata:  wraperClassVar){
            if(indata.Mapping != null){
        
        writer.writeStartElement(null, 'inputObject', null);
        writer.writeCharacters(indata.inputObject);
        writer.writeEndElement();
        writer.writeStartElement(null, 'outputObject', null);
        writer.writeCharacters(indata.outputObject);
        writer.writeEndElement();
        
       for(Mapping maps : indata.Mapping){
            writer.writeStartElement(null, 'mappingFields', null);
            writer.writeStartElement(null, 'inputField', null);
            writer.writeCharacters(maps.inputField);
            writer.writeEndElement(); 
            writer.writeStartElement(null, 'outputField', null);
            writer.writeCharacters(maps.outputField);
            writer.writeEndElement(); 
            writer.writeEndElement(); 
        }
        }
        }
        writer.writeEndElement();
        
        if(childData != null && String.isNotEmpty(childData)){
        List<childdataWrapper>  wrapClass  = (list<childdataWrapper>) System.JSON.deserialize(childData,List<childdataWrapper>.class);
        for(childdataWrapper dataout:  wrapClass){
            if(dataout.inputObject != null){
            if(dataout.mapping != Null ){
            writer.writeStartElement(null, 'childObjectMapping', null);
            writer.writeStartElement(null, 'inputObject', null);
            writer.writeCharacters(dataout.inputObject);
            writer.writeEndElement();
            writer.writeStartElement(null, 'outputObject', null);
            writer.writeCharacters(dataout.outputObject);
            writer.writeEndElement();
            
            for(childMapping acc :dataout.mapping){
                writer.writeStartElement(null, 'mappingFields', null);
                writer.writeStartElement(null, 'inputField', null);
                writer.writeCharacters(acc.childInputField);
                writer.writeEndElement(); 
                writer.writeStartElement(null, 'outputField', null);
                writer.writeCharacters(acc.childOutputField);
                writer.writeEndElement(); 
                writer.writeEndElement(); 
            }
            writer.writeEndElement();
            }
        }
        }
        }
        writer.writeStartElement(null, 'usageType', null);
        writer.writeCharacters(usageType);
        writer.writeEndElement();
        writer.writeEndElement();
        data = writer.getXmlString();
        writer.close();  
        String filenames = fileName +'.settings';
        resultsData.put(filenames, EncodingUtil.base64Encode(Blob.valueOf(data)));
        String getPackageXml = getPackageXml();
        resultsData.put('package.xml', EncodingUtil.base64Encode(Blob.valueOf(getPackageXml)));
        return resultsData;
    }
    
    public class dataWrapper {

    public List<Mapping> mapping;
    public String inputObject;
    public String outputObject;
    }
    public class Mapping {
        public String inputField;
        public String outputField;
    }
    
    public class childdataWrapper {

    public List<childMapping> mapping;
    public String inputObject;
    public String outputObject;
    }
    public class childMapping {
        public String childInputField;
        public String childOutputField;
    }
}