trigger OrderStatusTrigger on Order (after update) {
    for (Order order : Trigger.new) {
        if (order.Status == 'RTO Registration' && Trigger.oldMap.get(order.id).Status != 'RTO Registration') {
            SalesDataIntegration.pushSalesData(order.id);
        }
    }
}