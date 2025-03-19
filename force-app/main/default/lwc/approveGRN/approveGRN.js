import { LightningElement, api, track } from 'lwc';
import getClaimsAndItsLineItems from '@salesforce/apex/DiscrepancyController.getClaimsAndItsLineItems';
import getUserProfile from '@salesforce/apex/DiscrepancyController.getUserProfile';
 import updateClaimItemStatus from '@salesforce/apex/DiscrepancyController.updateClaimItemStatus';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ClaimApproval extends LightningElement {
    @api recordId;
    @track batchrecord = [];
    @track isLoading = true;
    @track SpareUser = false;
    @track Warehouse = false;
    @track flatClaimItems = [];
    @track onLoadSpare = true;


    connectedCallback() {
        debugger;
        this.recordId = new URL(window.location.href).searchParams.get("recordId");
        if (!this.recordId) {
            console.error("Record ID not found in URL");
            return;
        }
        this.loadData();
        this.getUserProfile();
    }

    loadData() {
        debugger;
        getClaimsAndItsLineItems({ recordId: this.recordId })
            .then(result => {
                this.batchrecord = result;
                this.flatClaimItems = this.flattenClaimItems(result).map(record => {
                    let onLoadSpare = true;
                    let onLoadReject = true;
                    let SpareOnApprove = false;
                    let SpareOnReject = false;
                    let showFeedback = false;
    
                    if (record.Status__c === 'Approved') {
                        onLoadSpare = false;
                        onLoadReject = false;
                        SpareOnApprove = true;
                        SpareOnReject = false;
                        showFeedback = false;
                    } else if (record.Status__c === 'Rejected') {
                        onLoadSpare = false;
                        onLoadReject = false;
                        SpareOnApprove = false;
                        SpareOnReject = true;
                        showFeedback = true;
                    }
    
                    return {
                        ...record,
                        onLoadSpare,
                        onLoadReject,
                        SpareOnApprove,
                        SpareOnReject,
                        showFeedback
                    };
                });
                this.isLoading = false;
            })
            .catch(error => {
                this.showToast('Error', error, 'error');
                this.isLoading = false;
            });
    }
    
    

    flattenClaimItems(batchrecord) {
        let flatList = [];
        batchrecord.forEach(record => {
            if (record.ClaimItems) {
                flatList = [...flatList, ...record.ClaimItems];
            }
        });
        return flatList;
    }

    getUserProfile() {
        debugger;
        getUserProfile()
            .then(result => {
                if (result === 'System Administrator' || result === 'Parts Manager') {
                    this.SpareUser = true;
                }
                if (result === 'Warehouse Profile') {
                    this.Warehouse = true;
                }
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    iconClicked(event) {
        debugger;
        const recordId = event.currentTarget.dataset.id;
        const clickedName = event.target.name;
        
        this.flatClaimItems = this.flatClaimItems.map(item => {
            if (item.Id === recordId) {
                return {
                    ...item,
                    onLoadSpare: clickedName === 'spareApprove' ? false : true,
                    SpareOnApprove: clickedName === 'spareApprove' ? true : false,
                    onLoadReject: clickedName === 'spareReject' ? false : true,
                    SpareOnReject: clickedName === 'spareReject' ? true : false,
                    showFeedback: clickedName === 'spareReject' ? true : false
                };
            }
            return item;
        });
        this.flatClaimItems = [...this.flatClaimItems];
    }

    handleFeedbackChange(event) {
        let itemId = event.target.dataset.id;
        let feedbackValue = event.target.value;

        this.flatClaimItems = this.flatClaimItems.map(item =>
            item.Id === itemId ? { ...item, feedback: feedbackValue } : item
        );
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSave() {
        debugger;
        let updates = {};
        let isValid = true;
    
        this.flatClaimItems.forEach(item => {
            if (item.SpareOnReject && (!item.feedback || item.feedback.trim() === '')) {
                this.showToast('Error', 'Feedback is required for rejected items', 'error');
                isValid = false;
            }
        });
    
        if (!isValid) return;
    
        this.flatClaimItems.forEach(item => {
            updates[item.Id] = {
                media: item,
                status: item.SpareOnApprove ? 'Approved' : item.SpareOnReject ? 'Rejected' : null,
                feedback: item.feedback || ''
            };
        });
    
      //  this.isLoading = true;
    
      updateClaimItemStatus({ mediaUpdates: updates })
            .then((result) => {
                if (result === 'Success') {
                    this.showToast('Success', 'Supporting Media updated successfully!', 'success');
                 //   this.isLoading = false;
                    this.dispatchEvent(new CloseActionScreenEvent());
                }
            })
            .catch(error => {
                this.showToast('Error', 'Failed to update media', 'error');
                console.error(error);
                //this.isLoading = false;
            });
    }
    

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}