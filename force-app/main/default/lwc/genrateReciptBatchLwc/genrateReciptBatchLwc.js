import { LightningElement,api,wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import saveGenerateReciptAsPdf from '@salesforce/apex/BatchRecordControllerPDF.saveGenerateReciptAsPdf';

export default class GenrateReciptBatchLwc extends NavigationMixin(LightningElement) {
        
        wireRecordId;
        currectRecordId;
        loading = true;
    
        @wire(CurrentPageReference)
        getStateParameters(currentPageReference) {
            if (currentPageReference) {
                console.log('currentPageReference ', currentPageReference);
                this.wireRecordId = currentPageReference.state.recordId;
            }
        }
    
        @api set recordId(value) {
            this.currectRecordId = value;
            console.log('this.currectRecordId ',this.currectRecordId);
            this.generatePdfUrl();
        }
    
        get recordId() {
            return this.currectRecordId;
        }
    
        generatePdfUrl() {
            if (this.currectRecordId) {
                this.pdfUrl = `/apex/GenerateReciptBatchPDF?Id=${this.currectRecordId}`;
                console.log('Generated PDF URL: ', this.pdfUrl);
                this.loading = false;
            }
        }
    
        pdfUrl ='';
    
        handleSave() {
            this.loading = true; 
            saveGenerateReciptAsPdf({ batchId: this.currectRecordId ,bypassTestCheck : false})
                .then(result => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: result,
                        variant: 'success',
                    }));
                    this.handleCancel();
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }));
                })
                .finally(() => {
                    this.loading = false;  
                });
        }
    
        handleCancel() {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.currectRecordId,
                    actionName: 'view'
                }
            });
        }

}