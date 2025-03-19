import { LightningElement, track, wire } from 'lwc';
import getLeadByPhone from '@salesforce/apex/LeadController.getLeadByPhone';
import submitLeadForApproval from '@salesforce/apex/LeadController.submitLeadForApproval';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class LeadSearchTransfer extends LightningElement {
    @track phoneNumber = '';
    @track lead;
    @track error;

    handleInputChange(event) {
        this.phoneNumber = event.target.value;
    }

    handleSearch() {
        debugger;
        if (!this.phoneNumber) {
            this.showToast('Error', 'Please enter a phone number.', 'error');
            return;
        }

        getLeadByPhone({ phoneNumber: this.phoneNumber })
            .then(result => {
                
                if (result) {
                    this.lead = result;
                    this.error = undefined;
                } else {
                    this.lead = undefined;
                    this.error = 'No lead found or you already own this lead.';
                }
            })
            .catch(error => {
                this.error = error.body.message;
                this.lead = undefined;
            });
    }

    handleTransferRequest() {
        if (!this.lead || !this.lead.Id) {
            this.showToast('Error', 'No Lead found to submit for approval', 'error');
            return;
        }

        submitLeadForApproval({ leadId: this.lead.Id })
            .then(result => {
                if (result.includes('successfully')){
                    this.showToast('Success', `Lead ${this.lead.Name} transferred successfully!`, 'success');
                    window.location.href = `https://rivermobilityprivatelimited2--rruat.sandbox.my.site.com/autocloudSite/s/lead/${this.lead.Id}`;
                    this.dispatchEvent(new CloseActionScreenEvent());
                }else {
                    this.showToast('Warning', result, 'warning'); 
                }
                // if (result.includes('A transfer request has already been initiated for this Lead.')) {
                //     this.showToast('Error', 'A transfer request has already been initiated for this Lead.', 'error');
                // }else {
                //     this.showToast('Success', result, 'success');
                // }
            })
            .catch(error => {
                //this.showToast('Error', error.body ? error.body.message : 'Approval failed', 'error');
                this.showToast('Error', 'Something went wrong.', 'error');
            });
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}