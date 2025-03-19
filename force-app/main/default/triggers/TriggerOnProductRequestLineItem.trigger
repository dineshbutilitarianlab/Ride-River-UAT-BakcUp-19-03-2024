trigger TriggerOnProductRequestLineItem on ProductRequestLineItem (After insert, After Update) {
    if (trigger.IsAfter && (trigger.IsInsert || trigger.IsUpdate)) {
        ProductRequestLineItemHandler.productLineItemUnitPrice(trigger.new);
    }
}