/**
 * Descriptio   : This is a custom hightlight Panel of Job card for DMS.
 * Author       : Jitendra Solanki
 * Created Date : 20 June 2024
 */

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getWeblinks from'@salesforce/apex/CustomHighlightPanelController.getWeblinks';
import {refreshApex} from '@salesforce/apex';
import OwnerId_FIELD from '@salesforce/schema/WorkOrder.OwnerId';
import CaseId_FIELD from '@salesforce/schema/WorkOrder.CaseId';
import Status_FIELD from '@salesforce/schema/WorkOrder.Status';
import StartDate_FIELD from '@salesforce/schema/WorkOrder.StartDate';
import EndDate_FIELD from '@salesforce/schema/WorkOrder.EndDate';

// Add fields you want to display
const FIELDS = [
    'WorkOrder.WorkOrderNumber',
    'WorkOrder.Status',
    'WorkOrder.RR_Job_Type__c'
    // Add more fields as needed
];

export default class CustomHighlightPanel extends NavigationMixin(LightningElement) {
    @api recordId;
    record;
    error;

    headerFields = [OwnerId_FIELD, CaseId_FIELD, Status_FIELD, StartDate_FIELD, EndDate_FIELD];

    @track buttons = [];
    @track dropdownButtons = [];

    showCanelJobCard = false;

    get inputFlowVariables() {
        console.log('recordId :',this.recordId);
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.fetchAllData();
            // this.record = data.fields;
            this.error = undefined;
        } else if (error) {
            this.record = undefined;
            this.error = error.body.message;
        }
    }

    fetchAllData() {
        this.dropdownButtons = [];
        console.log('connectedCallback called');
        getWeblinks({sobjectName : 'WorkOrder', recordId : this.recordId})
        .then(response => {
            console.log('response fetched',response);
            if (response) {
                this.record = response.record;
                let butttonData = response.buttons;
                let apexPages = response.apexPages;
                let apexPageURL = response.apexPageURL;
                console.log('this.record : ',this.record);
                if(this.record.Status != 'Completed'){
                    this.dropdownButtons.push({
                        id: 'RR_Cancel_Job_Card',
                        label: 'Cancel Job Card',
                        value: 'RR_Cancel_Job_Card',
                    });
                }

                this.dropdownButtons = [
                    ... this.dropdownButtons,{
                        id: 'Edit',
                        label: 'Edit',
                        value: 'Edit',
                    },
                    {
                        id: 'Delete',
                        label: 'Delete',
                        value: 'Delete',
                    },
                ]

                this.buttons = butttonData.map(item => {
                    let isVisible;
                    if(this.record.Status == 'Ready for Delivery'){
                        isVisible = true;
                        if(item.Name == 'Generate_Invoice' || item.Name == 'Generate_Insurance_Invoice'){
                            isVisible = false;
                        }
                        if(item.Name == 'Generate_Pre_Insurance_Invoice'){
                            if(this.record.RR_Job_Type__c != 'Accidental'){
                                isVisible = false;
                            }
                        }
                    }
                    else if(this.record.Status == 'Completed'){
                        isVisible = true;
                        if(item.Name == 'Generate_Pre_Invoice' || item.Name == 'Generate_Pre_Insurance_Invoice'){
                            isVisible = false;
                        }
                        if(item.Name == 'Generate_Insurance_Invoice'){
                            if(this.record.RR_Job_Type__c != 'Accidental'){
                                isVisible = false;
                            }
                        }
                    }
                    else{
                        if(item.Name == 'Generate_Invoice' || item.Name == 'Generate_Insurance_Invoice' || item.Name == 'Generate_Pre_Invoice' || item.Name == 'Generate_Pre_Insurance_Invoice'){
                            isVisible = false;
                        }
                        else{
                            isVisible = true;
                        }
                    }
                    return {... item, isVisible : isVisible, apexPageURL : apexPageURL[item.ScontrolId]}
                });
                console.log('buttons',this.buttons);
            }
        })
        .catch(error => {
            this.buttons = undefined;
            this.error = error.body.message;
            console.log('error',error);
        })
    }

    // @wire(getWeblinks, {sobjectName : 'WorkOrder'})
    // buttonsRes(response) {
    //     let {error, data} = response;
    //     if(!this.record){
    //         console.log('Need to refresh');
    //         refreshApex(response);
    //     }
    //     else if (data) {
    //         console.log('this.record : ',this.record);
    //         let butttonData = data.buttons;
    //         let apexPages = data.apexPages;
    //         this.buttons = butttonData.map(item => {
    //             let isVisible;
    //             if(this.record.Status.value == 'Ready for Delivery'){
    //                 if(item.Name == 'Generate_Invoice' || item.Name == 'Generate_Insurance_Invoice'){
    //                     isVisible = false;
    //                 }
    //                 else {
    //                     isVisible = true;
    //                 }
    //             }
    //             else if(this.record.Status.value == 'Completed'){
    //                 if(item.Name == 'Generate_Pre_Invoice' || item.Name == 'Generate_Pre_Insurance_Invoice'){
    //                     isVisible = false;
    //                 }
    //                 else {
    //                     isVisible = true;
    //                 }
    //             }
    //             else{
    //                 isVisible = true;
    //             }
    //             let apexPageName = apexPages.find(page => page.Id == item.ScontrolId)?.Name;
    //             return {... item, isVisible : isVisible, apexPageName : apexPageName}
    //         });
    //         console.log('buttons',this.buttons);
    //     } else if (error) {
    //         this.buttons = undefined;
    //         this.error = error.body.message;
    //         console.log('error',error);
    //     }
    // }

    handleMenuSelect(event){

        const value = event.detail.value;
        console.log('value',value);

        switch (value) {
            case 'Edit':
                this.handleEdit();
                break;
            case 'Delete':
                this.handleDelete();
                break;
            case 'RR_Cancel_Job_Card':
                this.openCancelJobCard();
                break;
            default:
                break;
        }
       
    }

    handleButtonClick(event){
        event.preventDefault();
        const value = event.target.value;
        const actionName = event.target.dataset.type;
        const pageURL = event.target.dataset.page;
        console.log('actionName',actionName);
        console.log('pageURL',pageURL);
        window.open(pageURL,'_blank');   
    }

    handleEdit() {
        // Navigate to the record edit page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'edit'
            }
        });
    }

    handleDelete() {
        // Delete the record
        console.log('Delete');
        return
        deleteRecord(this.recordId)
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record deleted',
                    variant: 'success'
                })
            );
            // Navigate to the object home page after delete
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Account',
                    actionName: 'home'
                }
            });
        })
        .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error deleting record',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        });
    }

    openCancelJobCard(){
        this.showCanelJobCard = true;
    }

    closeCancelJobCard(){
        this.showCanelJobCard = false;
    }
}