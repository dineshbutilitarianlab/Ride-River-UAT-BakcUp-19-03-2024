import { LightningElement , api } from 'lwc';
import getProductCategoryList from '@salesforce/apex/GetRecordId.getProductCategory'
import getVehicleDefinitionList from '@salesforce/apex/GetRecordId.getVehicleDefinition'
import getLeadList from '@salesforce/apex/GetRecordId.getLead'
import getOpportunityList from '@salesforce/apex/GetRecordId.getOpportunity'
import getVehicleList from '@salesforce/apex/GetRecordId.getVehicle'
import getProductViewList from '@salesforce/apex/GetRecordId.getProductView'
import getProductList from '@salesforce/apex/GetRecordId.getProduct'
import getAAFPartnerList from '@salesforce/apex/GetRecordId.getAAFPartner'
import getSAViewList from '@salesforce/apex/GetRecordId.getSAview'
import getAccountist from '@salesforce/apex/GetRecordId.getAccounts'
import getMfgPrgist from '@salesforce/apex/GetRecordId.getManufacturingProgram'
import getWarrantyList from '@salesforce/apex/GetRecordId.getWarrantyTerm'
import getVisitList from '@salesforce/apex/GetRecordId.getVisit'
import getSAList from '@salesforce/apex/GetRecordId.getSalesAgreement'

export default class DeveloperHome extends LightningElement {
    @api app_welcome_text = "Welcome to Automotive Cloud Learning";
    @api app_description = "Learn How to Customize and Develop Automotive Cloud Features";
    @api no_product_category = false;
    @api no_vehicle_definition = false;
    @api no_lead = false;
    @api no_opportunity = false;
    @api no_vehicle = false;
    @api no_product_view = false;
    @api no_product = false;   
    @api no_aaf_partner = false;
    @api no_sa_view = false;
    @api no_account = false;
    @api no_mfg_prg = false;
    @api no_warranty = false;
    @api no_visit = false;
    @api no_sa = false;


    productCategoryId;
    vehicleDefinitionId;
    saViewId;
    leadId;
    opportunityId;
    vehicleId;
    productViewId;
    aafId;
    accountId;
    saViewId;
    mfgPrdId;
    warrantyId;
    visitId;
    saId;

    connectedCallback() {

        getProductCategoryList()
        .then(result => {
            console.log("ProductCategory from getProductCategory", result);
            if (result.length) {
                this.no_product_category = false;
                this.productCategoryId = result[0].Id;
            } else {
                this.no_product_category = true;
                this.productCategoryId = ""
            }
        })

        getVehicleDefinitionList()
        .then(result => {
            console.log("VehicleDefinition from getVehicleDefinition", result);
            if (result.length) {
                this.no_vehicle_definition = false;
                this.vehicleDefinitionId = result[0].Id;
            } else {
                this.no_vehicle_definition = true;
                this.vehicleDefinitionId = ""
            }
        })

        getLeadList()
        .then(result => {
            console.log("Lead from getLead", result);
            if (result.length) {
                this.no_lead = false;
                this.leadId = result[0].Id;
            } else {
                this.no_lead = true;
                this.leadId = ""
            }
        })        

        getOpportunityList()
        .then(result => {
            console.log("Opportunity from getOpportunity", result);
            if (result.length) {
                this.no_opportunity = false;
                this.opportunityId = result[0].Id;
            } else {
                this.no_opportunity = true;
                this.opportunityId = ""
            }
        })

        getVehicleList()
        .then(result => {
            console.log("Vehicle from getVehicle", result);
            if (result.length) {
                this.no_vehicle = false;
                this.vehicleId = result[0].Id;
            } else {
                this.no_vehicle = true;
                this.vehicleId = ""
            }
        })

        getProductViewList()
        .then(result => {
            console.log("ProductView from getProductView", result);
            if (result.length) {
                this.no_product_view = false;
                this.productViewId = result[0].Id;
            } else {
                this.no_product_view = true;
                this.productViewId = ""
            }
        })


        getSAViewList()
        .then(result => {
            console.log("SA from ListView", result);
            if (result.length) {
                this.no_sa_view = false;
                this.saViewId = result[0].Id;
            } else {
                this.no_sa_view = true;
                this.saViewId = ""
            }
        })


        getProductList()
        .then(result => {
            console.log("Product from getProduct", result);
            if (result.length) {
                this.no_product = false;
                this.productId = result[0].Id;
            } else {
                this.no_product = true;
                this.productId = ""
            }
        })


        getAAFPartnerList()
        .then(result => {
            console.log("AAF from getAAF", result);
            if (result.length) {
                this.no_aaf_partner = false;
                this.aafId = result[0].Id;
            } else {
                this.no_aaf_partner = true;
                this.aafId = ""
            }
        })

        getAccountist()
        .then(result => {
            console.log("Account from getAccount", result);
            if (result.length) {
                this.no_account = false;
                this.accountId = result[0].Id;
            } else {
                this.no_account = true;
                this.accountId = ""
            }
        })


        getMfgPrgist()
        .then(result => {
            console.log("MfgProgram from getManufacturingProgram", result);
            if (result.length) {
                this.no_mfg_prg = false;
                this.mfgPrdId = result[0].Id;
            } else {
                this.no_mfg_prg = true;
                this.mfgPrdId = ""
            }
        })

        getWarrantyList()
        .then(result => {
            console.log("Warranty from getWarrantyList", result);
            if (result.length) {
                this.no_warranty = false;
                this.warrantyId = result[0].Id;
            } else {
                this.no_warranty = true;
                this.warrantyId = ""
            }
        })

        getVisitList()
        .then(result => {
            console.log("Visit from getVisitList", result);
            if (result.length) {
                this.no_visit = false;
                this.visitId = result[0].Id;
            } else {
                this.no_visit = true;
                this.visitId = ""
            }
        })

        getSAList()
        .then(result => {
            console.log("SA from getSAList", result);
            if (result.length) {
                this.no_sa = false;
                this.saId = result[0].Id;
            } else {
                this.no_sa = true;
                this.saId = ""
            }
        })
    }
    
    



    
    get pass_false() {
        return false;
    }

    get pass_true() {
        return true;
    }
}