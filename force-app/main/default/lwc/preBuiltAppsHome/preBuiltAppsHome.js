import { LightningElement , api } from 'lwc';
import getFlowDefinitionViewList from '@salesforce/apex/GetRecordId.getFlowDefinitionView'

export default class PreBuiltAppsHome extends LightningElement {
    @api app_welcome_text = "";
    @api app_description = "Learn About and Install the Automotive Cloud Pre-Built Apps";
    @api no_flow_definition = false;
    @api flowDefinitionId = "";
  //  flowDefinitionURL;
    flowDefinitionId;


    connectedCallback() {


        getFlowDefinitionViewList()
        .then(result => {
           //console.log("flowDefinitionId from getFlowDefinitionViewList", "/builder_platform_interaction/flowBuilder.app?flowId="+result[0].ActiveVersionId);
           //console.log("flowDefinitionURL from getFlowDefinitionViewList",flowDefinitionURL);

            if (result.length) {
                this.no_flow_definition = false;
                this.flowDefinitionId = result[0].ActiveVersionId;
                this.flowDefinitionId = "/builder_platform_interaction/flowBuilder.app?flowId="+result[0].ActiveVersionId;
                console.log("flowDefinitionURL from getFlowDefinitionViewList prebuildassthome.js",this.flowDefinitionId);
            } else {
                this.no_flow_definition = true;
                this.flowDefinitionId = ""
            }
        })
    }
    

    @api value = false;
    get pass_false() {
        return false;
    }

    get pass_true() {
        return true;
    }
}