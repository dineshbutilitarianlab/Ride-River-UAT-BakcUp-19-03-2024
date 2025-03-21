import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from "lightning/uiRecordApi";
import Status from "@salesforce/schema/WorkOrder.Status";
import JobType from "@salesforce/schema/WorkOrder.RR_Job_Type__c";
import getVoices from '@salesforce/apex/bulkInsert_CustomerVoiceController.getVoices';

const columns = [
    {
        label: 'Customer Voice No',
        fieldName: 'voiceUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
    },
    { label: 'Concern Category', fieldName: 'RR_Concern_Category__c', sortable: true },
    { label: 'Sub Category', fieldName: 'RR_Sub_Category__c', sortable: true },
    { label: 'Observation Action Taken', fieldName: 'RR_Observation_Action_Taken__c', sortable: true }
];

export default class BulkInsertCustomerVoices extends LightningElement {
    @api recordId;
    @track voiceRecords;
    @track initialvoiceRecords;
    @track error;
    showAddForm = false;
    showBtn = true;
    wiredVoicesResult;
    columns = columns;

    @wire(getRecord, { 
        recordId: "$recordId", 
        fields: [Status, JobType] 
    })
    wiredWorkOrder({ error, data }) {
        if (data) {
            const workOrderStatus = data.fields.Status.value;
            const jobType = data.fields.RR_Job_Type__c.value;
    
            // Show Add Button only if Status is not 'Completed' and Job Type is not 'VAS Purchase'
            if (workOrderStatus !== 'Completed' && jobType !== 'VAS Purchase') {
                this.showBtn = true;
            } else {
                this.showBtn = false;
            }
        } else if (error) {
            console.error("Error fetching Work Order details:", error);
        }
    }

    @wire(getVoices, { jcId: '$recordId' })
    wiredVoices(result) {
        this.wiredVoicesResult = result;
        if (result.data) {
            this.initialvoiceRecords = result.data.map(voice => ({
                ...voice,
                voiceUrl: `/${voice.Id}`
            }));
            this.voiceRecords = this.initialvoiceRecords;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.voiceRecords = undefined;
        }
    }

    refreshData() {
        refreshApex(this.wiredVoicesResult)
            .then(() => {
                this.showAddForm = false;
                this.voiceRecords = this.initialvoiceRecords;
            })
            .catch(error => {
                console.error('Error refreshing data:', error);
            });
    }

    toggleAdd() {
        this.showBtn = false;
        this.showAddForm = true;
        this.template.querySelector('.slide-in-box').classList.add('slide-in');
    }

    cancel() {
        const formBox = this.template.querySelector('.slide-in-box');
        formBox.classList.add('slide-out');

        setTimeout(() => {
            this.showBtn = true;
            this.showAddForm = false;
            formBox.classList.remove('slide-out');
        }, 500);
    }

    handleSubmit() {
        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            form.submit();
        }
    }

    handleSuccess() {
        this.showToast(true, 'Customer Voice added successfully!');
        this.refreshData();

        const formBox = this.template.querySelector('.slide-in-box');
        formBox.classList.add('slide-out');

        setTimeout(() => {
            this.showBtn = true;
            this.showAddForm = false;
            formBox.classList.remove('slide-out');
        }, 500);
    }

    handleError(event) {
        let errorMsg = 'An unknown error occurred. Please try again.';
        if (event.detail && event.detail.detail) {
            errorMsg = 'Error: ' + event.detail.detail;
        }
        this.showToast(false, errorMsg);
    }

    showToast(success, message) {
        this.dispatchEvent(new ShowToastEvent({
            title: success ? 'Success' : 'Error',
            message: message,
            variant: success ? 'success' : 'error',
        }));
    }

    // Enable Sub Category when Concern Category is selected
    handleConcernCategoryChange(event) {
        const subCategoryField = this.template.querySelector('[data-id="subCategoryField"]');
        if (subCategoryField) {
            subCategoryField.disabled = false;
        }
    }
}