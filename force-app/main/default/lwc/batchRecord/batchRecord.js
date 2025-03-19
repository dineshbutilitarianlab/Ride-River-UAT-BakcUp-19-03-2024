import { refreshApex } from '@salesforce/apex';
import createBatchAndTagClaims from '@salesforce/apex/BatchRecordController.createBatchAndTagClaims';
import fetchClaims from '@salesforce/apex/BatchRecordController.fetchClaims';
//import getCurrentUserContact from '@salesforce/apex/BatchRecordController.getCurrentUserContact';
import BATCH_OBJECT from '@salesforce/schema/Create_Batch__c';
import PICKLIST_FIELD_AOC from '@salesforce/schema/Create_Batch__c.Address_of_Consignee__c';
import PICKLIST_FIELD_MOT from '@salesforce/schema/Create_Batch__c.Mode_of_Transport__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { LightningElement, track, wire } from 'lwc';


export default class BatchRecord extends LightningElement {

    closeModal() {
        this.close('close');
    }
    @track claims = [];
    @track selectedClaims = [];
    @track preSelectedRowIds = [];
    @track batchAmount = 0;
    @track showModal = false;

    //@track batchDispatchDate;
    @track lrNumber = '';
    @track lrAttachment = ''; 
    @track today = new Date().toISOString().split('T')[0];
    TOD =''; AOC =''; RN =''; VN =''; HPS =''; Phone =''; POS =''; TN =''; TID =''; Eway =''; MOT ='';
    picklistValuesAOC = [];
    picklistValuesMOT = [];
    valueAOC = '';
    valueMOT = '';
    contact;
    contactName;
    wiredClaimsResult; // Store the result of the wired service to refresh later

    columns = [
        { label: 'Claim Name', fieldName: 'Name', cellAttributes: { alignment: 'left' } },
        { label: 'Total Claim Amount', fieldName: 'Total_Claim_Amount__c', type: 'currency', cellAttributes: { alignment: 'left' } }
    ];

    selectedClaimsColumns = [
        { label: 'Claim Name', fieldName: 'Name' },
        { label: 'Total Claim Amount', fieldName: 'Total_Claim_Amount__c', type: 'currency', cellAttributes: { alignment: 'left' } },
        {
            type: 'button',
            typeAttributes: {
                label: 'Remove',
                name: 'remove',
                variant: 'destructive'
            }
        }
    ];

    @wire(fetchClaims)
    
    wiredClaims(result) {
        debugger;
        this.wiredClaimsResult = result;
        if (result.data) {
            this.claims = result.data;
        } else if (result.error) {
            this.showToast('Error', `Error fetching claims: ${result.error.body.message}`, 'error');
        }
    }

    // @wire(getCurrentUserContact)
    // wiredContact({ error, data }) {
    //     debugger;
    //     if (data) {
    //         this.contact = data;
    //         this.contactName = data.FirstName + ' ' + data.LastName;
    //         this.error = undefined;
    //     } else if (error) {
    //         this.error = error.body.message;
    //         this.contact = undefined;
    //     }
    // }

    @wire(getObjectInfo, { objectApiName: BATCH_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PICKLIST_FIELD_AOC,
    })
    getPicklistValuesForAOC({ data, error }) {
        if (error) {
            console.error('Error fetching picklist values for AOC:', error);
        } else if (data) {
            this.picklistValuesAOC = data.values.map((item) => ({
                label: item.label,
                value: item.value,
            }));
        }
    }

    handlePicklistChangeAOC(event) {
        this.AOC = event.target.value;
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: PICKLIST_FIELD_MOT,
    })
    getPicklistValuesForMOT({ data, error }) {
        if (error) {
            console.error('Error fetching picklist values for MOT:', error);
        } else if (data) {
            this.picklistValuesMOT = data.values.map((item) => ({
                label: item.label,
                value: item.value,
            }));
        }
    }

    handlePicklistChangeMOT(event) {
        this.MOT = event.target.value;
    }

    handleAddWarrantyClaim() {
        this.preSelectedRowIds = this.selectedClaims.map(claim => claim.Id);
        this.showModal = true;
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.preSelectedRowIds = selectedRows.map(row => row.Id);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'remove') {
            this.selectedClaims = this.selectedClaims.filter(claim => claim.Id !== row.Id);
            this.calculateBatchAmount();
        }
    }

    handleSelect() {
        this.selectedClaims = this.claims.filter(claim =>
            this.preSelectedRowIds.includes(claim.Id)
        );
        this.calculateBatchAmount();
        this.showModal = false;
    }

    handleModalClose() {
        this.showModal = false;
    }

    // handleDispatchDateChange(event) {
    //     this.batchDispatchDate = event.target.value;
    // }

    handleLRNumberChange(event) {
        this.lrNumber = event.target.value;
    }

    handleLRAttachmentChange(event) {
        this.lrAttachment = event.target.value;
    }

    //TOD =''; AOC =''; RN =''; VN =''; HPS =''; Phone =''; POS =''; TN =''; 
    handleTOD(event) {
    this.TOD = event.target.value;
    }

    handleRN(event) {
        this.RN = event.target.value;
    }

    handleVN(event) {
    this.VN = event.target.value;
    }

    handleHPS(event) {
        this.HPS = event.target.value;
    }

    handlePhone(event) {
       // this.Phone = event.target.value;
        this.Phone = event.target.value.replace(/\D/g, '');

        if (this.Phone.length !== 10) {
            //this.showToast('Error', 'Phone number must be exactly 10 digits.', 'error');
            this.Phone = ''; // Clear input if incorrect
        }
    }

    restrictNonNumeric(event) {
        const charCode = event.which ? event.which : event.keyCode;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault(); 
        }
    }

    handlePOS(event) {
    this.POS = event.target.value;
    }

    handleTN(event) {
        this.TN = event.target.value;
    }
    //TID =''; Eway =''; MOT ='';
    handleTID(event) {
        this.TID = event.target.value;
    }

    handleEway(event) {
        this.Eway = event.target.value;
    }

    handlePurpose(){
        this.purpose = event.target.value;
    }

    calculateBatchAmount() {
        
        this.batchAmount = this.selectedClaims.reduce(
            (total, claim) => total + (claim.Total_Claim_Amount__c || 0), 0
        );
    }
    
    async handleSubmit() {
        debugger;
        if (!this.selectedClaims.length) {
            this.showToast('Error', 'Please select at least one claim.', 'error');
            return;
        }
        // if (!this.batchDispatchDate) {
        //     this.showToast('Error', 'Batch dispatch date is required.', 'error');
        //     return;
        // }
        // if (!this.VN) {
        //     this.showToast('Error', 'Vehicle No. is required.', 'error');
        //     return;
        // }
        // if (!this.Eway) {
        //     this.showToast('Error', 'Batch dispatch date is required.', 'error');
        //     return;
        // }
        if (!this.Phone || this.Phone.length !== 10) {
            this.showToast('Error', 'Phone number must be exactly 10 digits.', 'error');
            return;
        }
        // if (!this.TN) {
        //     this.showToast('Error', 'Transport Number is required.', 'error');
        //     return;
        // }
        // if (!this.TID) {
        //     this.showToast('Error', 'Transport Id is required', 'error');
        //     return;
        // }
        if (!this.AOC) {
            this.showToast('Error', 'Address of Consignee is required', 'error');
            return;
        }
        if (!this.MOT) {
            this.showToast('Error', 'Mode of Transport is required.', 'error');
            return;
        }
        // if (!this.lrAttachment) {
        //     this.showToast('Error', 'LR Attachement  is required.', 'error');
        //     return;
        // }

        try {
            const claimIds = this.selectedClaims.map(claim => claim.Id);
            const result = await createBatchAndTagClaims({
                claimIds,
               // batchDispatchDate: this.batchDispatchDate,
                lrNumber: this.lrNumber,
                lrAttachment: this.lrAttachment,
                TOD: this.TOD, AOC: this.AOC, RN: this.RN, VN: this.VN, HPS: this.HPS, Phone: this.Phone,
                POS: this.POS, TN: this.TN, TID: this.TID, Eway: this.Eway, MOT: this.MOT
            });

            this.showToast('Success', 'Batch created successfully.', 'success');
            let currentURL = window.location.origin;
            let redirectURL = `${currentURL}/lightning/r/Create_Batch__c/${result}/view`;
            window.location.href = redirectURL;

            this.resetForm();

            // Refresh the claims list after successful submission
            await refreshApex(this.wiredClaimsResult);
        } catch (error) {
            this.showToast('Error', `Error creating batch: ${error.body.message}`, 'error');
        }
    }

    resetForm() {
        this.batchAmount = 0;
        //this.batchDispatchDate = '';
        this.lrNumber = '';
        this.lrAttachment = '';
        this.selectedClaims = [];
        this.preSelectedRowIds = [];
        this.TOD =''; this.AOC =''; this.RN =''; this.VN =''; this.HPS =''; this.Phone =''; this.POS =''; this.TN ='';
        this.TID =''; this.Eway =''; this.MOT ='';
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}