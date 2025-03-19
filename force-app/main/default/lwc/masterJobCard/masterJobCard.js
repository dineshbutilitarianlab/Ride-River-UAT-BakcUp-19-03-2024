import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MasterJobCard extends NavigationMixin(LightningElement) {
    @api recordId;
    @track currentStep = 1;
    @track steps = [
        { label: 'Step 1', value: 1 },
        { label: 'Step 2', value: 2 },
        { label: 'Step 3', value: 3 }
    
    ];
    @track showError = false;
    @track error = '';
    @track showBulkInsertWorkPlans = false;
    @track showBulkInsertJCProducts = true;
    @track showBulkInsertCustomerVoices = false;
    @track showNextButton = true;
    @track buttonlabel = 'Next';
    @track successMessage = false;

    handleChildError(event) {
        this.showError = true;
        this.error = event.detail;
    }

    handleNext() {
        // Logic to advance to the next step
        if (this.currentStep < this.steps.length) {
            this.currentStep += 1;
            this.updateCurrentComponent();
        }else{
            this.successMessage = true;
            this.showToastMessage('Success', ' Updation successfull', 'success');

            this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: recordId,
                            objectApiName: 'WorkOrder',
                            actionName: 'view'
                        },
                    })
        }
    }

    showToastMessage(title, message, variant) {
        // Show toast message to the user
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    updateCurrentComponent() {
        // Update component visibility based on currentStep
        switch(this.currentStep) {
            case 1:
                this.showBulkInsertJCProducts = true;
                this.showBulkInsertWorkPlans = false;
                this.showBulkInsertCustomerVoices = false;
                this.buttonlabel = 'Next';
                break;
            case 2:
                this.showBulkInsertJCProducts = false;
                this.showBulkInsertWorkPlans = true;
                this.showBulkInsertCustomerVoices = false;
                this.buttonlabel = 'Next';
                break;
            case 3:
                this.showBulkInsertJCProducts = false;
                this.showBulkInsertWorkPlans = false;
                this.showBulkInsertCustomerVoices = true;
                this.buttonlabel = 'Submit';
                
                break;
            default:
                break;
        }
    }

    handlePrevious(){
        this.currentStep -= 1;
        this.updateCurrentComponent();
    }
    handleCancel(){
        this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: recordId,
                            objectApiName: 'WorkOrder',
                            actionName: 'view'
                        },
                    })
    }
    handleSubmit(){

    }
}