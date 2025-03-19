import fetchOnLoadData from '@salesforce/apex/cardsComponentController.fetchOnLoadData';
import No_Job_Card_img from "@salesforce/resourceUrl/No_Job_Card_img";
import No_Lead_img from "@salesforce/resourceUrl/No_Lead_img";
import No_Purchase_Order_img from "@salesforce/resourceUrl/No_Purchase_Order_img";
import No_cases_img from "@salesforce/resourceUrl/No_cases_img";
import Id from '@salesforce/user/Id';
// import allTask from 'c/allTasksRelateToUser';
// import AddPoPaymments from 'c/bulkInsertPoPayments1';
import MyPopup from 'c/createPurchaseOrderForm';
import TestcomponenetLwc from 'c/testComponentModal';
import navigateToCasesURL from '@salesforce/label/c.navigateToCasesURL';
import navigateToJobCardsURL from '@salesforce/label/c.navigateToJobCardsURL';
import { LightningElement, track } from 'lwc';

import orderProduct from 'c/orderProductModalLwc';

export default class CardsComponent extends LightningElement {
    NoLeadimg = No_Lead_img;
    NoJobCardimg = No_Job_Card_img;
    NoPurchaseOrderimg = No_Purchase_Order_img;
    Nocasesimg = No_cases_img;
    userId = Id;
    @track role;
    error;
    @track isDisabled = true;
    navigateToCasesURL = navigateToCasesURL;
    navigateToJobCardsURL = navigateToJobCardsURL;

    connectedCallback(){
        debugger;
        fetchOnLoadData({userId: this.userId}).then(result=>{
            this.role=result
            if(role = 'Service'){
                this.isDisabled = true;
            }
        }).catch((error)=>{
            console.log('error occurs')
        });
    }

    async navigateToPurchaseOrder() {
        debugger;
        console.log('userId ---> '+this.userId);
        const result = await MyPopup.open({
            size: 'large',
            description: 'This is a modal popup',
        });

        if (result === 'close') {
            console.log('Popup closed');
        }
       
    }

    async navigateToAddMerchandiseOrders() {
        debugger;
        console.log('userId ---> '+this.userId);
        const result = await orderProduct.open({
            size: 'large',
            description: 'This is a modal popup',
        });

        if (result === 'close') {
            console.log('Popup closed');
        }
       
    }

    async navigateToGetLeadDetails() {
        debugger;
        console.log('Navigating to Lead Transfer');
        const result = await TestcomponenetLwc.open({
            size: 'large',
            description: 'This is a modal popup for get Lead Details', 
        });

        if (result === 'close') {
            console.log('get lead details Order closed');
        }
    }
    // async navigateToTask() {
    //     debugger;
    //     const result1 = await allTask.open({
    //         size: 'large', 
    //         description: 'This is a modal popup', 
    //     });

    //     if (result1 === 'close') {
    //         console.log('Popup closed');
    //     }
    // }

    // async navigateToAddPoPayments() {
    //     debugger;
    //     console.log('Navigating to Add PO Payments');
    //     const result = await AddPoPaymments.open({
    //         size: 'large',
    //         description: 'This is a modal popup for Add PO Payments', 
    //     });

    //     if (result === 'close') {
    //         console.log('Add PO Payments popup closed');
    //     }
    // }
    navigateToJobCards() {
        window.open(
            this.navigateToJobCardsURL,
            '_blank'
        );
    }

    navigateToCases() {
        window.open(
            this.navigateToCasesURL,
            '_blank'
        );
    }
    
}