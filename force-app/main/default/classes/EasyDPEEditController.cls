/*
* @File Name          : EasyDPEEditController.cls
* @Description        : This class called by easyDPEEdit Lwc component for updating DPE json file.
* @Author             : Swapna Deshpande
* @Last Modified By   : Swapna Deshpande
* @Last Modified On   : 19/08/2022 
* @Modification Log   : 
* Ver       Date            Author            Modification
* 1.0    08/08/2022      Swapna Deshpande    Initial Version
*/
public with sharing class EasyDPEEditController {
    /*******************************************************************************************************
* @description - Method to get all the fields of TransactionJournal and RebateMemberProductAggregate.
* returns -  Map<String , Map<String, String>>
*/
    public static Map<String, String > MapfieldType = new Map<String, String>();  
    public static Map<String, String > MapfieldTypeRebate = new Map<String, String>();    
    public static final String appendLabel = 'Append Total Additional Aggregate Data to Total Amount and Quantity';
   	private static Map<String, String > MapfieldDataType = new Map<String, String>();   
    @AuraEnabled 
    public static Map<String , Map<String, String>> getfieldDetails(){
        String objectNameFirst = 'TransactionJournal';
        String objectNameSecond = 'RebateMemberProductAggregate';
        Map<String, String> fieldsTransactionJournal = getAllfields(objectNameFirst);
        Map<String, String> fieldsRebateMember = getAllfields(objectNameSecond);
        Map<String , Map<String, String>> fieldMap = new Map<String , Map<String, String>>();
        fieldMap.put('TransactionJournal', fieldsTransactionJournal);
        fieldMap.put('RebateMemberProductAggregate', fieldsRebateMember);
        fieldMap.put('TransactionAllFields', MapfieldType);
        fieldMap.put('RebateMemberAllField', MapfieldTypeRebate);
        return fieldMap;
    }
    /*******************************************************************************************************
* @description - Method to get all the fields of a particular Object.
* @param ObjectName- the name of the object to look up
* returns -  Map<String, String>
*/
    @AuraEnabled 
    public static Map<String, String> getAllfields(String objectName){
        Map<String, String> allFields = new  Map<String, String>();
        list<String> fieldsNames = new list<String>();
       	Map<String, Schema.SObjectField> fields = new Map<String, Schema.SObjectField>();
        if(objectName =='TransactionJournal'){
            Schema.DescribeSObjectResult transDescribe = TransactionJournal.sObjectType.getDescribe();
        	fields = transDescribe.fields.getMap();
        }else{
            //Schema.DescribeSObjectResult rebateDescribe = RebateMemberProductAggregate.sObjectType.getDescribe();
        	//fields = rebateDescribe.fields.getMap();
        	System.Debug('RideRiver');
        }
       
            for(Schema.SObjectField fld: fields.values()){
                Schema.DisplayType fielddataType = fld.getDescribe().getType();
                if(fielddataType ==Schema.DisplayType.Currency  || fielddataType ==Schema.DisplayType.Double){
                    fieldsNames.add(fld.getDescribe().getLabel()+'@!@'+fld.getDescribe().getName());
                }
                String stringIntance = String.valueOf(fielddataType);
                if(objectName =='TransactionJournal'){
                    MapfieldDataType.put(fld.getDescribe().getName(),stringIntance);
                    MapfieldType.put(fld.getDescribe().getName(),fld.getDescribe().getLabel());
                }else{
                    MapfieldTypeRebate.put(fld.getDescribe().getName(),fld.getDescribe().getLabel());
                }
            }
        
        if(!fieldsNames.isEmpty()){
            fieldsNames.sort();
            for (String name: fieldsNames) {
                //getting labels of the fields
                list<string> fName = name.split('@!@');
                allFields.put(fName[1],fName[0]);
            }
        }
        return allFields;
    }
    
    /*******************************************************************************************************
* @description - Method to update DPE file with for selected parameters from UI.
* @param groupData- Selected list of under group data section
* @param wrapperText- Selected list of under aggregate data section
* @param aggregatebyEligibiliy- Selected aggregated criteria options under aggregate data section
* @param fullName- Selected DPE name to updated in json file.
* returns -  EasyDPEWrapper
*/
    @AuraEnabled
    public static EasyDPEWrapper updateDPE(String groupData, String wrapperText, String aggregatebyEligibiliy, String fullName) {
        List<DataWrapper> dataWrap = (List<DataWrapper>) JSON.deserialize(wrapperText, List<DataWrapper>.class);
        List<GroupData> groupWrap = (List<GroupData>) JSON.deserialize(groupData, List<GroupData>.class);
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AggregateByMemberWithAggregateItemDetails' WITH SECURITY_ENFORCED  LIMIT 1 ];
        String dpeData = sr.Body.toString();
        EasyDPEWrapper dpewrap = updateDPEFile(dpeData,dataWrap,groupWrap,aggregatebyEligibiliy, fullName);
        return dpewrap ;
    }
    
    /*******************************************************************************************************
* @description - Method to update DPE file with for selected parameters from UI.
* @param groupData- Selected list of under group data section
* @param wrapperText- Selected list of under aggregate data section
* @param aggregatebyEligibiliy- Selected aggregated criteria options under aggregate data section
* @param fullName- Selected DPE name to updated in json file.
* returns -  EasyDPEWrapper
*/
    public static EasyDPEWrapper updateDPEFile(String fileData,List<DataWrapper> dataWrap, List<GroupData> groupWrap, String aggregatebyEligibiliy,String fullName){
        EasyDPEWrapper artWrap = (EasyDPEWrapper) JSON.deserialize(fileData, EasyDPEWrapper.class);
        list<EasyDPEWrapper.Fields> listTFields = new list<EasyDPEWrapper.Fields>();
        list<EasyDPEWrapper.Fields> listRFields = new list<EasyDPEWrapper.Fields>();
        
        list<String> groupby = new list<String>();
        list<String> egData = new list<String>();
        EasyDPEWrapper.Fields_X[] fieldsTList =  new list<EasyDPEWrapper.Fields_X>(); 
        EasyDPEWrapper.Fields_Y[] fieldslist =  new List<EasyDPEWrapper.Fields_Y>();
        EligibilityCriteria egCr = (EligibilityCriteria) JSON.deserialize(aggregatebyEligibiliy, EligibilityCriteria.class);
        string exp ='&&';
        
        Map<String,EasyDPEWrapper.Fields_Z> fieldsMap = verifyGroupData(groupWrap,fieldslist,groupby);
        if(dataWrap.size() > 0 ){
            for(DataWrapper data : dataWrap){
                integer i = 0;
                //Data Souces Fields
                listTFields.add(createDataFieldList(data.Values[i],'Numeric')); 
                listRFields.add(createDataFieldList(data.Values[i+1],'Numeric'));
                
                //Experssion to calculate Aggregate Records
                exp = exp + '({Total'+EasyDPEUtility.replaceString(data.Values[i])+'} == {'+EasyDPEUtility.replaceString(data.Values[i+1])+'}) &&';
                
                //Upsert fields
                EasyDPEWrapper.Fields_Y fieldsy =  new EasyDPEWrapper.Fields_Y();  
                fieldsy.sourceFieldName = 'Total'+EasyDPEUtility.replaceString(data.Values[i]);
                fieldsy.targetFieldName = data.Values[i+1];
                fieldslist.add(fieldsy);    
                
                if(!data.EgCriteria){
                    egData.add(data.Values[i]);
                    //Updated DPE as per eligibity criteria
                }else{
                    EasyDPEWrapper.Fields_X fieldTs = new  EasyDPEWrapper.Fields_X();
                    fieldTs.sourceFieldName = EasyDPEUtility.replaceString(data.Values[i]);
                    fieldTs.aggregateFunction = 'Sum';
                    fieldTs.alias = 'Total'+EasyDPEUtility.replaceString(data.Values[i]);
                    fieldsTList.add(fieldTs);
                    
                }
            }
            //Updated DPE as per eligibity criteria
            if(!egData.isEmpty())
            updateEgCriteria(artWrap,egData,groupby);
        }
        for(EasyDPEWrapper.Datasources ds :artWrap.Metadata.datasources){
            if(ds.name.contains('TransactionJournal')){
                ds.fields.addAll(listTFields);
                Set<String> currentFieldList = new Set<String>();
                 for(EasyDPEWrapper.Fields fs:ds.fields){
                     currentFieldList.add(fs.name);
                 }
                for(String fields : groupBy){
                    if(!currentFieldList.contains(fields)){
                        ds.fields.add(createDataFieldList(fields,'Text'));
                    }
                    
                }
            }
            if(ds.name.contains('RebateMemberProductAggregate')){
                ds.fields.addAll(listRFields);
            }
        }
        
        //Updates joins nodes
        updateJoins(artWrap,dataWrap,egCr,fieldsMap,groupby);
        
        if(String.isNotBlank(fullName)){
            artWrap.FullName = fullName;
            artWrap.Metadata.label = fullName.replace('_', ' ');
        }
        //update Aggregate nodes
        updateAggregates(artWrap,egCr,groupby,fieldsTList);
        //update Transforms(Formula) and Writeback nodes
        updateTransformandWritebacks(artWrap,exp,fieldslist);
        
        return artWrap;
    }
    
    /*******************************************************************************************************
* @description - Method to create field list for joins/filters node
* @param SourceName- Node name
* @param fieldName-  fields to add in the list
* @param groupby- boolean to check groupby or not.
* returns -  EasyDPEWrapper
*/
    
    Public static EasyDPEWrapper.Fields_Z createFieldList(String SourceName,String fieldName, Boolean groupby){
        EasyDPEWrapper.Fields_Z fieldsz = new EasyDPEWrapper.Fields_Z();
        fieldsz.sourceName = SourceName;
        if(SourceName == appendLabel.replace(' ','_') || SourceName =='TotalTransactionAmountAndTotalQuantity'){
            if(!groupby){
                fieldsz.sourceFieldName='Total'+EasyDPEUtility.replaceString(fieldName);
                fieldsz.alias ='Total'+EasyDPEUtility.replaceString(fieldName);
                
            }else{
                fieldsz.sourceFieldName=EasyDPEUtility.replaceString(fieldName);
                fieldsz.alias = EasyDPEUtility.replaceString(fieldName);
            }
        }else{
            fieldsz.sourceFieldName=EasyDPEUtility.replaceString(fieldName);
            fieldsz.alias = EasyDPEUtility.replaceString(fieldName);
        }
        return fieldsz;
    }
    
    /*******************************************************************************************************
* @description - Method to create add field list for group data fields
* @param groupWrap- Group data to groupby fields
* @param fieldslist-  fieldslist to add fields in the list
* @param groupBy- List to collect groupby fields.
* returns -  Map<String,EasyDPEWrapper.Fields_Z>
*/
    Public static Map<String,EasyDPEWrapper.Fields_Z> verifyGroupData(List<GroupData> groupWrap, EasyDPEWrapper.Fields_Y[] fieldslist,list<String> groupBy){
        Map<String,EasyDPEWrapper.Fields_Z> fieldsMap = new Map<String,EasyDPEWrapper.Fields_Z>();
        for(GroupData grps : groupWrap){
            if(grps.Values[0] != null){
                groupby.add(grps.Values[0]);
                //Create Lookup fields
                fieldsMap.put('fieldsTransgroup',createFieldList('TotalTransactionAmountAndTotalQuantity',grps.Values[0], true));
                fieldsMap.put('fieldsAppendgroup',createFieldList(appendLabel.replace(' ','_'),grps.Values[0], true));
                
                EasyDPEWrapper.Fields_Y fieldsy =  new EasyDPEWrapper.Fields_Y();  
                fieldsy.sourceFieldName = grps.Values[0];
                fieldsy.targetFieldName = grps.Values[1];
                fieldslist.add(fieldsy);
                
            }
        }
        return fieldsMap;
    }
    
    
    /*******************************************************************************************************
* @description - Method to updates nodes as per selected eligibity criteria
* @param artWrap- Wrapper class of  DPE json file.
* @param data-  fields to add in the list
* @param groupby- List to check groupby fields.
* returns -  void
*/
    Public static void updateEgCriteria(EasyDPEWrapper artWrap,List<String> egData,list<String> groupBy){
        EasyDPEWrapper.Fields_X[] fieldsAggList =  new list<EasyDPEWrapper.Fields_X>(); 
        for(String data : egData){
            EasyDPEWrapper.Fields_X fieldTNew = new  EasyDPEWrapper.Fields_X();
            fieldTNew.sourceFieldName = EasyDPEUtility.replaceString(data);
            fieldTNew.aggregateFunction = 'Sum';
            fieldTNew.alias = 'Total'+EasyDPEUtility.replaceString(data);
            fieldsAggList.add(fieldTNew);
        }
        
            EasyDPEWrapper.Aggregates aggs =  new EasyDPEWrapper.Aggregates();
            aggs.label = 'Total Additional Aggregate Data';
            aggs.name = aggs.label.replace(' ','_');
            aggs.sourceName = 'FilterTransactionJournalsWithValidActivityDates';
            aggs.fields = fieldsAggList;
            aggs.groupBy = new list<String>{'MemberId','RebateTypeId','PayoutPeriodId'};
                if(!groupby.isEmpty())
                aggs.groupBy.addAll(groupby);
            artWrap.Metadata.aggregates.add(aggs);
            
            EasyDPEWrapper.Appends appends = new EasyDPEWrapper.Appends();
            appends.name = appendLabel.replace(' ','_');
            appends.label = appendLabel;
            appends.sources =new list<String>{'TotalTransactionAmountAndTotalQuantity',aggs.label.replace(' ','_')};
                appends.isDisjointedSchema = true;
            EasyDPEWrapper.Appends[] appendList = new List<EasyDPEWrapper.Appends>();
            appendList.add(appends);
            artWrap.Metadata.appends = appendList;
        
        
    }
    
    /*******************************************************************************************************
* @description - Method to updates Transform and WriteBacks nodes.
* @param artWrap - Wrapper class of  DPE json file.
* @param exp -  Experession to check aggregate records as per newly added fields
* @param fieldslist-  fieldslist to add fields in the list
* returns -  void
*/
    Public static void updateTransformandWritebacks(EasyDPEWrapper artWrap, string exp, EasyDPEWrapper.Fields_Y[] fieldslist){
        for(EasyDPEWrapper.Transforms trans : artWrap.Metadata.transforms){
            if(trans.name.contains('ComputeNewOrUpdatedAggregateRecords')){
                EasyDPEWrapper.ExpressionFields[] expFieldsList = new List<EasyDPEWrapper.ExpressionFields>();
                EasyDPEWrapper.ExpressionFields expFields = new EasyDPEWrapper.ExpressionFields();
                exp = exp.removeEnd('&&');
                expFields.expression = 'IF(({TotalAggQuanity} == {TotalQuantity}) && ({TotalAggAmount} == {TotalTransactionAmount}) '+ exp+ ', 0,1)';
                expFields.alias = 'IsUpdateOrNew';
                expFields.dataType = 'Numeric';
                expFields.length = 2;
                expFields.decimalPlaces = 1;
                expFieldsList.add(expFields);
                trans.expressionFields = expFieldsList;
            }
        }
        
        for(EasyDPEWrapper.Writebacks wrbak :artWrap.Metadata.writebacks){
            if(wrbak.name.contains('UpsertTotalTransactionAmountAndQuantity')){
                wrbak.fields.addAll(fieldslist);
            }
        }
    }
    
    /*******************************************************************************************************
* @description -  Method to updates Aggregates nodes.
* @param artWrap - Wrapper class of  DPE json file.
* @param egCr -  Eligibity criteria checklist
* @param fieldslist-  fieldslist to add fields in the list
* @param groupby- boolean to check groupby or not.
* returns -  void
*/
    Public static void updateAggregates(EasyDPEWrapper artWrap, EligibilityCriteria egCr, list<String> groupBy,  EasyDPEWrapper.Fields_X[] fieldsTList){
        for(EasyDPEWrapper.Aggregates aggs : artWrap.Metadata.aggregates){
            if(aggs.name.contains('TotalTransactionAmountAndTotalQuantity')){
                if(!groupby.isEmpty())
                {
                    aggs.groupBy.addAll(groupby);
                }
                aggs.fields.addAll(fieldsTList);
                if(egCr.input0 == 'false' || egCr.input1 == 'false' || egCr.input2 == 'false'){
                    aggs.sourceName = 'FilterValidTransactionJournalsForRebateTypes';
                }
                
            }
        }
    }
    
    /*******************************************************************************************************
* @description - Method to updates field list for joins/filters node
* @param artWrap - Wrapper class of  DPE json file.
* @param egCr -  Eligibity criteria checklist
* @param fieldsMap-  fieldsMap to get fields from the list
* returns -  EasyDPEWrapper
*/
    Public static void updateJoins(EasyDPEWrapper artWrap,  List<DataWrapper> dataWrap,EligibilityCriteria egCr,Map<String,EasyDPEWrapper.Fields_Z> fieldsMap, List<String> groupBy){
        list<EasyDPEWrapper.Fields_Z> listTFields_z = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listTranFields_z = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listTran1Fields_z = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listTran2Fields_z = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listRFields_z = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listRFields_zappend = new list<EasyDPEWrapper.Fields_Z>();
        list<EasyDPEWrapper.Fields_Z> listRFields_ztoalAmount = new list<EasyDPEWrapper.Fields_Z>();
        EasyDPEWrapper.Fields_Z fieldsTrans;
        EasyDPEWrapper.Fields_Z fieldsAppend;
        for(DataWrapper data : dataWrap){
            integer i = 0;
            //Joins Fields
            listTFields_z.add(createFieldList('FilterJournalsByUsageType',data.Values[i],false));
            listRFields_z.add(createFieldList('RebateMemberProductAggregate',data.Values[i+1], false));
            listTranFields_z.add(createFieldList('FilterTransactionJournalsWithValidActivityDates',data.Values[i], false));
            listTran1Fields_z.add(createFieldList('FilterValidTransactionJournalsForRebateTypes',data.Values[i], false));
            listTran2Fields_z.add(createFieldList('TransactionJournalWithAggregateReferenceNumber',data.Values[i], false));
            //Create Lookup fields
            fieldsTrans = createFieldList('TotalTransactionAmountAndTotalQuantity',data.Values[i], false);
            fieldsAppend = createFieldList(appendLabel.replace(' ','_'),data.Values[i], false);
            listRFields_zappend.add(fieldsAppend);
            listRFields_ztoalAmount.add(fieldsTrans);
            
        }
       
        
        for(EasyDPEWrapper.Joins joins :artWrap.Metadata.joins){
            if(joins.name.contains('AddRebateTypeAndPayoutPeriodToTransactionJournal')){
                joins.fields.addAll(listTFields_z);
                Set<String> currentFieldList = new Set<String>();
                 for(EasyDPEWrapper.Fields_Z fs:joins.fields){
                     currentFieldList.add(fs.sourceFieldName);
                 }
                for(String fields : groupBy){
                    if(!currentFieldList.contains(fields)){
                        joins.fields.add(createFieldList('FilterJournalsByUsageType',fields,false));
                    }
                    
                }
              }
            if(joins.name.contains('LookUpExistingAggregateData')){
                
                if(egCr.input0 == 'false' || egCr.input1 == 'false' || egCr.input2 == 'false'){
                    joins.primarySourceName = appendLabel.replace(' ','_');
                    for(EasyDPEWrapper.Fields_Z fs:joins.fields){
                        if(fs.sourceName =='TotalTransactionAmountAndTotalQuantity'){
                            fs.sourceName =appendLabel.replace(' ','_');
                        }
                    }
                    listRFields_z.add(fieldsMap.get('fieldsAppendgroup'));
                    joins.fields.addAll(listRFields_z);
                    joins.fields.addAll(listRFields_zappend);
                }else{
                    joins.fields.addAll(listRFields_ztoalAmount);
                    listRFields_z.add(fieldsMap.get('fieldsTransgroup'));
                    joins.fields.addAll(listRFields_z);
                }
                
            }
            if(joins.name.contains('ValidActivityDatedJournalsWithProgramRebateTypeProduct')){
                joins.fields.addAll(listTranFields_z);
                Set<String> currentFieldList = new Set<String>();
                 for(EasyDPEWrapper.Fields_Z fs:joins.fields){
                     currentFieldList.add(fs.sourceFieldName);
                 }
                for(String fields : groupBy){
                    if(!currentFieldList.contains(fields)){
                        joins.fields.add(createFieldList('FilterTransactionJournalsWithValidActivityDates',fields,false));
                    }
                    
                }
            }
            if(joins.name.contains('TransactionJournalWithAggregateReferenceNumber')){
                joins.fields.addAll(listTran1Fields_z);
            }
            if(joins.name.contains('ValidTransactionJournalsForAggregateItem')){
                joins.fields.addAll(listTran2Fields_z);
            }
        }
    }
    /*******************************************************************************************************
* @description - Method to create field list for data source node
* @param fieldName-  fields to add in the list
* returns -  EasyDPEWrapper
*/ 
    Public static EasyDPEWrapper.Fields createDataFieldList(String fieldName, string dataType){
        EasyDPEWrapper.Fields fields = new EasyDPEWrapper.Fields();
        fields.name = fieldName;
        fields.dataType=dataType;
        fields.displaySequence = 1;
        fields.alias = EasyDPEUtility.replaceString(fieldName);
        return fields;
    }
    public class DataWrapper
    {
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public List<String> Values { get; set; }
        @AuraEnabled
        public Boolean EgCriteria { get; set; }
    }
    
    public class GroupData
    {
        @AuraEnabled
        public String Name{get;set;}
        @AuraEnabled
        public List<String> Values { get; set; }
    }
    
    public class EligibilityCriteria
    {
        @AuraEnabled
        public string input0{get;set;}
        @AuraEnabled
        public String input1 { get; set; }
        @AuraEnabled
        public String input2 { get; set; }
    }
    
    
}