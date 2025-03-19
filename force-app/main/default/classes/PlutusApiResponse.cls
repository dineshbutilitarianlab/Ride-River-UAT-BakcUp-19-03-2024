public class PlutusApiResponse {
    @AuraEnabled
    public Integer ResponseCode;
    @AuraEnabled
    public String ResponseMessage;
    @AuraEnabled
    public String PlutusTransactionReferenceID;
    @AuraEnabled
    public List<TransactionData> TransactionData;

    public class TransactionData {
        @AuraEnabled
        public String Tag;
        @AuraEnabled
        public String Value;
    }
}