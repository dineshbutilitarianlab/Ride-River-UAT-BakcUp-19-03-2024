import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import fetchPDIItems from'@salesforce/apex/Check_PDI_Item_Screen_Controller.fetchPDIItems';
import updatePDIItmes from'@salesforce/apex/Check_PDI_Item_Screen_Controller.updatePDIItmes';
import generatePDIPDF from '@salesforce/apex/Check_PDI_Item_Screen_Controller.getPdfFileAsBase64String';
// import fetchVehicleRecall from '@salesforce/apex/Check_PDI_Item_Screen_Controller.fetchVehicleRecall';
// import sendRecallRequest from '@salesforce/apex/Check_PDI_Item_Screen_Controller.sendRecallRequest';

// import LABOR_CODE_FIELD from '@salesforce/schema/Vehicle_Recall__c.Labor_Code__c';
// import PART_NUMBER_FIELD from '@salesforce/schema/Vehicle_Recall__c.Part_Number__c';
// import RECALL_BYPASS_FIELD from '@salesforce/schema/Vehicle_Recall__c.Recall_Bypass__c';

import { updateRecord } from 'lightning/uiRecordApi';
import ID_FIELD from "@salesforce/schema/Vehicle.Id";
import PDI_Status_FIELD from "@salesforce/schema/Vehicle.PDI_Status_Pass__c";

export default class Check_pdi_item_screen extends LightningElement {
    @api recordId;
    @track pdiItemList = [];
    @track headers = [];
    @track allItemData = [];
    isButtonShow = false;
    isScreenAvailable = false;
    isCheckDisabled = false;
    showLoading = false;
    isPDFButtonDisabled = true;

    //Changed Record
    updatedRecords = [];

    // recall params
    showRecallModal = false;
    // fields = [LABOR_CODE_FIELD, PART_NUMBER_FIELD, RECALL_BYPASS_FIELD];
    recallVehicleId='';
    recallVehicleCreate = true;
    showModalLoading = true;

    mailSent;

    connectedCallback() {

        console.log('this.recordId : ',this.recordId);
        this.showLoading = true;
        this.isButtonShow = false;
        this.updatedRecords = [];
        let allchecked = true;
        fetchPDIItems({recordId : this.recordId})
        .then(response => {
            console.log(response);
            let allItems = response.map(item => {
                if(allchecked && item.Check__c == false) {
                    allchecked = false;
                }
                this.headers.push(item.Pre_Delivery_Inspection__r.Attribute__c);
                return {...item, InspectionType : item.Pre_Delivery_Inspection__r.Attribute__c}
            })

            this.isPDFButtonDisabled = !allchecked;
            console.log('this.isPDFButtonDisabled : ',this.isPDFButtonDisabled);

            const result = Object.groupBy(allItems, ({ InspectionType }) => InspectionType);

            let pdiChecksList = [];

            Object.keys(result).forEach((header) => {
              pdiChecksList.push({header : header, countOfData : result[header].length - 1, data : result[header]});
            });

            this.allItemData = [... pdiChecksList];
            this.showLoading = false;
            this.isScreenAvailable = this.allItemData.length > 0 ? true : false;

            console.log('this.allItemData : ',JSON.parse(JSON.stringify(this.allItemData)));
            console.log('this.allItemData : ',pdiChecksList);
        })
        .catch(error => {
            this.showLoading = false;
			console.log(error);
		})
    }

    handleCheckboxChange(event) {
        this.isButtonShow = true;
        const itemId = event.target.name;
        const header = event.target.dataset.header;
        const isChecked = event.target.checked;
        console.log(header);
        console.log(isChecked);
        console.log(itemId);
        this.allItemData = this.allItemData.map(pdi => {
            let currPDI = {... pdi};
            if (currPDI.header == header) {
                console.log('matched : ',header);
                let newData = currPDI.data.map(item => {
                    if (item.Id == itemId) {
                        this.updatedRecords.push({ ...item, Check__c: isChecked });
                        return { ...item, Check__c: isChecked };
                    }
                    return { ...item};
                })
                return { ... currPDI, data : newData};
            }
            return { ... currPDI};
        });
        console.log('this.allItemData changed: ',this.allItemData);

    }

    handleSave() {
        let allchecked = true;
        this.allItemData.forEach(pdi => {
            pdi.data.forEach(item => {
                if(allchecked && item.Check__c == false) {
                    allchecked = false;
                }
            })
        });

        if(!allchecked){
            const event = new ShowToastEvent({
                title: 'Warning',
                message: 'Please check all PDI items.',
                variant: 'warning'
            });
            this.dispatchEvent(event);
            return;
        }
        else {
            console.log('this.allItemData in save: ',this.allItemData);
            console.log('this.updatedRecords in save: ',this.updatedRecords);
    
            this.showLoading = true;
            updatePDIItmes({recordId : this.recordId})
            .then(response => {
                console.log(response);

                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Records Updated Successfully.',
                    variant: 'success'
                });
                this.dispatchEvent(event);
                this.connectedCallback();

                // Update Vehicle Recall record
                // const fields = {};
                // fields[ID_FIELD.fieldApiName] = this.recordId;
                // fields[PDI_Status_FIELD.fieldApiName] = true;
                // const recordInput = { fields };
                // updateRecord(recordInput)
                // .then(() => {
                //     const event = new ShowToastEvent({
                //         title: 'Success',
                //         message: 'Records Updated Successfully.',
                //         variant: 'success'
                //     });
                //     this.dispatchEvent(event);
                //     this.connectedCallback();
                // })
                // .catch((error) => {
                //     console.log(error);
                //     this.dispatchEvent(
                //         new ShowToastEvent({
                //         title: "Error creating record",
                //         message: error.body.message,
                //         variant: "error",
                //         }),
                //     );
                // });
            })
            .catch(error => {
                console.error(error);
                const event = new ShowToastEvent({
                    title: error.body?.pageErrors[0]?.statusCode,
                    message: error.body?.pageErrors[0]?.message,
                    variant: 'error'
                });
                this.dispatchEvent(event);
                this.showLoading = false;
            })
        }


    }

    handleCancel() {
        // Add your cancel logic here
        this.connectedCallback();
    }

    generatePDF(){
        this.showLoading = true;
        // const fileName = 'Exam Application '+this.examApplication.Rve_Registration_Number__c;
        generatePDIPDF({vehicleId : this.recordId}).then(response => {
            console.log(response);
            this.showLoading = false;
            // var strFile = "data:application/pdf;base64,"+response;
            // window.download(strFile, fileName+".pdf", "application/pdf");
            window.open(response,'_blank');

        }).catch(error => {
            this.showLoading = false;
            console.log('Error: ' +error.body.message);
        });
    }

    // recallModal(){
    //     this.showRecallModal = true;
    //     this.showModalLoading = true;
    //     sendRecallRequest({recordId : this.recordId}).then(response => {
    //         console.log('response recall request:',response);
    //         this.showModalLoading = false;
    //         this.mailSent = response;
    //     })
    //     .catch(error => {
    //         this.showModalLoading = false;
    //         console.log('Error: ' +error.body.message);
    //     });
    //     // fetchVehicleRecall({recordId : this.recordId}).then(response => {
    //     //     console.log('response recall:',response);
    //     //     this.showModalLoading = false;
    //     //     if(response != undefined && response.length > 0){
    //     //         this.recallVehicleId = response[0].Id;
    //     //         this.recallVehicleCreate = false;
    //     //     }
    //     // })
    //     // .catch(error => {
    //     //     this.showModalLoading = false;
    //     //     console.log('Error: ' +error.body.message);
    //     // });
    //     // this.showRecallModal = true;
    // }

    closeRecallModal(){
        this.showRecallModal = false;
        this.showModalLoading = false;
    }

    showNotification(titleText,messageText,variant) {
        const evt = new ShowToastEvent({
          title: titleText,
          message: messageText,
          variant: variant,
        });
        this.dispatchEvent(evt);
      }

    saveRecall(event){
        event.preventDefault(); // stop the form from submitting
        this.showModalLoading = true;
        const fields = event.detail.fields;
        if(fields.Labor_Code__c == undefined ||fields.Labor_Code__c == ''){
            this.showNotification('All Field Required','Labor Code field is required.','error');
        }
        else if(fields.Part_Number__c == undefined ||fields.Part_Number__c == ''){
            this.showNotification('All Field Required','Part Number field is required.','error');
        }
        else {
            fields.Vehicle__c = this.recordId; // Add lookup with Vehicle
            console.log('fields :',fields);
            this.template.querySelector('lightning-record-form').submit(fields);
        }
        this.showModalLoading = false;
    }
}