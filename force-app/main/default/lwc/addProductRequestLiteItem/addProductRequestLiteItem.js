/**
 * @author Dinesh Baddawar
 * @email dinesh.butilitarianlab@gmail.com
 * @create date 2024-12-10 13:11:20
 * @modify date 2025-01-20 19:44:47
 * @desc [Add ProductRequestLineItems Comp]
 */

import createProductRequestLineItems from '@salesforce/apex/ProductRequestLineController.createProductRequestLineItems';
import createPurchaseorder from '@salesforce/apex/ProductRequestLineController.createPurchaseorder';
import getLogedInUserRelatedLocationPOLI from '@salesforce/apex/ProductRequestLineController.getLogedInUserRelatedLocationPOLI';
import userId from '@salesforce/user/Id';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, track } from 'lwc';
export default class AddProductRequestLiteItem extends LightningElement {

    @api recordId;
    @track requestLineItems = [];
    @track selectedItems = [];
    //@track updatedValues = new Map();
    @track filteredRequestLineItems = [];
    @track updatedValues = new Map();
    @track selectAllChecked = false;
    showSpinner = false;
    currentUserId;
    PoCreatedRecordId;
    recordIdfromURL = '';
    @track currentPageData = [];
    currentPage = 1;
    @track recordsPerPage = 10;
    totalPages = 0;
    buttonVisible = false;

    connectedCallback() {
        debugger;
        this.currentUserId = userId;
        if (this.recordId == undefined) {
            let params = location.search
            const urlParams = new URLSearchParams(params);
            this.recordIdfromURL = urlParams.get("recordId");
        }
        this.recordId = this.recordId;
        console.log(this.recordId);
        this.callApexMethod();
    }

    closeModal() {
        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }
    callApexMethod() {
        debugger;
        this.showSpinner = true; 
        const spinnerDelay = 1000; 
        const startTime = new Date().getTime();
        getLogedInUserRelatedLocationPOLI({ loggedInUserId: this.currentUserId })
            .then((data) => {
                if (data) {
                    this.requestLineItems = data.map((res) => ({
                        Id: res.Id,
                        ProductName: res.Name,
                        ProductCode: res.ProductCode,
                        AllocatedQuantity: 0,
                        selected: false,
                        isChargesDisabled: true,
                    }));
                    this.filteredRequestLineItems = [];
                    this.error = undefined;
                } else {
                    this.filteredRequestLineItems = [];
                    this.requestLineItems = [];
                }
            })
            .catch((error) => {
                this.error = error;
                console.error('Error fetching product request items:', error);
            })
            .finally(() => {
                // Calculate the time remaining to ensure the spinner shows for at least 3 seconds
                const elapsedTime = new Date().getTime() - startTime;
                const remainingTime = Math.max(0, spinnerDelay - elapsedTime);
                setTimeout(() => {
                    this.showSpinner = false; // Hide spinner after ensuring 3 seconds have passed
                }, remainingTime);
            });
    }

    handleSearchInput(event) {
        debugger;
        const searchTerm = event.target.value.toLowerCase().trim();
        if (searchTerm) {
            this.filteredRequestLineItems = this.requestLineItems.filter(item => (
                item.ProductName.toLowerCase().startsWith(searchTerm) || item.ProductCode.toLowerCase().startsWith(searchTerm))
            );
            this.totalPages = Math.ceil(this.filteredRequestLineItems.length / this.recordsPerPage);
            this.currentPage = 1;
            this.updatePageData();
        } else if (!searchTerm) {
            this.filteredRequestLineItems = [];
            this.updatePageData();
        }
        this.selectAllChecked = this.currentPageData.every(item => item.selected);
    }

    handleDelete(event) {
        const itemId = event.target.dataset.id;
        this.currentPageData = this.currentPageData.filter(item => item.Id !== itemId);
        this.requestLineItems = this.requestLineItems.filter(item => item.Id !== itemId);
    }

    handleDeleteSelectedItem(event) {
        const itemId = event.target.dataset.id;
        const deletedItem = this.selectedItems.find(item => item.Id === itemId);
        if (deletedItem) {
            this.selectedItems = this.selectedItems.filter(item => item.Id !== itemId);
            this.selectedItems = this.selectedItems.map((item, index) => ({
                ...item,
                index: index + 1 
            }));
            this.filteredRequestLineItems.push({
                ...deletedItem,
                selected: false,
                isChargesDisabled: true 
            });
            // Sort the filtered list to maintain order
            this.filteredRequestLineItems.sort((a, b) => a.index - b.index);
            // Update pagination
            this.totalPages = Math.ceil(this.filteredRequestLineItems.length / this.recordsPerPage);
            //this.updatePageData();
        }

        this.updatePageData();
        this.selectAllChecked = this.currentPageData.every(item => item.selected);
        this.buttonVisible = this.selectedItems.length > 0;
    }

    handleQuantityChange(event) {
        debugger;
        const itemId = event.target.dataset.id;
        const updatedQuantity = parseFloat(event.target.value);
        this.selectedItems = this.selectedItems.map(item => {
            if (item.Id === itemId) {
                item.AllocatedQuantity = updatedQuantity;
            }
            return item;
        });

        this.filteredRequestLineItems = this.selectedItems.filter(item =>
            this.selectedItems.some(selectedItem => selectedItem.Id === item.Id)
        ).map(item => {
            if (item.Id === itemId) {
                return { ...item, AllocatedQuantity: updatedQuantity };
            }
            return item;
        });
    }

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSelectAll(event) {
        const isChecked = event.target.checked;
        this.selectAllChecked = isChecked;
        this.currentPageData = this.currentPageData.map(item => {
            const updatedItem = {
                ...item,
                selected: isChecked,
                isChargesDisabled: !isChecked
            };
            if (isChecked) {
                if (!this.selectedItems.find(i => i.Id === item.Id)) {
                    this.selectedItems = [...this.selectedItems, updatedItem];
                }
            } else {
                this.selectedItems = this.selectedItems.filter(i => i.Id !== item.Id);
            }
            return updatedItem;
        });

        if (isChecked) {
            this.currentPageData = [];
        }
    }

    handleCheckboxChange(event) {
        const itemId = event.target.dataset.id;
        const isChecked = event.target.checked;
        this.currentPageData = this.currentPageData.map(item => {
            if (item.Id === itemId) {
                const updatedItem = { ...item, selected: isChecked };
                if (isChecked) {
                    this.selectedItems = [
                        ...this.selectedItems,
                        { ...updatedItem, index: this.selectedItems.length + 1 }
                    ];
                } else {
                    this.selectedItems = this.selectedItems.filter(i => i.Id !== itemId);
                }
                return updatedItem;
            }
            return item;
        });

        if (isChecked) {
            this.currentPageData = this.currentPageData.filter(item => item.Id !== itemId);
        }
        if (this.selectedItems.length > 0) {
            this.buttonVisible = true;
        }
        this.selectAllChecked = this.currentPageData.every(item => item.selected);
    }

    handleUpdateProcess() {
        debugger;
        const invalidItems = this.selectedItems.filter(item => {
            return isNaN(item.AllocatedQuantity) || item.AllocatedQuantity <= 0 || item.AllocatedQuantity === '' || item.AllocatedQuantity === null;
        });
        if (invalidItems.length > 0) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please ensure all quantities are entered and greater than 0.',
                    variant: 'error'
                })
            );
            return;
        }
        const updatedItems = this.selectedItems.map(item => ({
            Id: item.Id,
            QuantityRequested: parseFloat(item.AllocatedQuantity),
            Product2Id: item.Id,
            ParentId: this.PoCreatedRecordId
        }));
        console.log('updatedItems === >' + updatedItems);
        var jsondatatopass = JSON.stringify(updatedItems);
        debugger;
        createProductRequestLineItems({ jsonData: jsondatatopass })
            .then(result => {
                if (result != null && result === 'SUCCESS') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS',
                            message: 'Records Created Successfully!',
                            variant: 'success'
                        })
                    );
                    this.updatedValues.clear();
                    this.closeModal();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error Creating records: ' + result,
                            variant: 'error'
                        })
                    );
                    this.closeModal();
                }
            })
            .catch(error => {
                console.log('Error : ' + error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Creating records: ' + error.body.message,
                        variant: 'error'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    methodToCreatePORecords(){
        debugger;
        const hasZeroQuantity = this.methodToCheckZeroQuntiry();
        if (hasZeroQuantity) {
            return;
        }
        createPurchaseorder({ shipmentType: this.recordId.shipmentType, loggedInUserId: this.recordId.loggedInUserId }).then(result => {
            if (result && result != null) {
                this.PoCreatedRecordId = result;
                this.handleUpdateProcess();
            } else {
                alert('something went wrong !');
            }
        })
        .catch(error => {
            console.log('Error = >' + error);
        })
    }

    updatePageData() {
        debugger;
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = Math.min(start + this.recordsPerPage, this.filteredRequestLineItems.length);
        console.log('start:', start, 'end:', end);
        this.currentPageData = this.filteredRequestLineItems.slice(start, end).map((item, index) => {
            return {
                ...item,
                index: start + index + 1
            };
        });
        this.selectedItems = this.selectedItems.map((item, index) => ({
            ...item,
            index: index + 1 
        }));
        console.log('start:', start, 'end:', end);
    }

    handlePreviousPage() {
        debugger;
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePageData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePageData();
        }
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    handleFirstPage() {
        debugger;
        if (this.currentPage > 1) {
            this.currentPage = 1;
            this.updatePageData();
        }
    }

    handleLastPage() {
        debugger;
        if (this.currentPage < this.totalPages) {
            this.currentPage = this.totalPages;
            this.updatePageData();
        }
    }

    get isFirstDisabled() {
        return this.currentPage === 1;
    }

    get isLastDisabled() {
        return this.currentPage === this.totalPages;
    }

    methodToCheckZeroQuntiry() {
        debugger;
        var selectedQLIList = this.filteredRequestLineItems;
        const hasZeroQuantity = selectedQLIList.some(item => item.AllocatedQuantity === 0);
        if (hasZeroQuantity) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Allocated Quantity cannot be zero.',
                    variant: 'error'
                })
            );
        }
        return hasZeroQuantity;
    }

}