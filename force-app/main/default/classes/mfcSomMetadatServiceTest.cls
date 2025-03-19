@isTest  
private class mfcSomMetadatServiceTest
{    
    /**
* Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
**/
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof mfcSomMetadatService.retrieve_element)
                response.put('response_x', new mfcSomMetadatService.retrieveResponse_element());
            else if(request instanceof mfcSomMetadatService.checkDeployStatus_element)
                response.put('response_x', new mfcSomMetadatService.checkDeployStatusResponse_element());
            else if(request instanceof mfcSomMetadatService.listMetadata_element)
                response.put('response_x', new mfcSomMetadatService.listMetadataResponse_element());
            else if(request instanceof mfcSomMetadatService.checkRetrieveStatus_element)
                response.put('response_x', new mfcSomMetadatService.checkRetrieveStatusResponse_element());
            else if(request instanceof mfcSomMetadatService.describeMetadata_element)
                response.put('response_x', new mfcSomMetadatService.describeMetadataResponse_element());
            else if(request instanceof mfcSomMetadatService.deploy_element)
                response.put('response_x', new mfcSomMetadatService.deployResponse_element());
            else if(request instanceof mfcSomMetadatService.updateMetadata_element)
                response.put('response_x', new mfcSomMetadatService.updateMetadataResponse_element());
            else if(request instanceof mfcSomMetadatService.renameMetadata_element)
                response.put('response_x', new mfcSomMetadatService.renameMetadataResponse_element());
            else if(request instanceof  mfcSomMetadatService.cancelDeploy_element)
                response.put('response_x', new mfcSomMetadatService.cancelDeployResponse_element());
            else if(request instanceof  mfcSomMetadatService.deleteMetadata_element)
                response.put('response_x', new mfcSomMetadatService.deleteMetadataResponse_element());
            else if(request instanceof  mfcSomMetadatService.upsertMetadata_element)
                response.put('response_x', new mfcSomMetadatService.upsertMetadataResponse_element());
            else if(request instanceof  mfcSomMetadatService.createMetadata_element)
                response.put('response_x', new mfcSomMetadatService.createMetadataResponse_element());
            else if(request instanceof  mfcSomMetadatService.deployRecentValidation_element)
                response.put('response_x', new mfcSomMetadatService.deployRecentValidationResponse_element());
            else if(request instanceof mfcSomMetadatService.describeValueType_element)
                response.put('response_x', new mfcSomMetadatService.describeValueTypeResponse_element());
            else if(request instanceof mfcSomMetadatService.checkRetrieveStatus_element)
                response.put('response_x', new mfcSomMetadatService.checkRetrieveStatusResponse_element());
            return;
        }
    }    
    
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
        
    {	
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        mfcSomMetadatService mfcSomMetadatService = new mfcSomMetadatService();
        // Invoke operations     
        Test.startTest();    
        mfcSomMetadatService.MetadataPort metaDataPort = new mfcSomMetadatService.MetadataPort();
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {    	
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        mfcSomMetadatService mfcSomMetadatService = new mfcSomMetadatService();
        // Invoke operations    
        Test.startTest();     
        mfcSomMetadatService.MetadataPort metaDataPort = new mfcSomMetadatService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        mfcSomMetadatService mfcSomMetadatService = new mfcSomMetadatService();
        // Invoke operations     
        Test.startTest();    
        mfcSomMetadatService.MetadataPort metaDataPort = new mfcSomMetadatService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        Test.startTest();
        new mfcSomMetadatService();
        new mfcSomMetadatService.SaveResult();
        new mfcSomMetadatService.readMetadataResponse_element();
        new mfcSomMetadatService.ReadResult();
        new mfcSomMetadatService.RunTestSuccess();
        new mfcSomMetadatService.RetrieveMessage();
        new mfcSomMetadatService.DebuggingHeader_element();
        new mfcSomMetadatService.LogInfo();
        new mfcSomMetadatService.updateMetadataResponse_element();
        new mfcSomMetadatService.renameMetadataResponse_element();
        new mfcSomMetadatService.deleteMetadataResponse_element();
        new mfcSomMetadatService.AllOrNoneHeader_element();
        new mfcSomMetadatService.SessionHeader_element();
        new mfcSomMetadatService.CallOptions_element();
        new mfcSomMetadatService.PackageTypeMembers();
        new mfcSomMetadatService.PicklistEntry();
        new mfcSomMetadatService.RunTestFailure();
        new mfcSomMetadatService.ValueTypeField();
        new mfcSomMetadatService.CodeLocation();
        new mfcSomMetadatService.CodeCoverageWarning();
        new mfcSomMetadatService.listMetadataResponse_element();
        new mfcSomMetadatService.ListMetadataQuery();
        new mfcSomMetadatService.UpsertResult(); 
        new mfcSomMetadatService.retrieve_element();
        new mfcSomMetadatService.DeleteResult();
        new mfcSomMetadatService.PackageVersion();
        new mfcSomMetadatService.DescribeMetadataObject();
        new mfcSomMetadatService.listMetadata_element();
        new mfcSomMetadatService.DeployDetails();
        new mfcSomMetadatService.deployRecentValidationResponse_element();
        new mfcSomMetadatService.deployRecentValidation_element();
        new mfcSomMetadatService.DeployOptions();
        new mfcSomMetadatService.RetrieveRequest();
        new mfcSomMetadatService.AsyncResult();
        new mfcSomMetadatService.checkRetrieveStatusResponse_element();
        new mfcSomMetadatService.retrieveResponse_element();
        new mfcSomMetadatService.upsertMetadataResponse_element();
        new mfcSomMetadatService.cancelDeploy_element();
        new mfcSomMetadatService.updateMetadata_element();
        new mfcSomMetadatService.CancelDeployResult();
        new mfcSomMetadatService.upsertMetadata_element();
        new mfcSomMetadatService.describeMetadata_element();
        new mfcSomMetadatService.createMetadataResponse_element();
        new mfcSomMetadatService.readMetadata_element();
        new mfcSomMetadatService.DescribeValueTypeResult();
        new mfcSomMetadatService.DescribeMetadataResult();
        new mfcSomMetadatService.FileProperties();
        new mfcSomMetadatService.deleteMetadata_element();
        new mfcSomMetadatService.RetrieveResult();
        new mfcSomMetadatService.cancelDeployResponse_element();
        new mfcSomMetadatService.DeployMessage();
        new mfcSomMetadatService.ProfileObjectPermissions();
        new mfcSomMetadatService.checkRetrieveStatus_element();
        new mfcSomMetadatService.Package_x();
        new mfcSomMetadatService.Error();
        new mfcSomMetadatService.deploy_element();
        new mfcSomMetadatService.DeployResult();
        new mfcSomMetadatService.createMetadata_element();
        new mfcSomMetadatService.renameMetadata_element();
        new mfcSomMetadatService.describeMetadataResponse_element();
        new mfcSomMetadatService.deployResponse_element();
        new mfcSomMetadatService.checkDeployStatus_element();
        new mfcSomMetadatService.checkDeployStatusResponse_element();
        new mfcSomMetadatService.describeValueType_element();
        new mfcSomMetadatService.CodeCoverageResult();
        new mfcSomMetadatService.RunTestsResult();
        
        Test.stopTest();
    } 
    
    
}