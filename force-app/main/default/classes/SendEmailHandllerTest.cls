@isTest
public class SendEmailHandllerTest {
    
    @isTest
    Public static void SendEmailHandllerTest(){
        
        Map<string,Object> newMap = TestDataFactory.CreateOrder();
        
        Order o = (Order)newMap.get('OrderId');        
        
        List<attachment> attachmentsToInsert = new List<attachment>();
        // Create Attachment record
        Attachment att1 = new Attachment();
        att1.Name = 'Pre Order Receipt' + o.Id + '.pdf';
        att1.Body = Blob.valueOf('test data');
        att1.ParentId = o.Id;
        att1.ContentType = 'application/pdf';
        
        attachmentsToInsert.add(att1);
        
        Order_Payment__c op = (Order_Payment__c)newMap.get('OrderPaymentId'); 
        Map<Id, List<Attachment>> mapOrderIdToAttachments = new Map<Id, List<Attachment>>();
        mapOrderIdToAttachments.put(o.Id,attachmentsToInsert);
        Test.starttest();
		SendEmailHandller.SendEmailHandller(new List<Order>{o}, mapOrderIdToAttachments);
        SendEmailHandller.SendEmailHandller2(new List<Order>{o},attachmentsToInsert);
        SendEmailHandller.sendPreAttchamnets(op.Id,attachmentsToInsert);
        test.stoptest();        
    }
    
}