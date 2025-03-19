public class GenericClass {
    
    Public static boolean checkStatePicklistvalue(string accState, string dealerState){
        system.debug('accState==>'+accState +'::::dealerState==>' + dealerState );
        
        Boolean sameState = false;
        stateWrapper stateWrapper = getStateValue();
        
        Map<String, String> stateCodeToNameMap = stateWrapper.stateCodeToNameMap;
        Map<String, String> stateNameToCodeMap = stateWrapper.stateNameToCodeMap;
        
        string accStatAlt = '';
        string dealerStateAlt = '';
        
        accState = accState.toLowerCase();
        dealerState = dealerState.toLowerCase();
        
        If(accState == dealerState){
            sameState = true;
        }else{
            If(stateCodeToNameMap.containsKey(accState)){
                accStatAlt = stateCodeToNameMap.get(accState);
            }else If(stateNameToCodeMap.containsKey(accState)){
                accStatAlt = stateNameToCodeMap.get(accState);
            }
            
            If(stateCodeToNameMap.containsKey(dealerState)){
                dealerStateAlt = stateCodeToNameMap.get(dealerState);
            }else If(stateNameToCodeMap.containsKey(dealerState)){
                dealerStateAlt = stateNameToCodeMap.get(dealerState);
            }
        }
        
        If(accState == dealerStateAlt || dealerState == accStatAlt){
            sameState = true;
        }
        
        return sameState;
    }
    
    
    // Method to get the state code for a given state name or state name for a given state code
    public static stateWrapper getStateValue() {
        
        stateWrapper stateWrapper = new stateWrapper();
        Schema.DescribeFieldResult fieldResult = User.statecode.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        Map<String, String> stateCodeToNameMap = new Map<String, String>();
        Map<String, String> stateNameToCodeMap = new Map<String, String>();
        
        for (Schema.PicklistEntry entry : ple) {
            String code = entry.getValue().toLowerCase();
            String name = entry.getLabel().toLowerCase();
            stateCodeToNameMap.put(code, name);
            stateNameToCodeMap.put(name, code);
        }
        
        stateWrapper.stateCodeToNameMap = stateCodeToNameMap;
        stateWrapper.stateNameToCodeMap = stateNameToCodeMap;
        
        return stateWrapper;

    }
    
    public class stateWrapper{
        public Map<String, String> stateCodeToNameMap { get; set; }
        public Map<String, String> stateNameToCodeMap { get; set; }
        
        public StateWrapper() {
            stateCodeToNameMap = new Map<String, String>();
            stateNameToCodeMap = new Map<String, String>();
        }
    }
    
}