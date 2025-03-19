@isTest
public class mfcSomDataProvider_TEST{
    
	private class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
            if(request instanceof mfcSomMetadatService.retrieve_element){
                mfcSomMetadatService.retrieveResponse_element reRes =new mfcSomMetadatService.retrieveResponse_element();
                mfcSomMetadatService.AsyncResult res =  new mfcSomMetadatService.AsyncResult();
                res.Id = '001x00000000000AAA';
                res.done =true;
                reRes.result = res;
                response.put('response_x', reRes);
            }else if(request instanceof mfcSomMetadatService.checkDeployStatus_element){
                mfcSomMetadatService.checkDeployStatusResponse_element  checkres =  new mfcSomMetadatService.checkDeployStatusResponse_element();
                mfcSomMetadatService.DeployResult depres = new  mfcSomMetadatService.DeployResult();
                mfcSomMetadatService.DeployDetails depDetailsres = new  mfcSomMetadatService.DeployDetails();
                mfcSomMetadatService.DeployMessage[] mockdeployMsgs =  new List<mfcSomMetadatService.DeployMessage>();
                mfcSomMetadatService.DeployMessage mockdeployMsg =  new mfcSomMetadatService.DeployMessage();
                mockdeployMsg.problem = 'test';
                mockdeployMsg.fileName ='testFileName';
                mockdeployMsgs.add(mockdeployMsg);
                depDetailsres.componentFailures =mockdeployMsgs;
                depDetailsres.componentSuccesses =mockdeployMsgs;
                depres.done =  true;
                depres.details = depDetailsres;
                checkres.result = depres;
                response.put('response_x', checkres);
            }
				//response.put('response_x', new mfcSomMetadatService.checkDeployStatusResponse_element());
            else if(request instanceof mfcSomMetadatService.listMetadata_element){
            	mfcSomMetadatService.listMetadataResponse_element liststatus = new mfcSomMetadatService.listMetadataResponse_element();
                mfcSomMetadatService.FileProperties[] fileRes = new list<mfcSomMetadatService.FileProperties>();
                mfcSomMetadatService.FileProperties files = new mfcSomMetadatService.FileProperties();
                files.createdByName = 'swapna';
                files.createdDate =system.today();
                files.fileName ='Test';
                files.fullName ='TestData';
                files.id = '001x00000000000AAA';
                fileRes.add(files);
                liststatus.result = fileRes;
                response.put('response_x', liststatus);
                //response.put('response_x', new mfcSomMetadatService.listMetadataResponse_element());
            }else if(request instanceof mfcSomMetadatService.checkRetrieveStatus_element){
                mfcSomMetadatService.checkRetrieveStatusResponse_element checkStatus = new mfcSomMetadatService.checkRetrieveStatusResponse_element();
				mfcSomMetadatService.RetrieveResult results = new mfcSomMetadatService.RetrieveResult();
               		results.done = true;
                	results.status ='Succeeded';
                    results.errorMessage ='errorMessage';
                checkStatus.result = results;
                response.put('response_x', checkStatus);
            }
				//response.put('response_x', new mfcSomMetadatService.checkRetrieveStatusResponse_element());
			else if(request instanceof mfcSomMetadatService.describeMetadata_element)
				response.put('response_x', new mfcSomMetadatService.describeMetadataResponse_element());
            else if(request instanceof mfcSomMetadatService.deploy_element){
                mfcSomMetadatService.AsyncResult result ;
                mfcSomMetadatService.AsyncResult res =  new mfcSomMetadatService.AsyncResult();
                
                res.Id = '001x00000000000AAA';
                res.done =true;
                result =res;
                mfcSomMetadatService.deployResponse_element depRes = new  mfcSomMetadatService.deployResponse_element();
                 depRes.result = result;
                 response.put('response_x', depRes);
        		 
            }
				//response.put('response_x', new mfcSomMetadatService.deployResponse_element());
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
            return;
		}
	}    
    private class mfcSomDataProvider_HCM_TEST implements HttpCalloutMock{
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String,String> headers;
        public mfcSomDataProvider_HCM_TEST(Integer code,String status,String body,Map<String,String> headers){
            this.code=code;
            this.status=status;
            this.body=body;
            this.headers=headers;
        }
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res=new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(this.body);
            if(this.headers!=null){
                for(String key:this.headers.keySet()){
                    res.setHeader(key,this.headers.get(key));
                }
            }
            return res;
        }
    }
    @isTest
    private static void getPackageXml_TEST(){
        Test.startTest();
        String res = mfcSomDataProvider.getPackageXml();
        string checkres = '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
            '<types>' + 
            '<members>*</members>' +
            '<name>ObjectHierarchyRelationship</name>' + 
            '</types>' + 
            '<version>53.0</version>' + 
            '</Package>';	
        system.assertEquals(res, checkres);
        Test.stopTest();
    }
    @isTest
    private static void getAllObject_TEST(){
        Test.startTest();
        Map<String, String> allObj = mfcSomDataProvider.getAllObject();
        system.assert(allObj.containsKey('Account'), allObj);
        Test.stopTest();
    }
    @isTest
    private static void getAllfields_TEST(){
        Test.startTest();
        string name = 'Account';
        Map<String, String> allField = mfcSomDataProvider.getAllfields(name);
        system.assert(allField.containsKey('accountnumber'), allField);
        Test.stopTest();
    }
    
    @isTest
    private static void updateFieldDatav1_TEST(){
        mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        String parentdata = '[{\"mapping\":[{\"inputField\":\"AccountId\",\"outputField\":\"ContactId\"}],\"inputObject\":\"Account\",\"outputObject\":\"Contact\"}]';
        String childdata = '[{\"mapping\":[{\"childInputField\":\"OrderId\",\"childOutputField\":\"LeadID\"}],\"inputObject\":\"Order\",\"outputObject\":\"Lead\"}]';
        Map<String, String> response = mfcSomDataProvider.updateFieldDatav1(parentdata,childdata,'EligibleProgramRebateType','OrderLead');
        system.assert(response.containsKey('package.xml'), response);
        system.assert(response.containsKey('OrderLead.settings'), response);
        Test.stopTest();
    }
    
    @isTest
    private static void deployZIP_TEST(){
         mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        string data = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48UGFja2FnZSB4bWxucz0iaHR0cDovL3NvYXAuc2ZvcmNlLmNvbS8yMDA2LzA0L21ldGFkYXRhIj48dHlwZXM+PG1lbWJlcnM+KjwvbWVtYmVycz48bmFtZT5PYmplY3RIaWVyYXJjaHlSZWxhdGlvbnNoaXA8L25hbWU+PC90eXBlcz48dmVyc2lvbj41My4wPC92ZXJzaW9uPjwvUGFja2FnZT4=';
        mfcSomDataProvider.deploymentResultWrapper depres = mfcSomDataProvider.deployZIP(data);
         system.assertEquals('Deployment Completed', depres.isSuccess);
        mfcSomDataProvider.deployZIP(null);
        //metaDataPort.checkDeployStatus(null, false);
        Test.stopTest();
    }
    @isTest
    private static void checkAsyncRequest_TEST(){
         mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        mfcSomDataProvider.deploymentResultWrapper depres = mfcSomDataProvider.checkAsyncRequest('001x00000000000AAA');
        system.assertEquals('Deployment was completed.', depres.isSuccess);
        Test.stopTest();
    }
    
    @isTest
    private static void getOBMfiles_TEST(){
         mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        string data = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48UGFja2FnZSB4bWxucz0iaHR0cDovL3NvYXAuc2ZvcmNlLmNvbS8yMDA2LzA0L21ldGFkYXRhIj48dHlwZXM+PG1lbWJlcnM+KjwvbWVtYmVycz48bmFtZT5PYmplY3RIaWVyYXJjaHlSZWxhdGlvbnNoaXA8L25hbWU+PC90eXBlcz48dmVyc2lvbj41My4wPC92ZXJzaW9uPjwvUGFja2FnZT4=';
        mfcSomDataProvider.deploymentResultWrapper depres = mfcSomDataProvider.deployZIP(data);
        list<String> files = mfcSomDataProvider.getOBMfiles();
        system.assertEquals('Deployment Completed', depres.isSuccess);
         system.assertEquals('TestData', files[0]);
        Test.stopTest();
    }
    @isTest
    private static void retrieveMetadataItem_TEST(){
         mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        mfcSomDataProvider.deploymentResultWrapper results = mfcSomDataProvider.retrieveMetadataItem('Test');
        system.assertEquals('Success', results.isSuccess);
        system.assertEquals('001x00000000000AAA', results.dataId);
        Test.stopTest();
    }
    @isTest
    private static void checkAsyncRetriveRequest_TEST(){
         mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        Test.startTest();
        mfcSomDataProvider.deploymentResultWrapper results = mfcSomDataProvider.checkAsyncRetriveRequest('001x00000000000AAA');
        system.assertEquals('Expanding...', results.isSuccess);
        Test.stopTest();
    }
    @isTest
    private static void parseXMLFile_TEST(){
        Test.startTest();
        string bodyXMLFinal = '<?xml version="1.0" encoding="UTF-8"?><ObjectHierarchyRelationship xmlns="http://soap.sforce.com/2006/04/metadata"><parentObjectMapping><inputObject>Contract</inputObject><outputObject>OrderItem</outputObject><mappingFields><inputField>BillingPostalCode</inputField><outputField>Order</outputField></mappingFields></parentObjectMapping><childObjectMapping><inputObject>Contract</inputObject><outputObject>OrderItem</outputObject><mappingFields><inputField>BillingPostalCode</inputField><outputField>Order</outputField></mappingFields></childObjectMapping> <usageType>EligibleProgramRebateType</usageType></ObjectHierarchyRelationship>';
        mfcSomDataProvider.xmlWrapper responsedata = mfcSomDataProvider.parseXMLFile(bodyXMLFinal);
        System.assert(responsedata != null);
        System.assertEquals('Contract',responsedata.InputObject);
        Test.stopTest();
    }
    
    @isTest
    private static void getFieldNameAPI_TEST(){
        Test.startTest();
        String data = '{"InputObject":"Account","Mapping":{"inputField":["AccountId"],"outputField":["ContactId"]},"OutputObject":"Contact"}';
        string datachild = '{"childInputObject":"Order","childMapping":{"inputField":["OrderId"],"outputField":["LeadID"]},"childOutputObject":"Lead","InputObject":"Account","Mapping":{"inputField":["AccountId"],"outputField":["ContactId"]},"OutputObject":"Contact"}';
        mfcSomDataProvider.xmlWrapper responsedata = mfcSomDataProvider.getFieldNameAPI(data);
        System.assert(responsedata != null);
        System.assertEquals('Account',responsedata.InputObject);
        mfcSomDataProvider.xmlWrapper responsedata1 = mfcSomDataProvider.getFieldNameAPI(datachild);
        System.assert(responsedata1 != null);
        System.assertEquals('Order',responsedata1.childInputObject);
        Test.stopTest();
    }
    @isTest
    private static void deleteOBR_TEST(){
        Test.startTest();
        mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        try{
        mfcSomDataProvider.deleteOBR('a');
        }catch(Exception e){}
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','null',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        try{
        mfcSomDataProvider.deleteOBR('');
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    private static void handleDeleteResults_TEST(){
        Test.startTest();
        mfcSomDataProvider_HCM_TEST httpMock;
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','{}',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        try{
        mfcSomDataProvider.handleDeleteResults(null);
        }catch(Exception e){}
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','{}',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        mfcSomMetadatService.DeleteResult var1 = new mfcSomMetadatService.DeleteResult();
        var1.success=true;
        try{
        mfcSomDataProvider.handleDeleteResults(var1);
        }catch(Exception e){}
        httpMock=new mfcSomDataProvider_HCM_TEST(200,'Complete','{}',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        mfcSomMetadatService.DeleteResult var2 = new mfcSomMetadatService.DeleteResult();
        var2.errors=new List<mfcSomMetadatService.Error>();
        try{
        mfcSomDataProvider.handleDeleteResults(var2);
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    private static void mfcSomDataProvider_TEST(){
        mfcSomDataProvider obj = new mfcSomDataProvider();
    }
    @isTest
    private static void deploymentResultWrapper_TEST(){
        mfcSomDataProvider.deploymentResultWrapper obj = new mfcSomDataProvider.deploymentResultWrapper();
    }
    @isTest
    private static void xmlWrapper_TEST(){
        mfcSomDataProvider.xmlWrapper obj = new mfcSomDataProvider.xmlWrapper();
    }
}