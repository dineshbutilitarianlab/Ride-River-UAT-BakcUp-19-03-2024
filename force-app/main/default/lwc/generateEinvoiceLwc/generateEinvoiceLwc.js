import { LightningElement,api,wire,track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import generateEInvoice from '@salesforce/apex/ClearTaxApiHelper.generateEInvoice';
import generatePayloadForIRN from '@salesforce/apex/ClearTaxApiHelper.generatePayloadForIRN';
import genereteE_invoicePDF from '@salesforce/apex/ClearTaxApiHelper.genereteE_invoicePDF';
import checkValidateDataforIRNGeneration from '@salesforce/apex/ClearTaxApiHelper.checkValidateDataforIRNGeneration';
import { updateRecord } from 'lightning/uiRecordApi';
import Successinvoice from '@salesforce/resourceUrl/Successinvoice';
const FIELDS = [
    'Order.IRN_No__c'
];

export default class GenerateEinvoiceLwc extends LightningElement {
    Successinvoice = Successinvoice;
     @api recordId;
    error;
    @track pdfUrl;
    @track payloadData;
    @track loading = true;
    @track isSubmitDisabled = false;
    @track orderdata;

    connectedCallback() {
        debugger;
        const url = window.location.href.toString();
            const queryParams = url.split("&");
            const recordIdParam = queryParams.find(param => param.includes("recordId"));
            if (recordIdParam) {
                const recordIdKeyValue = recordIdParam.split("=");
                if (recordIdKeyValue.length === 2) {
                    const recordId = recordIdKeyValue[1];
                    this.recordId = recordId;
                } else {
                    console.error("Invalid recordId parameter format");
                }
            } else {
                console.error("recordId parameter not found in the URL");
            }
        this.validatePayloadData(); 
    }

    handleCancel() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    validatePayloadData(){
        debugger;
        this.checkMandatoryFields();
    }

    callApexMethod(){
        debugger;
        generateEInvoice({recordId : this.recordId}) .then(result =>{
            if(result != null && result == 'SUCCESS'){
             updateRecord({ fields: { Id: this.recordId }})
             setTimeout(() => {
                this.handleSave();
             }, 300);
            }else{
                this.showToast('ERROR', result, 'error');
            }
        })
        .catch(error =>{
            console.log('Error == >'+this.error);
        })
    }

    handleSave(){
        debugger;
        this.isSubmitDisabled = true;
        updateRecord({ fields: { Id: this.recordId }})
        genereteE_invoicePDF({recordId : this.recordId}) .then(result =>{
            if(result && result == 'success'){
                this.loading = false;
                updateRecord({ fields: { Id: this.recordId }})
                this.showToast('Success', 'Invoice generated successfully', 'success');
            }else{
                this.showToast('Error', result, 'error');
            }
        })
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, 
            mode: 'dismissable'
        });
        setTimeout(() => {
            this.dispatchEvent(event);
            this.handleCancel();
        }, 2000);
    }

    checkMandatoryFields(){
        debugger;
        checkValidateDataforIRNGeneration({recordId : this.recordId}) .then(result =>{
            if(result != null && result == 'success'){
                this.callApexMethod();
            }else{
                this.showToast('ERROR', result, 'error');
            }
        })
    }
    
}