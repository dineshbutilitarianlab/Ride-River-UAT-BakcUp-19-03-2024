import { LightningElement } from 'lwc';

export default class DMSCaseCreationForm extends LightningElement {
    textValue;
    handleInputChange(event) {
        this.textValue = event.detail.value;
    }
    
}