/* eslint-disable vars-on-top */
/* eslint-disable guard-for-in */
import { LightningElement,wire,track } from 'lwc';
import jszip from '@salesforce/resourceUrl/JSZIps';
import retrieveMetadataItem from '@salesforce/apex/mfcSomDataProvider.retrieveMetadataItem';
import getOHMList from '@salesforce/apex/mfcSomDataProvider.getOBMfiles';
import checkResult from '@salesforce/apex/mfcSomDataProvider.checkAsyncRetriveRequest';
import parseXMLFile from '@salesforce/apex/mfcSomDataProvider.parseXMLFile';
import deleteOBR from '@salesforce/apex/mfcSomDataProvider.deleteOBR';

import {NavigationMixin} from 'lightning/navigation';

import { loadScript } from 'lightning/platformResourceLoader';

const columns = [  
    
    { label: 'Name', fieldName: 'Name' },  
    
    {type: "button", typeAttributes: {  
        label: 'View',  
        name: 'View',  
        title: 'View',  
        disabled: false,  
        value: 'view',  
        iconPosition: 'center'  
    }},  
    {type: "button-icon", typeAttributes: {  
        name: 'Delete',  
        title: 'Delete',  
        value: 'delete',  
        iconPosition: 'center' ,
        iconName: "utility:delete" ,
        iconClass: "slds-icon-text"
    }}  

];
export default class MfcSOMRetriveData extends NavigationMixin(LightningElement) {
    
    @track contacts;
    @track columns = columns;
    @track objects;
    @track error;
    @track count = 0;
    @track percentage = 1;
    @track rowName;
    @track showConfirmDialog = false;
    @track count = 0;
    @track percentage = 1;
    @track existingList;
    @track showSpinner = false;
    connectedCallback(){
        
        this.getList();
    
    }

    getList(){
        getOHMList()
        .then(result => {
            this.existingList = result;
            var records = [];
            //var result = response.getReturnValue();
           // component.set("v.existingList", result);
            for(var i in result){
                var details ={};
                details.Name = result[i];
                records.push(details);
            }
            this.objects =  records;

        })
        .catch(error => {
            this.error = error;
        });
    }

    viewRecord( event ) {  
          
        const recId =  event.detail.row.Name;  
        const actionName = event.detail.action.name;  
        this.rowName = recId;
        if ( actionName === 'Delete' ) {  
            this.showConfirmDialog = true;
           
        } else if ( actionName === 'View') {  
            this.showSpinner =  true;
            retrieveMetadataItem({
                MetaDataItem: recId
                })
                .then(result => {
                    var intervalID = setInterval(function (){
                        this.count++;
                        this.checkResult(result.dataId);
                        if (this.count === this.percentage) {
                          clearInterval(intervalID);
                          this.count =0;
                        }
                        
                    }.bind(this),4000);
                    
                }).catch(error => {
                    this.error = error;
                });
             
  
        }          
  
    } 
    checkResult(dataid) {
        // Call Apex method logic
        checkResult({asyncId: dataid}).then(data => {
            if(data.isSuccess ==="Retrieving metadata..."){
                this.checkResult(dataid);
            }else{
                this.showSpinner = false;
                var resultData = data.data;
           this.convertZIP(resultData);
            }
           
         }).catch(error => {
            console.log('error in retrive'+error);
        })
    }

    convertZIP(result){
        //Used JSZIp library unzip retrived metadata zip file.
        loadScript(this, jszip).then(() => {
            var zip1 = new JSZip(result, {base64:true});
            var zipFileNames = [];
            for(let zipfileName in zip1.files){
                zipFileNames.push(zipfileName);
                if(zipfileName !=='package.xml'){
                    this.parseFile(zip1.file(zipfileName).asText()) ;       
                }
                        
            }
            
          });
    }

    parseFile(fileData){
       parseXMLFile({data: fileData}).then(data => {
            this.showSpinner = true;
            if(data['childInputObject'])
            var showchild = true;
            var compDefinition = {
                componentDef: "c:mfcSOMCreateMapping",
                attributes: {
                    xmlData:data,
                    existingList: this.existingList,
                    mName :this.rowName,
                    showChild :showchild
                }
            };
            var encodedCompDef = btoa(JSON.stringify(compDefinition));
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/one/one.app#' + encodedCompDef
                }
            });
            this.showSpinner = false;
         }).catch(error => {
            console.log(error);
        })
    }
    openOBJComponent(event) {
        
        var compDefinition = {
            componentDef: "c:mfcSOMCreateMapping"
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
        
    }

    deleteFile(event){
        this.showConfirmDialog = false;
        deleteOBR({name: this.rowName}).then(() => {
          // eval("$A.get('e.force:refreshView').fire();");
           this.getList();
         }).catch(error => {
            console.log(error);
        })
        //eval("$A.get('e.force:refreshView').fire();");
    }
    closeBox(event){
        this.showConfirmDialog = false;
    }
}