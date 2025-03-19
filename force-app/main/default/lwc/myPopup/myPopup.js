import { LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';

export default class MyPopup extends LightningModal {
    closeModal() {
        this.close('close');
    }
}