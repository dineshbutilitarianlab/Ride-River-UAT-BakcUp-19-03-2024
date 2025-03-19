@IsTest
public class EasyDPEEditControllerTest {
    @isTest
    private static void updateDPEFile_Test(){
		List<String> dataSource = new List<String>();
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        String groupData = '[{"Name":"group0","values":["ProductCategoryId","mfcdpe2022__Product_Category__c"]}]';
        String wrapperText = '[{"Name":"input0","EgCriteria":false,"values":["mfcdpe2022__count__c","mfcdpe2022__Total_Count__c"]},{"Name":"input1","EgCriteria":true,"values":["mfcdpe2022__Invoice__c","mfcdpe2022__Total_Invoice__c"]}]';
        String aggregatebyEligibiliy = '{"input0":false,"input1":true}';
        EasyDPEWrapper dpe = EasyDPEEditController.updateDPE(groupData,wrapperText,aggregatebyEligibiliy,filename);
        system.assert(dpe != null);
        system.assert(dpe.FullName == 'Test');
     }
    
    @isTest
    private static void updateEgCriteria_Test(){
		List<String> dataSource = new List<String>();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AggregateByMemberWithAggregateItemDetails' LIMIT 1];
        String dpeData = sr.Body.toString();
        EasyDPEWrapper artWrap = (EasyDPEWrapper) JSON.deserialize(dpeData, EasyDPEWrapper.class);
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        String groupData = '[{"Name":"group0","values":["ProductCategoryId","mfcdpe2022__Product_Category__c"]}]';
        String wrapperText = '[{"Name":"input0","EgCriteria":false,"values":["mfcdpe2022__count__c","mfcdpe2022__Total_Count__c"]},{"Name":"input1","EgCriteria":true,"values":["mfcdpe2022__Invoice__c","mfcdpe2022__Total_Invoice__c"]}]';
        String aggregatebyEligibiliy = '{"input0":false,"input1":true}';
        List<String> value = new list<String>();
        value.add('mfcdpe2022__count__c');
        list<String> groupby = new list<String>();
        EasyDPEEditController.updateEgCriteria(artWrap,value,groupby);
        system.assert(artWrap.Metadata.appends != null);
    	system.assertEquals(artWrap.Metadata.appends[0].name, 'Append_Total_Additional_Aggregate_Data_to_Total_Amount_and_Quantity');
     }
    
    @isTest
    private static void updateTransformandWritebacks_Test(){
		List<String> dataSource = new List<String>();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AggregateByMemberWithAggregateItemDetails' LIMIT 1];
        String dpeData = sr.Body.toString();
        EasyDPEWrapper artWrap = (EasyDPEWrapper) JSON.deserialize(dpeData, EasyDPEWrapper.class);
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        String groupData = '[{"Name":"group0","values":["ProductCategoryId","mfcdpe2022__Product_Category__c"]}]';
        String wrapperText = '[{"Name":"input0","EgCriteria":false,"values":["mfcdpe2022__count__c","mfcdpe2022__Total_Count__c"]},{"Name":"input1","EgCriteria":true,"values":["mfcdpe2022__Invoice__c","mfcdpe2022__Total_Invoice__c"]}]';
        String aggregatebyEligibiliy = '{"input0":false,"input1":true}';
        EasyDPEWrapper.Fields_Y[] fieldslist =  new List<EasyDPEWrapper.Fields_Y>();
        list<String> groupby = new list<String>();
        
        List<EasyDPEEditController.GroupData> groupWrap = (List<EasyDPEEditController.GroupData>) JSON.deserialize(groupData, List<EasyDPEEditController.GroupData>.class);
        EasyDPEEditController.verifyGroupData(groupWrap,fieldslist,groupby);
        EasyDPEEditController.updateTransformandWritebacks(artWrap,'testExp',fieldslist);
        system.assert(artWrap.Metadata.transforms != null);
        system.assert(artWrap.Metadata.transforms[0].expressionFields[0].expression.contains('testExp'));
     }
    
    @isTest
    private static void verifyGroupData_Test(){
		List<String> dataSource = new List<String>();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AggregateByMemberWithAggregateItemDetails' LIMIT 1];
        String dpeData = sr.Body.toString();
        EasyDPEWrapper artWrap = (EasyDPEWrapper) JSON.deserialize(dpeData, EasyDPEWrapper.class);
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        String groupData = '[{"Name":"group0","values":["ProductCategoryId","mfcdpe2022__Product_Category__c"]}]';
        String wrapperText = '[{"Name":"input0","EgCriteria":false,"values":["mfcdpe2022__count__c","mfcdpe2022__Total_Count__c"]},{"Name":"input1","EgCriteria":true,"values":["mfcdpe2022__Invoice__c","mfcdpe2022__Total_Invoice__c"]}]';
        String aggregatebyEligibiliy = '{"input0":false,"input1":true}';
        
        list<String> groupby = new list<String>();
        EasyDPEWrapper.Fields_Y[] fieldslist =  new List<EasyDPEWrapper.Fields_Y>();
        List<EasyDPEEditController.GroupData> groupWrap = (List<EasyDPEEditController.GroupData>) JSON.deserialize(groupData, List<EasyDPEEditController.GroupData>.class);
        EasyDPEEditController.verifyGroupData(groupWrap,fieldslist,groupby);
        system.assert(fieldslist != null);
    	system.assertEquals(fieldslist[0].sourceFieldName, 'ProductCategoryId');
     }
    
    @isTest
    private static void updateJoins_Test(){
		List<String> dataSource = new List<String>();
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AggregateByMemberWithAggregateItemDetails' LIMIT 1];
        String dpeData = sr.Body.toString();
        EasyDPEWrapper artWrap = (EasyDPEWrapper) JSON.deserialize(dpeData, EasyDPEWrapper.class);
        dataSource.add('ProgramRebateType');
        dataSource.add('RebateProgramPayoutPeriod');
        String filename = 'Test';
        String groupData = '[{"Name":"group0","values":["ProductCategoryId","mfcdpe2022__Product_Category__c"]}]';
        String wrapperText = '[{"Name":"input0","EgCriteria":false,"values":["mfcdpe2022__count__c","mfcdpe2022__Total_Count__c"]},{"Name":"input1","EgCriteria":true,"values":["mfcdpe2022__Invoice__c","mfcdpe2022__Total_Invoice__c"]}]';
        String aggregatebyEligibiliy = '{"input0":false,"input1":true}';
        
        list<String> groupby = new list<String>();
        EasyDPEWrapper.Fields_Y[] fieldslist =  new List<EasyDPEWrapper.Fields_Y>();
        List<EasyDPEEditController.GroupData> groupWrap = (List<EasyDPEEditController.GroupData>) JSON.deserialize(groupData, List<EasyDPEEditController.GroupData>.class);
        List<EasyDPEEditController.DataWrapper> dataWrap = (List<EasyDPEEditController.DataWrapper>) JSON.deserialize(wrapperText, List<EasyDPEEditController.DataWrapper>.class);
        EasyDPEEditController.EligibilityCriteria egCr = (EasyDPEEditController.EligibilityCriteria) JSON.deserialize(aggregatebyEligibiliy, EasyDPEEditController.EligibilityCriteria.class);
        Map<String,EasyDPEWrapper.Fields_Z> fieldsMap = EasyDPEEditController.verifyGroupData(groupWrap,fieldslist,groupby);
        EasyDPEEditController.updateJoins(artWrap,dataWrap,egCr,fieldsMap,groupby);
        system.assert(dataWrap != null);
    	system.assertEquals(dataWrap[0].values[0], 'mfcdpe2022__count__c');
     }
    
    @isTest
    private static void getfieldDetails_Test(){
		Map<String , Map<String, String>> testfield = EasyDPEEditController.getfieldDetails();
        system.assert(testfield != null);
     }
    
    @isTest
    Private static void testParse() {
		String json = EasyDPETestUtility.buildjson();
		EasyDPEWrapper obj = EasyDPEWrapper.parse(json);
		System.assert(obj != null);
	}
}