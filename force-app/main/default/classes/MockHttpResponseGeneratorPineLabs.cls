public class MockHttpResponseGeneratorPineLabs implements HttpCalloutMock {
    
    private Map<String, String> responseMap;
    
    public MockHttpResponseGeneratorPineLabs(Map<String, String> responseMap) {
        this.responseMap = responseMap;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        
        String jsonResponse = '{"PlutusTransactionReferenceID": "' + responseMap.get('PlutusTransactionReferenceID') + '", ' +
            '"ResponseCode": "' + responseMap.get('ResponseCode') + '", ' +
            '"ResponseMessage": "' + responseMap.get('ResponseMessage') + '", ' +
            '"TransactionData": [{' +
            '"Tag": "RRN", "Value": "' + responseMap.get('RRN') + '"}, ' +
            '{"Tag": "Acquirer Name", "Value": "' + responseMap.get('Acquirer Name') + '"}, ' +
            '{"Tag": "ApprovalCode", "Value": "' + responseMap.get('ApprovalCode') + '"}, ' +
            '{"Tag": "Transaction Date", "Value": "' + responseMap.get('Transaction Date') + '"}, ' +
            '{"Tag": "Transaction Time", "Value": "' + responseMap.get('Transaction Time') + '"}, ' +
            '{"Tag": "TransactionLogId", "Value": "' + responseMap.get('TransactionLogId') + '"}, ' +
            '{"Tag": "MID", "Value": "' + responseMap.get('MID') + '"}]}';
        
        res.setBody(jsonResponse);
        return res;
    }
    
}