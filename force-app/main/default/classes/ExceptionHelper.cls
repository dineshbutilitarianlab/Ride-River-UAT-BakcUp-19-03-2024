/**
* @author [Dinesh Baddawar]
* @email dinesh.b@utilitarianLab.com
* @create date 2024-07-18 13:30:49
* @modify date 2024-07-18 13:30:49
* @desc [This class is used to capture exception]
*/
public with sharing class ExceptionHelper {
    // Method to create exception log
    public static Exception_Log__c createExceptionLog(Exception expObj) {
        try {
            if (expObj != null) {
                Exception_Log__c exceptionLog = new Exception_Log__c();
                exceptionLog.Error_Message__c = String.valueOf(expObj.getMessage());
                exceptionLog.Error_Stack_Trace__c = String.valueOf(expObj.getStackTraceString());
                exceptionLog.Timestamp__c = DateTime.now();
                exceptionLog.Error_Line_No__c = Decimal.valueOf(expObj.getLineNumber());
                exceptionLog.Error_Type__c = String.valueOf(expObj.getTypeName());
                exceptionLog.Integration_Type__c = 'Apex Type';
                String tempObj = expObj.getStackTraceString();
                String[] stackTraceParts = tempObj.split(':')[0].split('\\.');
                if (stackTraceParts.size() > 1) {
                    exceptionLog.Class_Name__c = stackTraceParts[1] != null ? stackTraceParts[1] : '';
                    exceptionLog.Method_Name__c = stackTraceParts[2] != null ? stackTraceParts[2] : '';
                    exceptionLog.Developer_Name__c = [SELECT CreatedBy.Name FROM ApexClass WHERE Name =:stackTraceParts[1] LIMIT 1].CreatedBy.Name;
                }
                insert exceptionLog;
                System.debug('exceptionLog == >'+exceptionLog);
                return exceptionLog;
            }
        } catch (Exception e) {
            ExceptionHelper.createExceptionLog(e);
            System.debug('The Error: ' + e.getMessage() + ' AND Error Line No: ' + e.getLineNumber());
        }
        return null;
    }

    // Method to create exception log for callout
    public static void createAPICalloutLog(HttpRequest httpReq, HttpResponse httpRes,String refId) {
        try{
            Exception_Log__c logger = new Exception_Log__c();
            logger.Integration_Type__c = 'CALLOUT';
            logger.Start_Date_And_Time__c =  DateTime.now();
            logger.End_Date_And_Time__c =  DateTime.now();
            logger.Reference_Id__c = refId != null || refId != '' ? refId : '';
            if(httpReq != null) {
                logger.HTTP_Method__c = httpReq.getMethod();
                logger.Request_Body__c = httpReq.getBody().length() > 131000 ? httpReq.getBody().substring(0, 131000) : httpReq.getBody();
                logger.EndPoint__c = httpReq.getEndPoint();
            }
            if(httpRes != null) {
                logger.Response_Body__c = httpRes.getBody().length() > 131000 ? httpRes.getBody().substring(0, 131000) : httpRes.getBody();
                logger.Response_Status_Code__c = httpRes.getStatusCode();
            }
            insert logger;
            System.debug('API Callout Exception === >'+logger);
        }catch(Exception e){
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
}