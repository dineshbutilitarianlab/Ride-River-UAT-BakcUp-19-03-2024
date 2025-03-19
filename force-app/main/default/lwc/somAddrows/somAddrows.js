import { LightningElement, track, api } from 'lwc';
export default class SomAddrows extends LightningElement {

    @track _columns = [];
	@track _data = [];
	@track _inputColumns;
    @track showModal = false;
	@track tempRow = {};
	@track tempRows = {};
	editMode = false;
	@api _inputField = [];
	@api _outputField = [];
	classname = 'my-class';

    @api showScreen(input, output, mapping){
        this.showModal = true;
        this._inputField = input;
        this._outputField = output;
		this._mapping =  mapping;
    }

    handleCancel() {
		this.tempRow = {};
		this.showModal = false;
		this.editMode = false;
		this.editIndex = undefined;
	}
    handleInputChange(event) {
		//this.template.querySelector('[data-id="mydiv"]').className = this.classname;
		this.tempRow[event.target.name] = event.target.value;
		if(event.target.name == 'inputField'){
			for (var i = 0; i < this._inputField.length; i++) {

                if (this._inputField[i].value == event.target.value) {
					this.tempRows[event.target.name] = this._inputField[i].label;
                }

            }
		}else{
			for (var i = 0; i < this._outputField.length; i++) {
				if (this._outputField[i].value == event.target.value) {
					this.tempRows[event.target.name] = this._outputField[i].label;
                   
                }

            }
		}


	}
    handleSave() {
		this.dispatchEvent(new CustomEvent('select', {
            
			detail: {
                'mapping' : this._mapping,
                'value' :this.tempRow,
				'values' :this.tempRows,
            }
            
        }));
		this.tempRow = {};
		this.tempRows = {};
		this.showModal = false;

	}
}