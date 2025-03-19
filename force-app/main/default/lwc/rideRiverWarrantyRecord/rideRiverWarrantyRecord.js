import { refreshApex } from '@salesforce/apex';
import canViewApprovalActions from '@salesforce/apex/ApprovalProcessHelper.canViewApprovalActions';
import handleApproval from '@salesforce/apex/ApprovalProcessHelper.handleApproval';
import submitApprovalProcess from '@salesforce/apex/WarrantyPriorApprovalController.submitApprovalProcess';
import checkApprovalStatus from '@salesforce/apex/WarrantyPriorApprovalController.checkApprovalStatus';
import getRelatedWorkOrderLineItems from '@salesforce/apex/WarrantyPriorController.getRelatedWorkOrderLineItems';
import isWarrantySubmittedForApproval from '@salesforce/apex/WarrantyPriorApprovalController.isWarrantySubmittedForApproval';
import getRelatedWorkPlans from '@salesforce/apex/WarrantyPriorController.getRelatedWorkPlans';
import getWarrantyPrior from '@salesforce/apex/WarrantyPriorController.getWarrantyPrior';
import updateLabours from '@salesforce/apex/WarrantyPriorController.updateLabours';
import updateParts from '@salesforce/apex/WarrantyPriorController.updateParts';
import updateWarrantyPrior from '@salesforce/apex/WarrantyPriorController.updateWarrantyPrior';
import WARRANTY_OBJECT from '@salesforce/schema/Warranty_Prior__c';
import TYPE_OF_WARRANTY_FIELD from '@salesforce/schema/Warranty_Prior__c.Type_of_Warranty__c';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, api, track, wire } from 'lwc';

import updateAdditionalParts from '@salesforce/apex/WarrantyPriorController.updateAdditionalParts';
import getRelatedWorkOrderLineItemsOnlyCausal from '@salesforce/apex/WarrantyPriorController.getRelatedWorkOrderLineItemsOnlyCausal';
import getUserProfile from '@salesforce/apex/WarrantyPriorController.getUserProfile';

// Component class
export default class RideRiverWarrantyRecord extends LightningElement {
    // Variables and Constants
    @track isApprovalFired = false; // for changing the lable of sumbit for approval button
    @api recordId; // Job Card ID
    @track warrantyPrior = {};
    @track warrantyId = ''; // Stores the Warranty ID
    @track labourData = []; // Labour records
    @track partsData = []; // Parts records
    @track additionalPartsData =[];
    @track error; // Error handling
    @track draftValuesParts = []; // Draft values for Parts
    @track draftValuesLabours = []; // Draft values for Labours
    @track draftValuesAdditionalparts = []; 
    @track warrantyOptions = []; // Warranty picklist values

    wiredWarrantyResult; // Store the wired result for refreshApex

    refreshLabours; // Store wire result for refresh
    refreshParts; // Store wire result for refresh
    refreshAdditionalPartSave;

    // for Approval Process visibility
    isVisible = false;
    afterpproove = false;
    isApprovalProcess = false;
    @track asmFeedbackView = true;
    @track userProfile;
    @track isFFIRLinksEditable = true;
    

    labourColumns = [
        { label: 'Labour Name', fieldName: 'jobUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: true },
        { label: 'Labour Code', fieldName: 'codeUrl', type: 'url', typeAttributes: { label: { fieldName: 'RR_Labour_Code__c' }, target: '_blank' }, sortable: true },
        // { label: 'Amount/hr', fieldName: 'Amount_per_Hour__c', type: 'currency', editable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Amount/hr', fieldName: 'Labour_Charge_CodeSet__c', type: 'currency', editable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Tax %', fieldName: 'Code_Set_Tax__c', type: 'number', editable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Total Amount', fieldName: 'Total_Labour_Cost__c', type: 'currency', cellAttributes: { alignment: 'centre' } }
    ];

    partsColumns = [
        { label: 'Product Code', fieldName: 'partUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: true },
        { label: 'Product Name', fieldName: 'productUrl', type: 'url', typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }, sortable: true },
        { label: 'Parts Category', fieldName: 'RR_Parts_Category__c', type: 'text', sortable: true },
        // { label: 'Labour Code', fieldName: 'LabourUrl', type: 'url', typeAttributes: { label: { fieldName: 'Labour_Name__c' }, target: '_blank' }, sortable: true },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number' },
        { label: 'Dealer Observation', fieldName: 'Part_Description__c', type: 'text' },
        { label: 'Replacement Type', fieldName: 'Replacement_Type__c', type: 'text' },
        // { label: 'Hours', fieldName: 'Hours__c', type: 'number' },
        { label: 'Standard Value', fieldName: 'Electrical_Value__c', type: 'text' },
        // { label: 'Total Labour Charges', fieldName: 'Total_Labour_Charges__c', type: 'currency', editable: true, cellAttributes: { alignment: 'left' } },
        { label: 'Total NDP Amount', fieldName: 'Total_NDP__c', type: 'currency', cellAttributes: { alignment: 'left' } },

        { label: 'Tax %', fieldName: 'IGST_Percentage_formula__c', type: 'decimal', cellAttributes: { alignment: 'left' } },
        { label: 'Grand Total', fieldName: 'Grand_Total__c', type: 'currency' }
    ];

        partsAdditionalColumns = [
        { label: 'Product Code', fieldName: 'partUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }, sortable: true },
        { label: 'Product Name', fieldName: 'productUrl', type: 'url', typeAttributes: { label: { fieldName: 'ProductName' }, target: '_blank' }, sortable: true },
        { label: 'Quantity', fieldName: 'Quantity', type: 'number', cellAttributes: { alignment: 'center' } },
        { label: 'FFIR No.', fieldName: 'FFIR_Number__c', type: 'text' },
        { 
            label: 'FFIR Links', 
            fieldName: 'FFIR_Links__c', 
            type: 'url', editable: this.isFFIRLinksEditable,
            typeAttributes: { label: { fieldName: 'FFIR_Link_Label' }, target: '_blank' } 
        }
        
    ];

    get buttonLabel() {
      return this.isApprovalFired ? 'Submit For Approval' : 'Submit For Approval';
    }
    
    
        @wire(CurrentPageReference)
        getCurrentPageReference(currentPageReference) {
            debugger;
            if (currentPageReference) {
                if(currentPageReference.attributes.recordId != undefined){
                    this.recordId = currentPageReference.attributes.recordId;
                }
            }
        }
    
    // Lifecycle Hooks
    connectedCallback() {
        if (this.recordId) {
            this.fetchWarrantyPrior();
        }
    }

    // Wired Methods
    @wire(getObjectInfo, { objectApiName: WARRANTY_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TYPE_OF_WARRANTY_FIELD })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.warrantyOptions = data.values.map((value) => ({
                label: value.label,
                value: value.value
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.warrantyOptions = [];
        }
    }

    @wire(getRelatedWorkPlans, { warrantyId: '$warrantyId' })
    wiredLabourPlans(result) {
        debugger;
        this.refreshLabours = result;
        if (result.data) {
            this.labourData = result.data.map((item) => ({
                Id: item.Id,
                jobUrl: `/${item.Id}`,
                codeUrl: item.RR_Labour_Code__r ? `/${item.RR_Labour_Code__r.Id}` : '',
                Name: item.Name,
                RR_Labour_Code__c: item.RR_Labour_Code__r ? item.RR_Labour_Code__r.Code : 'N/A',
                Labour_Charge_CodeSet__c: item.Labour_Charge_CodeSet__c || 0,
                Code_Set_Tax__c : item.Code_Set_Tax__c || 0,
                Total_Labour_Cost__c: item.Total_Labour_Cost__c || 0
            }));
        } else if (result.error) {
            this.error = result.error;
            this.labourData = [];
        }
    }

    //to display part details 
    @wire(getRelatedWorkOrderLineItems, { warrantyId: '$warrantyId' })
    wiredWorkOrderLineItems(result) {
        debugger;
        this.refreshParts = result;
        if (result.data) {
            this.partsData = result.data.map((item) => ({
                Id: item.Id,
                partUrl: `/${item.Id}`,
                productUrl: item.PricebookEntry?.Product2Id ? `/${item.PricebookEntry.Product2Id}` : '',
                Labour_Name__c: item.Labour_Code__c ? item.Labour_Code__r.Name : '',
                LabourUrl: item.Labour_Code__c? `/${item.Labour_Code__c}` : '',
                Name: item.LineItemNumber || 'N/A',
                ProductName: item.PricebookEntry && item.PricebookEntry.Product2 ? item.PricebookEntry.Product2.Name : 'N/A',
                RR_Parts_Category__c: item.RR_Parts_Category__c || 'N/A',
                Quantity: item.Quantity || 0,
                Part_Description__c: item.Part_Description__c || 'N/A',
                //Hours__c: item.Hours__c || 0, item.Labour_Code__r?.RR_Efforts_Hours__c ?? 0
                Hours__c: item.Labour_Code__r?.RR_Efforts_Hours__c ?? 0,
                Electrical_Value__c: item.Electrical_Value__c || 'N/A',
                Replacement_Type__c: item.Replacement_Type__c || 'N/A',
                //Amount_per_Hour__c: (item.Quantity || 0) * (item.Hours__c || 0) * (item.Labour_Code__r?.RR_Labour_Charge__c || 0),
                Amount_per_Hour__c : (item.Hours__c || 1) *(item.Quantity || 1) * (item.Labour_Code__r?.RR_Labour_Charge__c || 1),
                Tax__c: item.Tax__c || 0,
                TotalAmount__c: ((item.Hours__c || 1) *(item.Quantity || 1) * (item.Labour_Code__r?.RR_Labour_Charge__c || 1)) + (((item.Hours__c || 1) *(item.Quantity || 1) * (item.Labour_Code__r?.RR_Labour_Charge__c || 1) * item.Tax__c) /100 ),
                Total_Labour_Charges__c:(item.Total_Labour_Charges__c),
                Total_NDP__c:(item.Total_NDP__c),
                IGST_Percentage_formula__c:(item.IGST_Percentage_formula__c),
                Grand_Total__c:(item.Grand_Total__c)
            }));
        } else if (result.error) {
            this.error = result.error;
            this.partsData = [];
        }
    }

    @wire(getUserProfile)
    wiredUserProfile({ error, data }) {
        debugger;
        if (data) {
            this.userProfile = data;
            if (this.userProfile === 'ASM Profile') {
                this.isFFIRLinksEditable = false;
            }
        } else if (error) {
            console.error('Error fetching user profile:', error);
        }
    }

    //for additional parts details 
    @wire(getRelatedWorkOrderLineItemsOnlyCausal, { warrantyId: '$warrantyId' })
    wiredWorkAddOrderLineItems(result) {
        debugger;
        this.refreshAdditionalPartSave = result;
        if (result.data) {

            this.additionalPartsData = result.data.map((item) => ({
                Id: item.Id,
                partUrl: `/${item.Id}`,
                productUrl: item.PricebookEntry?.Product2Id ? `/${item.PricebookEntry.Product2Id}` : '',
                Name: item.LineItemNumber || 'N/A',
                ProductName: item.PricebookEntry && item.PricebookEntry.Product2 ? item.PricebookEntry.Product2.Name : 'N/A',
                RR_Parts_Category__c: item.RR_Parts_Category__c || 'N/A',
                Quantity: item.Quantity || 0,
                FFIR_Number__c: item.FFIR_Number__c || 'N/A',
                FFIR_Links__c: item.FFIR_Links__c ? item.FFIR_Links__c : '', 
                FFIR_Link_Label: item.FFIR_Links__c ? item.FFIR_Links__c : ''

            }));
        } else if (result.error) {
            this.error = result.error;
            this.additionalPartsData = [];
        }
    }


    @wire(canViewApprovalActions)
    wiredPermission({ error, data }) {
        debugger; // For debugging purposes; remove this in production
        if (data) {
            this.isVisible = data; // Set `isVisible` to the value returned by the Apex method
            this.asmFeedbackView = false; 
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body ? error.body.message : 'Unknown error occurred', // Handle potential null error body
                    variant: 'error',
                })
            );
            console.error('Error in wiredPermission:', error); // Log the error for debugging
        }
    }

    @wire(isWarrantySubmittedForApproval , { warrantyId: '$warrantyId' })
    wiredisWarrantySubmittedForApproval({ error, data }) {
        debugger; // For debugging purposes; remove this in production
        if (data) {
            this.isApprovalProcess = data; // Set `isVisible` to the value returned by the Apex method
            //this.asmFeedbackView = false; 
        } else if (error) {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error',
            //         message: error.body ? error.body.message : 'Unknown error occurred', // Handle potential null error body
            //         variant: 'error',
            //     })
            // );
            console.error('Error in wiredPermission:', error); // Log the error for debugging
        }
    }
    
        // Fetch approval status when the component loads
        @wire(checkApprovalStatus, { warrantyId: '$warrantyId' })
        wiredApprovalStatus({ error, data }) {
            debugger;
            if (data !== undefined) {
                this.isApprovalFired = data;
            } else if (error) {
                //this.isApprovalFired = true;
                console.error('Error fetching approval status:', error);
            }
        }


    // Event Handlers

    handleAction(event) {
        debugger;
        const action = event.target.dataset.action;
    
        if (!action || !this.warrantyId) {
            this.showToast('Error', 'Invalid action or record ID.', 'error');
            return;
        }
    
        // Get ASM Feedback value
        // const asmFeedback = this.warrantyPrior.ASM_Feedback__c;
        // const asmFeedbackInput = this.template.querySelector('lightning-input[data-field="ASM_Feedback__c"]');
        const asmFeedbackInput = this.template.querySelector('lightning-input[data-field="ASM_Feedback__c"]');
        let asmFeedback = asmFeedbackInput ? asmFeedbackInput.value.trim() : '';
        // If action is 'reject', validate ASM Feedback (Required)
       /* if (action.toLowerCase() === 'reject') {
            // Ensure ASM Feedback is not empty for rejection
            if (!asmFeedbackInput) {
                asmFeedbackInput.setCustomValidity('ASM Feedback is required when rejecting the action.'); //
                asmFeedbackInput.reportValidity();
                this.showToast('Error', 'ASM Feedback is required when rejecting the action.', 'error');
                return; // Exit if ASM Feedback is empty
            } 

            else {
                asmFeedbackInput.setCustomValidity('');
                asmFeedbackInput.reportValidity();
            }
            
        }*/

        if (!asmFeedback && action.toLowerCase() === 'reject') {
            asmFeedbackInput.setCustomValidity('ASM Feedback is required.');
            asmFeedbackInput.reportValidity();
            this.showToast('Error', 'ASM Feedback is required before proceeding.', 'error');
            return; // Stop execution if feedback is empty
        } else {
            asmFeedbackInput.setCustomValidity('');
            asmFeedbackInput.reportValidity();
        }

        // if (action.toLowerCase() === 'approve') {
        //         asmFeedbackInput.reportValidity();
        //         return; 
        // }
    
        // Proceed with the approval/rejection/recall process after updating the feedback (if applicable)
        handleApproval({ recordId: this.warrantyId, action: action })
        .then(() => {
            return updateWarrantyPrior({ warrantyId: this.warrantyId, asmFeedback: asmFeedback });
        })
         .then(() => {
            console.log("Inside UPDATE WARRANTY");
            this.showToast('Success', `${action.charAt(0).toUpperCase() + action.slice(1)}action , Warranty Prior has been apporved.`, 'success');
            this.afterpproove = true; 
            this.isApprovalFired = false;
            this.isVisible = false;
            if (asmFeedbackInput) {
                asmFeedbackInput.value = ''; // Clear input after action
            }
            window.location.reload();
        })
           
            .catch((error) => {
                this.showToast('Error', `Failed to perform ${action} action.`, 'error');
                console.error(error);
            });
    }
    
    handleCellChange(event) {
        debugger;
        if (event.target === this.template.querySelector('lightning-datatable[data-id="parts"]')) {
            this.draftValuesParts = event.detail.draftValues;
        } else if (event.target === this.template.querySelector('lightning-datatable[data-id="labours"]')) {
            this.draftValuesLabours = event.detail.draftValues;
        }
        else if (event.target === this.template.querySelector('lightning-datatable[data-id="additionalParts"]')) {
            this.draftValuesAdditionalparts = event.detail.draftValues;
        }

    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this.warrantyPrior[field] = event.target.value;
    }

    handlePartsSave(event) {
       // const updatedParts = event.detail.draftValues;
       const updatedParts = event.detail.draftValues.map((draft) => {
        const originalRow = this.partsData.find((row) => row.Id === draft.Id);
        return { ...originalRow, ...draft ,Amount_per_Hour__c: draft.Amount_per_Hour__c || originalRow.Amount_per_Hour__c,}; // Merge original data with the draft values
        });
        updateParts({ partsDraftValues: updatedParts })
            .then(() => {
                this.showToast('Success', 'Parts updated successfully', 'success');
                this.draftValuesParts = [];
                return refreshApex(this.refreshParts);
            })
            .catch((error) => {
                this.showToast('Error', `Error updating Parts: ${error.body.message}`, 'error');
            });
    }

    handleAdditionalPartsSave(event) {
    debugger;
    if (!this.isFFIRLinksEditable) {
        this.showToast('Error', 'You are not allowed to edit FFIR Links.', 'error');
        return; // Stop execution
    }
    const updateAddParts = event.detail.draftValues.map((draft) => {
        const originalRow = this.additionalPartsData.find((row) => row.Id === draft.Id);
        return { ...originalRow, ...draft }; // Merge original data with the draft values };
    });

        // Validate if FFIR_Links__c is filled for all updated records
        let isValid = true;
        let invalidRows = [];
    
        updateAddParts.forEach(record => {
            if (!record.FFIR_Links__c || record.FFIR_Links__c.trim() === '') {
                isValid = false;
                invalidRows.push(record.Id);
            }
        });
    
        if (!isValid) {
            this.showToast('Error', 'FFIR Links is required for all rows.', 'error');
    
            // Highlight the invalid rows
            this.template.querySelector('lightning-datatable').errors = {
                rows: invalidRows.reduce((acc, rowId) => {
                    acc[rowId] = { title: 'Required Field Missing', messages: ['FFIR Links cannot be empty.'] };
                    return acc;
                }, {})
            };
    
            return; // Stop further processing
        }


    updateAdditionalParts({ partsDraftValues: updateAddParts })
        .then(() => {
            window.location.reload();
            this.showToast('Success', 'Additional parts updated successfully', 'success');
            console.log(JSON.stringify(updateAddParts));
            console.log(JSON.stringify(draftValuesAdditionalparts));
            this.draftValuesAdditionalparts = [];
            
            //return refreshApex(this.refreshAdditionalPartSave);
        })
        .catch((error) => {
            this.showToast('Error', `Error updating Additional Parts: ${error.body.message}`, 'error');
        });
    }


    handleLaboursSave(event) {
       // const updatedLabours = event.detail.draftValues;
       const updatedLabours = event.detail.draftValues.map((draft) => {
        const originalRow = this.labourData.find((row) => row.Id === draft.Id);
        return { ...originalRow, ...draft }; // Merge original data with the draft values
        });
        updateLabours({ labourDraftValues: updatedLabours })
            .then(() => {
                this.showToast('Success', 'Labours updated successfully', 'success');
                this.draftValuesLabours = [];
                return refreshApex(this.refreshLabours);
            })
            .catch((error) => {
                this.showToast('Error', `Error updating Labours: ${error.body.message}`, 'error');
            });
    }

    // Apex Call Helpers
    fetchWarrantyPrior() {
        getWarrantyPrior({ workOrderId: this.recordId })
            .then((data) => {
                this.wiredWarrantyResult = data;
                this.warrantyPrior = data || {};
                this.warrantyId = data?.Id || '';
            })
            .catch((error) => {
                this.error = error;
                this.warrantyPrior = {};
                this.warrantyId = '';
            });
    }

    // handleUpdateWarranty() {
    //     debugger;
    //     return 
    // }

    // handleSubmitApproval() {
    //     debugger;
    //     return 
    // }

    handleSubmit() {
        debugger;
        console.log('Submit button clicked');
        console.log('Parts Data:', this.partsData);
        console.log('Additional Parts Data:', this.additionalPartsData);
    

            // Validate FFIR_Links__c
    const invalidFFIRLinks = this.additionalPartsData.filter(
        (part) => !part.FFIR_Links__c || part.FFIR_Links__c.trim() === ''
    );

    if (invalidFFIRLinks.length > 0) {
        const errorMessage = 'FFIR Links are required for all parts.';
        console.error('Validation Error:', errorMessage);
        this.showToast('Validation Error', errorMessage, 'error');
        return; // Stop execution if validation fails
    }

        const invalidParts = this.partsData.filter(
            (part) => part.TotalAmount__c <= 0 || part.Tax__c === 0
        );
        console.log('Invalid Parts:', invalidParts);
    
        // if (invalidParts.length > 0) {
        //     const errorMessage = invalidParts.map((part) =>
        //         `Part ${part.Name}: Total Amount must be greater than 0 and Tax cannot be 0.`
        //     ).join('\n');
        //     console.error('Validation Error:', errorMessage);
    
        //     this.showToast('Validation Error', errorMessage, 'error');
        //     return; 
        // }

                    // Validate mandatory fields
                    //commented not to check the warranty prior mandatorty 
    // if (!this.warrantyPrior.FFIR_Number__c || !this.warrantyPrior.Standard_Values__c || !this.warrantyPrior.FFIR_Link__c) {
    //     const errorMessage = 'FFIR Number, Standard Value, and FFIR Link are mandatory fields. Please provide values for all.';
    //     console.error('Validation Error:', errorMessage);
    //     this.showToast('Validation Error', errorMessage, 'error');
    //     return; // Stop further execution
    // }

    
        console.log('Validation passed. Proceeding with submission...');
        submitApprovalProcess({
            warrantyId: this.warrantyId,
            typeOfWarranty: this.warrantyPrior.Type_of_Warranty__c,
            asmFeedback: this.warrantyPrior.ASM_Feedback__c,
            ffirNumber: this.warrantyPrior.FFIR_Number__c,
            dealerObservation: this.warrantyPrior.Dealer_Observation__c,
            media: this.warrantyPrior.Media__c,
            standardValue: this.warrantyPrior.Standard_Values__c,
            ffirLink: this.warrantyPrior.FFIR_Link__c
        })

        .then(result => {
            if(result == 'Success'){
                this.isApprovalFired = true;
                this.showToast('Success', 'Approval process initiated and Warranty updated successfully', 'success');
                // submitApprovalProcess({ warrantyId: this.warrantyId });
                //window.location.reload();
            }else{
                this.isApprovalFired = true;
                this.showToast('error', 'Approval process Already initiated for this Record', 'error');
            }
        })
        .catch(error => {
            this.error = error;
            
        });
        // // .then(() => {
        // //     console.log('Warranty updated successfully');
        // //     submitApprovalProcess({ warrantyId: this.warrantyId });
        // //     if(){

        // //     }
        // // })
        // // .then(() => {
        // //     console.log('Approval process initiated successfully');
        // //     this.showToast('Success', 'Approval process initiated successfully', 'success');
        // //     return Promise.all([refreshApex(this.refreshLabours), refreshApex(this.refreshParts)]);
        // // })
        // .catch((error) => {
        //     console.error('Error during submission:', error);
        //     this.showToast('Error', `Error during submission: ${error.message}`, 'error');
        // });
    }
    
    
    // handleUpdateWarranty() {
    //     debugger;
    //     updateWarrantyPrior({
    //         warrantyId: this.warrantyId,
    //         typeOfWarranty: this.warrantyPrior.Type_of_Warranty__c,
    //         asmFeedback: this.warrantyPrior.ASM_Feedback__c,
    //         ffirNumber: this.warrantyPrior.FFIR_Number__c,
    //         dealerObservation: this.warrantyPrior.Dealer_Observation__c,
    //         media: this.warrantyPrior.Media__c,
    //         standardValue: this.warrantyPrior.Standard_Value__c,
    //     })
    //         .then(() => {
    //             console.log('Warranty updated successfully');
    //             this.showToast('Success', 'Warranty updated successfully', 'success');
    //         })
    //         .catch((error) => {
    //             console.error('Error during warranty update:', error);
    //             this.showToast('Error', `Error during warranty update: ${error.message}`, 'error');
    //         });
    // }
    
    // handleSubmit() {
    //     debugger;
    //     console.log('Submit button clicked');
    //     this.handleUpdateWarranty();
    // }e
    

    // Utility Methods
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}