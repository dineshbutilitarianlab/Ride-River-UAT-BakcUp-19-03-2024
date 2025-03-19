import { LightningElement,wire,api,track } from 'lwc';
import getVehicleDetails from '@salesforce/apex/AddJobCardInVehiclePageController.getVehicleDetails';
import createJobCard from '@salesforce/apex/AddJobCardInVehiclePageController.createJobCard';
import {CloseActionScreenEvent} from 'lightning/actions';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class AddJobCardInVehiclePage extends LightningElement {
    @api recordId;
    @track vehicleDetails=[];
    @track jobType='';
    @track odoMeter=0;
    @track isVisible=false;
    @wire(getVehicleDetails,{recordId:'$recordId'})
    wiredData({data,error}){
        debugger;
       if(data){
        this.vehicleDetails=data;
        if(data.mileStoneType == 'PDI' || data.mileStoneType == 'Order Received'){
            this.isVisible=true;
        }
        console.log('Data===>',data);
       }else if(error){
        console.log(error);
       }
    }
    get jobTypeOptions(){
        return[
           {label:'Paid Service' ,value:'Paid Service'},
           {label:'Warranty' ,value:'Warranty'},
           {label:'Accidental' ,value:'Accidental'},
           {label:'PDI' ,value:'PDI'}
        ]
    }
    handleChange(event){
       this.jobType=event.detail.value;
       console.log('JobType===>',this.jobType);
 
    }
    handleOdometerChange(event){
        this.odoMeter=parseInt(event.target.value);
        console.log('odo meter===>',this.odoMeter);
    }
    handleCloseScreen(){
      this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    checkValidity(){
        debugger;
        let isValid=true;
        let jobTypeElement = this.template.querySelector('lightning-combobox');
        let odoMeterElement = this.template.querySelector('lightning-input');
        if((this.jobType === null || this.jobType === '')&& (this.odoMeter === null || this.odoMeter ===''|| this.odoMeter <= 0 || isNaN(this.odoMeter))){
            jobTypeElement.setCustomValidity('Job Type Cannot Be Blank');
            jobTypeElement.reportValidity();

            odoMeterElement.setCustomValidity('Odometer Reading Cannot Be Blank or Zero');
            odoMeterElement.reportValidity();

            isValid=false;
        }else if((this.jobType === null || this.jobType === '')&& (this.odoMeter !== null || this.odoMeter !=='')){
            jobTypeElement.setCustomValidity('Job Type Cannot Be Blank');
            jobTypeElement.reportValidity();

            odoMeterElement.setCustomValidity('');
            odoMeterElement.reportValidity();

            isValid=false;
        }else if((this.odoMeter === null || this.odoMeter ==='' || this.odoMeter <= 0 || isNaN(this.odoMeter))&&(this.jobType !== null || this.jobType !== '')){
            odoMeterElement.setCustomValidity('Odometer Reading Cannot Be Blank or Zero');
            odoMeterElement.reportValidity();

            jobTypeElement.setCustomValidity('');
            jobTypeElement.reportValidity();


            isValid=false;
        }else{
            jobTypeElement.setCustomValidity('');
            jobTypeElement.reportValidity();

            odoMeterElement.setCustomValidity('');
            odoMeterElement.reportValidity();
            
            
        }
        
        return isValid;
    }
    handleSubmit(){
        debugger;
        if(this.checkValidity()){
            const jobCardDataInObject = {
                accId:this.vehicleDetails.AccountIds,
                conId:this.vehicleDetails.ContactIds,
                vehId:this.vehicleDetails.VehicleId,
                oRed:this.odoMeter,
                jobType:this.jobType
            };
            const jobCardData = JSON.stringify(jobCardDataInObject);
            console.log('jobCardData==>'+jobCardData);
            debugger;
        
                createJobCard({jobCardData:jobCardData})
                .then((result)=>{
                    console.log('result==>',result);
                    this.showToast('Success','Job Card Has Been Created','success');
                    this.handleCloseScreen();
        
                })
                .catch((error)=>{
                    let errorMessage ='Something Went Wrong!!!';
                    if(error.body && error.body.message){
                        errorMessage = error.body.message;
                    }
                    this.showToast('Error',errorMessage , 'error');
                    console.log(error);

                })
            
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