import { LightningElement , api } from 'lwc';


export default class FscWealthManagementHome extends LightningElement {
    @api app_welcome_text = "Welcome to Automotive Cloud Learning";
    @api app_description = "Learn About Automotive Cloud";
    
    get pass_false() {
        return false;
    }

    get pass_true() {
        return true;
    }
}