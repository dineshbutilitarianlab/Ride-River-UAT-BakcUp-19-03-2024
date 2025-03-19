import { LightningElement,api,wire,track } from 'lwc';
import updateClaimItemsApprovedQuantityAndReason from '@salesforce/apex/clainAndShipmentItemController.updateClaimItemsApprovedQuantityAndReason';
//import getAllClaimItems from '@salesforce/apex/clainAndShipmentItemController.getAllClaimItems';
import getBatchClaims from '@salesforce/apex/clainAndShipmentItemController.getBatchClaims';

import getPartItems from '@salesforce/apex/clainAndShipmentItemController.getPartItems';
import getLabourItems from '@salesforce/apex/clainAndShipmentItemController.getLabourItems';

//import getBatchLabour from '@salesforce/apex/clainAndShipmentItemController.getBatchLabour';

import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createClaimItem from '@salesforce/apex/clainAndShipmentItemController.createClaimItem';

export default class BatchApproveClaims extends LightningElement {
        @api recordId;
        isLoading=false;
        refreshData=[];
        //claimList=[];
        @track partList=[];
        @track labourList = [];
        buttonVisibility=true;
        @track claimUpdates = {};
        @track isModalOpen = false;
        @track claimOptions = [];
        @track selectedClaimId;
        @track labourCode;
        //@track labourOptions =[];
        @track name;



        

        @wire(getPartItems, { recordId: '$recordId' })
        wiredPartData(result) {
            debugger;
            this.refreshData = result;
            console.log('Part Data:', JSON.stringify(result));

            if (result.data) {
            this.partList = result.data.map(item => ({
                Id: item.Id,
                ClaimName: item.Claim ? item.Claim.Name : 'N/A',
                ClaimItemNumber: item.Claim_Item_Number__c || 'N/A',
                PartLineItemNumber: item.Part__r ? item.Part__r.LineItemNumber : 'N/A',
                PartProductCode: item.Part__r ? item.Part__r.Product_Code__c : 'N/A',
                QuantityReceived: item.Received_Quantity__c	 || 0,
                QuantityRejected: item.Quantity_Rejected__c || 0,
                ApprovedQuantity: item.Approved_Quantity__c || 0,
                RejectionReason: item.Rejection_Reason__c || '',
                SendToFinance: item.Claim?.Create_Batch__r?.Send_to_Finance__c || false
            }));

            this.buttonVisibility = !this.partList.some(item => item.SendToFinance);

                    console.log('Processed Part List:', JSON.stringify(this.partList));
            } else if (result.error) {
                console.error('Error fetching Part Items:', JSON.stringify(result.error));
            }
        }

           //taking for labour record 
         @wire(getLabourItems,{recordId:'$recordId'})
            wiredData(result){
            this.refreshData=result;
            console.log('Part Data:', JSON.stringify(result));
            debugger;
            if(result.data){
               this.labourList = result.data.map(item => ({
                Id: item.Id,
                LabourCode: item.Labour_Code__r ? item.Labour_Code__r.Name : 'N/A',
                LabourAmount: item.Labour_Total_Amount__c || 0,
                ClaimName: item.Claim ? item.Claim.Name : 'N/A',
                ClaimItemNumber: item.Claim_Item_Number__c || 'N/A',
                Type: item.Labour_Category__c || 'N/A',
                ApprovalStatus: item.Status__c ? item.Status__c : 'Approved' 
            }));

            }else if(result.error){
                console.log('Error===>',result.error);
            }
    
        }
        @track labourList = [
            { Id: '1', LabourCode: 'LC101', LabourAmount: '500', ClaimName: 'Claim A', ClaimItemNumber: 'CI001', Type: 'Type 1', ApprovalStatus: '' },
            { Id: '2', LabourCode: 'LC102', LabourAmount: '700', ClaimName: 'Claim B', ClaimItemNumber: 'CI002', Type: 'Type 2', ApprovalStatus: '' }
        ];
    
        approvalOptions = [
            { label: 'Approved', value: 'Approved' },
            { label: 'Rejected', value: 'Rejected' }
        ];
        
        
        handleApprovalChange(event) {
            debugger;
            let labourId = event.target.dataset.id;
            let fieldName = event.target.dataset.field;
            let value = event.detail.value;
    
            // Update labourList with changed values
            this.labourList = this.labourList.map(item =>
                item.Id === labourId ? { ...item, [fieldName]: value } : item
            );
    
            // Store changes in claimUpdates
            if (!this.claimUpdates[labourId]) {
                this.claimUpdates[labourId] = {};
            }
            this.claimUpdates[labourId]['ApprovalStatus'] = value;
    
            console.log('Updated claimUpdates:', JSON.stringify(this.claimUpdates));
        }

         
    handleClaimChange(event) {
        this.selectedClaimId = event.detail.value;
    }

    handleLabourCodeChange(event) {
    this.labourCode = event.target.value;
    console.log('Labour Code:', this.labourCode); 
}

    handleNameChange(event) {
        
        this.name = event.detail.value;
        console.log('Name:', this.name);
    }

    openModal() {
        debugger;
        this.isModalOpen = true;
    }

    // Close Modal
    closeModal() {
        this.isModalOpen = false;
    }

    handleSave() {
        debugger;
        if (!this.selectedClaimId || !this.labourCode) {
            this.showToast('Error', 'Please select a Claim and enter a Labour Code', 'error');
            return;
        }

        createClaimItem({ name: this.name, claimId: this.selectedClaimId, labourCode: this.labourCode })
            .then(result => {
                this.showToast('Success', 'Claim Item created successfully!', 'success');
                this.closeModal();
            })
            .catch(error => {
                console.error('Error creating Claim Item:', error);
                errorMessage = 'Something went wrong!';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }

                this.showToast('Error', errorMessage, 'error');
            });
    }

    @wire(getBatchClaims, { batchId: '$recordId' })
    wiredClaims({ error, data }) {
        debugger;
        if (data) {
            this.claimOptions = data.map(claim => ({
                label: claim.Name,
                value: claim.Id
            }));
        } else if (error) {
            console.error('Error fetching claims:', error);
        }
    }

     
        handleSuccess(event) {
          
            console.log('Record created successfully:', event.detail);
            this.closeModal();
        }


            // Handle Error Event
    handleError(event) {
        console.error('Error creating record:', event.detail);
    }
    


        // @wire(getAllClaimItems,{recordId:'$recordId'})
        // wiredData(result){
        //     this.refreshData=result;
        //     debugger;
        //     if(result.data){
        //         this.claimList=result.data;
        //     }else if(result.error){
        //         console.log('Error===>',result.error);
        //     }
    
        // }

        connectedCallback() {
    console.log('Record ID:', this.recordId);
}


        //taking for parts record 




     

        get inputDisable(){
            return this.partList[0].Create_Batch__r.Is_GRN_Received__c === true;
        }
        
        handleInputChange(event) {
            debugger;
            const { id, field } = event.target.dataset;
            let value = event.target.value;
        
            // Convert Approved_Quantity__c to a number
            if (field === 'ApprovedQuantity') {
                value = value ? parseFloat(value) : 0;
            }
        
            // If the field is Rejection_Reason__c, it should store the string value
            if (field === 'RejectionReason') {
                value = value || ''; // Ensure it's always a string
            }
        
            // Ensure claimUpdates object is properly structured
            if (!this.claimUpdates[id]) {
                this.claimUpdates[id] = {};
            }
        
            // Store the updated values
            this.claimUpdates[id][field] = value;
            console.log('Updated claimUpdates:', JSON.stringify(this.claimUpdates));
        }
        

        inputValidation() {
            debugger;
            let isValid = true;
            // this.partList.forEach((ClaimItem) => {
            //     if (ClaimItem.ReceivedQuantity > ClaimItem.QuantityRejected) {
            //         this.showToast('Warning', 'Received Quantity cannot be greater than Rejected Quantity', 'warning');
            //         isValid = false;
            //     }
            // });

                this.partList.forEach((ClaimItem) => {
                let approvedQty = this.claimUpdates[ClaimItem.Id]?.ApprovedQuantity || ClaimItem.ApprovedQuantity;
                let receivedQty = ClaimItem.QuantityReceived;

                if (approvedQty > receivedQty) {
                    this.showToast('Warning', 'Approved Quantity cannot be greater than Received Quantity', 'warning');
                    isValid = false;
                }
            });

            return isValid;
        }
        
        
        handleSubmit(){
            debugger;
            if (!this.inputValidation()) {
                return; 
            }
        
            const updatesArray = Object.keys(this.claimUpdates).map(id => ({
                claimItemId: id,
                labourCodeId: this.claimUpdates[id]['LabourCodeId'] || '', 
                approvedQuantity: this.claimUpdates[id]['ApprovedQuantity'] || 0,
                rejectionReason: this.claimUpdates[id]['RejectionReason'] || '' ,
                approvalStatus: this.claimUpdates[id]['ApprovalStatus'] || '', // Including Labour Approval Status
                batchId: this.recordId

            }));

            console.log('Final claimItemWrappers before sending:', JSON.stringify(updatesArray));

            const updatesJson = JSON.stringify(updatesArray);
            this.isLoading = true;
            updateClaimItemsApprovedQuantityAndReason({ claimItemWrappersJson: updatesJson })
                .then(result => {
                    this.showToast('Success', 'Claim Items Update successfully', 'success');
                    setTimeout(() => {
                        this.isLoading = false;
                        this.buttonVisibility = false;
                        this.handleExit();
                    }, 2000);
                })
                .catch(error => {
                    console.error('Error updating claim items:', error);
                    this.showToast('Failure', 'Something went wrong!!!', 'error');
                    this.isLoading = false;
                })
                .finally(() => {
                    refreshApex(this.refreshData);
                });

        }
        handleExit(){
            this.dispatchEvent(new CloseActionScreenEvent());
        }
        showToast(Title,Message,Variant){
            this.dispatchEvent(
                new ShowToastEvent({
                    title:Title,
                    message:Message,
                    variant:Variant
                })
            )
        }
}