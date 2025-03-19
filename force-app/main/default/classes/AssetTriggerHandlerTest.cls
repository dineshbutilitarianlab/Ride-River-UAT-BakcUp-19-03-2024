@isTest
public with sharing class AssetTriggerHandlerTest {
    @isTest
    static void testAssetTriggerHandler() {
         
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        
        Product2 standardProduct = new Product2(Name = 'Standard Product', IsActive = true, ProductCode = 'abcd', HSN_Code__c = 'abcd', Type__c = 'Vehicle');
        Product2 extendedWarrantyProduct = new Product2(Name = 'Extended Warranty', IsActive = true, ProductCode = 'abcd', HSN_Code__c = 'abcd', Type__c = 'Vehicle');
        insert new List<Product2> { standardProduct, extendedWarrantyProduct };

        WarrantyTerm standardWarrantyTerm = new WarrantyTerm(
            WarrantyTermName = 'Standard Product',
            WarrantyDuration = 12,
            WarrantyType = 'Standard',
            ExchangeType = 'Replacement',
            IsTransferable = true,
            EffectiveStartDate = 'Manufacture Date',
            WarrantyUnitOfTime = 'Weeks',
            LaborCovered = 12,
            LaborCoveredDuration=4,
            LaborCoveredUnitOfTime='Weeks',
            PartsCovered = 12,
            PartsCoveredDuration=4,
            PartsCoveredUnitOfTime='Weeks',
            ExpensesCovered = 12,
            ExpensesCoveredDuration=4,
            ExpensesCoveredUnitOfTime='Weeks',
            isExtended__c = false
        );

        WarrantyTerm extendedWarrantyTerm = new WarrantyTerm(
            WarrantyTermName = 'Extended Warranty',
            WarrantyDuration = 12,
            WarrantyType = 'Extended Warranty',
            ExchangeType = 'Repair',
            IsTransferable = true,
            EffectiveStartDate = 'Manufacture Date',
            WarrantyUnitOfTime = 'Weeks',
            LaborCovered = 12,
            LaborCoveredDuration=4,
            LaborCoveredUnitOfTime='Weeks',
            PartsCovered = 12,
            PartsCoveredDuration=4,
            PartsCoveredUnitOfTime='Weeks',
            ExpensesCovered = 12,
            ExpensesCoveredDuration=4,
            ExpensesCoveredUnitOfTime='Weeks',
            
            isExtended__c = true 
        );

        insert new List<WarrantyTerm> { standardWarrantyTerm, extendedWarrantyTerm };

        insert new List<ProductWarrantyTerm> {
            new ProductWarrantyTerm(CoveredProductId = standardProduct.Id, WarrantyTermId = standardWarrantyTerm.Id),
            new ProductWarrantyTerm(CoveredProductId = extendedWarrantyProduct.Id, WarrantyTermId = extendedWarrantyTerm.Id)
        };

        
        Asset standardAsset = new Asset(
            Name = 'Standard Asset',
            AccountId = testAccount.Id,
            Product2Id = standardProduct.Id,
            Status = 'Purchased',
            Quantity = 1
        );

        Asset extendedWarrantyAsset = new Asset(
            Name = 'Extended Warranty Asset',
            AccountId = testAccount.Id,
            Product2Id = extendedWarrantyProduct.Id,
            Status = 'Purchased',
            Quantity = 1
        );

        

        
        Test.startTest();
        insert new List<Asset> { standardAsset, extendedWarrantyAsset };
        //update new List<Asset> { standardAsset, extendedWarrantyAsset };
        Test.stopTest();


          }
}