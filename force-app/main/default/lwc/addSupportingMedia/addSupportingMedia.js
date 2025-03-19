import { LightningElement, api, track, wire } from 'lwc';
import getLineItems from '@salesforce/apex/DiscrepancyController.getLineItems';
import updateSupportingMedia from '@salesforce/apex/DiscrepancyController.updateSupportingMedia';
import getUserProfile from '@salesforce/apex/DiscrepancyController.getUserProfile';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from "lightning/uiRecordApi";

export default class AddSupportingMedia extends LightningElement {
    @api recordId;
    @track lineItems = [];
    @track mediaUpdates = {};
    isLoading = true;
    @track SpareUser = false;
    @track Warehouse = false;
    @track userProfile = '';



    wiredLineItems;

    connectedCallback() {
        debugger;
        this.refreshComponent();
        const storedProfile = sessionStorage.getItem('userProfile');

        if (storedProfile) {
            this.userProfile = storedProfile;
            this.setUserFlags(storedProfile);
        } else {
            getUserProfile()
                .then(result => {
                    this.userProfile = result;
                    sessionStorage.setItem('userProfile', result);
                    this.setUserFlags(result);
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to fetch user profile', 'error');
                    this.isLoading = false;
                });
        }
    }

    setUserFlags(profile) {
        this.SpareUser = (profile === 'System Administrator' || profile === 'Parts Manager');
        this.Warehouse = (profile === 'Warehouse Profile');
        this.isSalesManager = (profile === 'Sales Manager (Partner)');
    }

    refreshComponent() {
        this.isLoading = true;
        setTimeout(() => {
            this.isLoading = false;
        }, 3000);
    }

    @wire(getLineItems, { discrepancyId: '$recordId' })
    wiredLineItems(result) {
        const { data, error } = result;

        if (data) {
            this.lineItems = data.map(item => ({
                ...item,
                isChecked: false,
                isDisabled: true,


                onLoadSpare: this.SpareUser ? !item.Spare_Approval__c : false,
                onLoadReject: this.SpareUser ? !item.Spare_Approval__c : false,
                SpareOnApprove: this.SpareUser ? item.Spare_Approval__c === 'Approved' : false,
                SpareOnReject: this.SpareUser ? item.Spare_Approval__c === 'Rejected' : false,


                WarehouseOnApprove: this.Warehouse ? item.Warehouse_Approval__c === 'Approved' : false,
                WarehouseOnReject: this.Warehouse ? item.Warehouse_Approval__c === 'Rejected' : false,


                feedback: this.SpareUser ? item.Feedback_From_Spare__c || '' : (this.Warehouse ? item.Feedback_From_Warehosue__c || '' : ''),

                // 🔹 Sales Manager Uses the Same Spare & Warehouse Approvals
                SalesMgrSpareOnApprove: this.isSalesManager ? item.Spare_Approval__c === 'Approved' : false,
                SalesMgrSpareOnReject: this.isSalesManager ? item.Spare_Approval__c === 'Rejected' : false,

                SalesMgrWarehouseOnApprove: this.isSalesManager ? item.Warehouse_Approval__c === 'Approved' : false,
                SalesMgrWarehouseOnReject: this.isSalesManager ? item.Warehouse_Approval__c === 'Rejected' : false,

                // 🔹 Sales Manager Gets Separate Feedback Fields for Both
                SalesMgrSpareFeedback: this.isSalesManager ? item.Feedback_From_Spare__c || '' : '',
                SalesMgrWarehouseFeedback: this.isSalesManager ? item.Feedback_From_Warehosue__c || '' : '',

            }));
            this.isLoading = false;
        } else if (error) {
            this.showToast('Error', 'Failed to fetch line items', 'error');
            this.isLoading = false;
        }
    }


    handleInputChange(event) {
        const itemId = event.target.dataset.id;
        const value = event.target.value;

        this.mediaUpdates[itemId] = {
            ...this.mediaUpdates[itemId],
            media: value
        };
    }

    iconClicked(event) {
        debugger;
        const itemId = event.target.dataset.id;
        const clickedName = event.target.name;

        this.lineItems = this.lineItems.map(item => {
            if (item.Id === itemId) {
                let updatedItem = {
                    ...item,
                    onLoadSpare: this.SpareUser ? (clickedName === 'spareApprove' ? false : true) : item.onLoadSpare,
                    SpareOnApprove: this.SpareUser ? (clickedName === 'spareApprove' ? true : false) : item.SpareOnApprove,
                    SpareOnReject: this.SpareUser ? (clickedName === 'spareReject' ? true : false) : item.SpareOnReject,
                    showFeedback: this.SpareUser ? (clickedName === 'spareReject' ? true : false) : item.showFeedback,

                    onLoadReject: this.Warehouse ? (clickedName === 'warehouseReject' ? false : true) : item.onLoadReject,
                    WarehouseOnApprove: this.Warehouse ? (clickedName === 'warehouseApprove' ? true : false) : item.WarehouseOnApprove,
                    WarehouseOnReject: this.Warehouse ? (clickedName === 'warehouseReject' ? true : false) : item.WarehouseOnReject,
                    showFeedback: this.Warehouse ? (clickedName === 'warehouseReject' ? true : item.showFeedback) : item.showFeedback
                };

                this.mediaUpdates[itemId] = {
                    ...this.mediaUpdates[itemId],
                    status: updatedItem.SpareOnApprove || updatedItem.WarehouseOnApprove ? 'Approved' :
                        updatedItem.SpareOnReject || updatedItem.WarehouseOnReject ? 'Rejected' : null
                };

                return updatedItem;
            }
            return item;
        });
    }

    handleFeedbackChange(event) {
        const itemId = event.target.dataset.id;
        const feedbackValue = event.target.value;

        this.lineItems = this.lineItems.map(item =>
            item.Id === itemId ? { ...item, feedback: feedbackValue } : item
        );

        this.mediaUpdates[itemId] = {
            ...this.mediaUpdates[itemId],
            feedback: feedbackValue
        };
    }

    async handleAddSupportingMedia() {
        debugger;

        if (!this.userProfile) {
            this.showToast('Error', 'User profile is not available!', 'error');
            return;
        }

        if (Object.keys(this.mediaUpdates).length === 0) {
            this.showToast('Warning', 'No changes detected!', 'warning');
            return;
        }

        let isValid = true;
        let updates = {};

        this.lineItems.forEach(item => {
            let updatedMedia = this.mediaUpdates[item.Id]?.media;
            let finalMediaUrl = updatedMedia !== undefined ? updatedMedia : item.Supporting_Media__c || '';

            let updatedFeedback = this.mediaUpdates[item.Id]?.feedback;
            let finalFeedback = updatedFeedback !== undefined ? updatedFeedback : item.feedback || '';

            if (item.SpareOnApprove && finalMediaUrl.trim() === '') {
                this.showToast('Error', `Supporting Media URL is required before approving ${item.Name}`, 'error');
                isValid = false;
            }

            if (item.SpareOnReject && finalFeedback.trim() === '') {
                this.showToast('Error', `Feedback is required before rejecting ${item.Name}`, 'error');
                isValid = false;
            }

            if (this.Warehouse && item.WarehouseOnApprove && finalMediaUrl.trim() === '') {
                this.showToast('Error', `Supporting Media URL is required before approving ${item.Name} for Warehouse`, 'error');
                isValid = false;
            }

            if (this.Warehouse && item.WarehouseOnReject && finalFeedback.trim() === '') {
                this.showToast('Error', `Feedback is required before rejecting ${item.Name} for Warehouse`, 'error');
                isValid = false;
            }

            if (this.mediaUpdates[item.Id]) {
                updates[item.Id] = {
                    media: finalMediaUrl,
                    status: item.SpareOnApprove || item.WarehouseOnApprove ? 'Approved' : item.SpareOnReject || item.WarehouseOnReject ? 'Rejected' : null,
                    feedback: finalFeedback
                };
            }
        });

        if (!isValid) return;

        this.isLoading = true;

        try {
            const result = await updateSupportingMedia({ mediaUpdates: updates, profileName: this.userProfile });
            debugger;
            console.log('Profile Name ===>', this.userProfile);

            if (result === 'Success') {
                this.showToast('Success', 'Updated successfully!', 'success');

                // var baseurl = 'https://rivermobilityprivatelimited2--rruat.sandbox.lightning.force.com/lightning/r/Discrepancy__c/'+this.recordId+'/View';
                // window.location.replace('', baseurl);
                const baseUrl = window.location.origin;
                const recordPageUrl = `${baseUrl}/lightning/r/Discrepancy__c/${this.recordId}/view`;
                window.location.replace(recordPageUrl);
                //await refreshApex(this.wiredLineItems);
                //  this.updateRecord(recordId  : this.recordId);
                //  updateRecord({ fields: { Id: this.recordId }})
                this.mediaUpdates = {};

                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } catch (error) {
            this.showToast('Error', 'Failed to update media', 'error');
            console.error(error);
        } finally {
            this.isLoading = false;
        }
    }

    handleExit() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}