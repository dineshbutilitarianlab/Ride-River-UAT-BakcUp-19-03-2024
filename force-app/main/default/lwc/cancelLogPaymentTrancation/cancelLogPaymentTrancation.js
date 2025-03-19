import { LightningElement, track,api } from 'lwc';
import cancelTransaction from '@salesforce/apex/PineLabsPaymentHelper.cancelTransaction';
export default class CancelLogPaymentTrancation extends LightningElement {
    @track isLoading = true; 
    @track isSuccess = false; 
    @track isError = false;
    @track errorMessage = '';
    @api recordId;

    connectedCallback() {
        debugger;
        setTimeout(() => {
            this.recordId = this.recordId;
        this.handleTransactionCancellation();
        }, 200);
    }

    handleTransactionCancellation() {
        debugger;
        cancelTransaction({recordId : this.recordId})
            .then((result) => {
                this.isLoading = false;
                if (result != null && result == 'SUCCESS') {
                    this.isSuccess = true;
                    setTimeout(() => {
                        this.closeScreen();
                    }, 2000);
                } else {
                    this.isError = true;
                    this.errorMessage = result || 'An unknown error occurred';
                }
            })
            .catch((error) => {
                this.isLoading = false;
                this.isError = true;
                this.errorMessage = error.body?.message || 'An error occurred while processing the transaction.';
            });
    }

    closeScreen() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }
}