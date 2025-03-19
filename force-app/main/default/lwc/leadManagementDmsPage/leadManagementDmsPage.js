import { LightningElement,track,wire } from 'lwc';
import getList from '@salesforce/apex/LeadCompController.getLeads';
import NotattendedSearchLead from '@salesforce/apex/homecontroller.getLeadsList';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import getleadrecord from '@salesforce/apex/LeadCompController.getLeaddeatails';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import leadupdate from '@salesforce/apex/LeadCompController.updatelead';
import leadcancellation from '@salesforce/apex/homecontroller.leadcancelreason';
import homerideaddress from '@salesforce/apex/homecontroller.createhomeride';
import storeride from '@salesforce/apex/homecontroller.createstoreride';
import createnewfollowup from '@salesforce/apex/homecontroller.createnewfollowup';









export default class LeadManagementDmsPage extends NavigationMixin(LightningElement){
@track activeSection = 'home';

  // Getters for conditional rendering of sections
  get isHome() {
    return this.activeSection === 'home';
  }

  get isCreateNewLead() {
    return this.activeSection === 'createNewLead';
  }

  get isNewLeadList() {

    return this.activeSection === 'newLeadList';
  }

  get isNotAttendedLeads() {
   
    return this.activeSection === 'notAttendedLeads';
  }

  get isNotAttendedTestRides() {
    return this.activeSection === 'notAttendedTestRides';
  }

  get isTodaysTestRideList() {
    return this.activeSection === 'todaysTestRideList';
  }

  get isNotAttendedFollowups() {
    return this.activeSection === 'notAttendedFollowups';
  }

  get isTodaysFollowUpList() {
    return this.activeSection === 'todaysFollowUpList';
  }

  // CSS classes for active menu items
  get homeClass() {
    return this.activeSection === 'home' ? 'menu-item active' : 'menu-item';
  }

  get createNewLeadClass() {
    return this.activeSection === 'createNewLead' ? 'menu-item active' : 'menu-item';
  }

  get newLeadListClass() {
    return this.activeSection === 'newLeadList' ? 'menu-item active' : 'menu-item';
  }

  get notAttendedLeadsClass() {
    return this.activeSection === 'notAttendedLeads' ? 'menu-item active' : 'menu-item';
  }

  get notAttendedTestRidesClass() {
    return this.activeSection === 'notAttendedTestRides' ? 'menu-item active' : 'menu-item';
  }

  get todaysTestRideListClass() {
    return this.activeSection === 'todaysTestRideList' ? 'menu-item active' : 'menu-item';
  }

  get notAttendedFollowupsClass() {
    return this.activeSection === 'notAttendedFollowups' ? 'menu-item active' : 'menu-item';
  }

  get todaysFollowUpListClass() {
    return this.activeSection === 'todaysFollowUpList' ? 'menu-item active' : 'menu-item';
  }

  // Handle menu click and set the active section
  handleMenuClick(event) {
    this.activeSection = event.currentTarget.dataset.section;
    switch (this.activeSection) {
  case 'home':
    break;  // Equivalent to isHome()
  case 'createNewLead':
    return true;  // Equivalent to isCreateNewLead()
  case 'newLeadList':
    return true;  // Equivalent to isNewLeadList()
  case 'notAttendedLeads':
  this.notattendedleadlist();
  this.Notattendentleaddetailsedit=false;
this.Notattendentleaddetails=false;
this.chooseoption=null;
  this.Notattendentleadlisttable=true;
break;
  case 'notAttendedTestRides':
    return true;  // Equivalent to isNotAttendedTestRides()
  case 'todaysTestRideList':
    return true;  // Equivalent to isTodaysTestRideList()
  case 'notAttendedFollowups':
    return true;  // Equivalent to isNotAttendedFollowups()
  case 'todaysFollowUpList':
    return true;  // Equivalent to isTodaysFollowUpList()
  default:
    return false;  // If no match, return false (as the default case)
}



    
  }
   toggleSubmenu(event) {
  // Get all menu headings and submenus
  const allMenus = document.querySelectorAll('.menu-group .submenu');
  const allHeadings = document.querySelectorAll('.menu-heading');

  // Get the clicked menu heading and submenu
  const menuHeading = event.target.closest('.menu-heading');
  const submenu = menuHeading.nextElementSibling;

  // Close all other menus
  allMenus.forEach((menu) => {
    if (menu !== submenu) {
      menu.classList.remove('show'); // Hide submenu
    }
  });
  allHeadings.forEach((heading) => {
    if (heading !== menuHeading) {
      heading.classList.remove('open'); // Reset arrow rotation
    }
  });

  // Toggle the clicked menu's visibility
  submenu.classList.toggle('show');
  menuHeading.classList.toggle('open');
}
@track Notattendentleadlisttable=false;
Notattendedleadrecords;
NotattendedleadsSearchkey;
Notattendentleaddetails=false;
        selectedrow =null;

 columns = [
        { label: 'Name', fieldName: 'Name', typeAttributes: { label: { fieldName: 'Name' }, name: 'leadName', variant: 'base' } },
        { label: 'Mobile', fieldName: 'Phone', cellAttributes: { class: 'fixed-width' } },
        { label: 'Lead Age', fieldName: 'Lead_Age__c', cellAttributes: { class: 'fixed-width' } },
        {
            label: 'Action',
            type: 'button',
            initialWidth: 120,
            typeAttributes: {
                label: 'Details',
                name: 'Deatils',
                title: 'Deatils',
                variant: 'brand'
            }
        },
    ];
    notattendedleadlist() {
        getList()
            .then(result => {
                console.log('hcvsshshs=' + JSON.stringify(result));
                //  this.testridescount=result;
                // console.log('getTestRidesdetail'+(this.testridescount.length));
                this.Notattendedleadrecords = result;
                            this.Notattendentleaddetails=false;
                //consol.log('records '+this.records);
            })
            .catch(error => {
                console.log('error2');
                // this.handleErrorClick();
            })
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedrow = row;
        switch (actionName) {
            case 'Deatils':
            this.getleaddetails(this.selectedrow);
            this.Notattendentleaddetails=true;
            this.Notattendentleadlisttable=false;

                break;
            default:
        }
    }
     NotattendedleadshandleKeydown(event) {
        if (event.key === 'Enter') {  // Check if the key pressed is "Enter"
            this.NotattendedleadsSearchkey = event.target.value;
            if(this.NotattendedleadsSearchkey!=null){
            this.notattendedhandleSearchClick();
            }else{
              this.notattendedleadlist();
            }
        }
    }
notattendedhandleSearchClick(){
  NotattendedSearchLead({searchKeyword:this.NotattendedleadsSearchkey})
  .then(result=>{
this.Notattendedleadrecords=result;
  })
  .catch(error=>{
    console.log('error1');
  })
}
psname;
leadowner;
LeadAge;
leademail;
MobilePhone;
LeadStatus;
source;
LeadName;
state=null;
country=null;
postalCode=null;
city=null;
street=null;
handleChangeleadsource(event){
  this.source=event.target.value;

}
handleChangeleadstatus(event){
  this.LeadStatus=event.detail.value;
   if (this.LeadStatus == 'close lost') {
            this.lostleadtrue = true;
   
        }
}
 handleChangeleadsource(event) {
        this.source = event.detail.value;
    }
    handleleadmoblie(event) {
        this.MobilePhone = event.target.value;
    }
    handleleadcoustmerage(event) {
        this.CustomerAge = event.target.value;
    }
    handleleadeamil(event) {
        this.leademail = event.target.value
    }
   handlepsname(event){
    this.psname=event.target.value;
   }
    handlestreet(event) {
        this.street = event.target.value;
    }
    handlecity(event) {
        this.city = event.target.value;
    }
    handlepostalcode(event) {
        this.postalCode = event.target.value;
    }
    handlecountry(event) {
        this.country = event.detail.value;
    }
    handlestate(event) {
        this.state = event.detail.value;
    }
    
    handleStepClick(event) {
        const clickedStepValue = event.target.dataset.value;
        if (clickedStepValue == "close lost") {
            console.log('step=' + clickedStepValue);
            this.lostleadtrue = true;
        }

        // this.currentStep = clickedStepValue;

        this.LeadStatus = clickedStepValue;

        console.log('Selected step value: ', this.LeadStatus);
    }
    steps = [
        { label: 'New', value: 'New' },
        { label: 'Test Ride', value: 'Test Ride' },
        { label: 'Follow Up', value: 'Follow Up' },
        { label: 'Ready For Booking', value: 'Ready For booking' },
        { label: 'Convert', value: 'Convert' },
        { label: 'Close Lost', value: 'close lost' }
    ];
     leadSourceOptions = [];
    recordTypeId;
    @wire(getObjectInfo, { objectApiName: LEAD_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
        }
    }

    // Fetch picklist values for the LeadSource field
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: LEAD_SOURCE_FIELD })
    leadSourcePicklist({ data, error }) {
        if (data) {
            const leadSourceOp = data.values;
            this.leadSourceOptions = leadSourceOp.map(picklist => ({
                label: picklist.label,
                value: picklist.value
            }));



        } else if (error) {
            this.error = error;
        }
    }
    getleaddetails(recorid) {
        console.log(this.selectedrow.Id);
        getleadrecord({ leadid:this.selectedrow.Id  })
            .then(result => {
                console.log('re=' + JSON.stringify(result))
                this.recordId = result.Id;
                this.LeadName = result.Name;
                this.source = result.LeadSource;
                this.LeadStatus = result.Status;
                this.MobilePhone = result.Phone;
                this.CustomerAge = result.Customer_Age__c;
                this.LeadAge = result.Lead_Age__c;
                this.city = result.City;
                this.country = result.Country;
                this.postalCode = result.PostalCode;
                this.state = result.State;
                this.street = result.Street;
                this.leadowner = result.Owner.Name;
                this.leademail = result.Email;
                this.psname = result.PS_Name__c;
            })
            .catch(error => {
                console.log('error3');
            })
    }
   
    Handleedit(){
this.Notattendentleaddetailsedit=true;
this.Notattendentleaddetails=false;
    }
    @track Notattendentleaddetailsedit=false;
    
Notattendentleaddetailseditcancelclick(){
  this.Notattendentleaddetailsedit=false;
this.Notattendentleaddetails=true;
this.chooseoption=null;
}
handleLeadConvert() {
        console.log('navigate' + this.selectedrow.Id);
        console.log('navigate' + this.recordId);
        if (this.url.includes('my.site')) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: '/lead-conversion?id=' + this.selectedrow.Id }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'runtime_sales_lead__convertDesktopConsole'
                },
                state: {
                    leadConvert__leadId: this.selectedrow.Id //Pass your record Id here
                }
            });
        }
}
@track url;
@wire(CurrentPageReference)
    getStateParameters(CurrentPageReference) {

        this.url = window.location.origin;
    }
     Notattendentleaddetailshandlesave() {

        leadupdate({ id: this.selectedrow.Id, lead_source: this.source, phone: this.MobilePhone, Age: this.CustomerAge, email: this.leademail, city: this.city, Country: this.country, PostalCode: this.postalCode, State: this.state, Street: this.street, Status: this.LeadStatus, psname: this.psname })
            .then(result => {
               console.log('success');
               this.Notattendentleaddetails=false;
               this.Notattendentleaddetailsedit=false;
               this.Notattendentleadlisttable=true;
               this.notattendedleadlist();
               this.chooseoption=null;
            })
            .catch(error => {
                console.log('error4')
            })
    }
     get stateoptions() {
        return [
            { label: 'Andhra Pradesh', value: 'Andhra Pradesh' },
            { label: 'Arunachal Pradesh', value: 'Arunachal Pradesh' },
            { label: 'Assam', value: 'Assam' },
            { label: 'Bihar', value: 'Bihar' },
            { label: 'Chhattisgarh', value: 'Chhattisgarh' },
            { label: 'Goa', value: 'Goa' },
            { label: 'Gujarat', value: 'Gujarat' },
            { label: 'Haryana', value: 'Haryana' },
            { label: 'Himachal Pradesh', value: 'Himachal Pradesh' },
            { label: 'Jharkhand', value: 'Jharkhand' },
            { label: 'Karnataka', value: 'Karnataka' },
            { label: 'Kerala', value: 'Kerala' },
            { label: 'Madhya Pradesh', value: 'Madhya Pradesh' },
            { label: 'Maharashtra', value: 'Maharashtra' },
            { label: 'Manipur', value: 'Manipur' },
            { label: 'Meghalaya', value: 'Meghalaya' },
            { label: 'Mizoram', value: 'Mizoram' },
            { label: 'Nagaland', value: 'Nagaland' },
            { label: 'Odisha', value: 'Odisha' },
            { label: 'Punjab', value: 'Punjab' },
            { label: 'Rajasthan', value: 'Rajasthan' },
            { label: 'Sikkim', value: 'Sikkim' },
            { label: 'Tamil Nadu', value: 'Tamil Nadu' },
            { label: 'Telangana', value: 'Telangana' },
            { label: 'Tripura', value: 'Tripura' },
            { label: 'Uttar Pradesh', value: 'Uttar Pradesh' },
            { label: 'Uttarakhand', value: 'Uttarakhand' },
            { label: 'West Bengal', value: 'West Bengal' },
            { label: 'Delhi', value: 'Delhi' },
            { label: 'Jammu and Kashmir', value: 'Jammu and Kashmir' },
            { label: 'Ladakh', value: 'Ladakh' }
        ];
    }
    get countryoptions() {
        return [
            { label: 'India', value: 'India' }
        ]
    }
@track lostleadtrue=false;
leadcancelreason=null;
reasonvalue=null;
handleleadcancelreason(event){
  this.leadcancelreason=event.target.value;
}
reasonhandleChange(event){
  this.reasonvalue=event.detail.value;
}
reasonoptions = [
        { label: 'Battery not Detachable', value: 'Battery not Detachable' },
        { label: 'Lost to Competitor', value: 'Lost to Competitor' },
        { label: 'Not Interested in Buying', value: 'Not Interested in Buying' },
        { label: 'Others', value: 'Others' },
        { label: 'Out of Delivery Area', value: 'Out of Delivery Area' },
        { label: 'Pricing too High', value: 'Pricing too High' },
        { label: 'Product Quality Issues', value: 'Product Quality Issues' },
        { label: 'null', value: 'null' },
    ];
lostleadcancel(){
  this.reasonvalue=null;
  this.leadcancelreason=null;
  this.lostleadtrue=false;
  this.followoptionchoose=true;
  this.followoptionchoosevalue=null;
}
lostleadsuccess(){
  if(this.selectedrow.Lead__c==null){
     this.leadlostsave(this.selectedrow.Id);
      }else{
        this.leadlostsave(this.selectedrow.Lead__c);
      }
   this.reasonvalue=null;
  this.leadcancelreason=null;
  this.lostleadtrue=false;
  this.Notattendentleaddetailsedit=false;
       this.Notattendentleaddetails=false;
  this.Notattendentleadlisttable=true;
  this.notattendedleadlist();
}
leadlostsave(leadid){
  if (this.reasonvalue != null && this.leadcancelreason != null) {
            leadcancellation({ leadid:leadid, reason: this.reasonvalue, reasonfeedback: this.leadcancelreason })
                .then(result => {
                    console.log('sucess');
                    
                })
                .catch(error => {
                    console.log('erorr5');
                    
                })
        } else {
          const Message='please enter the data value';

        }
    }
    chooseoption=null;
    get chooseactionoptions() {
        return [
            { label: 'Test Ride', value: 'Test Ride' },
            { label: 'Follow Up', value: 'Follow up' },
        ];
    }
    ChooseAnyactionchange(event) {
        this.chooseoption = event.detail.value;

        this.ChooseAnyaction(this.chooseoption);
    }
    ChooseAnyaction(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Test Ride') {
            console.log('Option 1 was selected!');
            this.Ridetypetrue=true;
            this.followoptionchoose=false;
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
                        this.followoptionchoose=true;
            this.Ridetypetrue = false;
            this.Ridetypevale=null;
        }
    }
    @track Ridetypetrue=false
    Ridetypevale=null;
     get Ridetypeoptions() {
        return [
            { label: 'Home Test Ride', value: 'Home Ride' },
            { label: 'Store Test Ride', value: 'Store Ride' },
        ];
     }
     Ridetypeoptionschange(event) {
        this.Ridetypevale = event.detail.value;

        this.performAction(this.Ridetypevale);
    }
    performAction(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Home Ride') {
            console.log('Option 1 was selected!');
            this.Homeridetrue = true;
            this.storeridetrue=false;
        } else if (selectedValue === 'Store Ride') {
            console.log('Option 2 was selected!');
            this.Homeridetrue = false;
            this.storeridetrue=true;;
        }
    }
    @track Homeridetrue=false;
    testridehomevaluedate;
    errordateMessage;
    testridehomevaluedatehandle(event) {
        this.testridehomevaluedate = event.target.value;
        const today = this.todaysDate;
        console.log('taday=' + JSON.stringify(today))
        console.log('SELtaday=' + JSON.stringify(this.testridehomevaluedate))

        if (this.testridehomevaluedate < today) {
            this.errordateMessage = 'Please select today (or) a Future Date';
            console.log('enter' + this.errordateMessage);
        } else {
            this.errordateMessage = '';
        }

    }
    handlehomesaveClick(){
      if(this.selectedrow.Lead__c==null){
      this.homeridecreation(this.selectedrow.Id)
      }else{
        this.homeridecreation(this.selectedrow.Lead__c);
      }
                        this.Homeridetrue=false;
                      this.testridehomevaluedate=null;
                      this.Ridetypevale=null;
                      this.chooseoption=null;
                      this.Ridetypetrue=false;
                      this.Notattendentleaddetailsedit=false;
                       this.Notattendentleaddetails=false;
                       this.Notattendentleadlisttable=true;
                      this.notattendedleadlist();
    }
    homeridecreation(leadtestid){
       if (this.testridehomevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridehomevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('ldvfhbg' + this.homecountry + 'jnjndsj' + this.homeExcutiveName);
                homerideaddress({ leadid: leadtestid, testridename: this.Leadname, ridedate: this.testridehomevaluedate, street: this.street, city: this.city, state: this.state, country: this.country, postalcode: this.postalCode })
                    .then(result => {
                      
                      console.log('success');
                        
                    })
                    .catch(error => {
                        console.log('error10');
                    })
            }
        }
    }
    get todaysDate() {
        var today = new Date();
        return today.toISOString();
    }
    cancelNewTestRidehome(){
      this.Homeridetrue=false;
      this.testridehomevaluedate=null;

    }
    @track storeridetrue=false;
    testridestorevaluedate;
    handlestoresaveClick(){
      if(this.selectedrow.Lead__c==null){
      this.storeridecreation(this.selectedrow.Id)
      }else{
        this.storeridecreation(this.selectedrow.Lead__c);
      }
                        this.storeridetrue=false;
                      this.testridehomevaluedate=null;
                      this.Ridetypevale=null;
                      this.chooseoption=null;
                      this.Ridetypetrue=false;
                      this.Notattendentleaddetailsedit=false;
                       this.Notattendentleaddetails=false;
                        this.Notattendentleadlisttable=true;
                      this.notattendedleadlist();

    }
    cancelNewTestRidestrore(){
      this.storeridetrue=false;
      this.testridestorevaluedate=null;
    }
    storeridecreation(leadtestid){
     if (this.testridestorevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridestorevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('hhhh' + this.storeExcutiveName)
                storeride({ leadid:leadtestid, testridename: this.testridestorevalue, ridedate: this.testridestorevaluedate })
                    .then(result => {
                        console.log('sucess');
                        

                    })
                    .catch(error => {
                        console.log('error9')
                        
                    })
            }
        
    }
    }
        testridestorevaluedatehandle(event) {
        this.testridestorevaluedate = event.target.value;
        const today = this.todaysDate;
        //  console.log('taday='+JSON.stringify(today))
        //    console.log('SELtaday='+JSON.stringify(this.testridehomevaluedate))

        if (this.testridestorevaluedate < today) {
            this.errordateMessage = 'Please select today (or) a Future DateTime';
            console.log('enter' + this.errordateMessage);
        } else {
            this.errordateMessage = '';
        }
    }
    followoptionchoosevalue;
    @track followoptionchoose=false;
    get followoptionchooseoptions() {
        return [
            { label: 'Ready For Booking', value: 'Ready For Booking' },
            { label: 'Follow Up', value: 'Follow up' },
            { label: 'Lost', value: 'Lost' },
        ];
    }
    followoptionchoosechange(event) {
        this.followoptionchoosevalue = event.detail.value;

        this.followupoptionsinlead(this.followoptionchoosevalue);
    }
    followupoptionsinlead(selectedValue) {
        console.log('testRidefollowoptionchooseoptionsradio : ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.handleLeadConvert();
            this.followoptionchoosevalue = null;
            this.followoptionchoose = false;
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
                this.followoptionchoose = false;
            this.newfollowuptrue=true;
        } else if (selectedValue === 'Lost') {
            console.log('Option 2 was selected!');
            this.followoptionchoose = false;
            this.lostleadtrue = true;;
        }

    }
    newfollowupdate=null;
    newFollowupfeedbck=null;
    cancelfollowoptionchoose(){
      this.followoptionchoosevalue = null;
            this.followoptionchoose = false;
            this.chooseoption=null;
    }
    @track newfollowuptrue=false;
    handlenewfollowupcancelClick(){
                this.followoptionchoosevalue = null;
                  this.followoptionchoose = true;
                  this.newfollowuptrue=false;
                  this.newfollowupdate=null;
                  this.newFollowupfeedbck=null;

    }
    followupdatehandle(event) {
        this.newfollowupdate = event.target.value;
        // this.newcNowshowfollowupdate = this.today + 1;
        //console.log('followupdatehandle', this.newfollowupdate);
        if (this.newfollowupdate < this.todaysDate) {
            this.errordateMessage = 'Please select today (or) a Future Date';
            console.log('enter' + this.errordateMessage);
        } else {
            this.errordateMessage = '';
        }
    }
    followupfeedbackHandler(event) {
        this.newFollowupfeedbck = event.target.value;
    }
handlenewfollowupsaveClick(){
  if(this.selectedrow.Lead__c==null){
    console.log('leadrecord');
      this.followupcreation(this.selectedrow.Id)
      }else{
        this.followupcreation(this.selectedrow.Lead__c);
      }
                        this.storeridetrue=false;
                      this.testridehomevaluedate=null;
                      this.Ridetypevale=null;
                      this.chooseoption=null;
                      this.Ridetypetrue=false;
                      this.Notattendentleaddetailsedit=false;
                       this.Notattendentleaddetails=false;
                        this.Notattendentleadlisttable=true;
                      this.notattendedleadlist();
                      this.followoptionchoosevalue = null;
                  this.followoptionchoose = false;
                  this.newfollowuptrue=false;
                  this.newfollowupdate=null;
                  this.newFollowupfeedbck=null;

}
followupcreation(leadid){
 console.log('handlenewfollowupsaveClick');
        if (this.newfollowupdate == null) {
            console.log('null value');
        } else {
            if (this.newfollowupdate < this.todaysDate) {
                //this.todaysDate
            } else {
                createnewfollowup({ leadid:leadid, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                    .then(result => {
                        
                    })
                    .catch(error => {
                        console.log('error' + error);
                    })
            }
       
    
}
}
}