/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable guard-for-in */
/* eslint-disable @lwc/lwc/no-api-reassignments */
/* eslint-disable dot-notation */
import { LightningElement, track, api } from 'lwc';
import jszip from '@salesforce/resourceUrl/JSZIps';
import getAllObject from '@salesforce/apex/mfcSomDataProvider.getAllObject';
import getAllfields from '@salesforce/apex/mfcSomDataProvider.getAllfields';
import updateFieldDatav1 from '@salesforce/apex/mfcSomDataProvider.updateFieldDatav1';
import deployZIP from '@salesforce/apex/mfcSomDataProvider.deployZIP';
import checkResult from '@salesforce/apex/mfcSomDataProvider.checkAsyncRequest';
import deleteOBR from '@salesforce/apex/mfcSomDataProvider.deleteOBR';
import getFieldNameAPI from '@salesforce/apex/mfcSomDataProvider.getFieldNameAPI';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
const OPTIONS = [];


export default class MfcSOMCreateMapping extends NavigationMixin(LightningElement) {

    @api xmlData;
    @api existingList;
    @api mName;
    count = 0;
    percentage = 1;
    searchActivity = 'SelectValueTest';
    msOptions = [];
    inputObj;
    outputObj;
    inputchildObj;
    outputchildObj;
    inputFields = [];
    outputFields = [];
    inputChildFields = [];
    outputChildFields = [];
    @track disable = true;
    @api showChild = false;
    showBool = false;
    zipData;
    selectInputObj;
    selectOutputObj;
    selectdInChildObj;
    selectdOutChildObj;
    dataResult;
    outDataResult;
    @track  deploybutton = true;
    showSpinner = false;
    usagevalue;
    savedata = [];
    savechilddata = [];
    showConfirmDialog = false;
    error;
    @track _columns = [
        { label: "Input Field", fieldName: "inputField", type: "text", isPicklist: true, options: OPTIONS },
        { label: "Output Field", fieldName: "outputfield", type: "text", isPicklist: true, options: OPTIONS },
        { type: "button-icon", typeAttributes: { iconName: "utility:delete", name: "delete"}, fixedWidth: 50 }
    ];
    @track _data = [];
    @track _childdata = [];
    @track options = [
        { label: "EligibleProgramRebateType", value: "EligibleProgramRebateType" },
        { label: "ConvertToSalesAgreement", value: "ConvertToSalesAgreement" },

    ];

    connectedCallback() {
        this.showSpinner = true;
        if (this.xmlData) {
            /*eslint dot-notation: ["error", { "allowKeywords": false }]*/
            if (this.xmlData['Mapping']) {
                if (this.xmlData['InputObject'])
                    this.selectInputObj = this.xmlData['InputObject'];

                if (this.xmlData['OutputObject'])
                    this.selectOutputObj = this.xmlData['OutputObject'];

                if (this.xmlData['childInputObject']){
                    this.selectdInChildObj = this.xmlData['childInputObject'];
                    this.showBool = true;
                }
                    

                if (this.xmlData['childOutputObject'])
                    this.selectdOutChildObj = this.xmlData['childOutputObject'];

                this.usagevalue = this.xmlData['UsageType'];
                this.usageType = this.usagevalue;
                this.getFieldAPIs(this.xmlData);
            }
        }
        getAllObject()
            .then(result => {
                let listofObjects = [];
                for (let key in result) {
                    if (Object.prototype.hasOwnProperty.call(result, key)) {
                    listofObjects.push({ label: key, value: result[key] });
                    }
                }
                this.msOptions = listofObjects;
                this.template.querySelectorAll('c-multi-select-combobox').forEach(element => {
                    if (element.label === 'Input Object') {

                        element.refreshOptions(this.msOptions, this.selectInputObj);
                    }

                    if (element.label === 'Output Object') {
                        element.refreshOptions(this.msOptions, this.selectOutputObj);
                    }

                    if(element.label === 'Input Child object'){
                        element.refreshOptions(this.msOptions, this.selectdInChildObj);
                    }

                    if(element.label === 'Output Child Object'){
                        element.refreshOptions(this.msOptions, this.selectdOutChildObj);
                    }
                });
                this.showSpinner = false;
            })
            .catch(error => {
                this.error = error;
            });



    }
    getFieldAPIs(data) {
        getFieldNameAPI({ data: JSON.stringify(data) })
            .then(result => {
                let records = [];
                if (result['Mapping']) {
                    for (let i = 0; i < result['Mapping']['inputField'].length; i++) {
                        let initRec = {};
                        initRec["inputField"] = result['Mapping']['inputField'][i].toLowerCase();
                        initRec["outputfield"] = result['Mapping']['outputField'][i].toLowerCase();
                        initRec["uid"] = i + 1;
                        records.push(initRec);
                    }
                }
                let childrecords = [];
                if (result['childMapping']) {
                    this.childMapping = true;
                    for (let i = 0; i < result['childMapping']['inputField'].length; i++) {
                        let initRec = {};
                       initRec["inputField"] =result['childMapping']['inputField'][i].toLowerCase();
                       initRec["outputfield"] = result['childMapping']['outputField'][i].toLowerCase();
                        initRec["uid"] = i + 1;
                        childrecords.push(initRec);
                    }

                }
                this._data = records;
                this._childdata = childrecords;
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleSelect(event) {
        var payload = event.detail.payload;
        if (payload.name === 'inputobj') {
            this.inputObj = payload.value;
            this.getFieldsData(payload.value, payload.name, 'parent');
        }

        else {
            this.outputObj = payload.value;
            this.getFieldsDataOutPut(payload.value, payload.name, 'parent');
        }
        if (this.inputObj && this.outputObj)
            this.mName = this.inputObj + this.outputObj;

    }

    handleChildSelect(event) {
        var payload = event.detail.payload;
        
        if (payload.name === 'inputchildobj') {
            this.inputchildObj = payload.value;
            this.getFieldsData(payload.value, payload.name, 'child');
        } else {
            this.outputchildObj = payload.value;
            this.getFieldsDataOutPut(payload.value, payload.name, 'child');
        }

    }

    getFieldsData(objName, name, mapping) {
        if (mapping === 'parent')
            this.savedata = this._data;
        else
            this.savechilddata = this._childdata;
        getAllfields({ objectName: objName })
            .then(result => {
                var options = [];
                this.dataResult = result;
                for (let key in result) {
                   options.push({ label: result[key], value: key });
                }

                if (name === 'inputobj')
                    this.inputFields = options;
                else
                    this.inputChildFields = options;

             
                if (mapping === 'parent') {
                    
                    if (this._data.length) {
                        let records = [];
                        for (let key in this._data) {
                            let initRec = {};
                            initRec["inputField"] = result[this._data[key]['inputField']];
                            initRec["outputfield"] = this._data[key]['outputfield'];
                            initRec["uid"] = this._data[key]['uid'];
                            records.push(initRec);
                        }
                        this._data = records;
                    }
                } else {
                    if (this._childdata.length) {
                        let records = [];
                        for (let key in this._childdata) {
                            let initRec = {};
                            initRec["inputField"] = result[this._childdata[key]['inputField']];
                            initRec["outputfield"] = this._childdata[key]['outputfield'];
                            initRec["uid"] =this._childdata[key]['uid'];
                            records.push(initRec);
                            

                        }
                        this._childdata = records;
                    }
                }

            })
            .catch(error => {
                this.error = error;
            });


    }

    getFieldsDataOutPut(objName, name, mapping) {
        getAllfields({ objectName: objName })
            .then(result => {
                var options = [];
                this.outDataResult = result;
                for (let key in result) {
                    options.push({ label: result[key], value: key });
                }
                if (name === 'outputobj')
                    this.outputFields = options;
                else
                    this.outputChildFields = options;
                if (mapping === 'parent') {
                    if (this._data.length) {
                        let records = [];
                        for (let key in this._data) {
                            let initRec = {};
                            initRec["inputField"] = this._data[key]['inputField'];
                            initRec["outputfield"] = result[this._data[key]['outputfield']];
                            initRec["uid"] = this._data[key]['uid'];
                            records.push(initRec);

                        }
                        this._data = records;
                    }
                } else {
                    if (this._childdata.length) {
                        let records = [];
                        for (let key in this._childdata) {
                            let initRec = {};
                            initRec["inputField"] = this._childdata[key]['inputField'];
                            initRec["outputfield"] = result[this._childdata[key]['outputfield']];
                            initRec["uid"] = this._childdata[key]['uid'];
                            records.push(initRec);

                        }
                        this._childdata = records;
                    }
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    onCheck() {
        if(this.showChild === false){
            this.showChild = true;
        }else{
            this.showChild = false;
        }
        
    }


    handleAddRow(event) {
        if (event.target.name === 'parent')
            this.template.querySelector('c-som-addrows').showScreen(this.inputFields, this.outputFields, 'parentMapping');
        else
            this.template.querySelector('c-som-addrows').showScreen(this.inputChildFields, this.outputChildFields, 'childMapping');
    }

    handleSave(event) {
        let name = event.detail.mapping;
        let payload = event.detail.value;
        let addfs = event.detail.values;
        if (name ==='parentMapping') {
            //Create data for download - parent mapping
            let newData = JSON.parse(JSON.stringify(this.savedata));
            payload.uid = this.savedata.length + 1;
            newData.push(payload);
            this.savedata = newData;
            //Create data for datatable
            let newDatas = JSON.parse(JSON.stringify(this._data));
            addfs.uid = this._data.length + 1;
            newDatas.push(addfs);
            this._data = newDatas;
        } else {
             //Create data for download - child mapping
            let newData = JSON.parse(JSON.stringify(this.savechilddata));
            payload.uid = this.savechilddata.length + 1;
            newData.push(payload);
            this.savechilddata = newData;
            //Create data for datatable
            let newDatas = JSON.parse(JSON.stringify(this._childdata));
            addfs.uid = this._childdata.length + 1;
            newDatas.push(addfs);
            this._childdata = newDatas;
        }

        this.disable = false;
        this.deploybutton = false;

    }

    handleRowAction(event) {
        if (event.detail.action.name === "delete") {
            this.deleteSelectedRow(event.detail.row, 'parent');
        } else if (event.detail.action.name === "edit") {
            //can be used for edit rows
        }
    }
    handleRowChildAction(event) {
        if (event.detail.action.name === "delete") {
            this.deleteSelectedRow(event.detail.row, 'child');
        } else if (event.detail.action.name === "edit") {
            //can be used for edit rows

        }
    }

    deleteSelectedRow(deleteRow, mapping) {
         //delete rows
        if (mapping === 'child') {
            let newData = JSON.parse(JSON.stringify(this._childdata));
            newData = newData.filter((row) => row.uid !== deleteRow.uid);
            // recalculate uids
            newData.forEach((element, index) => (element.uid = index + 1));
            this._childdata = newData;

            let newDatas = JSON.parse(JSON.stringify(this.savechilddata));
            newDatas = newDatas.filter((row) => row.uid !== deleteRow.uid);
            // recalculate uids
            newDatas.forEach((element, index) => (element.uid = index + 1));
            this.savechilddata = newDatas;
        } else {
            let newData = JSON.parse(JSON.stringify(this._data));
            newData = newData.filter((row) => row.uid !== deleteRow.uid);
            // recalculate uids
            newData.forEach((element, index) => (element.uid = index + 1));
            this._data = newData;
            let newDatas = JSON.parse(JSON.stringify(this.savedata));
            newDatas = newDatas.filter((row) => row.uid !== deleteRow.uid);
            // recalculate uids
            newDatas.forEach((element, index) => (element.uid = index + 1));
            this.savedata = newDatas;
        }
        this.disable = false;
        this.deploybutton = false;
    }
    handleChange(event) {
        this.usageType = event.detail.value;
    }

    isInputValid() {
        //Validate required inputs
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    downloadfile(deployZip) {
        //download zip file for selected mapping 
        let validRecords = [];
        let validChildRecords = [];
        //Parent Mapping
        if (this.savedata) {
            let initRec = {};
            let mapping = [];
            for (let i = 0; i < this.savedata.length; i++) {
                let data = {};
                data.inputField = this.savedata[i].inputField;
                data.outputField = this.savedata[i].outputfield;
                mapping.push(data);
            }
            initRec['mapping'] = mapping;
            initRec['inputObject'] = this.inputObj;
            initRec['outputObject'] = this.outputObj;
            validRecords.push(initRec);

        }
        //Child Mapping
        if (this.savechilddata.length) {
            let initRec = {};
            let mapping = [];
            for (let i = 0; i < this.savechilddata.length; i++) {
                let data = {};
                data.childInputField = this.savechilddata[i].inputField;
                data.childOutputField = this.savechilddata[i].outputfield;
                mapping.push(data);
            }
            initRec['mapping'] = mapping;
            initRec['inputObject'] = this.inputchildObj;
            initRec['outputObject'] = this.outputchildObj;
            validChildRecords.push(initRec);

        }

        if (this.isInputValid()) {
            this.showSpinner = true;
            updateFieldDatav1({
                parentData: JSON.stringify(validRecords),
                childData: JSON.stringify(validChildRecords),
                usageType: this.usageType,
                fileName: this.mName,
            })
                .then(result => {
                    //create Zip file and download
                    this.compressFile(result, deployZip);
                })
                .catch(error => {
                    this.error = error;
                });
        }


    }

    compressFile(result, deployZip) {
        //load JSZip to create zip file for download and deploy using metadata
        loadScript(this, jszip).then(() => {
            // eslint-disable-next-line no-undef
            let zipFile = new JSZip();
            for (let filename in result) {
                if (filename === "package.xml") {
                    zipFile.file(filename, result[filename], { base64: true });
                } else {
                    zipFile.folder("ObjectHierarchyRelationship").file(filename, result[filename], { base64: true });
                }
            }

            this.zipData = zipFile.generate();
            this.showSpinner = false;
            if (deployZip === true) {
                this.deployfile();
            } else {
                this.showToast('', 'Mappings file was downloaded.', 'success');
                let blobLink = document.createElement('a');
                blobLink.download = "objecthirarchyRelationship.zip";
                blobLink.href = 'data:application/zip;base64,' + this.zipData;
                blobLink.click();
            }
        });
    }

    deployZipFile(event) {
        if(this.existingList !==undefined){
        if(event.target.label === 'Deploy'){
            
            if(this.existingList.includes(this.mName)){
                this.showConfirmDialog = true;
            }else{
                this.downloadfile(true);
            }
        } else if(event.target.label === 'Update'){
            this.deleteMapping(this.mName);
            this.showConfirmDialog = false;
           
        }else if(event.target.label === 'Cancel'){
            this.showConfirmDialog = false;
        }
        
        }else{
            this.downloadfile(true);
        }
    }

    deleteMapping(name){
        deleteOBR({ name: name})
            .then(result => {
                this.downloadfile(true);
            })
            .catch(error => {
                this.error = error;
            });
    }
    handleCancel() {
        eval("$A.get('e.force:refreshView').fire();");
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                //apiName: 'mfc2022__Configure_Mappings',
                 apiName: 'Configure_Mappings',
            }
        });
    }
    deployfile() {
        //deploy Zip file using metadata
        this.showSpinner = true;
        this.showToast('', 'Deployment was started.', 'success');
        deployZIP({
            data: this.zipData
        })
            .then(result => {
                var intervalID = setInterval(function () {
                    this.count++;
                    this.checkResult(result.dataId);
                    if (this.count === this.percentage) {
                        //this.showSpinner = false;
                        clearInterval(intervalID);
                        this.count = 0;
                    }
                }.bind(this), 4000);
            })
            .catch(error => {
                this.error = error;
            });
    }

    checkResult(dataid) {
        // Call Apex method to check deployment status
        checkResult({ resultId: dataid }).then(data => {
            if (data.isError) {
                this.showSpinner = false;
                this.showToast('', data.errorMessage, 'error');
            } else {
                if(data.isSuccess ==='Deploying'){
                    this.showToast('', data.isSuccess, 'success');
                    this.checkResult(dataid);
                }else{
                this.showSpinner = false;
                this.showToast('', data.isSuccess, 'success');
                }
            }


        }).catch(error => {
            this.error = error;
        })
    }

    showToast(title, message, variant) {
        //show Toast Message
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,

        });
        this.dispatchEvent(event);
    }
}