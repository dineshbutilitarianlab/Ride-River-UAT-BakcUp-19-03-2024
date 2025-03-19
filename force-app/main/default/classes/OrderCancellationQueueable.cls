public class OrderCancellationQueueable implements Queueable {
    private Set<Id> idSet;
    
    public OrderCancellationQueueable(Set<Id> ids) {
        this.idSet = ids;
    }
    
    public void execute(QueueableContext context) {
        
        List<Order> orderList = [SELECT Id, Total_Amount_paid__c, Assigned_Vehicle__c, Status, payment_status__c,
                                 (SELECT Id, TotalPrice, Status__c, Order.Assigned_Vehicle__c, Type__c FROM OrderItems)
                                 FROM Order 
                                 WHERE ID IN :idSet];
        
        List<Order> ordersToUpdate = new List<Order>();
        List<OrderItem> ordersProdToUpdate = new List<OrderItem>();
        
        for (Order order : orderList) {
            Order newOrder = order;
            Decimal totalPrice = 0;
            Decimal totalRefund = 0;
            Integer refundCount = 0;
            Integer deliveryPCount = 0;
            Boolean vehicleAssigned = false;
            
            for (OrderItem item : order.OrderItems) {
                if (item.Type__c == 'Vehicle' && item.Status__c == 'REFUND_REQUESTED') {
                    vehicleAssigned = true;
                }
                
                if (item.Status__c == 'READY_FOR_DELIVERY' || item.Status__c == 'DELIVERED') {
                    deliveryPCount += 1;
                }
                
                if (item.TotalPrice != null) {
                    if (item.Status__c == 'REFUND_REQUESTED') {
                        totalRefund += item.TotalPrice;
                        refundCount = refundCount + 1;
                    } else {
                        totalPrice += item.TotalPrice;
                    }
                }
            }
            
            //Make the payment status completed
            if(order.Total_Amount_paid__c >= totalPrice && totalPrice != 0){
                order.payment_status__c = 'Completed';
                system.debug('made the payment status as completed');
            }
            
            
            // Cancel the order if all the orders products are cancelled
            if (refundCount == order.OrderItems.size()) {
                System.debug('order is cancelled is running');
                order.Status = 'Order Cancelled';
            }
            
            // Make the order ready for delivery if all the remaining products are either delivered or ready for delivery
            else if (deliveryPCount == (order.OrderItems.size() - refundCount) && order.Total_Amount_paid__c >= totalPrice && vehicleAssigned != true) {
                
                order.Status = 'Ready For Delivery';
            }
            
            // Remove the assigned vehicle
            if (vehicleAssigned) {
                
                order.Status = 'Order Cancelled';
                // }
            }
            
            ordersToUpdate.add(order);
        }
        
        //Database.update(ordersToUpdate, false);
        
        Database.SaveResult[] updateResults = Database.update(ordersToUpdate, false);
        
        for (Database.SaveResult result : updateResults) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error updating record: ' + error.getStatusCode() + ' - ' + error.getMessage());
                }
            }else{
                system.debug('updated succesfully>>'+result);
            }
        }
        
    }
}