import { refreshApex } from '@salesforce/apex';
import createBatchAndTagClaims from '@salesforce/apex/BatchRecordController.createBatchAndTagClaims';
import fetchClaims from '@salesforce/apex/BatchRecordController.fetchClaims';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track, wire } from 'lwc';

export default class BatchList extends LightningElement {
    @track batches = [];
    @track error;
    @track showCreateForm = false;
    @track showClaimModal = false;
    @track claims = [];
    @track selectedClaims = [];
    @track batchAmount = 0;
    @track batchDispatchDate = '';
    @track lrNumber = '';
    @track lrAttachment = '';
    @track today = new Date().toISOString().split('T')[0];
    wiredBatchesResult;
    wiredClaimsResult;

    @track preSelectedRowIds = [];

    // Columns for Batch DataTable
    columns = [
        { label: 'Batch Amount', fieldName: 'Batch_Amount__c' },
        { label: 'Created Date', fieldName: 'Batch_Created_Date__c' },
        { label: 'Dispatch Date', fieldName: 'Batch_Dispatch_Date__c' },
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'LR Number', fieldName: 'LR_Number__c' },
    ];

    
    claimsColumns = [
        { label: 'Claim Name', fieldName: 'Name' },
        { label: 'Total Claims Amount', fieldName: 'Total_Claim_Amount__c', type: 'currency' },

    ];

    
    selectedClaimsColumns = [
        { label: 'Claim Name', fieldName: 'Name' },
        { label: 'Total Claims Amount', fieldName: 'Total_Claim_Amount__c', type: 'currency' },
        {
            type: 'button',
            typeAttributes: {
                label: 'Remove',
                name: 'remove',
                variant: 'destructive',
            },
        },
    ];


    @wire(fetchClaims)
    wiredClaims(result) {
        debugger;
        this.wiredClaimsResult = result;
        if (result.data) {
            this.claims = result.data;
        } else if (result.error) {
            this.showToast('Error', `Error fetching claims: ${result.error.body.message}`, 'error');
            console.error('Error fetching claims:', result.error);
        }
    }


    
    // @wire(getBatchStatus)
    // wiredBatches(result) {
    //     this.wiredBatchesResult = result;
    //     if (result.data) {
    //         this.batches = result.data;
    //     } else if (result.error) {
    //         this.error = result.error;
    //     }
    // }

   
    handleCreateRecord() {
        this.showCreateForm = true;
    }


    handleAddWarrantyClaim() {
        console.log('Add Warranty Claim button clicked');        
        debugger;
        this.preSelectedRowIds = this.selectedClaims.map(claim => claim.Id);
        console.log(JSON.stringify(this.preSelectedRowIds));
        console.log(JSON.stringify(this.claim));
        this.showClaimModal = true;
    }

    
    closeModal() {
        this.showCreateForm = true;
        this.showClaimModal = false;
    }

    handleRowSelection(event) {
        debugger;
        this.selectedClaims = event.detail.selectedRows;
        this.calculateBatchAmount();
        this.preSelectedRowIds = selectedRows.map(row => row.Id);
    }

    handleRowAction(event) {
        debugger;
        const { action, row } = event.detail;
        if (action.name === 'remove') {
            this.selectedClaims = this.selectedClaims.filter(
                (claim) => claim.Id !== row.Id
            );
            this.calculateBatchAmount();
        }
    }

    
    calculateBatchAmount() {
        this.batchAmount = this.selectedClaims.reduce(
            (total, claim) => total + (claim.Total_Claim_Amount__c || 0), 0
        );
    }

    // Handle Dispatch Date Change
    handleDispatchDateChange(event) {
        this.batchDispatchDate = event.target.value;
    }

    // Handle LR Number Change
    handleLRNumberChange(event) {
        this.lrNumber = event.target.value;
    }


    // Handle LR Attachment Change
    handleLRAttachmentChange(event) {
        this.lrAttachment = event.target.value;
    }

    // Submit Batch and Associate Claims
    async handleSubmit() {
        if (!this.selectedClaims.length) {
            this.showToast('Error', 'Please select at least one claim.', 'error');
            return;
        }
        if (!this.batchDispatchDate || !this.lrNumber) {
            this.showToast('Error', 'All required fields must be filled.', 'error');
            return;
        }

        try {
            const claimIds = this.selectedClaims.map((claim) => claim.Id);
            await createBatchAndTagClaims({
                claimIds,
                batchDispatchDate: this.batchDispatchDate,
                lrNumber: this.lrNumber,
                lrAttachment: this.lrAttachment,
            });

            this.showToast('Success', 'Batch created successfully.', 'success');
            this.resetForm();
            await refreshApex(this.wiredBatchesResult);
            await refreshApex(this.wiredClaimsResult);
        } catch (error) {
            this.showToast('Error', `Error creating batch: ${error.body.message}`, 'error');
        }
    }

    // Reset Form
    resetForm() {
        this.batchAmount = 0;
        this.batchDispatchDate = '';
        this.lrNumber = '';
        this.lrAttachment = '';
        this.selectedClaims = [];
        this.showCreateForm = false;
        this.showClaimModal = false;
        this.preSelectedRowIds = [];
    }

    // Show Toast Notification
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}