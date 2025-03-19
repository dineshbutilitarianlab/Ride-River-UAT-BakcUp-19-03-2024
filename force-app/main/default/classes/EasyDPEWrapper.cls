public class EasyDPEWrapper {
    public class Parameters {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String dataType;
        @AuraEnabled public String defaultValue;
    }
    
    @AuraEnabled public String FullName;
    @AuraEnabled public Metadata Metadata;
    
    
    public class Writebacks {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String sourceName;
        @AuraEnabled public String targetObjectName;
        @AuraEnabled public String operationType;
        @AuraEnabled public Integer writebackSequence;
        @AuraEnabled public String writebackUser;
        @AuraEnabled public List<Fields_Y> fields;
    }
    
    public class ExpressionFields_Z {
        @AuraEnabled public String expression;
        @AuraEnabled public String alias;
        @AuraEnabled public String dataType;
        @AuraEnabled public Integer length;
    }
    
    public class Transforms {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String sourceName;
        @AuraEnabled public List<DroppedFields> droppedFields;
        @AuraEnabled public List<ExpressionFields> expressionFields;
        @AuraEnabled public List<PartitionBy> partitionBy;
        @AuraEnabled public String transformationType;
    }
    
    public class DroppedFields {
        @AuraEnabled public String sourceFieldName;
    }
    public class Criteria_Y {
        @AuraEnabled public String sourceFieldName;
        @AuraEnabled public String operator;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public String value;
    }
    
    public class Fields_Y {
        @AuraEnabled public String sourceFieldName;
        @AuraEnabled public String targetFieldName;
        @AuraEnabled public String parentName;
        @AuraEnabled public String relationshipName;
    }
    
    public class PartitionBy {
    }
    
    public class Metadata {
        @AuraEnabled public String processType;
        @AuraEnabled public String status;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean isTemplate;
        @AuraEnabled public List<Datasources> datasources;
        @AuraEnabled public List<Joins> joins;
        @AuraEnabled public List<Filters> filters;
        @AuraEnabled public List<Appends> appends;
        @AuraEnabled public List<Writebacks> writebacks;
        @AuraEnabled public List<Transforms> transforms;
        @AuraEnabled public List<Aggregates> aggregates;
        @AuraEnabled public List<HierarchyPaths> hierarchyPaths;
        @AuraEnabled public List<Parameters> parameters;
    }
    
    public class Fields_X {
        @AuraEnabled public String sourceFieldName;
        @AuraEnabled public String aggregateFunction;
        @AuraEnabled public String alias;
    }
    
    public class Datasources {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String sourceName;
        @AuraEnabled public String type;
        @AuraEnabled public List<Fields> fields;
    }
    
    public class Criteria {
        @AuraEnabled public String sourceFieldName;
        @AuraEnabled public String operator;
        @AuraEnabled public String value;
        @AuraEnabled public Integer sequence;
        @AuraEnabled public String inputVariable;
    }
    
    public class Fields_Z {
        @AuraEnabled public String sourceName;
        @AuraEnabled public String sourceFieldName;
        @AuraEnabled public String alias;
    }
    
    public class Joins {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public String primarySourceName;
        @AuraEnabled public String secondarySourceName;
        @AuraEnabled public List<JoinKeys> joinKeys;
        @AuraEnabled public List<Fields_Z> fields;
    }
    
    public class Filters {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String sourceName;
        @AuraEnabled public String filterCondition;
        @AuraEnabled public List<Criteria> criteria;
        @AuraEnabled public Boolean isDynamicFilter;
        @AuraEnabled public String filterParameterName;
    }
    
    public class Fields {
        @AuraEnabled public String name;
        @AuraEnabled public String dataType;
        @AuraEnabled public String alias;
        @AuraEnabled public Integer displaySequence;
    }
    public class Appends {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean isDisjointedSchema;
        @AuraEnabled public List<String> sources;
    }
    public class Aggregates {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String description;
        @AuraEnabled public String sourceName;
        @AuraEnabled public List<Fields_X> fields;
        @AuraEnabled public List<String> groupBy;
    }
    
    public class ExpressionFields {
        @AuraEnabled public String expression;
        @AuraEnabled public String alias;
        @AuraEnabled public String dataType;
        @AuraEnabled public Integer length;
        @AuraEnabled public Integer decimalPlaces;
    }
    
    public class JoinKeys {
        @AuraEnabled public String primarySourceFieldName;
        @AuraEnabled public String secondarySourceFieldName;
    }
    
    public class HierarchyPaths {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public String sourceName;
        @AuraEnabled public String selfFieldName;
        @AuraEnabled public String parentFieldName;
        @AuraEnabled public String hierarchyFieldName;
    }
    
    public static EasyDPEWrapper parse(String json) {
        return (EasyDPEWrapper) System.JSON.deserialize(json, EasyDPEWrapper.class);
    }
}