public class PineLabs_UploadTxnBatch implements Database.Batchable<PineLabs_UploadTxn.reqWrapper>, Database.AllowsCallouts {
    private List<PineLabs_UploadTxn.reqWrapper> pSplitWrapList;
    
    public PineLabs_UploadTxnBatch(List<PineLabs_UploadTxn.reqWrapper> pSplitWrapList) {
        this.pSplitWrapList = pSplitWrapList;
    }
    
    public Iterable<PineLabs_UploadTxn.reqWrapper> start(Database.BatchableContext bc) {
        return pSplitWrapList; 
    }
    
    public void execute(Database.BatchableContext bc, List<PineLabs_UploadTxn.reqWrapper> scope) {
        try {            
            system.debug('scope === > ' + scope);
            List<Payment_Split__c> splitList = new List<Payment_Split__c>();
            for(PineLabs_UploadTxn.reqWrapper pWrap : scope){ 
                DateTime stDateTime = System.Now();                        
                PineLabs_UploadTxn.responseWrapper wrapRes = PineLabs_UploadTxn.doPost(pWrap.paymentSplitId, pWrap.seqNo, pWrap.oppId, pWrap.PnLbMachineId);
                system.debug('wrapRes === > ' + wrapRes);
                if(wrapRes.pSplitRec != null){
                    splitList.add(wrapRes.pSplitRec);
                    DateTime endDateTime = System.Now(); 
                }
            }
            if (!splitList.isEmpty())
                update splitList;
            system.debug('splitList === >' + splitList);
        } 
        catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Exception === > ' + e.getMessage() + ' && Error line === > ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Success fully Batch Run == >'+bc);
    }
    
}