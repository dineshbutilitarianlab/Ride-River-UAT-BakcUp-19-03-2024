import { LightningElement, track } from 'lwc';
import getLogedInUserRelatedLocationPOLI from '@salesforce/apex/OrderController.getLogedInUserRelatedLocationPOLI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningModal from 'lightning/modal';
import createOrderProductLineItems from '@salesforce/apex/OrderController.createOrderProductLineItems';
import createOrderRecord from '@salesforce/apex/OrderController.createOrderRecord';
//import { CloseActionScreenEvent } from 'lightning/actions';

export default class OrderProductLwc extends LightningElement {

    //@api recordId;
    @track requestLineItems = [];
    @track selectedItems = [];
    //@track updatedValues = new Map();
    @track filteredRequestLineItems = [];
    @track updatedValues = new Map();
    @track selectAllChecked = false;
    showSpinner = false;
    //currentUserId;
    PoCreatedRecordId;
    recordIdfromURL = '';
    @track currentPageData = [];
    currentPage = 1;
    @track recordsPerPage = 10;
    totalPages = 0;
    buttonVisible = false;
    additonalDiscount;
    OrderTotal = 0;
    FinalPayableAmount = 0;

    connectedCallback() {
        debugger;

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
        debugger;
        // const closeEvent = new CustomEvent('closemodal');
        // this.dispatchEvent(closeEvent);
        this.close('close');
    }

    callApexMethod() {
        debugger;
        this.showSpinner = true;
        const spinnerDelay = 1000;
        const startTime = new Date().getTime();
        getLogedInUserRelatedLocationPOLI()
            .then((data) => {
                if (data) {
                    this.requestLineItems = data.map((res) => ({
                        Id: res.Id,
                        ProductName: res.Name,
                        ProductCode: res.ProductCode,
                        unitPirce: res.PricebookEntries[0].UnitPrice,
                        tax: res.PricebookEntries[0].IGST__c != null ? res.PricebookEntries[0].IGST__c : 0,
                        discount: res.PricebookEntries[0].Discount__c != null ? res.PricebookEntries[0].Discount__c : 0,
                        Type: res.Type__c,
                        AllocatedQuantity: 0,
                        totalBeforediscount : 0,
                        TotalAmountAfterDiscount : 0,
                        OrderTotal : 0,
                        FinalPayableAmount : 0,
                        selected: false,
                        totalPrice: 0,
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

                const elapsedTime = new Date().getTime() - startTime;
                const remainingTime = Math.max(0, spinnerDelay - elapsedTime);
                setTimeout(() => {
                    this.showSpinner = false;
                }, remainingTime);
            });
    }

    handleSearchInput(event) {
        debugger;
        const searchTerm = event.target.value.toLowerCase().trim();
        if (searchTerm) {
            this.filteredRequestLineItems = this.requestLineItems.filter(item => (
                item.ProductName.toLowerCase().startsWith(searchTerm) || item.ProductCode.toLowerCase().startsWith(searchTerm) || item.Type.toLowerCase().startsWith(searchTerm))
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
        debugger;
        const itemId = event.target.dataset.id;
        this.currentPageData = this.currentPageData.filter(item => item.Id !== itemId);
        this.requestLineItems = this.requestLineItems.filter(item => item.Id !== itemId);
    }

    handleDeleteSelectedItem(event) {
        debugger;
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

            this.filteredRequestLineItems.sort((a, b) => a.index - b.index);

            this.totalPages = Math.ceil(this.filteredRequestLineItems.length / this.recordsPerPage);

        }

        this.updatePageData();
        this.selectAllChecked = this.currentPageData.every(item => item.selected);
        this.buttonVisible = this.selectedItems.length > 0;
    }

    // handleQuantityChange(event) {
    //     debugger;
    //     const itemId = event.target.dataset.id;
    //     const updatedQuantity = parseFloat(event.target.value);
    //     let unitPrice = 0; 
    //     let tax = 0;
    //     let discount = 0;
    //     const additonalDiscount = 0;

    //     if (this.selectedItems != null) {
    //         const selectedItem = this.selectedItems.find(item => item.Id === itemId);
    //         if (selectedItem) {
    //             unitPrice = selectedItem.unitPirce;
    //             tax = selectedItem.tax;
    //             discount = selectedItem.discount;
    //         }
    //     }

    //     this.selectedItems = this.selectedItems.map(item => {
    //         if (item.Id === itemId) {
    //             // item.AllocatedQuantity = updatedQuantity;
    //             // item.totalPrice = (updatedQuantity || 0) * (unitPrice || 0);
    //             // item.totalBeforediscount = item.totalPrice + (item.totalPrice * (tax/100));
    //             // item.TotalAmountAfterDiscount = item.totalBeforediscount - discount;

    //             if(updatedQuantity != null && updatedQuantity != 0 && updatedQuantity != '' && unitPrice != null && unitPrice != 0 && unitPrice != ''){
    //                 item.totalPrice = updatedQuantity * unitPrice;
    //             }else{
    //                 item.totalPrice = unitPrice;
    //             }
                 
    //             if(item.totalPrice != 0 && item.totalPrice != null && item.totalPrice != ''){
    //                 item.totalBeforediscount = item.totalPrice + (item.totalPrice * (tax/100));
    //             }

    //             if(item.totalBeforediscount != 0 && item.totalBeforediscount != null && item.totalBeforediscount != ''){
    //                 item.TotalAmountAfterDiscount = item.totalBeforediscount - discount;
    //                 additonalDiscount = item.TotalAmountAfterDiscount;
    //             }
    //         }

    //         if(additonalDiscount != 0 && additonalDiscount != null && additonalDiscount != ''){
    //             item.OrderTotal = - additonalDiscount - item.additonalDiscount;
                
    //         }
    //         return item;
    //     });

    //     this.filteredRequestLineItems = this.selectedItems.map(item => {
    //         const totalPrice = 0;
    //         const totalAmountBD = 0;
    //         const TotalAmountAD = 0;
    //         if (item.Id === itemId) {
    //             if(updatedQuantity != null && updatedQuantity != 0 && updatedQuantity != '' && unitPrice != null && unitPrice != 0 && unitPrice != ''){
    //                 totalPrice = updatedQuantity * unitPrice;
    //             }else{
    //                 totalPrice = unitPrice;
    //             }
                 
    //             if(totalPrice != 0 && totalPrice != null && totalPrice != ''){
    //                 totalAmountBD = item.totalPrice + (item.totalPrice * (tax/100));
    //             }

    //             if(totalAmountBD != 0 && totalAmountBD != null && totalAmountBD != ''){
    //                 TotalAmountAD = item.totalBeforediscount - discount;
    //             }
                 
    //             console.log(`Item ID: ${itemId}, Updated Quantity: ${updatedQuantity}, Unit Price: ${unitPrice}, Total Price: ${totalPrice}`);
    //             return { ...item, AllocatedQuantity: updatedQuantity, totalPrice : totalPrice, totalBeforediscount: totalAmountBD, TotalAmountAfterDiscount: TotalAmountAD };
    //         }
    //         return item;
    //     });
    // }

    // handleAddtionalQty(event){
    //     debugger;
    //     this.additonalDiscount = event.target.value;

    //     this.filteredRequestLineItems.forEach(product => {
    //         product.OrderTotal = product.TotalAmountAfterDiscount - this.additonalDiscount;
    //     });
    // }


    handleQuantityChange(event) {
        debugger;
        const itemId = event.target.dataset.id;
        const updatedQuantity = parseFloat(event.target.value.trim()) || 0;
        let unitPrice = 0, tax = 0, discount = 0;
    
        if (this.selectedItems) {
            const selectedItem = this.selectedItems.find(item => item.Id === itemId);
            if (selectedItem) {
                unitPrice = selectedItem.unitPirce;
                tax = selectedItem.tax;
                discount = selectedItem.discount;
            }
        }
    
        this.selectedItems = this.selectedItems.map(item => {
            if (item.Id === itemId) {
                
                let totalPrice = (updatedQuantity === 0) ? 0 : (updatedQuantity ? updatedQuantity * unitPrice : unitPrice);
                let totalBeforediscount = totalPrice ? totalPrice + (totalPrice * (tax / 100)) : 0;
                let TotalAmountAfterDiscount = totalBeforediscount ? totalBeforediscount - discount : 0;
    
                return { 
                    ...item, 
                    AllocatedQuantity: updatedQuantity, 
                    totalPrice, 
                    totalBeforediscount, 
                    TotalAmountAfterDiscount
                };
            }
            return item;
        });
    
        this.filteredRequestLineItems = [...this.selectedItems];
        this.calculateFinalPayableAmount();
        this.handleAddtionalQty();
    }
    
    handleAddtionalQty(event) {
        debugger;
    
        // Ensure we retrieve `updatedQuantity` correctly from the selected item
        const selectedItem = this.selectedItems.find(item => item.AllocatedQuantity !== undefined);
        let updatedQuantity = selectedItem ? selectedItem.AllocatedQuantity : 0; // ✅ Fetch from stored value
    
        if (updatedQuantity !== 0 && updatedQuantity !== undefined && updatedQuantity !== '') {
            this.additonalDiscount = parseFloat(event.target.value) || 0;
        } else {
            this.additonalDiscount = 0;
        }
    
        this.calculateFinalPayableAmount();
    }
    
    
    calculateFinalPayableAmount() {
        let totalOrderAmount = this.filteredRequestLineItems.reduce((sum, item) => sum + item.TotalAmountAfterDiscount, 0);
        this.OrderTotal = totalOrderAmount;
        
            this.FinalPayableAmount = this.additonalDiscount != null ? totalOrderAmount - this.additonalDiscount : totalOrderAmount;
       
        
    }
    
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSelectAll(event) {
        debugger;
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
        debugger;
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
        console.log('UpdatedItemss:::' + JSON.stringify(updatedItems));

        createOrderProductLineItems({ jsonData: JSON.stringify(updatedItems) })
            .then(result => {
                console.log('result =>' + result);
                console.log(
                    'UpdatedItemss:::' + JSON.stringify(result))
                if (result === 'SUCCESS') {

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Records Created Successfully!',
                            variant: 'success'
                        })
                    );
                    // this.closeModal();
                    // this.dispatchEvent(new CloseActionScreenEvent());
                    this.updatedValues.clear();
                    //this.closeModal();
                    // this.close('success');
                    this.template.querySelector('c-order-product-lwc-modal')?.closeModal();
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error Creating records: ' + result,
                            variant: 'error'
                        })
                    );
                     this.template.querySelector('c-order-product-lwc-modal')?.closeModal();
                }
            })
            .catch(error => {
                console.error('Error: ', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Creating records: ' + error.body.message,
                        variant: 'error'
                    })
                );
                 this.template.querySelector('c-order-product-lwc-modal')?.closeModal();
            });
    }

    methodToCreateOrdersRecords() {
        debugger;
        createOrderRecord({ shipmentType: 'Standard', additonal : this.additonalDiscount})
            .then(result => {
                if (result) {
                    this.PoCreatedRecordId = result;
                    this.handleUpdateProcess();
                     this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Order created successfully!',
                            variant: 'success'
                        })
                    );
                //   setTimeout(() => {
                //     //this.close('success'); 
                //     this.closeScreen();
                // }, 500); 
                 window.location.href = `https://rivermobilityprivatelimited2--rruat.sandbox.my.site.com/autocloudSite/s/`;
                   
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Something went wrong!',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.error('Error: ', error);
            });
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