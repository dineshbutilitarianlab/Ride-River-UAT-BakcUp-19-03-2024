import { LightningElement } from 'lwc';
import getfieldDetails from '@salesforce/apex/EasyDPEEditController.getfieldDetails';
import updateDPE from '@salesforce/apex/EasyDPEEditController.updateDPE';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Easy_DPE_Edit_App_SubHeahder from '@salesforce/label/c.Easy_DPE_Edit_App_SubHeahder';
import easyDPEEditHeader from '@salesforce/label/c.easyDPEEditHeader';
import Easy_DPE_Edit_App_Aggr_SubHeader from '@salesforce/label/c.Easy_DPE_Edit_App_Aggr_SubHeader';
import EasyDPEEditappcheckhelptext from '@salesforce/label/c.EasyDPEEditappcheckhelptext';

export default class EasyDPEEdit extends LightningElement {

    options = [];
    optionsRebateData = [];
    optionsTransaction = [];
    optionsRebate = [];
    data = [];
    disable = false;
    disableReset = false;
    fileName;
    subHeader = Easy_DPE_Edit_App_SubHeahder;
    checkboxHelpText = EasyDPEEditappcheckhelptext;
    subAggHeader = Easy_DPE_Edit_App_Aggr_SubHeader;
    header = easyDPEEditHeader;
    areAggregate = new Map();

    obj = {
        'prop1': 'test1',
        'prop2': 'test2',
        'prop3': 'test1',
        'prop4': 'test2',
        'prop5': 'test1',
        'prop6': 'test2'
    }
    objGroup = {
        'prop1': 'test1',
        'prop2': 'test2',
        'prop3': 'test1',
        'prop4': 'test2',
        'prop5': 'test1',
        'prop6': 'test2'
    }
    areAggregates = {
        'input0': false,
        'input1': false,
        'input2': false
    }
    connectedCallback() {
        getfieldDetails()
            .then(result => {
                let listoptions = [];
                let listoptions1 = [];
                let listoptionTransF = [];
                let listoptionRebate = [];
                for (let name in result) {
                    if (Object.prototype.hasOwnProperty.call(result, name)) {
                        if (name === 'TransactionJournal') {
                            const myMap = result[name];
                            for (let key in myMap) {
                                if (Object.prototype.hasOwnProperty.call(myMap, key)) {
                                    listoptions.push({ label: myMap[key], value: key });
                                }

                            }
                        } else if (name === 'TransactionAllFields') {
                            const myMap = result[name];
                            for (let key in myMap) {
                                if (Object.prototype.hasOwnProperty.call(myMap, key)) {
                                    listoptionTransF.push({ label: myMap[key], value: key });
                                }

                            }
                        } else if (name === 'RebateMemberAllField') {
                            const myMap = result[name];
                            for (let key in myMap) {
                                if (Object.prototype.hasOwnProperty.call(myMap, key)) {
                                    listoptionRebate.push({ label: myMap[key], value: key });
                                }

                            }
                        } else {
                            const myMap = result[name];
                            for (let key in myMap) {
                                if (Object.prototype.hasOwnProperty.call(myMap, key)) {
                                    listoptions1.push({ label: myMap[key], value: key });
                                }

                            }
                        }

                    }
                }
                this.options = listoptions;
                this.optionsRebateData = listoptions1;
                this.optionsTransaction = listoptionTransF;
                this.optionsRebate = listoptionRebate;

            })
            .catch(error => {
                this.error = error;
            });
    }
    handleChange(event) {

        if (event.target.name === 'rebate') {
            this.obj.prop2 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop4, this.obj.prop6, 'Rebate', 'True');

        } else if (event.target.name === 'progress') {
            this.obj.prop1 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop3, this.obj.prop5, 'Transaction', 'True');

        } else if (event.target.name === 'progress1') {
            this.obj.prop3 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop1, this.obj.prop5, 'Transaction', 'True');

        } else if (event.target.name === 'progress2') {
            this.obj.prop5 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop3, this.obj.prop1, 'Transaction', 'True');

        } else if (event.target.name === 'rebate1') {
            this.obj.prop4 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop2, this.obj.prop6, 'Rebate', 'True');

        } else if (event.target.name === 'rebate2') {
            this.obj.prop6 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.obj.prop4, this.obj.prop2, 'Rebate', 'True');

        }

    }
    handleChangeGroup(event) {

        if (event.target.name === 'transaction') {
            this.objGroup.prop2 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop3, this.objGroup.prop4, 'Transaction', 'False');

        } else if (event.target.name === 'rebate') {
            this.objGroup.prop1 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop5, this.objGroup.prop5, 'Rebate', 'False');

        } else if (event.target.name === 'transaction1') {
            this.objGroup.prop3 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop2, this.objGroup.prop4, 'Transaction', 'False');

        } else if (event.target.name === 'rebate1') {
            this.objGroup.prop5 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop1, this.objGroup.prop6, 'Rebate', 'False');

        } else if (event.target.name === 'transaction2') {
            this.objGroup.prop4 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop2, this.objGroup.prop3, 'Transaction', 'False');


        } else if (event.target.name === 'rebate2') {
            this.objGroup.prop6 = event.detail.value;
            this.verifySelectedValues(event.detail.value, this.objGroup.prop1, this.objGroup.prop5, 'Rebate', 'False');

        }

    }
    handleInputChange(event) {
        this.fileName = event.detail.value;
    }


    handleUpdate() {
        let i = 0;
        let j = 1;
        const validData = [];
        let keys = Object.keys(this.obj);
        for (let i = 0; i < keys.length; i++) {
            let key = keys[i];
            let prop = this.obj[key];
            if (prop.toLowerCase().indexOf("test") === -1) {
                validData.push(prop);
            }

        }

        let k = validData.length / 2;
        const Wrapper = [];
        for (let ins = 0; ins < k; ins++) {
            let egCr = this.areAggregates['input' + ins];
            let inss = 'input' + ins;
            this.areAggregate.set(inss, egCr);
            let valids = [];
            valids.push(validData[i], validData[j])
            let pass =
            {
                Name: 'input' + ins,
                EgCriteria: egCr,
                values: valids
            }
            i = i + 2;
            j = j + 2;
            Wrapper.push(pass);
        }
        const obj = Object.fromEntries(this.areAggregate);
        const validDataGroup = [];
        let keyV = Object.keys(this.objGroup);
        for (let k1 = 0; k1 < keyV.length; k1++) {
            let key = keys[k1];
            let prop = this.objGroup[key];
            if (prop.toLowerCase().indexOf("test") === -1) {
                validDataGroup.push(prop);
            }

        }
        console.log('validDataGroup=' + validDataGroup);
        let counts = validDataGroup.length / 2;
        const wrapperGrp = [];
        let grps = 0;
        let grpsJ = 1;
        for (let ins = 0; ins < counts; ins++) {
            let groupData = [];
            groupData.push(validDataGroup[grps], validDataGroup[grpsJ]);

            if (groupData !== '') {
                let pass =
                {
                    Name: 'group' + ins,
                    values: groupData
                }
                wrapperGrp.push(pass);
            }
            grps = grps + 2;
            grpsJ = grpsJ + 2;

        }
        console.log(JSON.stringify(wrapperGrp), JSON.stringify(Wrapper), JSON.stringify(obj));
        updateDPE({ groupData: JSON.stringify(wrapperGrp), wrapperText: JSON.stringify(Wrapper), aggregatebyEligibiliy: JSON.stringify(obj), fullName: this.fileName })
            .then(result => {
                const jsonData = result;
                let data = JSON.stringify(jsonData, null, 4);
                let blobLink = document.createElement('a');
                if (this.fileName === '' || this.fileName === undefined) {
                    blobLink.download = 'AggregatebyMemberwithAggregateItemDetails.json'
                } else {
                    blobLink.download = this.fileName + '.json';
                }
                //blobLink.download = this.fileName+'.json';
                const blob = new Blob([data], { type: 'application/octet-stream' });
                blobLink.href = window.URL.createObjectURL(blob);
                blobLink.click();
            }).catch(error => {
                this.error = error;
            });

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

    handleChecked(event) {
        let inputs = event.target.name;
        this.areAggregates[inputs] = event.target.checked;
    }

    handleCancel() {
        this.disable =  false;
        const lwcInputFields = this.template.querySelectorAll(
            'lightning-combobox'
        );
        if (lwcInputFields) {
            lwcInputFields.forEach(field => {
                //field.reset();
                field.value = null;
            });
        }

        this.template.querySelectorAll('lightning-input').forEach(element => {
            if (element.type === 'checkbox' || element.type === 'checkbox-button') {
                element.checked = false;
            } else {
                element.value = null;
            }
        });

        this.template.querySelectorAll('lightning-input[data-id="reset"]').forEach(element => {
            element.value = null;
        });

        this.obj = {
            'prop1': 'test1',
            'prop2': 'test2',
            'prop3': 'test1',
            'prop4': 'test2',
            'prop5': 'test1',
            'prop6': 'test2'
        }
        this.objGroup = {
            'prop1': 'test1',
            'prop2': 'test2',
            'prop3': 'test1',
            'prop4': 'test2',
            'prop5': 'test1',
            'prop6': 'test2'
        }
        this.areAggregates = {
            'input0': false,
            'input1': false,
            'input2': false
        }
        this.fileName = '';

    }

    verifySelectedValues(selectedvalue, compareGroup, compareGroup0, data, aggData) {
        console.log(selectedvalue, compareGroup, compareGroup0);
        if (aggData === 'True') {
            if (data === 'Rebate') {
                if (selectedvalue === 'TotalQuantity' || selectedvalue === 'TotalTransactionAmount') {
                    this.disable = true;
                    this.showToast('Message', 'We can’t download the JSON because one or more of the specified mappings are already available in the Aggregate by Member with Aggregate Item Details template. Remove the duplicate mappings and try again.', 'Error');
                } else{
                    this.disable = false;
                }
            } else {
                if (selectedvalue === 'TransactionAmount' || selectedvalue === 'Quantity') {
                    this.disable = true
                    this.showToast('Message', 'We can’t download the JSON because one or more of the specified mappings are already available in the Aggregate by Member with Aggregate Item Details template. Remove the duplicate mappings and try again.', 'Error');
                }else{
                    this.disable = false;
                }
            }
        }
        if (compareGroup === selectedvalue || compareGroup0 === selectedvalue) {
            if (data === 'Rebate') {
                this.showToast('Message', 'You can’t map more than one Transaction Journal Field to the same Rebate Aggregate Object Field. Specify unique mappings and try again.', 'Warning');
            } else {
                this.showToast('Message', 'You can’t map a Transaction Journal Field more than one time to a Rebate Aggregate Object Field. Specify unique mappings and try again.', 'Warning');
            }
        }
    }

}