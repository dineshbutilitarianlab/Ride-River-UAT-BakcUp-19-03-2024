import getPinelabsMachineInfo from '@salesforce/apex/PineLabsPaymentHelper.getPinelabsMachineInfo';
import savePaymentLogs from '@salesforce/apex/PineLabsPaymentHelper.savePaymentLogs';
import paymentImage from '@salesforce/resourceUrl/Payment_Completion_Image';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';

const FIELDS = [
    'Order.Remaining_Amount__c',
    'Order.Dealer__c',
    'Order.Total_Log_Payment__c'
];

export default class PineLabsLogPayments extends LightningElement {
 @api recordId;
    orderdata;
    @track orderAmount = 0;
    @track pinelabsOptions = [];
    @track isPinelabsInfoModalOpen = false;
    @track selectedPinelabsInfo = '';
    showSpinner=false;
    showPaymentGateWay=true;
     
    imageURL=paymentImage;
    connectedCallback() {
        debugger;
        setTimeout(() =>{
        this.callApexMethod();
        },300);
      }

    callApexMethod(){
        debugger;
         getPinelabsMachineInfo({ OrderId: this.recordId })
        .then(records => {
            this.pinelabsRecords = records;
            console.log('PineLab Records-->' + JSON.stringify(this.pinelabsRecords));
            this.pinelabsOptions = this.pinelabsRecords.map(record => ({
                label: record.Name,
                value: record.Id
            }));
        })
        .catch(error => {
            console.error('Error fetching Pinelabs Machine Info:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'An error occurred while fetching Pinelabs Machine Info.',
                    variant: 'error'
                })
            );
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredOrderdata({ error, data }) {
        debugger;
        if (data) {
            this.orderdata = data.fields;
          // var totalLogPayment = this.orderdata.Total_Log_Payment__c.value != null ? this.orderdata.Total_Log_Payment__c.value : 0;
           this.orderAmount = this.orderdata.Remaining_Amount__c.value;
           if(this.orderdata.Remaining_Amount__c.value == 0){
            this.showPaymentGateWay=false;
           }

            console.log('orderdata details:', this.orderdata);
        } else if (error) {
            console.error('Error retrieving orderdata:', error);
        }
    }

    @track rows = [{
            id: this.generateId(),
            paymentMode: '',
            amount: '',
            trxnid: '',
            remark: '',
            availablePaymentModeOptions: this.getPaymentModes()
        }
    ];

    @track paymentModeOptions = [
        { label: 'Card', value: 'Card' },
        { label: 'UPI', value: 'UPI' },
        { label: 'Cash', value: 'Cash' }
    ];

    generateId() {
        return Math.random().toString(36).substring(2, 10);
    }

    getPaymentModes() {
        return [
            { label: 'Card', value: 'Card' },
            { label: 'UPI', value: 'UPI' },
            { label: 'Cash', value: 'Cash' }
        ];
    }

    handlePaymentModeChange(event) {
        debugger;
        const id = event.target.dataset.id;
        const value = event.target.value;
        const row = this.rows.find(row => row.id === id);
        if (row) {
            row.paymentMode = value;  
        }
        
        const validPaymentModes = ['UPI', 'Card'];
        const SelectedPayment = this.rows.some(row => 
            validPaymentModes.includes(row.paymentMode) && this.pinelabsRecords.length > 0
        );

        if (SelectedPayment) {
            this.showPinelabsButton = true;
        } else {
            this.showPinelabsButton = false;
        }
    }

    handleAmountChange(event) {
        const rowId = event.target.dataset.id;
        const amountValue = event.target.value;
        this.updateRowData(rowId, 'amount', amountValue);
    }

    handleTrxnIdChange(event) {
        const rowId = event.target.dataset.id;
        const trxnIdValue = event.target.value;
        this.updateRowData(rowId, 'trxnid', trxnIdValue);
    }

    handleRemarkChange(event) {
        const rowId = event.target.dataset.id;
        const remarkValue = event.target.value;
        this.updateRowData(rowId, 'remark', remarkValue);
    }

    updateRowData(rowId, field, value) {
        this.rows = this.rows.map(row => {
            if (row.id === rowId) {
                return { ...row, [field]: value };
            }
            return row;
        });
    }

    removeRow(event) {
        const rowId = event.target.dataset.id;
        this.rows = this.rows.filter(row => row.id !== rowId);
    }

    addRow() {
        this.rows = [
            ...this.rows,
            {
                id: this.generateId(),
                paymentMode: '',
                amount: '',
                trxnid: '',
                remark: '',
                availablePaymentModeOptions: this.getPaymentModes()
            }
        ];
    }

     resetForm() {
        debugger;
        this.rows = [{
            id: this.generateId(),
            paymentMode: '',
            amount: '',
            availablePaymentModeOptions: this.paymentModeOptions 
        }];
        this.cashRows = [];
        this.showRow = false;
        this.isChecked = false;
        this.selectedPaymentModes = [];
        this.errorMessage = '';
        this.showPinelabsButton = false;
        this.selectedPinelabsInfo = false;
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
        this.closeModal();
    }

    handlePinelabsInfoClick() {
        this.callApexMethod();
        this.isPinelabsInfoModalOpen = true;
    }

    get pinelabsRecordsWithSelection() {
        return this.pinelabsRecords.map(record => {
            return {
                ...record,
                isChecked: record.Id === this.selectedPinelabsInfo
            };
        });
    }

    closePinelabsModal() {
        this.isPinelabsInfoModalOpen = false;
    }
    
     handlePinelabsRadioChange(event) {
        debugger;
        this.selectedPinelabsInfo = event.target.value;
    }

      handlePinelabsSelection() {
        debugger;
        if (this.selectedPinelabsInfo) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: `Selected Pinelabs Machine Info`,
                    variant: 'success',
                })
            );
            this.isPinelabsInfoModalOpen = false; 
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a Pinelabs record.',
                    variant: 'error',
                })
            );
        }
    }

    closeModal() {
        const closeEvent = new CustomEvent('cancel');
        this.dispatchEvent(closeEvent);
    }

    async saveRecords() {
        debugger;
        let isValid = true;
         
        this.rows = this.rows.map(row => {
            const inputField = this.template.querySelector(`lightning-combobox[data-id="${row.id}"]`)
            const inputFieldForAmount = this.template.querySelector(`lightning-input[data-id="${row.id}"]`);//additional by Aniket 21/01/2025
            const paymentModeError = !row.paymentMode;
            const amountError = !row.amount;
            if(row.paymentMode == '' && row.amount == ''){
                isValid = false;
                inputField.setCustomValidity('Please Select Payment Mode');//addition by Aniket 21/01/2025
                inputField.reportValidity();
                inputFieldForAmount.setCustomValidity('Please Select Payment Amount');//addition by Aniket 21/01/2025
                inputFieldForAmount.reportValidity();
            }else if(row.amount == 0){
                isValid = false;
                inputField.setCustomValidity('');//addition by Aniket 21/01/2025
                inputField.reportValidity();
                inputFieldForAmount.setCustomValidity('Amount cannot be zero');//addition by Aniket 21/01/2025
                inputFieldForAmount.reportValidity();

            }else if(row.amount > this.orderdata.Remaining_Amount__c.value){
                isValid = false;
                inputField.setCustomValidity('');//addition by Aniket 21/01/2025
                inputField.reportValidity();
                inputFieldForAmount.setCustomValidity('Amount cannot be greater than Amount to be paid');//addition by Aniket 21/01/2025
                inputFieldForAmount.reportValidity();

            }else if(row.amount < 0){
                isValid = false;
                inputField.setCustomValidity('');//addition by Aniket 21/01/2025
                inputField.reportValidity();
                inputFieldForAmount.setCustomValidity('Amount cannot be negative');//addition by Aniket 21/01/2025
                inputFieldForAmount.reportValidity();

            }
           
            else{
                inputField.setCustomValidity('');//addition by Aniket 21/01/2025
                inputField.reportValidity();
                inputFieldForAmount.setCustomValidity('');//addition by Aniket 21/01/2025
                inputFieldForAmount.reportValidity();
            }
            
            return { ...row, paymentModeError, amountError };
        });
    
        if (!isValid) {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error',
            //         message: 'Please fill all mandatory fields.',
            //         variant: 'error'
            //     })
            // );
            return;
        }
    

        if (this.rows.length === 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'No splits to save.',
                    variant: 'error'
                })
            );
            return;
        }

        const validPaymentModes = ['UPI', 'Card'];
        const rowsWithValidPaymentMode = this.rows.filter(row => validPaymentModes.includes(row.paymentMode));
        const requiresPinelabs = rowsWithValidPaymentMode.length > 0;

        if (requiresPinelabs) {
            debugger;
            if (this.pinelabsRecords.length === 0) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'No Pinelabs Machine Info found. Please ensure Pinelabs records are available.',
                        variant: 'error'
                    })
                );
                return;
            }
    
            if (this.pinelabsRecords.length === 1) {
                this.pinelabsId = this.pinelabsRecords[0].Id;
            } else if (this.selectedPinelabsInfo) {
                this.pinelabsId = this.selectedPinelabsInfo;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select a Pinelabs Machine Info.',
                        variant: 'error'
                    })
                );
                return; 
            }
        } else {
            this.pinelabsId = null;
        }

        const payload = this.rows.map(row => ({
            Order__c: this.recordId,
            Payment_Mode__c: row.paymentMode,
            Pay_Amount__c: row.amount,
            Transaction_Id__c: row.trxnid,
            Remark__c: row.remark,
            PineLabs_Machine_Info__c: validPaymentModes.includes(row.paymentMode) ? this.pinelabsId : null
        }));
        console.log('Payload-->' + JSON.stringify(payload));

        this.showSpinner=true;
        savePaymentLogs({ paymentSplits: payload, orderId: this.recordId, pnLbMcnId: this.pinelabsId })
        .then(() => {
            setTimeout(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Log Payment created successfully ..!',
                        variant: 'success'
                    })
                );
            }, 2000);
            setTimeout(() => {
                this.showSpinner=false;
                this.dispatchEvent(new CloseActionScreenEvent());
               this.redirectToRecord();
            }, 2000);
        })
        .catch(error => {
            console.log('Payment splits not saved: ' + error.body.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    redirectToRecord() {
        debugger;
        const recordUrl = `${window.location.origin}/lightning/r/Order/${this.recordId}/view`;
        window.location.href = recordUrl;
    }
}