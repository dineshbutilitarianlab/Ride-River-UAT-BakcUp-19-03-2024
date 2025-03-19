public class mfcSomMetadatService {
	
	public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';
    public class SaveResult {
        public mfcSomMetadatService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
    public class readMetadataResponse_element {
        public mfcSomMetadatService.ReadResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
     public class ReadResult {
        public mfcSomMetadatService.Metadata[] records;
        private String[] records_type_info = new String[]{'records',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'records'};
    }
    public class RunTestSuccess {
        public String id;
        public String methodName;
        public String name;
        public String namespace;
        public Boolean seeAllData;
        public Double time_x;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','methodName','name','namespace','seeAllData','time_x'};
    }
    public class RetrieveMessage {
        public String fileName;
        public String problem;
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fileName','problem'};
    }
     public class DebuggingInfo_element {
        public String debugLog;
        private String[] debugLog_type_info = new String[]{'debugLog',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'debugLog'};
    }
    public class DebuggingHeader_element {
        public mfcSomMetadatService.LogInfo[] categories;
        public String debugLevel;
        private String[] categories_type_info = new String[]{'categories',SOAP_M_URI,null,'0','-1','false'};
        private String[] debugLevel_type_info = new String[]{'debugLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'categories','debugLevel'};
    }
    public class LogInfo {
        public String category;
        public String level;
        private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
        private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'category','level'};
    }
    public class describeValueTypeResponse_element {
        public mfcSomMetadatService.DescribeValueTypeResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class updateMetadataResponse_element {
        public mfcSomMetadatService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class renameMetadataResponse_element {
        public mfcSomMetadatService.SaveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class deleteMetadataResponse_element {
        public mfcSomMetadatService.DeleteResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class AllOrNoneHeader_element {
        public Boolean allOrNone;
        private String[] allOrNone_type_info = new String[]{'allOrNone',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allOrNone'};
    }
     public class SessionHeader_element {
        public String sessionId;
        private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'sessionId'};
    }
    public class CallOptions_element {
        public String client;
        private String[] client_type_info = new String[]{'client',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'client'};
    }
    public class PackageTypeMembers {
        public String[] members;
        public String name;
        private String[] members_type_info = new String[]{'members',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'members','name'};
    }
    public class ExtendedErrorDetails {
        public String extendedErrorCode;
        private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorCode'};
    }
    public class PicklistEntry {
        public Boolean active;
        public Boolean defaultValue;
        public String label;
        public String validFor;
        public String value;
        private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
        private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'1','1','false'};
        private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
        private String[] validFor_type_info = new String[]{'validFor',SOAP_M_URI,null,'0','1','false'};
        private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'active','defaultValue','label','validFor','value'};
    }
    public class RunTestFailure {
        public String id;
        public String message;
        public String methodName;
        public String name;
        public String namespace;
        public String packageName;
        public Boolean seeAllData;
        public String stackTrace;
        public Double time_x;
        public String type_x;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','true'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] packageName_type_info = new String[]{'packageName',SOAP_M_URI,null,'1','1','false'};
        private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
        private String[] stackTrace_type_info = new String[]{'stackTrace',SOAP_M_URI,null,'1','1','true'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','message','methodName','name','namespace','packageName','seeAllData','stackTrace','time_x','type_x'};
    }
    public class ValueTypeField {
        public mfcSomMetadatService.ValueTypeField[] fields;
        public String[] foreignKeyDomain;
        public Boolean isForeignKey;
        public Boolean isNameField;
        public Integer minOccurs;
        public String name;
        public mfcSomMetadatService.PicklistEntry[] picklistValues;
        public String soapType;
        public Boolean valueRequired;
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] foreignKeyDomain_type_info = new String[]{'foreignKeyDomain',SOAP_M_URI,null,'0','-1','false'};
        private String[] isForeignKey_type_info = new String[]{'isForeignKey',SOAP_M_URI,null,'1','1','false'};
        private String[] isNameField_type_info = new String[]{'isNameField',SOAP_M_URI,null,'1','1','false'};
        private String[] minOccurs_type_info = new String[]{'minOccurs',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] picklistValues_type_info = new String[]{'picklistValues',SOAP_M_URI,null,'0','-1','false'};
        private String[] soapType_type_info = new String[]{'soapType',SOAP_M_URI,null,'1','1','false'};
        private String[] valueRequired_type_info = new String[]{'valueRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'fields','foreignKeyDomain','isForeignKey','isNameField','minOccurs','name','picklistValues','soapType','valueRequired'};
    }
    public class CodeLocation {
        public Integer column;
        public Integer line;
        public Integer numExecutions;
        public Double time_x;
        private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
        private String[] line_type_info = new String[]{'line',SOAP_M_URI,null,'1','1','false'};
        private String[] numExecutions_type_info = new String[]{'numExecutions',SOAP_M_URI,null,'1','1','false'};
        private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'column','line','numExecutions','time_x'};
    }
    public class CodeCoverageWarning {
        public String id;
        public String message;
        public String name;
        public String namespace;
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','true'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'id','message','name','namespace'};
    }
     public class listMetadataResponse_element {
        public mfcSomMetadatService.FileProperties[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class CodeCoverageResult {
        public mfcSomMetadatService.CodeLocation[] dmlInfo;
        public String id;
        public mfcSomMetadatService.CodeLocation[] locationsNotCovered;
        public mfcSomMetadatService.CodeLocation[] methodInfo;
        public String name;
        public String namespace;
        public Integer numLocations;
        public Integer numLocationsNotCovered;
        public mfcSomMetadatService.CodeLocation[] soqlInfo;
        public mfcSomMetadatService.CodeLocation[] soslInfo;
        public String type_x;
        private String[] dmlInfo_type_info = new String[]{'dmlInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] locationsNotCovered_type_info = new String[]{'locationsNotCovered',SOAP_M_URI,null,'0','-1','false'};
        private String[] methodInfo_type_info = new String[]{'methodInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
        private String[] numLocations_type_info = new String[]{'numLocations',SOAP_M_URI,null,'1','1','false'};
        private String[] numLocationsNotCovered_type_info = new String[]{'numLocationsNotCovered',SOAP_M_URI,null,'1','1','false'};
        private String[] soqlInfo_type_info = new String[]{'soqlInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] soslInfo_type_info = new String[]{'soslInfo',SOAP_M_URI,null,'0','-1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'dmlInfo','id','locationsNotCovered','methodInfo','name','namespace','numLocations','numLocationsNotCovered','soqlInfo','soslInfo','type_x'};
    }
    public class RunTestsResult {
        public String apexLogId;
        public mfcSomMetadatService.CodeCoverageResult[] codeCoverage;
        public mfcSomMetadatService.CodeCoverageWarning[] codeCoverageWarnings;
        public mfcSomMetadatService.RunTestFailure[] failures;
        public Integer numFailures;
        public Integer numTestsRun;
        public mfcSomMetadatService.RunTestSuccess[] successes;
        public Double totalTime;
        private String[] apexLogId_type_info = new String[]{'apexLogId',SOAP_M_URI,null,'0','1','false'};
        private String[] codeCoverage_type_info = new String[]{'codeCoverage',SOAP_M_URI,null,'0','-1','false'};
        private String[] codeCoverageWarnings_type_info = new String[]{'codeCoverageWarnings',SOAP_M_URI,null,'0','-1','false'};
        private String[] failures_type_info = new String[]{'failures',SOAP_M_URI,null,'0','-1','false'};
        private String[] numFailures_type_info = new String[]{'numFailures',SOAP_M_URI,null,'1','1','false'};
        private String[] numTestsRun_type_info = new String[]{'numTestsRun',SOAP_M_URI,null,'1','1','false'};
        private String[] successes_type_info = new String[]{'successes',SOAP_M_URI,null,'0','-1','false'};
        private String[] totalTime_type_info = new String[]{'totalTime',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apexLogId','codeCoverage','codeCoverageWarnings','failures','numFailures','numTestsRun','successes','totalTime'};
    }
    public class ListMetadataQuery {
        public String folder;
        public String type_x;
        private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'folder','type_x'};
    }
    public class UpsertResult {
        public Boolean created;
        public mfcSomMetadatService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'created','errors','fullName','success'};
    }
    
    public class retrieve_element {
        public mfcSomMetadatService.RetrieveRequest retrieveRequest;
        private String[] retrieveRequest_type_info = new String[]{'retrieveRequest',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'retrieveRequest'};
    }
    
    public class DeleteResult {
        public mfcSomMetadatService.Error[] errors;
        public String fullName;
        public Boolean success;
        private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'errors','fullName','success'};
    }
   
    public class PackageVersion {
        public Integer majorNumber;
        public Integer minorNumber;
        public String namespace;
        private String[] majorNumber_type_info = new String[]{'majorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] minorNumber_type_info = new String[]{'minorNumber',SOAP_M_URI,null,'1','1','false'};
        private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
    }
    public class DescribeMetadataObject {
        public String[] childXmlNames;
        public String directoryName;
        public Boolean inFolder;
        public Boolean metaFile;
        public String suffix;
        public String xmlName;
        private String[] childXmlNames_type_info = new String[]{'childXmlNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] directoryName_type_info = new String[]{'directoryName',SOAP_M_URI,null,'1','1','false'};
        private String[] inFolder_type_info = new String[]{'inFolder',SOAP_M_URI,null,'1','1','false'};
        private String[] metaFile_type_info = new String[]{'metaFile',SOAP_M_URI,null,'1','1','false'};
        private String[] suffix_type_info = new String[]{'suffix',SOAP_M_URI,null,'0','1','false'};
        private String[] xmlName_type_info = new String[]{'xmlName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'childXmlNames','directoryName','inFolder','metaFile','suffix','xmlName'};
    }
    
    public class listMetadata_element {
        public mfcSomMetadatService.ListMetadataQuery[] queries;
        public Double asOfVersion;
        private String[] queries_type_info = new String[]{'queries',SOAP_M_URI,null,'0','-1','false'};
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'queries','asOfVersion'};
    }
    
    
   public class DeployDetails {
        public mfcSomMetadatService.DeployMessage[] componentFailures;
        public mfcSomMetadatService.DeployMessage[] componentSuccesses;
        public mfcSomMetadatService.RetrieveResult retrieveResult;
        public mfcSomMetadatService.RunTestsResult runTestResult;
        private String[] componentFailures_type_info = new String[]{'componentFailures',SOAP_M_URI,null,'0','-1','false'};
        private String[] componentSuccesses_type_info = new String[]{'componentSuccesses',SOAP_M_URI,null,'0','-1','false'};
        private String[] retrieveResult_type_info = new String[]{'retrieveResult',SOAP_M_URI,null,'0','1','false'};
        private String[] runTestResult_type_info = new String[]{'runTestResult',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'componentFailures','componentSuccesses','retrieveResult','runTestResult'};
    }
    
    
    public class deployRecentValidationResponse_element {
        public String result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class deployRecentValidation_element {
        public String validationId;
        private String[] validationId_type_info = new String[]{'validationId',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'validationId'};
    }
    
    public class DeployOptions {
        public Boolean allowMissingFiles;
        public Boolean autoUpdatePackage;
        public Boolean checkOnly;
        public Boolean ignoreWarnings;
        public Boolean performRetrieve;
        public Boolean purgeOnDelete;
        public Boolean rollbackOnError;
        public String[] runTests;
        public Boolean singlePackage;
        public String testLevel;
        private String[] allowMissingFiles_type_info = new String[]{'allowMissingFiles',SOAP_M_URI,null,'1','1','false'};
        private String[] autoUpdatePackage_type_info = new String[]{'autoUpdatePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] performRetrieve_type_info = new String[]{'performRetrieve',SOAP_M_URI,null,'1','1','false'};
        private String[] purgeOnDelete_type_info = new String[]{'purgeOnDelete',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTests_type_info = new String[]{'runTests',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] testLevel_type_info = new String[]{'testLevel',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowMissingFiles','autoUpdatePackage','checkOnly','ignoreWarnings','performRetrieve','purgeOnDelete','rollbackOnError','runTests','singlePackage','testLevel'};
    }
    public class RetrieveRequest {
        public Double apiVersion;
        public String[] packageNames;
        public Boolean singlePackage;
        public String[] specificFiles;
        public mfcSomMetadatService.Package_x unpackaged;
        private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] packageNames_type_info = new String[]{'packageNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
        private String[] specificFiles_type_info = new String[]{'specificFiles',SOAP_M_URI,null,'0','-1','false'};
        private String[] unpackaged_type_info = new String[]{'unpackaged',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiVersion','packageNames','singlePackage','specificFiles','unpackaged'};
    }
    public class AsyncResult {
        public Boolean done;
        public String id;
        public String message;
        public String state;
        public String statusCode;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'0','1','false'};
        private String[] state_type_info = new String[]{'state',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id','message','state','statusCode'};
    }
    public class checkRetrieveStatusResponse_element {
        public mfcSomMetadatService.RetrieveResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    
    public class retrieveResponse_element {
        public mfcSomMetadatService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
   
    public class upsertMetadataResponse_element {
        public mfcSomMetadatService.UpsertResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class cancelDeploy_element {
        public String String_x;
        private String[] String_x_type_info = new String[]{'String',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'String_x'};
    }
    
    public class updateMetadata_element {
        public mfcSomMetadatService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
   
    public class CancelDeployResult {
        public Boolean done;
        public String id;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','id'};
    }
   
    public class upsertMetadata_element {
        public mfcSomMetadatService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
     
    
    public virtual class Metadata {
        public String fullName;
    }
    
    public class describeMetadata_element {
        public Double asOfVersion;
        private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asOfVersion'};
    }
    
    public class createMetadataResponse_element {
        public mfcSomMetadatService.SaveResult[] result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    
    public class readMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    
    
    public class DescribeValueTypeResult {
        public Boolean apiCreatable;
        public Boolean apiDeletable;
        public Boolean apiReadable;
        public Boolean apiUpdatable;
        public mfcSomMetadatService.ValueTypeField parentField;
        public mfcSomMetadatService.ValueTypeField[] valueTypeFields;
        private String[] apiCreatable_type_info = new String[]{'apiCreatable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiDeletable_type_info = new String[]{'apiDeletable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiReadable_type_info = new String[]{'apiReadable',SOAP_M_URI,null,'1','1','false'};
        private String[] apiUpdatable_type_info = new String[]{'apiUpdatable',SOAP_M_URI,null,'1','1','false'};
        private String[] parentField_type_info = new String[]{'parentField',SOAP_M_URI,null,'0','1','false'};
        private String[] valueTypeFields_type_info = new String[]{'valueTypeFields',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'apiCreatable','apiDeletable','apiReadable','apiUpdatable','parentField','valueTypeFields'};
    }
    
    public class DescribeMetadataResult {
        public mfcSomMetadatService.DescribeMetadataObject[] metadataObjects;
        public String organizationNamespace;
        public Boolean partialSaveAllowed;
        public Boolean testRequired;
        private String[] metadataObjects_type_info = new String[]{'metadataObjects',SOAP_M_URI,null,'0','-1','false'};
        private String[] organizationNamespace_type_info = new String[]{'organizationNamespace',SOAP_M_URI,null,'1','1','false'};
        private String[] partialSaveAllowed_type_info = new String[]{'partialSaveAllowed',SOAP_M_URI,null,'1','1','false'};
        private String[] testRequired_type_info = new String[]{'testRequired',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadataObjects','organizationNamespace','partialSaveAllowed','testRequired'};
    }
    public class FileProperties {
        public String createdById;
        public String createdByName;
        public DateTime createdDate;
        public String fileName;
        public String fullName;
        public String id;
        public String lastModifiedById;
        public String lastModifiedByName;
        public DateTime lastModifiedDate;
        public String manageableState;
        public String namespacePrefix;
        public String type_x;
        private String[] createdById_type_info = new String[]{'createdById',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedById_type_info = new String[]{'lastModifiedById',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'1','1','false'};
        private String[] manageableState_type_info = new String[]{'manageableState',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
    }
    public class deleteMetadata_element {
        public String type_x;
        public String[] fullNames;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','fullNames'};
    }
    public class RetrieveResult {
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public mfcSomMetadatService.FileProperties[] fileProperties;
        public String id;
        public mfcSomMetadatService.RetrieveMessage[] messages;
        public String status;
        public Boolean success;
        public String zipFile;
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] fileProperties_type_info = new String[]{'fileProperties',SOAP_M_URI,null,'0','-1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] messages_type_info = new String[]{'messages',SOAP_M_URI,null,'0','-1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] zipFile_type_info = new String[]{'zipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'done','errorMessage','errorStatusCode','fileProperties','id','messages','status','success','zipFile'};
    }
    
    public class cancelDeployResponse_element {
        public mfcSomMetadatService.CancelDeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public interface IReadResult {
        mfcSomMetadatService.Metadata[] getRecords();
    }
    public interface IReadResponseElement {
        IReadResult getResult();
    }
    public class DeployMessage {
        public Boolean changed;
        public Integer columnNumber;
        public String componentType;
        public Boolean created;
        public DateTime createdDate;
        public Boolean deleted;
        public String fileName;
        public String fullName;
        public String id;
        public Integer lineNumber;
        public String problem;
        public String problemType;
        public Boolean success;
        private String[] changed_type_info = new String[]{'changed',SOAP_M_URI,null,'1','1','false'};
        private String[] columnNumber_type_info = new String[]{'columnNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'0','1','false'};
        private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] deleted_type_info = new String[]{'deleted',SOAP_M_URI,null,'1','1','false'};
        private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'0','1','false'};
        private String[] lineNumber_type_info = new String[]{'lineNumber',SOAP_M_URI,null,'0','1','false'};
        private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'0','1','false'};
        private String[] problemType_type_info = new String[]{'problemType',SOAP_M_URI,null,'0','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'changed','columnNumber','componentType','created','createdDate','deleted','fileName','fullName','id','lineNumber','problem','problemType','success'};
    }
    public class ProfileObjectPermissions {
        public Boolean allowCreate;
        public Boolean allowDelete;
        public Boolean allowEdit;
        public Boolean allowRead;
        public Boolean modifyAllRecords;
        public String object_x;
        public Boolean viewAllRecords;
        private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'0','1','false'};
        private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'0','1','false'};
        private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'0','1','false'};
        private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'0','1','false'};
        private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
        private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
    }
    public class checkRetrieveStatus_element {
        public String asyncProcessId;
        public Boolean includeZip;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeZip_type_info = new String[]{'includeZip',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeZip'};
    }
   
    public class Package_x extends Metadata {
        public String type = 'Package_x';
        public String fullName;
        private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
        public String apiAccessLevel;
        public String description;
        public String namespacePrefix;
        public mfcSomMetadatService.ProfileObjectPermissions[] objectPermissions;
        public String packageType;
        public String postInstallClass;
        public String setupWeblink;
        public mfcSomMetadatService.PackageTypeMembers[] types;
        public String uninstallClass;
        public String version;
        private String[] apiAccessLevel_type_info = new String[]{'apiAccessLevel',SOAP_M_URI,null,'0','1','false'};
        private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
        private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
        private String[] objectPermissions_type_info = new String[]{'objectPermissions',SOAP_M_URI,null,'0','-1','false'};
        private String[] packageType_type_info = new String[]{'packageType',SOAP_M_URI,null,'0','1','false'};
        private String[] postInstallClass_type_info = new String[]{'postInstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] setupWeblink_type_info = new String[]{'setupWeblink',SOAP_M_URI,null,'0','1','false'};
        private String[] types_type_info = new String[]{'types',SOAP_M_URI,null,'0','-1','false'};
        private String[] uninstallClass_type_info = new String[]{'uninstallClass',SOAP_M_URI,null,'0','1','false'};
        private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] type_att_info = new String[]{'xsi:type'};
        private String[] field_order_type_info = new String[]{'fullName', 'apiAccessLevel','description','namespacePrefix','objectPermissions','packageType','postInstallClass','setupWeblink','types','uninstallClass','version'};
    }
   public class Error {
        public mfcSomMetadatService.ExtendedErrorDetails[] extendedErrorDetails;
        public String[] fields;
        public String message;
        public String statusCode;
        private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails',SOAP_M_URI,null,'0','-1','false'};
        private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
        private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
        private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
    }
    public class deploy_element {
        public String ZipFile;
        public mfcSomMetadatService.DeployOptions DeployOptions;
        private String[] ZipFile_type_info = new String[]{'ZipFile',SOAP_M_URI,null,'1','1','false'};
        private String[] DeployOptions_type_info = new String[]{'DeployOptions',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'ZipFile','DeployOptions'};
    }
    public class DeployResult {
        public String canceledBy;
        public String canceledByName;
        public Boolean checkOnly;
        public DateTime completedDate;
        public String createdBy;
        public String createdByName;
        public DateTime createdDate;
        public mfcSomMetadatService.DeployDetails details;
        public Boolean done;
        public String errorMessage;
        public String errorStatusCode;
        public String id;
        public Boolean ignoreWarnings;
        public DateTime lastModifiedDate;
        public Integer numberComponentErrors;
        public Integer numberComponentsDeployed;
        public Integer numberComponentsTotal;
        public Integer numberTestErrors;
        public Integer numberTestsCompleted;
        public Integer numberTestsTotal;
        public Boolean rollbackOnError;
        public Boolean runTestsEnabled;
        public DateTime startDate;
        public String stateDetail;
        public String status;
        public Boolean success;
        private String[] canceledBy_type_info = new String[]{'canceledBy',SOAP_M_URI,null,'0','1','false'};
        private String[] canceledByName_type_info = new String[]{'canceledByName',SOAP_M_URI,null,'0','1','false'};
        private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
        private String[] completedDate_type_info = new String[]{'completedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] createdBy_type_info = new String[]{'createdBy',SOAP_M_URI,null,'1','1','false'};
        private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
        private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
        private String[] details_type_info = new String[]{'details',SOAP_M_URI,null,'1','1','false'};
        private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
        private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
        private String[] errorStatusCode_type_info = new String[]{'errorStatusCode',SOAP_M_URI,null,'0','1','false'};
        private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
        private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
        private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'0','1','false'};
        private String[] numberComponentErrors_type_info = new String[]{'numberComponentErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsDeployed_type_info = new String[]{'numberComponentsDeployed',SOAP_M_URI,null,'1','1','false'};
        private String[] numberComponentsTotal_type_info = new String[]{'numberComponentsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestErrors_type_info = new String[]{'numberTestErrors',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsCompleted_type_info = new String[]{'numberTestsCompleted',SOAP_M_URI,null,'1','1','false'};
        private String[] numberTestsTotal_type_info = new String[]{'numberTestsTotal',SOAP_M_URI,null,'1','1','false'};
        private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
        private String[] runTestsEnabled_type_info = new String[]{'runTestsEnabled',SOAP_M_URI,null,'1','1','false'};
        private String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,null,'0','1','false'};
        private String[] stateDetail_type_info = new String[]{'stateDetail',SOAP_M_URI,null,'0','1','false'};
        private String[] status_type_info = new String[]{'status',SOAP_M_URI,null,'1','1','false'};
        private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'canceledBy','canceledByName','checkOnly','completedDate','createdBy','createdByName','createdDate','details','done','errorMessage','errorStatusCode','id','ignoreWarnings','lastModifiedDate','numberComponentErrors','numberComponentsDeployed','numberComponentsTotal','numberTestErrors','numberTestsCompleted','numberTestsTotal','rollbackOnError','runTestsEnabled','startDate','stateDetail','status','success'};
    }
    public class createMetadata_element {
        public mfcSomMetadatService.Metadata[] metadata;
        private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'metadata'};
    }
    public class renameMetadata_element {
        public String type_x;
        public String oldFullName;
        public String newFullName;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] oldFullName_type_info = new String[]{'oldFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] newFullName_type_info = new String[]{'newFullName',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x','oldFullName','newFullName'};
    }
    
    public class describeMetadataResponse_element {
        public mfcSomMetadatService.DescribeMetadataResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class deployResponse_element {
        public mfcSomMetadatService.AsyncResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }
    public class checkDeployStatus_element {
        public String asyncProcessId;
        public Boolean includeDetails;
        private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
        private String[] includeDetails_type_info = new String[]{'includeDetails',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'asyncProcessId','includeDetails'};
    }
    public virtual class MetadataWithContent extends Metadata {
        public String content;
    }
    
    public class checkDeployStatusResponse_element {
        public mfcSomMetadatService.DeployResult result;
        private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'result'};
    }

    public class describeValueType_element {
        public String type_x;
        private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
        private String[] field_order_type_info = new String[]{'type_x'};
    }
    
    public class MetadataPort {
        //public String endpoint_x = URL.getOrgDomainUrl().toExternalForm() + '/services/Soap/m/53.0';
        /* Named credential*/
        public String endpoint_x = 'callout:ApexMDAPI/services/Soap/m/53.0';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        public mfcSomMetadatService.SessionHeader_element SessionHeader;
        public mfcSomMetadatService.DebuggingInfo_element DebuggingInfo;
        public mfcSomMetadatService.DebuggingHeader_element DebuggingHeader;
        public mfcSomMetadatService.CallOptions_element CallOptions;
        public mfcSomMetadatService.AllOrNoneHeader_element AllOrNoneHeader;
        private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
        private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
        private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
        private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
        private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'mfcSomMetadatService'};
        public mfcSomMetadatService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
            mfcSomMetadatService.deleteMetadata_element request_x = new mfcSomMetadatService.deleteMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            mfcSomMetadatService.deleteMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.deleteMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.deleteMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deleteMetadata',
              SOAP_M_URI,
              'deleteMetadataResponse',
              'mfcSomMetadatService.deleteMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.SaveResult renameMetadata(String type_x,String oldFullName,String newFullName) {
            mfcSomMetadatService.renameMetadata_element request_x = new mfcSomMetadatService.renameMetadata_element();
            request_x.type_x = type_x;
            request_x.oldFullName = oldFullName;
            request_x.newFullName = newFullName;
            mfcSomMetadatService.renameMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.renameMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.renameMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'renameMetadata',
              SOAP_M_URI,
              'renameMetadataResponse',
              'mfcSomMetadatService.renameMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.SaveResult[] updateMetadata(mfcSomMetadatService.Metadata[] metadata) {
            mfcSomMetadatService.updateMetadata_element request_x = new mfcSomMetadatService.updateMetadata_element();
            request_x.metadata = metadata;
            mfcSomMetadatService.updateMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.updateMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.updateMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'updateMetadata',
              SOAP_M_URI,
              'updateMetadataResponse',
              'mfcSomMetadatService.updateMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.DescribeMetadataResult describeMetadata(Double asOfVersion) {
            mfcSomMetadatService.describeMetadata_element request_x = new mfcSomMetadatService.describeMetadata_element();
            request_x.asOfVersion = asOfVersion;
            mfcSomMetadatService.describeMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.describeMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.describeMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeMetadata',
              SOAP_M_URI,
              'describeMetadataResponse',
              'mfcSomMetadatService.describeMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.DeployResult checkDeployStatus(String asyncProcessId,Boolean includeDetails) {
            mfcSomMetadatService.checkDeployStatus_element request_x = new mfcSomMetadatService.checkDeployStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeDetails = includeDetails;
            mfcSomMetadatService.checkDeployStatusResponse_element response_x;
            Map<String, mfcSomMetadatService.checkDeployStatusResponse_element> response_map_x = new Map<String, mfcSomMetadatService.checkDeployStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkDeployStatus',
              SOAP_M_URI,
              'checkDeployStatusResponse',
              'mfcSomMetadatService.checkDeployStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.RetrieveResult checkRetrieveStatus(String asyncProcessId,Boolean includeZip) {
            mfcSomMetadatService.checkRetrieveStatus_element request_x = new mfcSomMetadatService.checkRetrieveStatus_element();
            request_x.asyncProcessId = asyncProcessId;
            request_x.includeZip = includeZip;
            mfcSomMetadatService.checkRetrieveStatusResponse_element response_x;
            Map<String, mfcSomMetadatService.checkRetrieveStatusResponse_element> response_map_x = new Map<String, mfcSomMetadatService.checkRetrieveStatusResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'checkRetrieveStatus',
              SOAP_M_URI,
              'checkRetrieveStatusResponse',
              'mfcSomMetadatService.checkRetrieveStatusResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.AsyncResult retrieve(mfcSomMetadatService.RetrieveRequest retrieveRequest) {
            mfcSomMetadatService.retrieve_element request_x = new mfcSomMetadatService.retrieve_element();
            request_x.retrieveRequest = retrieveRequest;
            mfcSomMetadatService.retrieveResponse_element response_x;
            Map<String, mfcSomMetadatService.retrieveResponse_element> response_map_x = new Map<String, mfcSomMetadatService.retrieveResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'retrieve',
              SOAP_M_URI,
              'retrieveResponse',
              'mfcSomMetadatService.retrieveResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.CancelDeployResult cancelDeploy(String String_x) {
            mfcSomMetadatService.cancelDeploy_element request_x = new mfcSomMetadatService.cancelDeploy_element();
            request_x.String_x = String_x;
            mfcSomMetadatService.cancelDeployResponse_element response_x;
            Map<String, mfcSomMetadatService.cancelDeployResponse_element> response_map_x = new Map<String, mfcSomMetadatService.cancelDeployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'cancelDeploy',
              SOAP_M_URI,
              'cancelDeployResponse',
              'mfcSomMetadatService.cancelDeployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public String deployRecentValidation(String validationId) {
            mfcSomMetadatService.deployRecentValidation_element request_x = new mfcSomMetadatService.deployRecentValidation_element();
            request_x.validationId = validationId;
            mfcSomMetadatService.deployRecentValidationResponse_element response_x;
            Map<String, mfcSomMetadatService.deployRecentValidationResponse_element> response_map_x = new Map<String, mfcSomMetadatService.deployRecentValidationResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deployRecentValidation',
              SOAP_M_URI,
              'deployRecentValidationResponse',
              'mfcSomMetadatService.deployRecentValidationResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.DescribeValueTypeResult describeValueType(String type_x) {
            mfcSomMetadatService.describeValueType_element request_x = new mfcSomMetadatService.describeValueType_element();
            request_x.type_x = type_x;
            mfcSomMetadatService.describeValueTypeResponse_element response_x;
            Map<String, mfcSomMetadatService.describeValueTypeResponse_element> response_map_x = new Map<String, mfcSomMetadatService.describeValueTypeResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'describeValueType',
              SOAP_M_URI,
              'describeValueTypeResponse',
              'mfcSomMetadatService.describeValueTypeResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.SaveResult[] createMetadata(mfcSomMetadatService.Metadata[] metadata) {
            mfcSomMetadatService.createMetadata_element request_x = new mfcSomMetadatService.createMetadata_element();
            request_x.metadata = metadata;
            mfcSomMetadatService.createMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.createMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.createMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'createMetadata',
              SOAP_M_URI,
              'createMetadataResponse',
              'mfcSomMetadatService.createMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.AsyncResult deploy(String ZipFile,mfcSomMetadatService.DeployOptions DeployOptions) {
            mfcSomMetadatService.deploy_element request_x = new mfcSomMetadatService.deploy_element();
            request_x.ZipFile = ZipFile;
            request_x.DeployOptions = DeployOptions;
            mfcSomMetadatService.deployResponse_element response_x;
            Map<String, mfcSomMetadatService.deployResponse_element> response_map_x = new Map<String, mfcSomMetadatService.deployResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'deploy',
              SOAP_M_URI,
              'deployResponse',
              'mfcSomMetadatService.deployResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.IReadResult readMetadata(String type_x,String[] fullNames) {
            mfcSomMetadatService.readMetadata_element request_x = new mfcSomMetadatService.readMetadata_element();
            request_x.type_x = type_x;
            request_x.fullNames = fullNames;
            mfcSomMetadatService.IReadResponseElement response_x;
            Map<String, mfcSomMetadatService.IReadResponseElement> response_map_x = new Map<String, mfcSomMetadatService.IReadResponseElement>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'readMetadata',
              SOAP_M_URI,
              'readMetadataResponse',
              'mfcSomMetadatService.read' + type_x + 'Response_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.getResult();
        }
        public mfcSomMetadatService.UpsertResult[] upsertMetadata(mfcSomMetadatService.Metadata[] metadata) {
            mfcSomMetadatService.upsertMetadata_element request_x = new mfcSomMetadatService.upsertMetadata_element();
            request_x.metadata = metadata;
            mfcSomMetadatService.upsertMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.upsertMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.upsertMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'upsertMetadata',
              SOAP_M_URI,
              'upsertMetadataResponse',
              'mfcSomMetadatService.upsertMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
        public mfcSomMetadatService.FileProperties[] listMetadata(mfcSomMetadatService.ListMetadataQuery[] queries,Double asOfVersion) {
            mfcSomMetadatService.listMetadata_element request_x = new mfcSomMetadatService.listMetadata_element();
            request_x.queries = queries;
            request_x.asOfVersion = asOfVersion;
            mfcSomMetadatService.listMetadataResponse_element response_x;
            Map<String, mfcSomMetadatService.listMetadataResponse_element> response_map_x = new Map<String, mfcSomMetadatService.listMetadataResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
              this,
              request_x,
              response_map_x,
              new String[]{endpoint_x,
              '',
              SOAP_M_URI,
              'listMetadata',
              SOAP_M_URI,
              'listMetadataResponse',
              'mfcSomMetadatService.listMetadataResponse_element'}
            );
            response_x = response_map_x.get('response_x');
            return response_x.result;
        }
    }
}