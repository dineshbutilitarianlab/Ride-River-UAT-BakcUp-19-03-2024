//import createPurchaseorder from '@salesforce/apex/ProductRequestLineController.createPurchaseorder';
import getCurrentLogedUserAccountRecord from '@salesforce/apex/ProductRequestLineController.getCurrentLogedUserAccountRecord';
import userId from '@salesforce/user/Id';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api } from 'lwc';
export default class CreatePurchaseOrderForm extends LightningModal {
    closeModal() {
        this.close('close');
    }

    handleChildCloseModal() {
        this.closeModal();
    }
    status = 'New';
    shipmentType = '';
    accountRecordId = '';
    locationRecordId = '';
    @api purchaseOrderRecordId = {};

    firstScreen = true;
    secondScreen = false;

    currentUserId;
    userLocationName = '';
    accountName;
    connectedCallback() {
        debugger;
        this.currentUserId = userId;
        this.apexMethod();
    }

    @api POTempObj = {};

    apexMethod() {
        debugger;
        getCurrentLogedUserAccountRecord({ loggedInUserId: this.currentUserId })
            .then(result => {
                if (result && result != null) {
                    this.accountName = result;
                } else {

                }
            })
            .then(error => {
                console.log('Error = ' + error);
            })
    }

    get statusOptions() {
        return [
            { label: 'New', value: 'New' },
            { label: 'Order Placed', value: 'Order Placed' },
            { label: 'Allotted', value: 'Allotted' },
            { label: 'Submitted for Finance Approval', value: 'Submitted for Finance Approval' },
            { label: 'Packing in Progress', value: 'Packing in Progress' },
            { label: 'Dispatch', value: 'Dispatch' },
            { label: 'Recevied', value: 'Recevied' },
            { label: 'Partial Fulfilment', value: 'Partial Fulfilment' },
            { label: 'Complete Fulfilment', value: 'Complete Fulfilment' },
            { label: 'Cancelled', value: 'Cancelled' }
        ];
    }

    get shipmentTypeOptions() {
        return [
            { label: 'VOR', value: 'VOR' },
            { label: 'STK', value: 'STK' }
        ];
    }

    handleStatusChange(event) {
        this.status = event.detail.value;
    }

    handleShipmentChange(event) {
        this.shipmentType = event.detail.value;
    }

    // handleAccountChange(event) {
    //     this.accountRecordId = event.detail.recordId;
    // }

    // handleLocationChange(event) {
    //     this.locationRecordId = event.detail.recordId;
    //     console.log(this.locationRecordId);
    // }

    handleSubmitProcess() {
        debugger;
        if (this.shipmentType === '' || this.locationRecordId === null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill Shipment Type',
                    variant: 'error'
                })
            )
            return;
        }


        var obj = {
            shipmentType: this.shipmentType,
            loggedInUserId: this.currentUserId
        };

        this.purchaseOrderRecordId = obj;
        this.secondScreen = true;
        this.firstScreen = false;

        // createPurchaseorder({ shipmentType: this.shipmentType, loggedInUserId: this.currentUserId })
        //     .then((result) => {
        //         debugger;
        //         this.purchaseOrderRecordId = result;
        //         this.secondScreen = true;
        //         this.firstScreen = false;
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Success',
        //                 message: 'New Purchase Order Has Been Created',
        //                 variant: 'success'
        //             })
        //         )
        //         this.status = '';
        //         this.shipmentType = '';
        //         this.accountRecordId = '';
        //         this.locationRecordId = '';
        //     })
        //     .catch((error) => {
        //         this.dispatchEvent(
        //             new ShowToastEvent({
        //                 title: 'Failure',
        //                 message: 'Something went wrong!!!',
        //                 variant: 'error'
        //             })
        //         )
        //     })

    }

    handleExit() {
        this.close('close');
    }

}