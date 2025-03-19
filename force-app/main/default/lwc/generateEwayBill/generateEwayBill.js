import { LightningElement, track, api } from 'lwc';
import generateEWayBillUsingIRN from '@salesforce/apex/ClearTaxApiHelper.generateEWayBillUsingIRN';
import { updateRecord } from 'lightning/uiRecordApi';
export default class GenerateEwayBill extends LightningElement {
    @api recordId = '';
    @track ewaybill = null;
    @track errorMessage = '';
    @track isProcessing = false;
    @track hideScrren = true;

    connectedCallback() {
        if (!this.recordId) {
            setTimeout(() => {
                this.recordId = this.recordId;
            }, 3000);
        }
    }

    async generateEWayBill() {
        debugger;
        this.isProcessing = true;
        this.ewaybill = null;
        this.errorMessage = '';
        try {
            const response = await generateEWayBillUsingIRN({ shipId: this.recordId });
            if (response && response.status === 'Success') {
                updateRecord({ fields: { Id: this.recordId }})
                this.ewaybill = response.EwbNo || 'E-Way Bill Not Found';
                this.hideScrren = false;
            } else {
                this.errorMessage = response.message || 'Failed to generate E-Way Bill!';
            }
        } catch (error) {
            this.errorMessage = 'Error: ' + (error.body ? error.body.message : error.message);
        } finally {
            this.isProcessing = false; 
        }
    }
}