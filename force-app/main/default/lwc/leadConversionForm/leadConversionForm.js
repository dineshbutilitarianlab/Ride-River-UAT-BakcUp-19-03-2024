import { LightningElement, api, track,wire } from 'lwc';
import convertLead from '@salesforce/apex/LeadConvertController.convertLead';
import getLeadDetails from '@salesforce/apex/LeadConvertController.getLeadDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
export default class LeadConversionForm extends NavigationMixin(LightningElement) {
    @api recordId; // Lead Id passed from the parent or record page
    @track lead = {};
    @track accountId; // For Account association or creation
    @track contactId; // For Contact association or creation
    @track createOpportunity = true; // Whether to create an Opportunity or not

    // Load Lead details when the component initializes
    @track urlId=null;
    @track convertValue ='Converted';
    @track accountName;
    @track isDisable = false;
    get convertOptions() {
        return [
            { label: 'Converted', value: 'Converted' },
        ];
    }

    handleConvertChange(event){
        this.convertValue = event.target.value;
    }



    @wire(CurrentPageReference)
    getStateParameters(CurrentPageReference){
        this.urlId=CurrentPageReference.state?.id;
        console.log('getStateParameters urlId: ',this.urlId);
    }

    connectedCallback() {
        this.loadLeadDetails();
    }


    loadLeadDetails() {
        getLeadDetails({ leadId: this.urlId })
            .then(result => {
                console.log('result',result);
                this.lead = result;
                this.accountName = result.Name;
                this.contactName = result.Name;
                this.opportunityName = result.Name;

            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    handleAccountChange(event) {
        this.accountId = event.detail.value; // Assuming this comes from a lookup component
    }

    handleContactChange(event) {
        this.contactId = event.detail.value; // Assuming this comes from a lookup component
    }

    handleOpportunityToggle(event) {
        this.createOpportunity = event.target.checked;
        console.log('this.createOpportunity : ',this.createOpportunity);
        if(!this.createOpportunity){
            this.isDisable = true;
        }
        else{
            this.isDisable = false;
        }
    }

    handleConvertLead() {
        convertLead({ 
            leadId: this.urlId, 
            accountId: this.accountId, 
            contactId: this.contactId, 
            createOpportunity: this.createOpportunity 
        })
        .then(() => {
            this.showToast('Success', 'Lead successfully converted!', 'success');
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: '/dms' }
            });
            // Optionally navigate to the newly created Account, Contact, or Opportunity
        })
        .catch(error => {
            this.showToast('Error', error.body.message, 'error');
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}