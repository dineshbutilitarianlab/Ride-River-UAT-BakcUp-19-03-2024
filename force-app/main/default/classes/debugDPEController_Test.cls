@IsTest
public class debugDPEController_Test {
    private class debugDPEController_HCM_TEST implements HttpCalloutMock{
        protected Integer code;
        protected String status;
        protected String body;
        protected Map<String,String> headers;
        public debugDPEController_HCM_TEST(Integer code,String status,String body,Map<String,String> headers){
            this.code=code;
            this.status=status;
            this.body=body;
            this.headers=headers;
        }
        public HTTPResponse respond(HTTPRequest req){
            HttpResponse res=new HttpResponse();
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            res.setBody(debugDPETestUtility.buildresponsejson());
            if(this.headers!=null){
                for(String key:this.headers.keySet()){
                    res.setHeader(key,this.headers.get(key));
                }
            }
            return res;
        }
    }
    
    @isTest(SeeAllData=true)
    private static void getDPEList_TEST(){
        Test.startTest();
        List<BatchCalcJobDefinition> allDPE = debugDPEController.getDPEList();
        Test.stopTest();
    }
    
    
    @isTest
    private static void updateDPEFile_TEST(){
        debugDPEController_HCM_TEST httpMock;
        Test.setMock(HttpCalloutMock.class,httpMock);
        Test.startTest();
        String fileData = debugDPETestUtility.buildjson();
        List<String> dataSource = new List<String>();
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        debugDPEController.updateDPEFile(fileData,dataSource,filename);
        Test.stopTest();
    }
    
    @isTest
    private static void updateDPEFilev1_TEST(){
        debugDPEController_HCM_TEST httpMock;
        Test.setMock(HttpCalloutMock.class,httpMock);
        Test.startTest();
        String fileData = debugDPETestUtility.buildjsonv1();
        List<String> dataSource = new List<String>();
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        debugDPEController.updateDPEFile(fileData,dataSource,filename);
        Test.stopTest();
    }
    
    @isTest
    private static void getDPEMetadata_TEST(){
        debugDPEController_HCM_TEST httpMock;
        httpMock=new debugDPEController_HCM_TEST(200,'Complete','{}',null);
        Test.setMock(HttpCalloutMock.class,httpMock);
        Test.startTest();
        String fileData = debugDPETestUtility.buildjson();
        debugDPEController.getDPEMetadata('');
        Test.stopTest();
    }    
    @isTest
    Private static void testParse() {
		String json = debugDPETestUtility.buildjson();
		DPEWrapper obj = DPEWrapper.parse(json);
		System.assert(obj != null);
	}
}