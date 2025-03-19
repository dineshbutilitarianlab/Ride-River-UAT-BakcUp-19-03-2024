import getAllTask from '@salesforce/apex/allTasksRelateToUserController.getAllTask';
import updateTask from '@salesforce/apex/allTasksRelateToUserController.updateTask';
import Id from '@salesforce/user/Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, wire } from 'lwc';

export default class AllTasksRelateToUser extends LightningElement {
    
    

   // userId='005F40000092LntIAE';
   userId=Id;
   

    

    allTaskList=[];
    
    get statusOptions(){
        return [
            {label:'Not Started',value:'Not Started'},
            {label:'In Progress',value:'In Progress'},
            {label:'Completed',value:'Completed'},
            {label:'Waiting on someone else',value:'Waiting on someone else'},
            {label:'Deferred',value:'Deferred'}
        ];
    }
    


    @wire(getAllTask)
    wiredData({data,error}){
        debugger;
        if(data){
            this.allTaskList=data;
            console.log(data);
            console.log(this.userId);
        }else if(error){
            this.allTaskList=[];
            console.log('Error occured',error);
        }
    }
    handleInputChange(event){
        const newValue = event.detail.value;
        const taskId=event.target.dataset.id;
        const fieldName=event.target.dataset.field;

        console.log('newValue:',newValue);
        console.log('taskId:',taskId);
        console.log('fieldName:',fieldName);

        for (let i = 0; i < this.allTaskList.length; i++) {
            if (this.allTaskList[i].Id === taskId) {
                this.allTaskList = this.allTaskList.map((task, index) => {
                    if (index === i) {
                        return { ...task, [fieldName]: newValue }; 
                    }
                    return task;
                });
                console.log(this.allTaskList[i]);
                break; 
            }
        }
    }
    handleUpdateProcess(){
        debugger;
        console.log(this.allTaskList);
        updateTask({allTaskList:this.allTaskList})
        .then(result=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Success',
                    message:'Task Status updated',
                    variant:'success'
                })
            )
        })
        .catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title:'Error',
                    message:'Something went wrong',
                    variant:'error'
                })
            )
        })


    }
    handleExit(){

    }
}