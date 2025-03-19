public class RR_Additional_Job_Recommended_Handler {
    public static void handleUnitPriceUpdate(List<RR_Additional_Job_Recommended__c> additionalJobs) {
        Set<Id> productIds = new Set<Id>();
        for (RR_Additional_Job_Recommended__c additionalJob : additionalJobs) {
            if (additionalJob.RR_Product__c != null) {
                productIds.add(additionalJob.RR_Product__c);
            }
        }

        Map<Id, PricebookEntry> productPriceBookEntries = new Map<Id, PricebookEntry>();
        for (PricebookEntry pbe : [SELECT Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :productIds]) {
            productPriceBookEntries.put(pbe.Product2Id, pbe);
        }

        for (RR_Additional_Job_Recommended__c additionalJob : additionalJobs) {
            if (additionalJob.RR_Product__c != null) {
                PricebookEntry pbe = productPriceBookEntries.get(additionalJob.RR_Product__c);
                if (pbe != null) {
                    additionalJob.RR_Unit_Price__c = pbe.UnitPrice;
                }
            }
        }
    }
}