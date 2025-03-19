/*
 * @File Name          : debugDPEController.cls
 * @Description        : 
 * @Author             : Swapna Deshpande
 * @Last Modified By   : Swapna Deshpande
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author            Modification
 * 1.0    04/20/2022      Swapna Deshpande    Initial Version
*/
public with sharing class debugDPEController {
   private static final String formulaDummyValue = 'DummyValue';
     private static final String formulaDummyName = 'DummyName';
     private static final String formulaExpDummyValue = '\"Test\"';
    private static final String formulaExpDataType = 'Text';
    private static final String trasfLabel = 'Debug Formula ';
    private static final String aggsLabel = 'Debug Aggregate ';
    private static final String aggFieldAlias = 'GroupbyDebugDummy';
    private static final String appendLabel = 'Debug Append All Node';
    private static final String writebackLabel = 'Insert DPE Debug Object';
   

    @AuraEnabled(cacheable=true)
    public static List<BatchCalcJobDefinition> getDPEList() {
        return [SELECT  Id, MasterLabel FROM BatchCalcJobDefinition WITH SECURITY_ENFORCED];
    }
    
    @AuraEnabled(cacheable =true)
    public static DPEWrapper updateDPEFile(String fileData, List<String> dataSource, String fileName){
        system.debug('test='+dataSource);
        DPEWrapper artWrap = (DPEWrapper) JSON.deserialize(fileData, DPEWrapper.class);
        list<String> sourcesNodes = new list<String>();
        String sourceName ;
        Boolean debugAgg = false;
        Boolean debugAppend = false;
        list<String> existingListAgg = new List<String>();
        for(DPEWrapper.Aggregates agg :artWrap.Metadata.aggregates){
            if(agg.label.contains('Debug Aggregate')){
                debugAgg = true;
                existingListAgg.add(agg.name);
            }
        }
        
        if(dataSource.size() > 0){
            for(String selectDataS : dataSource){
                DPEWrapper.ExpressionFields[] expFieldsList = new List<DPEWrapper.ExpressionFields>();
                
                DPEWrapper.ExpressionFields expFields = new DPEWrapper.ExpressionFields();
                expFields.alias = formulaDummyValue;
                expFields.expression = formulaExpDummyValue;
                expFields.dataType = formulaExpDataType;
                expFields.length = 8;
                expFieldsList.add(expFields);
                DPEWrapper.ExpressionFields expNameFields = new DPEWrapper.ExpressionFields();
                expNameFields.alias = formulaDummyName;
                expNameFields.expression = '\"'+selectDataS+'-'+fileName+'\"';
                expNameFields.dataType = formulaExpDataType;
                expNameFields.length = 255;
                expFieldsList.add(expNameFields);
                
                DPEWrapper.Transforms trasf = new DPEWrapper.Transforms();
                trasf.label = trasfLabel+selectDataS;
                trasf.name = trasf.label.replace(' ','_');
                trasf.sourceName = selectDataS.replace(' ','');
                trasf.expressionFields = expFieldsList;
                trasf.transformationType = 'Expression';
                artWrap.Metadata.transforms.add(trasf);
                
                DPEWrapper.Aggregates aggs =  new DPEWrapper.Aggregates();
                aggs.label = aggsLabel+selectDataS;
                aggs.name = aggs.label.replace(' ','_');
                aggs.sourceName =   trasf.name;
                
                DPEWrapper.Fields_X[] fieldsList =  new list<DPEWrapper.Fields_X>();   
                DPEWrapper.Fields_X fields = new  DPEWrapper.Fields_X();
                fields.aggregateFunction = 'Count';
                fields.alias = aggFieldAlias;
                fields.sourceFieldName = expFields.alias;
                fieldsList.add(fields);
                aggs.fields = fieldsList;
                aggs.groupBy = new list<String>{formulaDummyValue,formulaDummyName};
                    artWrap.Metadata.aggregates.add(aggs);
                sourcesNodes.add(aggs.name);
                sourceName = sourcesNodes[0];
                
            }
            
            
            if(debugAgg){
                for(DPEWrapper.Appends app :artWrap.Metadata.appends){
                    if(app.label.contains('Debug Append')){
                        debugAppend = true;
                        app.sources.addAll(sourcesNodes);
                        sourceName = app.name;
                    }
                }
                
                if(debugAppend == false){
                    sourcesNodes.addAll(existingListAgg);
                    DPEWrapper.Appends appends = new DPEWrapper.Appends();
                    appends.name = appendLabel.replace(' ','_');
                    appends.label = appendLabel;
                    appends.sources =sourcesNodes;
                    appends.isDisjointedSchema = true;
                    artWrap.Metadata.appends.add(appends); 
                    sourceName = appends.name;
                }
            }else{
                if(dataSource.size() > 1){
                DPEWrapper.Appends appends = new DPEWrapper.Appends();
                appends.name = appendLabel.replace(' ','_');
                appends.label = appendLabel;
                appends.sources =sourcesNodes;
                appends.isDisjointedSchema = true;
                artWrap.Metadata.appends.add(appends); 
                sourceName = appends.name;
                }
            }
            
            
            if(debugAgg){
                for(DPEWrapper.Writebacks wrbak :artWrap.Metadata.writebacks){
                    if(wrbak.label.contains('Insert DPE Debug')){
                        wrbak.sourceName = sourceName;
                    }
                }
            }else{
                
                DPEWrapper.Writebacks wrback = new  DPEWrapper.Writebacks();
                wrback.label = writebackLabel;
                wrback.name = writebackLabel.replace(' ','_');
                wrback.operationType = 'Insert';
                wrback.targetObjectName= Label.Debug_DPE_Object	;
                wrback.writebackSequence = 1;
                wrback.writebackUser = UserInfo.getUserId();
                wrback.sourceName = sourceName;
                DPEWrapper.Fields_Y[] fieldslist =  new List<DPEWrapper.Fields_Y>();  
                DPEWrapper.Fields_Y fieldsy =  new DPEWrapper.Fields_Y();  
                fieldsy.sourceFieldName = aggFieldAlias;
                fieldsy.targetFieldName = Label.DPE_Data_Count;
                fieldslist.add(fieldsy);
                
                DPEWrapper.Fields_Y fieldsy1 =  new DPEWrapper.Fields_Y();  
                fieldsy1.sourceFieldName = formulaDummyName;
                fieldsy1.targetFieldName = Label.DPE_Name;
                fieldslist.add(fieldsy1);
                wrback.fields = fieldslist;
                artWrap.Metadata.writebacks.add(wrback); 
            }
        }
    
        return artWrap;
    }
    @AuraEnabled 
    public static String getDPEMetadata(string dpeId) {
        String baseURL='callout:ToolingRestDPE/sobjects/BatchCalcJobDefinition/'+dpeId;
        HTTPRequest req = new HTTPRequest();
        req.setEndpoint(baseUrl);
        req.setMethod('GET');
        
        //Send Request
        Http h = new Http();
        HttpResponse res = h.send(req);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('FullName');
        gen.writeObject(m.get('DeveloperName'));
        gen.writeFieldName('Metadata');
        gen.writeObject(m.get('Metadata'));
        gen.writeEndObject();
        String pretty = gen.getAsString();
        return pretty;
        
    }
    
    public class DataWrapper
    {
        @AuraEnabled
        public string Name{get;set;}
        @AuraEnabled
        public List<String> Values { get; set; }
    }
    
    
    
}