import { LightningElement , api } from 'lwc';


export default class AdminHome extends LightningElement {
    @api app_welcome_text = "Welcome to Automotive Cloud Learning";
    @api app_description = "Learn About and Set Up Automotive Cloud Features";
    
    get pass_false() {
        return false;
    }

    get pass_true() {
        return true;
    }
}