import { refreshApex } from '@salesforce/apex';
import getDynamicValues from '@salesforce/apex/AdditionalJobsRecommendedController.getDynamicValues';
import deleteWorkOrderLineItemApex from '@salesforce/apex/WorkOrderLineItemController.deleteWorkOrderLineItemApex';
import getRelatedWorkOrderLineItems from '@salesforce/apex/WorkOrderLineItemController.getRelatedWorkOrderLineItems';
import getWarrantyForJobCard from '@salesforce/apex/WorkOrderLineItemController.getWarrantyForJobCard';
import Status from "@salesforce/schema/WorkOrder.Status";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import { getRecord } from "lightning/uiRecordApi";
import { api, LightningElement, track, wire } from 'lwc';
import getAvailableQuantity from '@salesforce/apex/WorkOrderLineItemController.getAvailableQuantity';


export default class BulkInsert_JCProducts extends NavigationMixin(LightningElement) {

    @api recordId;
    keyIndex = 0;
    showProducts = true;
    showSubmitButton = true;
    showAddMoreButton = false;
    existingWorkOrderLineItems = [];
    
    @track itemList = [
        {
            id: 0,
            price: 0,
            hasError: false
        }
    ];

    @track warrantyId;
    @track showAll;
    @track showRow = false;
    @track partCategory = '';
    @track replacementType = '';
    @track picklistOptions = {};
    @track showAdditionalFields = false;
    @track showVideofield = false;
    hasErrorInList = false;


    connectedCallback() {
        debugger;
        this.fetchWarranty();
    }
    @wire(getRecord, {
        recordId: "$recordId",
        fields: [Status],
    })
    wiredWorkOrder({ error, data }) {
        if (data && data.fields.Status.value == 'Completed') {
            this.showAll = false;
        }
        else if (data) {
            this.showAll = true;
        }
    }

    fetchWarranty() {
        getWarrantyForJobCard({ workOrderId: this.recordId })
            .then(result => {
                this.warrantyId = result;
                console.log('Fetched Warranty ID: ', this.warrantyId);
            })
            .catch(error => {
                console.error('Error fetching Warranty ID:', error);
            });
    }

    toggleTemplates() {
        this.clearRows();
        this.showAll = !this.showAll;
        this.showRow = !this.showRow;
        this.showAdditionalFields = false;
        this.showVideofield = false;
        this.template.querySelectorAll('lightning-record-edit-form').forEach(form => {
            form.reset();
        });
    }
    // Columns definition for Lightning Datatable
    // columns = [
    //     {
    //         label: 'Part No',
    //         fieldName: 'partUrl',
    //         type: 'url',
    //         typeAttributes: {
    //             label: { fieldName: 'Name' },
    //             target: '_blank'
    //         },
    //         sortable: true
    //     },
    //     {
    //         label: 'Labour Code',
    //         fieldName: 'labourUrl',
    //         type: 'url',
    //         typeAttributes: {
    //             label: { fieldName: 'Labour_Name__c' },
    //             target: '_blank'
    //         },
    //         sortable: true
    //     },
    //     {
    //         label: 'Product',
    //         fieldName: 'productUrl',
    //         type: 'url',
    //         typeAttributes: {
    //             label: { fieldName: 'RR_Product__c' },
    //             target: '_blank'
    //         },
    //         sortable: true
    //     },

    //     { label: 'Quantity', fieldName: 'Quantity', type: 'Number' },
    //     { label: 'Parts Category', fieldName: 'RR_Parts_Category__c', type: 'text' },
    //     { label: 'Status', fieldName: 'Status', type: 'text' },
    //     {label:'Action',
    //         type: 'button',
    //         typeAttributes: {
    //             label: 'Delete',
    //             name: 'delete',
    //             variant: 'destructive',
    //             disabled: { fieldName: 'showDeleteButton' }
                
    //         },
    //     },
    //     /* { label: 'FFIR Number', fieldName: 'FFIR_Number__c', type: 'text' },
    //      { label: 'Photos', fieldName: 'Photos__c', type: 'text' },
    //      { label: 'Replacement Type', fieldName: 'Replacement_Type__c', type: 'text' },
    //      { label: 'Videos', fieldName: 'Videos__c', type: 'text' }*/

    // ];
    // refreshResultData;

    @wire(getRelatedWorkOrderLineItems, { workOrderId: '$recordId' })
    wiredWorkPlans(result) {
        debugger;
        this.refreshResultData = result
        if (result.data) {
            console.log('data received1>>', result.data);

            
            this.existingWorkOrderLineItems = result.data.map(Lineitem => {
                const nameUrl = Lineitem.Id ? `/${Lineitem.Id}` : '';
                const labourUrl = Lineitem.Labour_Code__c ? `/${Lineitem.Labour_Code__c}` : '';
                const productUrl = Lineitem.PricebookEntry && Lineitem.PricebookEntry.Product2Id ? `/${Lineitem.PricebookEntry.Product2Id}` : '';
                const allowedStatuses = ['New','In Progress','Re-Work','On Hold'];
                const showDeleteButton = allowedStatuses.includes(Lineitem.WorkOrder.Status);
                return {
                    WorkOrderId: Lineitem.WorkOrder ? Lineitem.WorkOrder.WorkOrderNumber : '',
                    RR_Product__c: Lineitem.PricebookEntryId ? Lineitem.PricebookEntry.Product2.Name : '',
                    //added
                    ProductCode: Lineitem.PricebookEntryId ? Lineitem.PricebookEntry.Product2.ProductCode : '',
                    Quantity: Lineitem.Quantity,
                    RR_Parts_Category__c: Lineitem.RR_Parts_Category__c,
                    Status: Lineitem.Status,
                    Name: Lineitem.LineItemNumber,
                    partUrl: nameUrl,
                    productUrl: productUrl,
                    labourUrl:labourUrl,
                    Labour_Name__c: Lineitem.Labour_Code__r ? Lineitem.Labour_Code__r.Name : '',
                    FFIR_Number__c: Lineitem.FFIR_Number__c,
                    Photos__c: Lineitem.Photos__c,
                    Replacement_Type__c: Lineitem.Replacement_Type__c,
                    Videos__c: Lineitem.Videos__c,
                    showDeleteButton: !showDeleteButton
                };
            });

        } else if (result.error) {
            console.error('Error fetching Work Plans:', result.error);
        }
    }
    columns = [
        {
            label: 'Part No',
            fieldName: 'partUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'Name' },
                target: '_blank'
            },
            sortable: true
        },
        // {
        //     label: 'Labour Code',
        //     fieldName: 'labourUrl',
        //     type: 'url',
        //     typeAttributes: {
        //         label: { fieldName: 'Labour_Name__c' },
        //         target: '_blank'
        //     },
        //     sortable: true
        // },
        {
            label: 'Product',
            fieldName: 'productUrl',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'RR_Product__c' },
                target: '_blank'
            },
            sortable: true
        },
        { label: 'Part Code', fieldName: 'ProductCode', type: 'text' },
        { label: 'Quantity', fieldName: 'Quantity', type: 'Number' },
        { label: 'Parts Category', fieldName: 'RR_Parts_Category__c', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        // {label:'Action',
        //     type: 'button',
        //     typeAttributes: {
        //         label: 'Delete',
        //         name: 'delete',
        //         variant: 'destructive',
        //         disabled: { fieldName: 'showDeleteButton' }
                
        //     },
        // },
        /* { label: 'FFIR Number', fieldName: 'FFIR_Number__c', type: 'text' },
         { label: 'Photos', fieldName: 'Photos__c', type: 'text' },
         { label: 'Replacement Type', fieldName: 'Replacement_Type__c', type: 'text' },
         { label: 'Videos', fieldName: 'Videos__c', type: 'text' }*/

    ];
    refreshResultData;

    handleRowAction(event) {
        debugger;
        const actionName = event.detail.action.name;
        const rowId = event.detail.row.partUrl.split("/")[1];
        

        console.log('Action Name==>',actionName);
        console.log('rowId===>',rowId);
    
        if(actionName === 'delete') {
            this.deleteWorkOrderLineItem(rowId);
        }
    }

    deleteWorkOrderLineItem(rowId) {
        deleteWorkOrderLineItemApex({ rowId :rowId ,workOrderId :this.recordId}) 
          
            .then(() => {

                this.showToast(true, 'Part deleted successfully.');
                return refreshApex(this.refreshResultData); 
            })
            .catch(error => {
                this.showToast(false, 'Error deleting part: ' + error.body.message);
            });
    }

    handlepicklistchange(event) {
        debugger;
        const selectedValue = event.detail.value;
        const fieldName = event.target.dataset.fieldname;
        const index = parseInt(event.target.dataset.id, 10);

        let updatedItems = [...this.itemList];

        if (fieldName === 'RR_Parts_Category__c') {

            console.log('Itemlist==>'+ this.itemList);
            //this.itemList[index].showAdditionalFields = true;

            if (selectedValue === 'Parts Warranty' || selectedValue === 'Goodwill Warranty') {
                updatedItems[index].isPartDescriptionRequired = false;
                updatedItems[index].isElectricalValueRequired = false;
                updatedItems[index].isReplacementTypeRequired = false;
            } else {
                updatedItems[index].isPartDescriptionRequired = true;
                updatedItems[index].isElectricalValueRequired = true;
                updatedItems[index].isReplacementTypeRequired = true;
            }

            if (selectedValue === 'Paid') {
                this.itemList[index].showAdditionalFields = false;

            } else {
                this.itemList[index].showAdditionalFields = true;
            }
        // } else if (fieldName === 'Replacement_Type__c') {

        //     if (selectedValue === 'Causal') {
        //         this.itemList[index].showVideofield = true;
        //     } else {
        //         this.itemList[index].showVideofield = false;
        //     }

         }

         if (fieldName === 'Replacement_Type__c') {
        // Set isElectricalValueRequired to true if "Causal" is selected, false otherwise
        this.itemList[index].isElectricalValueRequired = selectedValue === 'Causal';
    }
    }



    addRow(event, index) {
        index = parseInt(event.target.dataset.id, 10);
        ++this.keyIndex;
        let newItem = { id: this.keyIndex, code: '', showAdditionalFields: false, showVideofield: false };
        this.itemList.splice(index + 1, 0, newItem);

        console.log('add rows>>' + JSON.stringify(newItem));
    }

    handleAddMore() {
        // Clear the itemList
        this.itemList = [];
        this.clearRows();
        // Add a new record with an incremented id
        let newId = this.keyIndex + 1;
        let newItem = { id: newId, price: 0, hasError: false, showAdditionalFields: false, showVideofield: false };
        this.itemList.push(newItem);

        // Update keyIndex and button visibility
        this.keyIndex = newId;
        this.showSubmitButton = true;
        this.showAddMoreButton = false;
        this.showAdditionalFields = false;
        this.showVideofield = false;

    }

    handleProductSelection(event) {
        const index = event.target.dataset.id;
        const productId = event.target.value;
    }

    handleLabourSelection(event) {
        const index = event.target.dataset.id;
        const productId = event.target.value;
    }

    removeRow(event) {
        let index = parseInt(event.target.id, 10);
        if (this.itemList.length > 1) {
            this.itemList.splice(index, 1);
        } 
    }


    handleSubmit() {
        debugger;
        console.log('submit');
        let isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {

            isVal = isVal && element.reportValidity();
        });

        this.itemList.map((item, idx) => {
            if (item.hasError) {
                isVal = false;
            }

            if (item.Quantity > item.availableQuantity) {
                isVal = false;
                this.itemList[idx].errorMessage = `Quantity exceeds available stock (${item.availableQuantity}).`;
                this.itemList[idx].hasError = true;
            }
        });

        if (isVal) {
            // Add event listeners for success and error
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                const warrantyField = element.querySelector("lightning-input-field[data-fieldname='Warranty_Prior__c']");
                if (warrantyField) {
                    warrantyField.value = this.warrantyId;
                }
                element.submit();
            });


        } else {
            this.showToast(false, 'Validation failed. Please check the fields and try again.');
        }
    }

    handleSuccess(event) {
        this.showAll = true;
        this.showRow = false;
        this.clearRows();
        this.showToast(true, 'Record saved successfully.');
        this.showAdditionalFields = false;
        this.showVideofield = false;
        return refreshApex(this.refreshResultData);
    }

    handleError(event) {
        let fieldErrors = {};

        // Check for field errors
        if (event.detail && event.detail.output && event.detail.output.fieldErrors) {
            fieldErrors = event.detail.output.fieldErrors;

            for (let fieldName in fieldErrors) {
                if (fieldErrors.hasOwnProperty(fieldName)) {
                    const fieldError = fieldErrors[fieldName];
                    if (fieldError && fieldError.length > 0) {
                        const errorMsg = fieldError[0].message;
                        // Display the field-specific error
                        this.showToast(false, 'Error while saving record: ' + errorMsg);
                    }
                }
            }
        } else if (event.detail && event.detail.message) {
            const generalErrorMsg = event.detail.message;

            if (!fieldErrors || Object.keys(fieldErrors).length === 0) {
                this.showToast(false, 'Error: ' + generalErrorMsg);
            }
        } else if (event.detail && event.detail.output && event.detail.output.errors) {
            const apexErrors = event.detail.output.errors;

            if (apexErrors && apexErrors.length > 0) {
                apexErrors.forEach(error => {
                    const errorMsg = error.message;
                    this.showToast(false, 'Apex Error: ' + errorMsg);
                });
            }
        } else if (!event.detail || (!fieldErrors && !event.detail.message && (!event.detail.output || !event.detail.output.errors))) {
            this.showToast(false, 'An unknown error occurred. Please try again.');
        }
    }


    showToast(success, message) {
        const event = new ShowToastEvent({
            title: success ? 'Success' : 'Error',
            message: message,
            variant: success ? 'success' : 'error',
        });
        this.dispatchEvent(event);
    }



    handleProductselection(event) {
        debugger;
        const index = event.target.dataset.id;
        const productId = event.target.value;
    
        if (!productId) {
            this.itemList = this.itemList.map((item, idx) => {
                if (idx == index) {
                    return { ...item, price: '', productCode: '', errorMessage: '', hasError: false };
                }
                return item;
            });
        } else {
            getDynamicValues({ productId: productId })
                .then(result => {
                    debugger;
                    if (result && result.price && result.productCode) {
                        this.itemList = this.itemList.map((item, idx) => {
                            if (idx == index) {
                                return { ...item, price: result.price, productCode: result.productCode, errorMessage: '', hasError: false };
                            }
                            return item;
                        });
                        return getAvailableQuantity({ productId: productId, workOrderId: this.recordId });
                    }
                })
                // .then(availableQuantity => {
                //     if (availableQuantity !== -1) {
                //         this.itemList[index].availableQuantity = availableQuantity;
                //     } else {
                //         this.itemList[index].errorMessage = 'No inventory found for this product';
                //         this.itemList[index].hasError = true;
    
                //        /* const toastEvent = new ShowToastEvent({
                //             title: 'Error',
                //             message: 'No inventory found for this product.',
                //             variant: 'error',
                //         });
                //         this.dispatchEvent(toastEvent); */
                //     }
                // })
                .then(availableQuantity => {
                    this.itemList = this.itemList.map((item, idx) => {
                        if (idx == index) {
                            if (availableQuantity !== -1) {
                                return { ...item, availableQuantity: availableQuantity, errorMessage: '', hasError: false };
                            } else {
                                return { ...item, errorMessage: 'No inventory found for this product', hasError: true };
                            }
                        }
                        return item;
                    });

                    this.hasErrorInList = this.itemList.some(item => item.hasError);
                })
                .catch(error => {
                    this.itemList = this.itemList.map((item, idx) => {
                        if (idx == index) {
                            return { ...item, errorMessage: error.body.message, hasError: true };
                        }
                        return item;
                    });
    
                    const toastEvent = new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                });
        }
    }
    
    // get isSubmitDisabled() {
    //     debugger;
    //     return this.itemList.some(item => item.hasError);
    // }

    get isSubmitDisabled() {
        return this.hasErrorInList;
    }
    
    handleQuantityChange(event) {
        const index = event.target.dataset.id;
        const enteredQuantity = event.target.value;

        if (enteredQuantity <= 0) {
            this.itemList = this.itemList.map((item, idx) => {
                if (idx == index) {
                    return { ...item, errorMessage: 'Quantity must be greater than 0.', hasError: true };
                }
                return item;
            });
            return;
        }

        this.itemList = this.itemList.map((item, idx) => {
            if (idx == index) {
                if (enteredQuantity > item.availableQuantity) {
                    return { ...item, errorMessage: `Quantity exceeds available stock (${item.availableQuantity}).`, hasError: true };
                } else {
                    return { ...item, errorMessage: '', hasError: false };
                }
            }
            return item;
        });
    }

    // handleQuantityChange(event) {
    //     const index = event.target.dataset.id;
    //     const enteredQuantity = event.target.value;

       


    //     this.itemList = this.itemList.map((item, idx) => {
    //         if (idx == index) {
    //             if (enteredQuantity > item.availableQuantity) {
    //                 return { ...item, errorMessage: `Quantity exceeds available stock (${item.availableQuantity}).`, hasError: true };
    //             } else {
    //                 return { ...item, errorMessage: '', hasError: false };
    //             }
    //         }
    //         return item;
    //     });
    // }

    clearRows() {
        // Reset itemList and keyIndex
        this.itemList = [];
        this.keyIndex = 0;
        let newItem = { id: this.keyIndex, price: '', productCode: '', errorMessage: '', hasError: false };
        this.itemList = [...this.itemList, newItem];
        this.showAdditionalFields = false;
        this.showVideofield = false;
    }

    navigateToRecord(recordid) {
        this.dispatchEvent(new RefreshEvent());
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordid,
                objectApiName: 'WorkOrder',
                actionName: 'view'
            },
        });
    }

}