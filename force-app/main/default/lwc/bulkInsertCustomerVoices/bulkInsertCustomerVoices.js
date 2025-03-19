import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CloseActionScreenEvent} from 'lightning/actions';
import {RefreshEvent} from 'lightning/refresh';
import getVoices from '@salesforce/apex/bulkInsert_CustomerVoiceController.getVoices';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from "lightning/uiRecordApi";
import Status from "@salesforce/schema/WorkOrder.Status";

 const columns = [
    {
        label: 'Customer Voice No',
        fieldName: 'voiceUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    {
        label: 'Concern Category',
        fieldName: 'RR_Concern_Category__c',
        sortable: true
    },
    {
        label: 'Sub Category',
        fieldName: 'RR_Sub_Category__c',
        sortable: true
    },
    {
        label: 'Observation Action Taken',
        fieldName: 'RR_Observation_Action_Taken__c',
        sortable: true
    }
];

export default class bulkInsertCustomerVoices extends LightningElement {

    @api recordId;
    @track voiceRecords;
    @track initialvoiceRecords;
    @track error;
    showEditForm = false;
    showtable = true;
    wiredVoicesResult;
    columns = columns;
    @track showBtn;
    draftValues = [];

    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Status],
    })
    wiredWorkOrder({ error, data }) {
        if (data && data.fields.Status.value == 'Completed') {
            this.showBtn = false;
        }
        else if(data){
            this.showBtn = true;
        } 
    }

    @wire(getVoices, { jcId: '$recordId' })
    wiredVoices(result) {
        this.wiredVoicesResult = result;
        if (result.data) {

            this.initialvoiceRecords = result.data.map(voice => {
                const nameUrl = `/${voice.Id}`; 
                
                return {
                    ...voice,
                    voiceUrl: nameUrl
                };
            });

            this.voiceRecords = this.initialvoiceRecords;
            console.log('the data is fetched>>',JSON.stringify(this.initialvoiceRecords));

            this.error = undefined; // Reset error if there was any
        } else if (result.error) {
            this.error = result.error;
            this.voiceRecords = undefined; // Reset data in case of error
        }
    }



      handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.initialvoiceRecords];
    
        cloneData.sort((a, b) => {
            let aVal = a[sortedBy] ? a[sortedBy].toLowerCase() : '';
            let bVal = b[sortedBy] ? b[sortedBy].toLowerCase() : '';
            return aVal > bVal ? 1 : -1;
        });
    
        this.initialvoiceRecords = sortDirection === 'asc' ? cloneData : cloneData.reverse();
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
    }


    refreshData() { 
        refreshApex(this.wiredVoicesResult)
            .then(result => {
                console.log('The voices refreshed are>>',JSON.stringify(this.wiredVoicesResult));
                
                //this.initialvoiceRecords = this.wiredVoicesResult.data;
                this.initialvoiceRecords = this.wiredVoicesResult.data.map(voice => {
                    const nameUrl = `/${voice.Id}`; 
                    
                    return {
                        ...voice,
                        voiceUrl: nameUrl
                    };
                });

                console.log('The voices refreshed are1>>',JSON.stringify(this.initialvoiceRecords));

                this.showtable = true;
                this.voiceRecords = this.initialvoiceRecords;
            })
            .catch(error => {
                // Handle any errors that occur during the refresh
                console.error('Error refreshing data:', error.message);
            });
    }       

    cancel(event){
        this.showBtn = true;
        this.showEditForm = false;
        this.showtable = true;
        this.voiceRecords = this.initialvoiceRecords;
    }

    toggleEdit(){
        this.showBtn = false;
        this.showtable = false;
        this.showEditForm = true;

    }

    handleSubmit(event) {
        //this.initialvoiceRecords = this.voiceRecords;
        event.stopPropagation();
        event.preventDefault();

        console.log('button clicked');
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal &&   element.reportValidity();
        });
        if (isVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
            });

            
            
        } else {
            this.showToast(false, 'Please check the validations');
        }
    }

    handleSuccess(){
        this.showToast(true, 'Customer Voices are updated successfully!');
        this.showEditForm = false;
        this.showBtn = true;
        this.refreshData();
        //setTimeout(this.refreshData(), 400);
    }

    handleError(event) {
        let errorMsg = '';
    
        console.log('Error:1', JSON.stringify(event.detail));
    
        if (event.detail && event.detail.output && event.detail.output.fieldErrors &&event.detail.output.fieldErrors.length > 0) {
            console.log('inside 1');
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
                console.log(' error loccured1>>'+ JSON.stringify(fieldErrors[fieldName]));
                if (fieldErrors.hasOwnProperty(fieldName)) {
                    console.log(' error loccured2>>'+ JSON.stringify(fieldErrors[fieldName]));
                    const fieldError = fieldErrors[fieldName];
                    if (fieldError && fieldError.length > 0) {
                        console.log(' error loccured3>>'+ JSON.stringify(fieldErrors[fieldName]));
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
            console.log('inside 3');
            errorMsg = 'Error: ' + event.detail.detail;
        }else if (event.detail && event.detail.message) {
            console.log('inside 4');
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

    showToast(success, message) {
        const event = new ShowToastEvent({
            title: success ? 'Success' : 'Error',
            message: message,
            variant: success ? 'success' : 'error',
        });
        this.dispatchEvent(event);
    }

    // showToast(isSuccess, message) {
    //     let event;
    //     if(isSuccess) {
    //         event = new ShowToastEvent({
    //             title: 'Success',
    //             message: 'Customer Voices are updated successfully!',
    //             variant: 'success',
    //         });
    //     } else {
    //         event = new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Error while updating Customer Voices!',
    //             variant: 'error',
    //         });
    //     }
    //     this.dispatchEvent(event);
    // }

    navigateToRecord(recordid) {
        this.dispatchEvent(new RefreshEvent());
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordid,
                objectApiName: 'WorkOrder',
                actionName: 'view'
            },
        });
    }


    handleCellChange(event) {

        const recordId = event.target.name;
        const newValue = event.target.value;
        console.log('the change is>>',event.target.value);
        console.log('the change is>>',event.target.name);

        this.voiceRecords = this.voiceRecords.map(item => {
            if (item.Id === recordId) {
                const newItem = { ...item, RR_Observation_Action_Taken__c: newValue };
                return newItem;
            }
            return item;
        });
       
        console.log('the updated records is>>',this.voiceRecords);
        
    }
}