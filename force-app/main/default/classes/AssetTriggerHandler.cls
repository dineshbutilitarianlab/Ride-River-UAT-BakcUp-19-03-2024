public class AssetTriggerHandler {

    public static void handleAssetInsert(List<Asset> newAssets) {
        try {
            Set<Id> productIds = new Set<Id>();
            Map<Id, String> productNameMap = new Map<Id, String>(); // Map to store Product2Id -> Product2.Name
            Boolean isExtendedWarrantyProductPresent = false; // Flag to check if any product is 'Extended Warranty'

            // Collect Product IDs from Assets
            for (Asset asset : newAssets) {
                if (asset.Product2Id != null) {
                    productIds.add(asset.Product2Id);
                }
            }
            System.debug('Collected Product2 IDs: ' + productIds);

            if (productIds.isEmpty()) {
                System.debug('No Product2 IDs found, exiting.');
                return;
            }

            // Query Products and Map Product Names
            List<Product2> products = [
                SELECT Id, Name
                FROM Product2
                WHERE Id IN :productIds
            ];
            for (Product2 product : products) {
                productNameMap.put(product.Id, product.Name);
                if (product.Name == 'Extended Warranty') {
                    isExtendedWarrantyProductPresent = true; // Extended Warranty Product exists
                }
            }
            System.debug('Product Name Map: ' + productNameMap);
            System.debug('Is Extended Warranty Product Present: ' + isExtendedWarrantyProductPresent);

            // Query ProductWarrantyTerms
            Map<Id, List<ProductWarrantyTerm>> productWarrantyTermMap = new Map<Id, List<ProductWarrantyTerm>>();
            List<ProductWarrantyTerm> productWarrantyTerms = [
                SELECT CoveredProductId, WarrantyTermId, WarrantyTerm.WarrantyDuration, WarrantyTerm.WarrantyType,
                WarrantyTerm.ExchangeType, WarrantyTerm.Exclusions, WarrantyTerm.IsTransferable, WarrantyTerm.LaborCovered,
                WarrantyTerm.PartsCovered, WarrantyTerm.ExpensesCovered, WarrantyTerm.ExpensesCoveredDuration, WarrantyTerm.ExpensesCoveredUnitOfTime,
                WarrantyTerm.LaborCoveredDuration, WarrantyTerm.LaborCoveredUnitOfTime, WarrantyTerm.PartsCoveredDuration, WarrantyTerm.PartsCoveredUnitOfTime
                FROM ProductWarrantyTerm
                WHERE CoveredProductId IN :productIds
            ];

            for (ProductWarrantyTerm pwt : productWarrantyTerms) {
                if (!productWarrantyTermMap.containsKey(pwt.CoveredProductId)) {
                    productWarrantyTermMap.put(pwt.CoveredProductId, new List<ProductWarrantyTerm>());
                }
                productWarrantyTermMap.get(pwt.CoveredProductId).add(pwt);
            }
            System.debug('ProductWarrantyTerm Map: ' + productWarrantyTermMap);

            // Query WarrantyTerms with isExtended__c = true
            List<WarrantyTerm> extendedWarrantyTerms = [
                SELECT Id, WarrantyDuration, WarrantyType, ExchangeType, Exclusions, IsTransferable, LaborCovered,
                PartsCovered, ExpensesCovered, ExpensesCoveredDuration, ExpensesCoveredUnitOfTime,
                LaborCoveredDuration, LaborCoveredUnitOfTime, PartsCoveredDuration, PartsCoveredUnitOfTime
                FROM WarrantyTerm
                WHERE isExtended__c = true
            ];

            List<AssetWarranty> warrantiesToInsert = new List<AssetWarranty>();

            // Iterate through each Asset
            for (Asset asset : newAssets) {
                List<ProductWarrantyTerm> relatedPWTs = productWarrantyTermMap.get(asset.Product2Id);

                // Create a standard AssetWarranty for every Asset
                if (relatedPWTs != null) {
                    for (ProductWarrantyTerm pwt : relatedPWTs) {
                        AssetWarranty warranty = new AssetWarranty();
                        warranty.AssetId = asset.Id;
                        warranty.WarrantyTermId = pwt.WarrantyTermId;

                        warranty.StartDate = Date.today();
                        warranty.EndDate = Date.today().addMonths(pwt.WarrantyTerm.WarrantyDuration);

                        warranty.WarrantyType = pwt.WarrantyTerm.WarrantyType;
                        warranty.ExchangeType = pwt.WarrantyTerm.ExchangeType;

                        warranty.Exclusions = pwt.WarrantyTerm.Exclusions;
                        warranty.IsTransferable = pwt.WarrantyTerm.IsTransferable;

                        warranty.LaborCovered = pwt.WarrantyTerm.LaborCovered;
                        warranty.PartsCovered = pwt.WarrantyTerm.PartsCovered;
                        warranty.ExpensesCovered = pwt.WarrantyTerm.ExpensesCovered;

                        warrantiesToInsert.add(warranty);
                    }
                }

                // If 'Extended Warranty' Product is present, create an extra AssetWarranty for every Asset
                if (isExtendedWarrantyProductPresent) {
                    for (WarrantyTerm extendedTerm : extendedWarrantyTerms) {
                        AssetWarranty extendedWarranty = new AssetWarranty();
                        extendedWarranty.AssetId = asset.Id;
                        extendedWarranty.WarrantyTermId = extendedTerm.Id;

                        extendedWarranty.StartDate = Date.today();
                        extendedWarranty.EndDate = Date.today().addMonths(extendedTerm.WarrantyDuration);

                        extendedWarranty.WarrantyType = extendedTerm.WarrantyType;
                        extendedWarranty.ExchangeType = extendedTerm.ExchangeType;

                        extendedWarranty.Exclusions = extendedTerm.Exclusions;
                        extendedWarranty.IsTransferable = extendedTerm.IsTransferable;

                        extendedWarranty.LaborCovered = extendedTerm.LaborCovered;
                        extendedWarranty.PartsCovered = extendedTerm.PartsCovered;
                        extendedWarranty.ExpensesCovered = extendedTerm.ExpensesCovered;

                        warrantiesToInsert.add(extendedWarranty);
                    }
                }
            }

            // Insert AssetWarranty records
            if (!warrantiesToInsert.isEmpty()) {
                try {
                    insert warrantiesToInsert;
                    System.debug('Successfully inserted AssetWarranty records.');
                } catch (DmlException dmlEx) {
                    System.debug('Error while inserting Asset Warranties: ' + dmlEx.getMessage());
                }
            } else {
                System.debug('No AssetWarranty records to insert.');
            }

        } catch (Exception ex) {
            System.debug('Error in handleAssetInsert: ' + ex.getMessage());
        }
    }
}