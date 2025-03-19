import { LightningElement ,api,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WarrantyTagPdfViewer extends NavigationMixin(LightningElement) {
wireRecordId; //this will hold the current record id fetched from pagereference
currectRecordId; //this will hold the current record id fetched from getter and setter
loading = true;

@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        console.log('currentPageReference ', currentPageReference);
        //it gets executed before the connected callback and avilable to use
        this.wireRecordId = currentPageReference.state.recordId;
    }
}

@api set recordId(value) {
    this.currectRecordId = value;
    console.log('this.currectRecordId ',this.currectRecordId);

    //onload action here where you need current recordid
    //this gets executed post connected callback
    this.generatePdfUrl();  // Generate the PDF URL whenever recordId is updated
}

get recordId() {
    return this.currectRecordId;
}

// Method to construct the PDF URL based on the currectRecordId
generatePdfUrl() {
    if (this.currectRecordId) {
        this.pdfUrl = `/apex/WarrantyTagPDF?Id=${this.currectRecordId}`;
        console.log('Generated PDF URL: ', this.pdfUrl);
        this.loading = false;
    }
}

pdfUrl;  // URL for the Visualforce page

handleSave() {
    this.loading = true;  // Show spinner while saving
    saveInvoiceAsPDF({ invoiceId: this.currectRecordId })
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
            this.loading = false;  // Hide spinner after save completes
        });
}

// Handle Cancel action
handleCancel() {
    // For redirecting, use the NavigationMixin
    // Example: redirect to the record page
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: this.currectRecordId,
            actionName: 'view'
        }
    });
}

}