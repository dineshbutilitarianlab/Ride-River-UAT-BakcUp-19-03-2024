import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAdditionalJobs from '@salesforce/apex/AdditionalJobsRecommendedController.getAdditionalJobs';
import getDynamicValues from '@salesforce/apex/AdditionalJobsRecommendedController.getDynamicValues';
import submitAndSendEmail from '@salesforce/apex/AdditionalJobsRecommendedController.submitAndSendEmail';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from "lightning/uiRecordApi";
import Status from "@salesforce/schema/WorkOrder.Status";

export default class BulkInsertAdditionalJobs extends NavigationMixin(LightningElement) {

    @api recordId;
    keyIndex = 0;
    showProducts = true;
    showSubmitButton = true;
    showAddMoreButton = false;
    refreshResultData;
    @track existingAdditionalJobs = [];
    @track itemList = [
        {
            id: 0,
            price: 0,
            productCode: ''
        }
    ];

    @track showAll;
    @track showRow = false;
    @track emailSent = false;
    @track isSubmitting = false; // Flag to track if submission is in progress
    @track submittedForms = 0;
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Status],
    })
    wiredWorkOrder({ error, data }) {
        if (data && data.fields.Status.value == 'Completed') {
            this.showAll = false;
        } else if (data) {
            this.showAll = true;
        }
    }
    
    toggleTemplates() {
        this.showAll = !this.showAll;
        this.showRow = !this.showRow;
    }
    
    // Columns definition for Lightning Datatable
    columns = [
        {
            label: 'Additional Job No',
            fieldName: 'jobUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'Name' }, 
            target: '_blank'},
            sortable: true
        },
        {
            label: 'Part',
            fieldName: 'productUrl',
            type: 'url',
            typeAttributes: {label: { fieldName: 'RR_Product__c' }, 
            target: '_blank'},
            sortable: true
        },
       // { label: 'Part', fieldName: 'RR_Product__c', type: 'text' },
        { label: 'Quantity', fieldName: 'RR_Quantity__c', type: 'Number' },
        { label: 'Labour Code', fieldName: 'RR_Labour_Code__c', type: 'text' },
        { label: 'Description', fieldName: 'RR_Description__c', type: 'text' }
    ];

    @wire(getAdditionalJobs, { workOrderId: '$recordId' })
    wiredWorkPlans(result) {
        this.refreshResultData = result;
        if (result.data) {
            console.log('data received>>', result.data);

            

            this.existingAdditionalJobs = result.data.map(Ajob => {

                const jobUrl = Ajob.Id ? `/${Ajob.Id}`:''; 
                const productUrl = Ajob.RR_Product__c ? `/${Ajob.RR_Product__c}` : '';

                return{
                    RR_Work_Order__c: Ajob.RR_Work_Order__r.WorkOrderNumber,
                    Name: Ajob.Name,
                    RR_Product__c: Ajob.RR_Product__r ? Ajob.RR_Product__r.Name : '', 
                    RR_Quantity__c: Ajob.RR_Quantity__c,
                    RR_Description__c: Ajob.RR_Description__c,
                    RR_Labour_Code__c: Ajob.RR_Labour_Code__r ? Ajob.RR_Labour_Code__r.Code : '',
                    jobUrl:jobUrl,
                    productUrl:productUrl
                }
            });
            
        } else if (result.error) {
            console.error('Error fetching Additional Jobs:', result.error);
        }
    }

    // renderedCallback() {
    //     console.log('----------in renderCallBackMethod');
    // }

    // connectedCallback() {
    //     // Refresh data every second
    //     this.refreshInterval = setInterval(() => {
    //         refreshApex(this.refreshResultData);
    //     }, 1000);
    // }

    // disconnectedCallback() {
    //     // Clear the interval when the component is disconnected
    //     clearInterval(this.refreshInterval);
    // }

    addRow(event, index) {
        index = parseInt(event.target.dataset.id,10);
        console.log('indes os>>s',JSON.stringify(event.target));

        ++this.keyIndex;
        let newItem = { id: this.keyIndex, code: '' };
        this.itemList.splice(index + 1, 0, newItem);
        console.log('Row added at index:', index + 1);
    }

    removeRow(event) {
        let index = parseInt(event.target.id,10);
        if (this.itemList.length > 1) {
            this.itemList.splice(index, 1);
        } else {
            console.log('Cannot delete the last row.');
        }
    }

    async handleSubmit() {
        console.log('clisked..');
        if (this.emailSent || this.isSubmitting) {
            return;
        }
        this.isSubmitting = true;
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });

        this.itemList.map((item, idx) => {
            if (item.hasError) {
                isVal = false;
                console.log('there are some error in products you have added');
            }
        });

        if (isVal) {
            const forms = Array.from(this.template.querySelectorAll('lightning-record-edit-form'));
            this.submittedForms = 0; // Reset submitted forms counter
            try {
                await Promise.all(forms.map(form => form.submit()));
                
            } catch (error) {
                console.error('Error while submitting forms:', error);
                this.showToast(false, 'Error while adding the Additional Jobs!');
            } finally {
                this.isSubmitting = false;
            }
        } else {
            this.isSubmitting = false;
            this.showToast(false, 'Error while adding the Additional Jobs!');
        }
    }

    async sendEmail() {
        console.log('success method is called');
        // Increment the counter for submitted forms
        this.submittedForms++;
        // Check if all forms have been submitted
        if (this.submittedForms === this.itemList.length) {
            try {
                const response = await submitAndSendEmail({ jobId: this.recordId });
                console.log('Email response:', response);
                // Handle success or failure of sending email
                if (response === 'Email sent successfully') {
                    this.emailSent = true;
                    this.showToast(true, 'Additional Jobs added successfully and mail sent!');
                } else {
                    this.showToast(false, 'Error while sending email: ' + response);
                }
            } catch (error) {
                console.error('Error sending email:', error);
                this.showToast(false, 'Error while sending email: ' + error.message);
                this.emailSent = false;
            }
        }
    }

    handleSuccess(event) {
        this.showAll = true;
        this.showRow = false;
        this.clearRows();
        this.showToast(true, 'Additional Jobs added successfully.');
        refreshApex(this.refreshResultData);
        this.sendEmail();
    }
    
    handleError(event) {
        let errorMsg = '';
    
        if (event.detail && event.detail.output && event.detail.output.fieldErrors &&event.detail.output.fieldErrors.length > 0) {
            
            // Check for field-specific errors
            let fieldErrors = event.detail.output.fieldErrors;
            for (let fieldName in fieldErrors) {
                if (fieldErrors.hasOwnProperty(fieldName)) {
                    const fieldError = fieldErrors[fieldName];
                    if (fieldError && fieldError.length > 0) {
                        errorMsg = 'Error: ' + fieldError[0].message;
                        break; // Exit loop after finding the first field error
                    }
                }
            }
        }else if (event.detail && event.detail.output && event.detail.output.errors && event.detail.output.errors.length > 0) {
            console.log('inside 2');
            // Check for field-specific errors
            let fieldErrors = event.detail.output.errors;
            for (let fieldName in fieldErrors) {
                if (fieldErrors.hasOwnProperty(fieldName)) {
                    const fieldError = fieldErrors[fieldName];
                    if (fieldError && fieldError.length > 0) {
                        errorMsg = 'Error: ' + fieldError[0].message;
                        break; // Exit loop after finding the first field error
                    }else if(fieldError.message){
                        errorMsg = 'Error: ' + fieldError.message;
                        break; 
                    }
                }
            }
        }
         else if (event.detail && event.detail.detail) {
            errorMsg = 'Error: ' + event.detail.detail;
        }else if (event.detail && event.detail.message) {
            errorMsg = 'Error: ' + event.detail.message;
        }
         else if (event.detail && event.detail.output && event.detail.output.errors) {
            // Check for Apex errors
            const apexErrors = event.detail.output.errors;
            if (apexErrors && apexErrors.length > 0) {
                errorMsg = 'Apex Error: ' + apexErrors[0].message;
            }
        } else {
            // Default generic error message
            errorMsg = 'An unknown error occurred. Please try again.';
        }
    
        // Display the error message in a single toast
        this.showToast(false, errorMsg);
    }
    

    handleAddMore() {
        this.clearRows(); // Clear rows when Add More is clicked
        this.showSubmitButton = true;
        this.showAddMoreButton = false;
        this.showRow = true;
    }

    clearRows() {
        this.itemList = [];
        this.keyIndex = 0;
        let newItem = { id: this.keyIndex, price: 0, productCode: '' };
        this.itemList = [...this.itemList, newItem];
    }

    handleProductselection(event) {

        const index = event.target.dataset.id;
        const productId = event.target.value;

        if (!productId) {
            // If the input field is cleared, reset the corresponding values
            this.itemList = this.itemList.map((item, idx) => {
                if (idx == index) {
                    return { ...item, price: '', productCode: '', errorMessage:'', hasError:false };
                }
                return item;
            });
        } else {
            getDynamicValues({ productId: productId })
                .then(result => {
                    if (result && result.price && result.productCode) {
                        
                        this.itemList = this.itemList.map((item, idx) => {
                            if (idx == index) {
                                return { ...item, price: result.price, productCode: result.productCode, errorMessage:'', hasError:false};
                            }
                            return item;
                        });
                    }
                })
                .catch(error => {
                    // Set the error message in the product field
                    this.itemList = this.itemList.map((item, idx) => {
                        if (idx == index) {
                            return { ...item, errorMessage: error.body.message, hasError:true };
                        }
                        return item;
                    });
                    
                });
        }
    }


    showToast(isSuccess, message) {
        console.log('errormessage >>'+message);
        let event;
        if (isSuccess) {
            event = new ShowToastEvent({
                title: 'Success',
                message: message || 'Additional Jobs Recommended added successfully!',
                variant: 'success',
            });
        } else {
            event = new ShowToastEvent({
                title: 'Error',
                message: message || 'Error while adding the Additional Job Recommended!',
                variant: 'error',
            });
        }
        this.dispatchEvent(event);
    }
}