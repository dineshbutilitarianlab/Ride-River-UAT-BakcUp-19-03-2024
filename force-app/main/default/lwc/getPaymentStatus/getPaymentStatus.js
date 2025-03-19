import { LightningElement,api, track } from 'lwc';
import GetPaymentStatusAPI from '@salesforce/apex/PineLabsPaymentHelper.GetPaymentStatusAPI';
import { updateRecord } from 'lightning/uiRecordApi';
export default class GetPaymentStatus extends LightningElement {
    @api recordId;
    @track paymentStatus = '';
    @track paymentDetails = {};

    @track isLoading = true;
    @track hasPaymentDetails = false;
    @track NoPaymentDetailsFound = false;

    connectedCallback() {
        debugger;
        setTimeout(() => {
        this.recordId = this.recordId;    
        this.fetchPaymentStatus();
        }, 500);
    }

    get isApproved() {
        return this.paymentStatus === 'approved';
    }

    get isRejected() {
        return this.paymentStatus === 'rejected';
    }

    fetchPaymentStatus(){
        debugger;
        var today = new Date();
        var formattedDate = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

        GetPaymentStatusAPI({ recordId: this.recordId }) .then(result =>{
            if(result && result != null){
                this.isLoading = false;
                this.hasPaymentDetails = true;
                const response = result;
                this.paymentStatus = response.ResponseCode === '0' ? 'approved' : 'rejected';
                this.paymentDetails = {
                    amount : response.Amount !=null ? response.Amount : '0',
                    transactionId : response.PlutusTransactionReferenceID !=null ? response.PlutusTransactionReferenceID : '',
                    method : response.PaymentMode !=null ? response.PaymentMode : '',
                    date : formattedDate 
                }
                console.log('Payment Details == '+this.paymentDetails);
                updateRecord({ fields: { Id: this.recordId }})
            }else{
                this.NoPaymentDetailsFound = true;
            }
        })
        .catch(error => {
            console.error('Error fetching payment status: ', error);
            this.paymentDetails = {
                amount: '0',
                transactionId: '',
                method: '',
                date: formattedDate
            };
        });
        this.isLoading = false;
        this.NoPaymentDetailsFound = false;
    }
}