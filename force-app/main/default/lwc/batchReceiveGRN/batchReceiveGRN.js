//import getAllClaimItems from '@salesforce/apex/clainAndShipmentItemController.getAllClaimItems';
import getAllClaimItemsApproved from '@salesforce/apex/clainAndShipmentItemController.getAllClaimItemsApproved';
import updateClaimItems from '@salesforce/apex/clainAndShipmentItemController.updateClaimItems';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, api, wire } from 'lwc';

export default class BatchReceiveGRN extends LightningElement {
    @api recordId;
    isLoading=false;
    refreshData=[];
    claimList=[];
    buttonVisibility=true;
    
    @wire(getAllClaimItemsApproved,{recordId:'$recordId'})
    wiredData(result){
        this.refreshData=result;
        debugger;
        if(result.data){
            this.claimList=result.data;
            if(this.claimList[0].Claim.Create_Batch__r.Is_GRN_Received__c === true){
                console.log('this.claimList.Create_Batch__r.Is_GRN_Received__c===>',
                    this.claimList[0].Claim.Create_Batch__r.Is_GRN_Received__c);
                this.buttonVisibility=false;
            }
            
            console.log('Claim List==>',result.data);
        }else if(result.error){
            console.log('Error===>',result.error);
        }

    }
    get inputDisable(){
        return this.claimList[0].Create_Batch__r.Is_GRN_Received__c === true;
    }
    
    handleQuantityChange(event){
        debugger;
        
        const dataId=event.target.dataset.id;
        const fieldName=event.target.dataset.field;
        let updatedQuantity=event.target.value;

        if (updatedQuantity === '') {
            updatedQuantity = 0;  
        } else {
            updatedQuantity = parseFloat(updatedQuantity);
        }
    
        
        if (isNaN(updatedQuantity)) {
            updatedQuantity = 0;  
        }
        

        this.claimList=this.claimList.map((item)=>{
            if(item.Id == dataId){
                return {...item,[fieldName]:updatedQuantity}
            }
            return item;  
        })
        console.log('updated Claim List==>',this.claimList);

    }
    inputValidation() {
        let isValid = true;
        this.claimList.forEach((ClaimItem, index) => {
            const inputField = this.template.querySelector(`lightning-input[data-id="${ClaimItem.Id}"]`);
            if (ClaimItem.Received_Quantity__c > ClaimItem.Quantity_Formula__c) {
                this.showToast('Warning', 'Received Quantity Cannot be greater than Shipped Quantity', 'warning');
                inputField.setCustomValidity('Received Quantity Cannot exceed Shipped Quantity');
                inputField.reportValidity();
                isValid = false;
            } else if (ClaimItem.Received_Quantity__c < 0) {
                this.showToast('Warning', 'Received Quantity Cannot be less than Zero/Blank', 'warning');
                inputField.setCustomValidity('Received Quantity Cannot be less than Zero/Blank');
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity(''); 
                inputField.reportValidity();
            }
        });
        return isValid;
    }
    
    
    handleSubmit(){

        debugger;
        if (!this.inputValidation()) {
            return; 
        }
    
        
            this.isLoading=true;
            updateClaimItems({claimList:this.claimList,recordId:this.recordId})
            .then(result=>{
                this.showToast('Success','GRN has been received successfully','success');
                setTimeout(()=>{
                    
                    this.isLoading=false;
                    window.location.href = `/lightning/r/Create_Batch__c/${this.recordId}/view`;
                    this.handleExit();
                },2000);
                
            })
            .catch(error=>{
                this.showToast('Failure','Something went wrong!!!','error');
                this.handleExit();
            })
            .finally(()=>{
                refreshApex(this.wiredData);
            })     

    }
    handleExit(){
        this.dispatchEvent(new CloseActionScreenEvent());
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