/**
 * @author Dinesh Baddawar
 * @email dinesh.butilitarianlab@gmail.com
 * @create date 2025-02-21 23:30:12
 * @modify date 2025-02-21 23:30:12
 * @desc [Clear Tax API Helper Class]
 */

public class ClearTaxTagIrnNumber {
    
    // Method to Tag IRN Number to Order Record ##3
    @future
    public static void TagIRNnumberToOrder(String orderId,String IrnNumber){
        try{
            Order ordRec = new Order();
            ordRec.Id = orderId;
            if(IrnNumber != null){
                ordRec.IRN_No__c = IrnNumber;
                ordRec.IRN_Generated_DateTime__c = system.Now();
                update ordRec;
                System.debug('Update Order Record with IRN  === >'+ordRec);
            }else{
                System.debug('No IRN Number Found !===>'+orderId);
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }

    // Method to Remove IRN Number to Order Record #6
    @future
    public static void RemoveIRNnumberToOrder(String orderId){
        try{
            Order ordRec = new Order();
            if(orderId != null){
                ordRec.Id = orderId;
                ordRec.IRN_No__c = '';
                ordRec.IRN_Generated_DateTime__c = system.Now();
                update ordRec;
                System.debug('Update Order Record without IRN  === >'+ordRec);
            }else{
                System.debug('No IRN Number Found !===>'+orderId);
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }

      // Method to Generate QR Code - Response which will come from Goverment ##4
    @future(callout=true)
    public static void generateAndStoreQRCode(String data,String recordId) {
        Integer xsize = 170;
        Integer ysize = 170;
        String qrApiUrl = System.Label.QRCodeBaseURL + EncodingUtil.urlEncode(data, 'UTF-8') + '&size=' + ysize + 'x' + xsize + '&format=png';
        try {
            Order ord = [SELECT Id,OrderNumber,Is_QR_Generated__c FROM Order WHERE Id=:recordId LIMIT 1];
            System.debug('ord ##  == >'+ord);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(qrApiUrl);
                request.setMethod('GET');
                HttpResponse response = http.send(request);
                System.debug('Response #3 == > ' + response);
                if (response.getStatusCode() == 200) {
                    Blob qrCodeBlob = response.getBodyAsBlob();
                    System.debug('qrCodeBlob  == >'+qrCodeBlob);
                    Attachment attachment = new Attachment();
                    attachment.ParentId = recordId; 
                    attachment.Name = String.valueOf(ord.OrderNumber)+'_QRCode '+System.now().format('h:mm a')+'.png';
                    attachment.Body = qrCodeBlob;
                    attachment.ContentType = 'png'; 
                    insert attachment; 
                    System.debug('attachment QR Code  == >'+attachment);
                }
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }

    // Delete Generated QR for that Order record after E-invoice generation ##6
    public static void deleteOrderQRcode(Order Orderec){
        try{
            List<Attachment> attList = [SELECT Id FROM Attachment WHERE  Name LIKE :('' + Orderec.OrderNumber + '%') LIMIT 1];
            if(attList.size() > 0){
                delete attList;
                System.debug('Deleted QR Code for Order Record === >'+attList);
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }

    // Update Order When IRN is Cancled ##7
    public static void updateOrderIRNCancel(Order ordRec){
        try{
            ordRec.IRN_No__c = '';
            ordRec.IRN_Generated_DateTime__c = null;
            ordRec.Is_IRN_Cancelled__c = true;
            ordRec.Is_E_invoice_Generated__c = false;
            update ordRec;
            System.debug('Update Order Record without IRN  === >'+ordRec);
            DeleteGenerateE_InvoiceOnIRNCancel(ordRec);
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
    }
   }

    // Delete E-invoice Attachment when IRN is get Cancled ##8
   public static void DeleteGenerateE_InvoiceOnIRNCancel(Order ordRec) {
    try {
        String orderName = ordRec.OrderNumber.trim();
        String searchPattern = '%E-invoice%' + orderName + '%'; 
        System.debug('searchPattern === >' + searchPattern);
        List<Attachment> attList = [SELECT Id FROM Attachment WHERE Name LIKE :searchPattern LIMIT 1];
        if (!attList.isEmpty()) {
            delete attList;
            System.debug('Deleted E-Invoice for Order Record === >' + attList);
        } else {
            System.debug('No matching E-Invoice found for Order Number ==> ' + orderName);
        }
    } catch (Exception e) {
        ExceptionHelper.createExceptionLog(e);
        System.debug('Error Message ==>' + e.getMessage() + ' && Error Line == >' + e.getLineNumber());
    }
  }

  // Method get E-way Bill Number on Shipments ##9
  public static void TagE_wayBillToShipment(String recordId,String ewaybillNo){
    try{
    Shipment shipRec = new Shipment();
    shipRec.Id = recordId;
    shipRec.E_Way_bill__c = ewaybillNo;
    shipRec.Is_E_Way_Bill_No_Generated__c = true;
    update shipRec;
    System.debug('Update Shipment Record with E-way Bill  === >'+shipRec);
    }catch(Exception e){
        ExceptionHelper.createExceptionLog(e);
        System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
    }
  }

}