import { LightningElement,api,wire,track } from 'lwc';
import getVehicleDetailsForEW from '@salesforce/apex/submitExtendedWarrantyController.getVehicleDetailsForEW';
import callTheEWAPIQueueable from '@salesforce/apex/submitExtendedWarrantyController.callTheEWAPIQueueable';
import rideRiverLogo from '@salesforce/resourceUrl/Ride_River_Logo_LWC';


import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class SubmitExtendedWarranty extends LightningElement {
    @api recordId;
    @track vehicleData=[];
    @track warrantyType='';
    @track saleOrigin='';
    @track showSpinner=false;
    @track showButton=true;
    rideRiverLogo=rideRiverLogo;
    @wire(getVehicleDetailsForEW,{recordId:'$recordId'})
    wiredData({data,error}){
        debugger;
        if(data){
            this.vehicleData = data;
            if(data.EWSubmitted == true){
                this.showButton=false;
            }
            console.log('Vehicle Data===>',data);
        }else if(error){
            console.log('Error==>',error);
        }
    }
    get warrantyTypeOptions(){
        return[
            {label:'Manufacturer Warranty',value:'Manufacturer Warranty'},
            {label:'Extended Warranty',value:'Extended Warranty'}
        ]
    }
    get saleOriginOptions(){
        return [
            {label:'Showroom',value:'Showroom'},
            {label:'Workshop',value:'Workshop'}
        ]
    }
    handleWarrantyTypeChange(event){
     this.warrantyType=event.target.value;
     console.log('WarrantyType===>',event.target.value);
    }
    
    handleSaleOriginChange(event){
     this.saleOrigin=event.target.value;
     console.log('SaleOrigin===>',event.target.value);
    }
    validateInput() {
        debugger;
        let isValid = true;
        let warrantyTypeElement = this.template.querySelector(`lightning-combobox[data-id='warrantyType']`);
        let saleOriginElement = this.template.querySelector(`lightning-combobox[data-id='saleOrigin']`);

    
        let isWarrantyTypeEmpty = !this.warrantyType; 
        let isSaleOriginEmpty = !this.saleOrigin;
    
        if (isWarrantyTypeEmpty && isSaleOriginEmpty) {
            warrantyTypeElement.setCustomValidity('Warranty Type Cannot be Blank');
            saleOriginElement.setCustomValidity('Sale Origin Cannot be Blank');
            isValid = false;
        } else if (isWarrantyTypeEmpty) {
            warrantyTypeElement.setCustomValidity('Warranty Type Cannot be Blank');
            saleOriginElement.setCustomValidity('');
            isValid = false;
        } else if (isSaleOriginEmpty) {
            saleOriginElement.setCustomValidity('Sale Origin Cannot be Blank');
            warrantyTypeElement.setCustomValidity('');
            isValid = false;
        } else {
            warrantyTypeElement.setCustomValidity('');
            saleOriginElement.setCustomValidity('');
        }
    
        warrantyTypeElement.reportValidity();
        saleOriginElement.reportValidity();
    
        return isValid;
    }
    
    handleCloseScreen(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleSubmit(){
        debugger;
        
        
            if(this.validateInput()){
                this.showSpinner=true;
                setTimeout(()=>{
                    const dataToPass = {
                        dealerCode:this.vehicleData.dealerCode,
                        purchaseDate:this.vehicleData.purchaseDate,
                        chassisNumber:this.vehicleData.chassisNumber,
                        model:this.vehicleData.model,
                        battery:this.vehicleData.battery,
                        engineNumber:this.vehicleData.engineNumber,
                        charger:this.vehicleData.engineNumber,
                        warrantyType:this.warrantyType,
                        saleOrigin:this.saleOrigin}
        
                        const dataToPassInString = JSON.stringify(dataToPass);
                        console.log('dataToPassInString===>',dataToPassInString);
        
                        callTheEWAPIQueueable({dataToPassInString:dataToPassInString,recordId:this.recordId})
                        .then((result)=>{
                            if(result == 'SUCCESS'){
                                this.showToast('Success','Extended Warranty Has Been Created','success');
                                this.handleCloseScreen();
                                //window.location.reload();
                            }else{
                                console.log('Result==>',result);
                                this.showToast('Oops!',result,'error');
                                //this.handleCloseScreen();
                            }
                             
                            // this.jobId = result;
                            // console.log('Queueable Job ID:', this.jobId);
                            // this.pollForJobCompletion();
                            this.showSpinner=false;
                            
                        })
                        .catch((error)=>{
                            console.log('error==>',error);
                            this.showSpinner=false;
                        })
                },1500)
                
           }
        
        

    }

    showToast(Title,Message,Variant){
        this.dispatchEvent(
            new ShowToastEvent({
                title:Title,
                message:Message,
                variant:Variant
            })
        )
    }
}