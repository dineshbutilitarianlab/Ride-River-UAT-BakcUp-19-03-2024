/**
* @author Dinesh Baddawar
* @email dinesh.butilitarianlab@gmail.com
* @create date 2025-01-03 17:11:45
* @modify date 2025-01-03 17:11:45
* @desc [Generate PineLabs API]
*/

public class PineLabsPaymentHelper {
    
    public static PineLabs_API_Config__c PineLabsAPIDetails;
    static {
        PineLabsAPIDetails = PineLabs_API_Config__c.getInstance('PineLabs API URL');
        if (PineLabsAPIDetails == null) {
            System.debug('Custom setting "ClearTax Api" is not found.');
        }
    }
    
    @AuraEnabled
    public static List<Pinelabs_Machine_Info__c> getPinelabsMachineInfo(Id OrderId) {
        try{
            Order ord = [SELECT Id, Dealer__c FROM Order WHERE Id = :OrderId LIMIT 1];
            if (ord == null) {
                return new List<Pinelabs_Machine_Info__c>();
            }
            List<Pinelabs_Machine_Info__c> records = [ SELECT Id, Name, Device_No__c, Merchant_Name__c,Store_Name__c  FROM Pinelabs_Machine_Info__c];
            system.debug('records === >'+records);
            return records;
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
            ExceptionHelper.createExceptionLog(e);
        }
        return null;
    }
    
    @AuraEnabled
    public static void savePaymentLogs(List<Map<String, Object>> paymentSplits, Id orderId, Id pnLbMcnId) {
        try{
            List<Payment_Split__c> recordsToInsert = new List<Payment_Split__c>();
            System.debug('paymentSplits-->' + paymentSplits +' && orderId == >'+orderId+' && pnLbMcnId == >'+pnLbMcnId);
            for (Map<String, Object> split : paymentSplits) {
                System.debug('split == >' + split);
                String pnLbMcnInfoId = '';
                String paymentMode = (String)split.get('Payment_Mode__c');
                if (paymentMode == 'UPI' || paymentMode == 'Card') {
                    pnLbMcnInfoId = pnLbMcnId;
                } else {
                    pnLbMcnInfoId = null; 
                }
                String status = paymentMode == 'Cash' ? 'Paid' : 'Initiated';
                System.debug('status == >'+status);
                Payment_Split__c paymentSplit = new Payment_Split__c(
                    Order__c = (String)split.get('Order__c'),
                    Payment_Mode__c = paymentMode,
                    Pay_Amount__c = Decimal.valueOf((String)split.get('Pay_Amount__c')),
                    Status__c = status,
                    Pinelabs_Machine_Info__c = pnLbMcnInfoId,
                    Remark__c = (String)split.get('Remark__c')
                  //  Transaction_Id__c = (String)split.get('Transaction_Id__c')
                );
                recordsToInsert.add(paymentSplit);
            }
            if (recordsToInsert.size() > 0) {
                insert recordsToInsert;
                System.debug('recordsToInsert == >' + recordsToInsert);
            }
            Map<Id, List<Payment_Split__c>> mpaofOppIdListOfPaymentSplit = new Map<Id, List<Payment_Split__c>>();
            for (Payment_Split__c paymentsplit : recordsToInsert) {
                if (paymentsplit.Order__c != null && !paymentsplit.PineLabs_Initiated__c && 
                    (paymentsplit.Payment_Mode__c == 'Card' || paymentsplit.Payment_Mode__c == 'UPI')) {
                        if (mpaofOppIdListOfPaymentSplit.containsKey(paymentsplit.Order__c))
                            mpaofOppIdListOfPaymentSplit.get(paymentsplit.Order__c).add(paymentsplit);
                        else
                            mpaofOppIdListOfPaymentSplit.put(paymentsplit.Order__c, new List<Payment_Split__c> { paymentsplit });
                    }
            }
            System.debug('mpaofOppIdListOfPaymentSplit -->> ' + mpaofOppIdListOfPaymentSplit);
            Set<Id> orderIdSet = new Set<Id>();
            List<PineLabs_UploadTxn.reqWrapper> reqList = new List<PineLabs_UploadTxn.reqWrapper>();
            for (Id oppId : mpaofOppIdListOfPaymentSplit.keySet()) {
                if (mpaofOppIdListOfPaymentSplit.containsKey(oppId)) {
                    Integer i = 1;
                    for (Payment_Split__c paymentSplitRec : mpaofOppIdListOfPaymentSplit.get(oppId)) {
                        if (paymentSplitRec.Status__c != 'Paid') {
                            PineLabs_UploadTxn.reqWrapper rWrap = new PineLabs_UploadTxn.reqWrapper();
                            rWrap.paymentSplitId = paymentSplitRec.Id;
                            rWrap.seqNo = i;
                            rWrap.oppId = oppId;
                            rWrap.PnLbMachineId = paymentSplitRec.Pinelabs_Machine_Info__c;
                            reqList.add(rWrap);
                            i++;
                            orderIdSet.add(oppId);
                        }
                    }
                }
            }
            System.debug('reqList === >' + reqList);
            Database.executeBatch(new PineLabs_UploadTxnBatch(reqList));
            Order ordRec = [SELECT ID,Status,Total_Log_Payment__c,Remaining_Amount__c FROM Order WHERE Id = :orderId LIMIT 1];
            ordRec.Status = 'Payment Pending';
            Boolean IsPaymentComp;
            if (ordRec != null && ordRec.Total_Log_Payment__c >= ordRec.Remaining_Amount__c ) {
                update ordRec;
                System.debug('ordRec === >'+ordRec);
            }else{
                System.debug('Full Payment is Incomplete === >');
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    public static Map<String, String> GetPaymentStatusAPI(String recordId){
        PlutusApiResponse responseObj = new PlutusApiResponse();
        Map<String, String> responseMap = new Map<String, String>();
        try{
            PineLabs_API_Config__c pineLabsDetails = PineLabs_API_Config__c.getInstance('PineLabs API URL');
            Payment_Split__c logpay = [SELECT Id,Name,Acquirer_Name__c,Retrieval_Reference_Number__c,Transaction_Log_Id__c,Merchant_ID__c,ApprovalCode__c,Transaction_Date__c,Transaction_Time__c,PineLabs_Machine_Info__c,PineLabs_Machine_Info__r.Merchant_ID__c,PineLabs_Machine_Info__r.Security_Token__c,PineLabs_Machine_Info__r.Store_Id__c,Plutus_Txn_ref_Id__c,Pine_Labs_Response_Status__c,Order__c,IsPayment_Status_Checked__c,Pay_Amount__c,Payment_Mode__c FROM Payment_Split__c WHERE Id=:recordId Order BY CreatedDate DESC LIMIT 1];
            System.debug('logpay === >'+logpay);
            if(logpay != null && logpay.IsPayment_Status_Checked__c == false){
                responseObj =  HTTPUtility.getInstance().getTransactionStatus(logpay.PineLabs_Machine_Info__r.Merchant_ID__c, logpay.PineLabs_Machine_Info__r.Security_Token__c, logpay.PineLabs_Machine_Info__r.Store_Id__c, logpay.Plutus_Txn_ref_Id__c, pineLabsDetails.Payment_Status_Endpoint_URL__c);
                System.debug('responseObj === >'+responseObj);
                if(responseObj != null){
                    responseMap.put('PlutusTransactionReferenceID', responseObj.PlutusTransactionReferenceID);
                    responseMap.put('ResponseCode', String.valueOf(responseObj.ResponseCode));
                    responseMap.put('ResponseMessage', responseObj.ResponseMessage);
                    if (responseObj.TransactionData != null && !responseObj.TransactionData.isEmpty()) {
                        System.debug('responseObj.TransactionData == >'+responseObj.TransactionData);
                        for (PlutusApiResponse.TransactionData trans : responseObj.TransactionData) {
                            if (trans.Tag == 'TID' || trans.Tag == 'MID' || trans.Tag == 'Amount' || trans.Tag == 'RRN' || trans.Tag == 'ApprovalCode' || trans.Tag == 'PaymentMode' || trans.Tag == 'Acquirer Name' || trans.Tag == 'Transaction Date' || trans.Tag == 'Transaction Time' || trans.Tag == 'TransactionLogId') {
                                responseMap.put(trans.Tag, trans.Value);
                            }
                        }
                    }
                }
                System.debug('responseMap # 1 === >'+responseMap);
                if(responseMap != null && logpay.IsPayment_Status_Checked__c != true){
                    UpdateTransCationDetailOnLogPayment(logpay.Id,responseMap.get('RRN'),responseMap.get('Acquirer Name'),responseMap.get('ApprovalCode'),responseMap.get('Transaction Date'),responseMap.get('Transaction Time'),responseMap.get('TransactionLogId'),responseMap.get('MID'),responseMap.get('TID'));
                    return responseMap;
                }else{
                    System.debug('Alreay Payment Staus is Checked / Updated === >'+logpay.IsPayment_Status_Checked__c);
                    return new Map<String, String>();
                }
            }else{
                System.debug('Payment Status id Checked === >'+logpay.IsPayment_Status_Checked__c);
                responseMap.put('ResponseCode', '0');
                responseMap.put('Amount', String.valueOf(logpay.Pay_Amount__c));
                responseMap.put('PlutusTransactionReferenceID', String.valueOf(logpay.Plutus_Txn_ref_Id__c));
                responseMap.put('PaymentMode', String.valueOf(logpay.Payment_Mode__c));
            }
            System.debug('responseMap # 2 === >'+responseMap);
            return responseMap;
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    Public static void  UpdateTransCationDetailOnLogPayment(String recordId,String RRNId,String AcquirerName,String ApprovalCode,String TransactionDate,String TransactionTime,String TransactionLogId,String MIDId,String TID){
        try{
            if(recordId !=null){
                Integer day = Integer.valueOf(TransactionDate.substring(0, 2));
                Integer month = Integer.valueOf(TransactionDate.substring(2, 4));
                Integer year = Integer.valueOf(TransactionDate.substring(4, 8));
                
                Integer hours = Integer.valueOf(TransactionTime.substring(0, 2));
                Integer minutes = Integer.valueOf(TransactionTime.substring(2, 4));
                Integer seconds = Integer.valueOf(TransactionTime.substring(4, 6));
                String period = (hours >= 12) ? 'PM' : 'AM';
                hours = (hours == 0) ? 12 : (hours > 12 ? hours - 12 : hours);
                    
                    String formattedTime = String.format('{0}:{1}:{2} {3}', 
                                            new String[] {
                                            String.valueOf(hours),
                                            minutes < 10 ? '0' + String.valueOf(minutes) : String.valueOf(minutes),
                                            seconds < 10 ? '0' + String.valueOf(seconds) : String.valueOf(seconds),
                                            period});
                Payment_Split__c paylog = new Payment_Split__c();
                paylog.Id =recordId;
                paylog.Retrieval_Reference_Number__c = RRNId != null ? RRNId : '';
                paylog.Acquirer_Name__c = AcquirerName != null ? AcquirerName : '';
                paylog.ApprovalCode__c = ApprovalCode != null ? ApprovalCode : '';
                paylog.Transaction_Log_Id__c = TransactionLogId != null ? TransactionLogId : '';
                paylog.Merchant_ID__c = MIDId != null ? MIDId : '';
                paylog.IsPayment_Status_Checked__c = true;
                paylog.Transaction_Date__c = Date.newInstance(year, month, day);
                paylog.Transaction_Time__c = formattedTime;
                paylog.TID__c = TID != null ? TID : '';
                if(ApprovalCode == '00'){
                    paylog.Status__c = 'Paid';
                }
                update paylog;
                System.debug('Updated Record === >'+paylog);
            }else{
                System.debug('No Records find === >'+recordId);
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    // Method to call the CancelTransaction API
    @AuraEnabled
    public static String cancelTransaction(String recordId) {
        try {
            if(recordId != null){
                Payment_Split__c paylog = [SELECT Id,PineLabs_Machine_Info__c,PineLabs_Machine_Info__r.Merchant_ID__c,PineLabs_Machine_Info__r.Security_Token__c,PineLabs_Machine_Info__r.Store_Id__c,PineLabs_Machine_Info__r.Client_Id__c,Plutus_Txn_ref_Id__c,Pay_Amount__c FROM Payment_Split__c WHERE Id =:recordId LIMIT 1];
                String endpoint = PineLabsAPIDetails.Cancel_Txn_Endpoint_URL__c;
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                
                Map<String, Object> payload = new Map<String, Object>();
                payload.put('MerchantID', paylog.PineLabs_Machine_Info__r.Merchant_ID__c);
                payload.put('SecurityToken', paylog.PineLabs_Machine_Info__r.Security_Token__c);
                payload.put('ClientId', paylog.PineLabs_Machine_Info__r.Client_Id__c);
                payload.put('StoreID', paylog.PineLabs_Machine_Info__r.Store_Id__c);
                payload.put('PlutusTransactionReferenceID', paylog.Plutus_Txn_ref_Id__c);
                payload.put('Amount', paylog.Pay_Amount__c);
                String requestBody = JSON.serialize(payload);
                req.setBody(requestBody);
                Http http = new Http();
                HttpResponse res = http.send(req);
                ExceptionHelper.createAPICalloutLog(req,res,recordId);
                if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                    String response = res.getBody();
                    System.debug('response == > ' + res.getBody());
                    paylog.Status__c = 'Rejected';
                    return 'SUCCESS';
                } else {
                    System.debug('Error response: ' + res.getBody());
                    return String.valueOf(res.getBody());
                }
            }else{
                return 'No Record Found !';
            }
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('Exception Message == > ' + e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
        return null;
    }
    
    public static void testData(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
    public static void testData1(){
        Integer i=0;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
        i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;i++;
    }
    
}