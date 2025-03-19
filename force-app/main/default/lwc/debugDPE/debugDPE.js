/*
 * @File Name          : DebugDPE.Js
 * @Description        : 
 * @Author             : Swapna Deshpande
 * @Last Modified By   : Swapna Deshpande
 * @Last Modified On   : 
 * @Modification Log   : 
 * Ver       Date            Author            Modification
 * 1.0    04/20/2022      Swapna Deshpande    Initial Version
*/
import { LightningElement } from 'lwc';
import getDPEMetadata from '@salesforce/apex/debugDPEController.getDPEMetadata';
import getDPEList from '@salesforce/apex/debugDPEController.getDPEList';
import { NavigationMixin } from 'lightning/navigation';

export default class DebugDPE extends NavigationMixin(LightningElement) {
   accountId = '';
   showList = false;
   objects = [];
   error;
   count = 0;
   percentage = 1;
   jsondata;
   TypeOptions = [];
   resultData;

   connectedCallback() {
      //Get list of DPE present in org.
      getDPEList()
         .then(result => {
            this.objects = result;
            let options = [];
            for (let key in result) {
               if (Object.prototype.hasOwnProperty.call(result, key)) {
                  options.push({ label: result[key].MasterLabel, value: result[key].Id });

               }
            }
            this.TypeOptions = options;
            console.log(JSON.stringify(this.TypeOptions));
         })
         .catch(error => {
            this.error = error;
         });

   }
   onValueSelection(event) {

      this.showList = true;
      const selectedDPE = event.target.value;
      let currentLabel = this.objects.filter(function (option) {
         return option.Id === selectedDPE;

      });

      const selectDPEName = currentLabel[0].MasterLabel.replace(/ /g, "_");
      this.resultData = selectedDPE;
      if (selectedDPE != null) {
         getDPEMetadata({
            dpeId: selectedDPE
         })
            .then(result => {
               this.template.querySelector('c-show-d-p-e-node').jsonData(result, selectDPEName);
            }).catch(error => {
               this.error = error;
            });
      }
   }

   openVisualDPE() {
      let compDefinition = {
         componentDef: "c:visualDPE",
         attributes: {
            fileData: this.resultData,
         }
      };
      let encodedCompDef = btoa(JSON.stringify(compDefinition));
      this[NavigationMixin.Navigate]({
         type: 'standard__webPage',
         attributes: {
            url: '/one/one.app#' + encodedCompDef
         }
      }).then(generatedUrl => {
         window.open(generatedUrl, "_blank");
      });
   }


}