import { LightningElement, track, wire } from 'lwc';
import getList from '@salesforce/apex/LeadCompController.getLeads';
import getFllowups from '@salesforce/apex/LeadCompController.TodaysFollowUp';
import getTestRidesdetail from '@salesforce/apex/LeadCompController.getTestDriveRecords';
import Updaterescheduledate from '@salesforce/apex/LeadCompController.rescheduledate';
import completeride from '@salesforce/apex/LeadCompController.leadstatuscomplete';
import NotAttendedtestdrive from '@salesforce/apex/LeadCompController.NotAttendedtestdrives';
import NotAttendedfllowups from '@salesforce/apex/LeadCompController.NotAttendedfllowups';
import newgetLeads from '@salesforce/apex/LeadCompController.newgetLeads';
import newgetLeadsList from '@salesforce/apex/homecontroller.newgetLeadsList';
import Feedback from '@salesforce/apex/LeadCompController.followupfeedback';
import summarrywrappersetcount from '@salesforce/apex/LeadCompController.summarrywrappersetcount';
import SearchLead from '@salesforce/apex/homecontroller.getLeadsList';
import newSearchLead from '@salesforce/apex/homecontroller.newgetLeadsList';
import getleadrecord from '@salesforce/apex/LeadCompController.getLeaddeatails';
import leadupdate from '@salesforce/apex/LeadCompController.updatelead';
import bookingid from '@salesforce/apex/homecontroller.bookingid';
import createnewfollowup from '@salesforce/apex/homecontroller.createnewfollowup';
import homerideaddress from '@salesforce/apex/homecontroller.createhomeride';
import storeride from '@salesforce/apex/homecontroller.createstoreride';
import leadcancellation from '@salesforce/apex/homecontroller.leadcancelreason';
import updatedstatustestridecomplete from '@salesforce/apex/homecontroller.updatedstatustestridecomplete';
import updatefollowup from '@salesforce/apex/homecontroller.updatefollowup';
import updatedtestdrivefeedback from '@salesforce/apex/homecontroller.updatedtestdrivefeedback';
import updatedstatustestride from '@salesforce/apex/homecontroller.updatedstatustestride';
import createnewfollowuptestride from '@salesforce/apex/homecontroller.createnewfollowuptestride';
import updatetestridedl from '@salesforce/apex/homecontroller.updatedltestride';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import LightningAlert from 'lightning/alert';
import { CurrentPageReference } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';


export default class leadmanagementscreen extends NavigationMixin(LightningElement) {
    @track isHome = true;
    @track isCreateNewLead = false;
    @track isNewLeadList = false;
    @track isNotAttendedLeads = false;
    @track isNotAttendedTestRides = false;
    @track isTodaysTestRideList = false;
    @track isNotAttendedFollowups = false;
    @track isTodaysFollowUpList = false;
    @track allleadlist = false;
    NotAttendedtestdriveslistsize;
    NotAttendedfllowupslistsize;
    nlist;
    ntlist;

    // Handle sidebar menu click
    handleMenuClick(event) {
        const section = event.target.dataset.section;
        this.resetSections();
        if (section === 'home'){
             this.isHome = true;
             this.summarrywrappersetcountmethod();
        }
        else if (section === 'createNewLead') {
            this.handleNewLead();
        }
        else if (section === 'newLeadList'){
            this.records=null;
          this.isNewLeadList = true;
          this.nlist=true;
          this.ntlist=false;
    this.newgetLeadsmethod();
           this.allleadlist = true;
            this.isNotAttendedLeads = true;
           // this.leaddetails = fals
            this.edittrue = false;
            this.leaddetails=false;
            this.Searchkey=null;
    
          
        } 
        else if (section === 'notAttendedLeads') {
                      this.nlist=false;
                      this.ntlist=true;
            this.records=null;
            this.getLeadDetails();
            this.allleadlist = true;
            this.isNotAttendedLeads = true;
            this.leaddetails = false
            this.edittrue = false;
            this.Searchkey=null;
        }
        else if (section === 'notAttendedTestRides') {
            this.isNotAttendedTestRides = true;
            this.NotAttendedtestdrivesmethod();
        }
        else if (section === 'todaysTestRideList') {
            this.isTodaysTestRideList = true;
            this.getFgetTestRidesdetails()

        }
        else if (section === 'notAttendedFollowups') {
            this.isNotAttendedFollowups = true;
            this.NotAttendedfllowupsmethod();
        }
        else if (section === 'todaysFollowUpList') {
            this.isTodaysFollowUpList = true;
            this.getFollowupdetails();
        }
    }

    resetSections() {
        this.isHome = false;
        this.isCreateNewLead = false;
        this.isNewLeadList = false;
        this.isNotAttendedLeads = false;
        this.isNotAttendedTestRides = false;
        this.isTodaysTestRideList = false;
        this.isNotAttendedFollowups = false;
        this.isTodaysFollowUpList = false;
    }
        handleKeydown(event) {
        if (event.key === 'Enter') {  // Check if the key pressed is "Enter"
            this.Searchkey = event.target.value;
            this.handleSearchClick();
        }
    }


    // Computed classes for active styling
    get homeClass() { return this.isHome ? 'menu-item active' : 'menu-item'; }
    get createNewLeadClass() { return this.isCreateNewLead ? 'menu-item active' : 'menu-item'; }
    get newLeadListClass() { return this.isNewLeadList ? 'menu-item active' : 'menu-item'; }
    get notAttendedLeadsClass() { return this.isNotAttendedLeads ? 'menu-item active' : 'menu-item'; }
    get notAttendedTestRidesClass() { return this.isNotAttendedTestRides ? 'menu-item active' : 'menu-item'; }
    get todaysTestRideListClass() { return this.isTodaysTestRideList ? 'menu-item active' : 'menu-item'; }
    get notAttendedFollowupsClass() { return this.isNotAttendedFollowups ? 'menu-item active' : 'menu-item'; }
    get todaysFollowUpListClass() {
        //   this.getFollowupdetails();
    }
    @track paginatedData = [];
    @track isShowModal = false;
    @track isshowTestRideModal = false;
    @track Rescheduledate = false;
    @track showcancelModal = false;
    @track cancelreason;
    datevalue;
    flowApiName = 'Follow_Up_Record_Creation';
    flowApiNameTestRide = 'Test_Drive_Record_Creation';
    @track shownewfollowupModal = false;
    @track Followupname;
    @track Followupdate;
    @track showFeedbackModal = false;
    @track showTestRideFeedbackModal = false;
    @track FeedbackValue;
    @track recordId;
    @track bRecordFound = true;
    @track btestRideRecordFound = true;
    @track leaddetailspageopen = false;
    @track leaddetails = false;
    @track ifFollowUp = false;
    @track ifTesTRideUp = false;
    @track selectedLeadId = '';
    @track data;
    @track dataFolloUp;
    @track datatestRides;
    @track edittrue = false;
    @track isConvert = true;
    @track followUpId;
    @track typevalue;
    newFollowupfeedbck;
    Searchkey = '';
    @track selectedrow;
    LeadAge;
    CustomerAge
    MobilePhone;
    LeadSource;
    Status
    @track source;
    LeadName;
    leademail;
    @track city;
    @track country;
    @track postalCode;
    @track state;
    @track street;
    LeadStatus;
    @track PreviousFeedBackValue = '';
    @track newFollowUpFeedBack = '';
    @track records = [];
    @track currentPage = 1;
    pageSize = 10;
    @track Allleads = true;
    @track searchlead = false;
    @track Ridetypetrue = false;
    @track Ridetypevale = '';
    @track chooseoption = '';
    @track followoptionchoosevalue = '';
    @track followoptionchoose = false;
    @track readyforbookingoptiontrue = false;
    @track newcNowshowfollowupdate;
    bookingId;
    phone;
    cretatedDate;
    @track bookedtrue = false
    newfollowupdate;
    newfollowupname;
    testridestorevaluedate;
    testridestorevalue;
    testridehomevalue;
    testridehomevaluedate;
    @track homestreet = '';
    @track homecity = '';
    @track homecountry = '';
    @track homepostalCode = '';
    @track homestate = '';
    testridescount = [];
    followupscount;
    @track storeIndemnity;
    @track homeIndemnity = false;
    leadowner;
    storedlnumber;
    homedlnumber;
    @track errorMessage = '';
    errordateMessage = '';
    homeExcutiveName;
    storeExcutiveName;
    @track todayfollowupchooseoptionsvalue = null;
    @track newfollowupModal = false;
    leadcancelreason = null;
    @track lostleadtrue = false;
    reasonvalue = null;
    @track istart = false;
    @track homerideAddress = false;
    newleads;
    psname;
    NotAttendedtestdriveslist = [];
    NotAttendedfllowupslist = [];
    newleadscount;
    notattentedleadscount;
    todaytestrides;
    notattendedtestrides;
    todayfollowups;
    notattendedfollowups;
    newstatusleads;
    testrideleads;
    followupleads;
    readyforbookingleads;
    convertleads;
    closelostleads;

summarrywrappersetcountmethod(){
    console.log('entering')
    summarrywrappersetcount()
    .then(result=>{
        console.log('success');
this.newleadscount=result.Newleads;
this.notattentedleadscount=result.Notattendedleads;
this.todaytestrides=result.todayTestRide
this.notattendedtestrides=result.notattendedTestRide;
this.todayfollowups=result.todayfolloups
this.notattendedfollowups=result.notattenedfolloups
this.newstatusleads=result.newstatusleads
this.testrideleads=result.testrideleads
this.followupleads=result.followupLead
this.readyforbookingleads=result.readyforbbokingleads
this.convertleads=result.convertleads
this.closelostleads=result.clostlostleads;
console.log('eummary'+JSON.stringify(result));
    })
    .catch(error=>{
        console.log('error');
    })

}




    NotAttendedtestdrivesmethod() {
        NotAttendedtestdrive()
            .then(result => {
                console.log('sucess');
                  let arrdata = [];

                let valueArr = result;
                for (let i = 0; i < valueArr.length; i++) {
                    console.log('valueArr[i].MobilePhone__c>>>>' + JSON.stringify(valueArr[i].MobilePhone__c));
                    let value = {
                        LeadName: valueArr[i].Lead__c ? valueArr[i].Lead__r.Name : '',
                        Mobile: valueArr[i].MobilePhone__c ? valueArr[i].MobilePhone__c : '',
                        Ride_Type__c: valueArr[i].Ride_Type__c ? valueArr[i].Ride_Type__c : '',
                        Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Lead_Age__c : '',
                        //  datandtime: valueArr[i].Test_Drive_Date__c ? valueArr[i].Test_Drive_Date__c : '',
                        Indemnity__c: valueArr[i].Indemnity__c ? valueArr[i].Indemnity__c : '',
                        Drivers_License_Number__c: valueArr[i].Drivers_License_Number__c ? valueArr[i].Drivers_License_Number__c : '',
                        TestRideTime: this.convertToIST(valueArr[i].Test_Ride_Date__c),
                        Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        TestRideId: valueArr[i].Id,
                        //  TestRideTime: this.convertToIST(TestRideTime)

                    }
                    console.log('phone=' + JSON.stringify(value.TestRideTime));

                    arrdata.push(value);
                    this.recordId = valueArr[i].Id ? valueArr[i].Id : '';
                }


                this.NotAttendedtestdriveslist = arrdata;
                this.NotAttendedtestdriveslistsize = arrdata.length;

            })
            .catch(error => {
                console.log('error');
            })
    }
    NotAttendedfllowupsmethod() {
        NotAttendedfllowups()
            .then(result => {
                console.log('sucess');
                 let valueArr = result;
                let dataWhenfollowUp = [];
                let arrData = [];
                for (let i = 0; i < valueArr.length; i++) {
                    let val = {
                        LeadName: valueArr[i].Lead__c ? valueArr[i].Lead__r.Name : '',
                        Veiw_lead: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Lead_Age__c : '',
                        FollowupDate: this.followupconvertToIST(valueArr[i].Follow_Up_Date__c),
                        Follow_Up__c: valueArr[i].Follow_Up__c ? valueArr[i].Follow_Up__c : '',
                        // Folllow_Up1_Summary__c: valueArr[i].Folllow_Up1_Summary__c ? valueArr[i].Folllow_Up1_Summary__c : '',
                        // Previousfollowupdate: result.oldValue[valueArr[i].Id] ? result.oldValue[valueArr[i].Id].OldValue : '',
                        Previous_Feedback__c: valueArr[i].Feedback__c ? valueArr[i].Feedback__c : '',
                        Previous_Followup_date__c: this.followupconvertToIST(valueArr[i].Previous_Followup_date__c),
                        Subject: valueArr[i].Subject__c ? valueArr[i].Subject__c : '',
                        FollupId: valueArr[i].Id,
                        Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        Phone__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Phone__c : '',
                        Country: valueArr[i].Lead__c ? valueArr[i].Lead__r.Country : '',
                        State: valueArr[i].Lead__c ? valueArr[i].Lead__r.State : '',
                        City: valueArr[i].Lead__c ? valueArr[i].Lead__r.City : '',
                        Street: valueArr[i].Lead__c ? valueArr[i].Lead__r.Street : '',
                        PostalCode: valueArr[i].Lead__c ? valueArr[i].Lead__r.PostalCode : ''


                    }
                    console.log('phone=' + JSON.stringify(val.Country));
                    arrData.push(val);

                    this.recordId = valueArr[i].Lead__c ? valueArr[i].Lead__c : '';

                    /* 
                    this.followUpsId = result[i].Id ? result[i].Id : '';
                    console.log('followUpsId : ',this.followUpsId); */
                }
                console.log('OUTPUT : ', arrData);

                this.NotAttendedfllowupslist = arrData
               
              this.NotAttendedfllowupslistsize = arrData.length;

            })
            .catch(error => {
                console.log('error');
            })
    }
    newgetLeadsmethod() {
        newgetLeads()
            .then(result => {
                console.log('sucess');
                this.records = result;
            })
            .catch(error => {
                console.log('error');
            })
    }
    newleadhandleSearchClick() {
        newgetLeadsList()
            .then(result => {
                console.log('sucess');
                this.records = result;
            })
            .catch(error => {
                console.log('error');
            })
    }

    @track url = '';
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
    handlepsname(event) {
        this.psname = event.target.value;
    }
    @wire(CurrentPageReference)
    getStateParameters(CurrentPageReference) {

        this.url = window.location.origin;
    }

    connectedCallback() {
        //  this.loadLeadDetails();
        this.fetchLeadSourceOptions();
        
    }

    handlehomeExcutiveName(event) {
        this.homeExcutiveName = event.target.value;
        console.log(this.homeExcutiveName);
    }
    handlestoreExcutiveName(event) {
        this.storeExcutiveName = event.target.value;
    }

    homehandledlnumber(event) {
        this.homedlnumber = event.target.value;
        //  const regex = /^[A-Z]{2}\d{2}\d{4}\d{7}$/;
        // if (!regex.test(this.homedlnumber.replace(/[-\s]/g, ''))) {
        //     this.errorMessage = 'Invalid driving license format. Please use the format: SS-RR-YYYY-NNNNNNN.';
        // } else {
        //     this.errorMessage = '';
        // }
    }
    storehandledlnumber(event) {
        this.storedlnumber = event.target.value;
        //  const regex = /^[A-Z]{2}\d{2}\d{4}\d{7}$/;
        // if (!regex.test(this.storedlnumber.replace(/[-\s]/g, ''))) {
        //     this.errorMessage = 'Invalid driving license format. Please use the format: SS-RR-YYYY-NNNNNNN.';
        // } else {
        //     this.errorMessage = '';
        // }
    }
    handleleadowner(event) {
        this.leadowner = event.target.value;
    }
    handlehomeCheckboxChange(event) {
        this.homeIndemnity = event.target.checked;
        console.log(this.homeIndemnity);
    }
    handlestoreCheckboxChange(event) {
        this.storeIndemnity = event.target.unchecked;
    }

    get Ridetypeoptions() {
        return [
            { label: 'Home Test Ride', value: 'Home Ride' },
            { label: 'Store Test Ride', value: 'Store Ride' },
        ];
    }
    handletypeValueChange(event) {
        this.typevalue = event.detail.value;
        if (this.typevalue == 'Home Ride') {
            this.homerideAddress = true;
        } else {
            this.homerideAddress = false;
        }
    }


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

    // get leadsourceoptions() {
    //     return [
    //         { label: 'Walk-In', value: 'Walk-In' },
    //         { label: 'Calendly', value: 'Calendly' },
    //         { label: 'Telephone', value: 'Telephone' },
    //         { label: 'Bike Dekho', value: 'Bike Dekho' },
    //         { label: 'CRM - Meta HTR', value: 'CRM - Meta HTR' },
    //         { label: 'Employee Referral', value: 'Employee Referral' },
    //         { label: 'External Referral', value: 'External Referral' },
    //         { label: 'Partner', value: 'Partner' },
    //         { label: 'Trade Show', value: 'Trade Show' },
    //         { label: 'Web', value: 'Web' },
    //         { label: 'Word of mouth', value: 'Word of mouth' },
    //         { label: 'Email-To-Lead', value: 'Email-To-Lead' },
    //         { label: 'CTI', value: 'CTI' },
    //         { label: 'Public Relations', value: 'Public Relations' },
    //         { label: 'Seminar - Internal', value: 'Seminar - Internal' },
    //         { label: 'Seminar - Partner', value: 'Seminar - Partner' },
    //         { label: 'Other', value: 'Other' },
    //         { label: 'WhatsApp', value: 'WhatsApp' },

    //     ];
    // }

    @track flowInputVariables = [
        {
            name: "recordId",
            type: "String",
            value: this.recordId,
        },
    ];
    handleFlowStatusChange(event) {
        console.log('flow Status', event.detail.status);
    }
    followUpColumns = [
        {
            label: 'Lead Name',
            fieldName: 'LeadName',
            type: 'button',
            typeAttributes: {
                label: { fieldName: 'LeadName' },
                name: 'Veiw_lead',
                variant: 'base'
            }
        },
        { label: 'Mobile', fieldName: 'Phone__c' },
        { label: 'Type', fieldName: 'Follow_Up__c' },
        // { label: 'Follow-Up Date', fieldName: 'FollowupDate', type: 'date' },
        // { label: 'Subject', fieldName: 'Subject', type: 'Text' },
        //  { label: 'Lead Age', fieldName: 'Lead_Age__c' },
        { label: 'Previous follow up date', fieldName: 'Previous_Followup_date__c', type: 'datetime' },
        { label: 'Prev followup comments', fieldName: 'Previous_Feedback__c' },


        {
            type: 'button',
            initialWidth: 120,
            typeAttributes: {
                label: 'Complete',
                name: 'complete',
                title: 'complete',
                initialWidth: 60,
                variant: 'brand',
                class: 'custom-button',
                style: 'transform: scale(0.75); display: block;'
            }
        },

    ];

    testRidecolumns = [
        {
            label: 'Lead Name',
            fieldName: 'LeadName',
            type: 'button',
            initialWidth: 150, // Fixed width for the column
            typeAttributes: {
                label: { fieldName: 'LeadName' },
                name: 'Veiw_lead',
                variant: 'base'
            }
        },
        {
            label: 'Mobile',
            fieldName: 'Mobile',
            type: 'Number',
            initialWidth: 120
        },
        {
            label: 'Ride Type',
            fieldName: 'Ride_Type__c',
            initialWidth: 150
        },
        {
            label: 'Lead Age',
            fieldName: 'Lead_Age__c',
            initialWidth: 100
        },
        {
            label: 'Time',
            fieldName: 'TestRideTime',
            type: 'time',
            initialWidth: 150
        },
        {
            type: 'button',
            initialWidth: 100,
            typeAttributes: {
                label: 'Start',
                name: 'Start',
                title: 'Start',
                variant: 'brand'
            }
        },
        {
            type: 'button',
            initialWidth: 120,
            typeAttributes: {
                label: 'Reschedule',
                name: 'Reschedule',
                title: 'Reschedule',
                variant: 'brand'
            }
        },
        {
            type: 'button',
            initialWidth: 120,
            typeAttributes: {
                label: 'No Show',
                name: 'Cancel',
                title: 'Cancel',
                variant: 'destructive'
            }
        },
        {
            type: 'button',
            initialWidth: 120,
            typeAttributes: {
                label: 'Complete',
                name: 'Complete',
                title: 'Complete',
                variant: 'Success'
            }
        }
    ];



    showModalBox() {
        this.flowInputVariables = [
            {
                name: "recordId",
                type: "String",
                value: this.recordId,
            },
        ];
        this.isShowModal = true;
        console.log('Record Id New', this.recordId);
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    showTestRideModalBox() {
        this.flowInputVariables = [
            {
                name: "recordId",
                type: "String",
                value: this.recordId,
            },
        ];
        this.isshowTestRideModal = true;
        this.Ridetypetrue = false;
        console.log(this.Ridetypetrue)
    }
    cancelNewTestRide() {
        this.isshowTestRideModal = false;
        this.Ridetypevale = null;
        this.chooseoption = null
    }

    cancelNewFollowUp() {
        this.isShowModal = false;
    }

    handleFollowUp() {
        console.info('handleFollowUp');
        this.getFollowupdetails();
        this.ifFollowUp = true;
        this.leaddetails = false;
        this.ifTesTRideUp = false;
        this.Ridetypetrue = false;
        this.shownewfollowupModal = false;
    }
    handleTestRides() {
        console.info('handleTestRides');
        this.getFgetTestRidesdetails();
        this.ifFollowUp = false;
        this.leaddetails = false;
        this.ifTesTRideUp = true;
        this.Ridetypetrue = false;
        this.shownewfollowupModal = false;
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

        /*this[NavigationMixin.Navigate]({ 
            type: 'standard__webPage', 
            attributes: { url: '/lead/leadconvert.jsp?id=' + this.selectedrow.Id } 
        });*/
    }

    handleLeadConvert1() {
        console.log('navigate' + this.selectedrow.Id);
        console.log('navigate' + this.recordId);
        if (this.url.includes('my.site')) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: '/lead-conversion?id=' + this.recordId }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'runtime_sales_lead__convertDesktopConsole'
                },
                state: {
                    leadConvert__leadId: this.recordId //Pass your record Id here
                }
            });
        }

        /*this[NavigationMixin.Navigate]({ 
            type: 'standard__webPage', 
            attributes: { url: '/lead/leadconvert.jsp?id=' + this.selectedrow.Id } 
        });*/
    }

    handleChangeleadstatus(event) {
        this.LeadStatus = event.detail.value;
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
    handleleadAddreess(event) {
        const { street, city, province, country, postalCode } = event.detail;
        this.street = street;
        this.city = city;
        this.state = province;
        this.country = country;
        this.postalCode = postalCode;
        console.log(this.city);

    }
    handleFollowupname(event) {
        this.Followupname = event.target.value;
    }
    handlefollowupdate(event) {
        this.Followupdate = event.target.value;
    }
    get todaysDate() {
        var today = new Date();
        return today.toISOString();
    }
    handlecancelreason(event) {
        this.cancelreason = event.target.value;

    }

    handelcancelreason() {
        if (confirm('Are you sure you want to save the changes?')) {
            console.log('id' + this.selectedrow.TestRideId);
            /* cancelride({ testrideId: this.selectedrow.TestRideId, cancelreason: this.cancelreason })
                .then(result => {
                    console.log('success');
                    this.cancelreason = null;
                    this.showcancelModal = false;
                    this.getFgetTestRidesdetails();
                    const message = 'Test Ride Cancel Successfully';
                    this.handleSuccessClick(message);
                })
                .catch(error => {
                    console.log('error handelcancelreason', error);
                    this.errorMessage = error;
                    this.handleErrorClick();
                }); */
            console.log('handelcancelreason recordId', this.recordId);
            if (this.newcNowshowfollowupdate != null && this.newFollowupfeedbck != null && this.newcNowshowfollowupdate != null < this.todaysDate) {
                createnewfollowup({ leadid: this.recordId, followupdate: this.newcNowshowfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                    .then(result => {
                        console.log('sucess');
                        this.handlenewfollowupcancelClick();
                        this.newfollowupdate = null;
                        this.newfollowupname = null;
                        this.newfollowuptrue = false;
                        this.newFollowupfeedbck = null;
                        this.newfollowupModal = false;
                        this.Ridetypevale = null;
                        todayfollowupchooseoptionsvalue = null;


                        const message = 'New Follow up Created Successfully';
                        this.handleSuccessClick(message);
                    })
            } else {
                this.handleErrorClick();
            }
        } else {
            console.log('Action canceled');
        }
    }
    closecancelModal() {
        this.showcancelModal = false;
        this.cancelreason = null;
        this.followoptionchoosevalue = null;
        this.newcNowshowfollowupdate = null;
        this.newFollowupfeedbck = null;
    }

    handlesave() {

        leadupdate({ id: this.selectedrow.Id, lead_source: this.source, phone: this.MobilePhone, Age: this.CustomerAge, email: this.leademail, city: this.city, Country: this.country, PostalCode: this.postalCode, State: this.state, Street: this.street, Status: this.LeadStatus, psname: this.psname })
            .then(result => {
                this.Allleads = true;
                this.searchlead = false;
                this.leaddetailspageopen = false;
                this.Searchkey = null;
                this.connectedCallback();
                this.edittrue = false;
                this.cancelclick();
                const message = 'Lead updated Successfully';
                this.handleSuccessClick(message);
            })
            .catch(error => {
                console.log('error1')
                this.handleErrorClick();
            })
    }
    cancelclick() {
        this.Allleads = true;
        this.searchlead = false;
        this.edittrue = false;
        this.getleaddetails();
        this.leaddetailspageopen = true;
        this.Searchkey = null;
        this.chooseoption = null;
        this.Ridetypevale = null;
        this.Ridetypetrue = false;
    }

    connectedCallback() {
        this.getLeadDetails();
               this.summarrywrappersetcountmethod();

        // let today = new Date(); 
        // this.newcNowshowfollowupdate = new Date(today);
        // this.newcNowshowfollowupdate.setDate(this.newcNowshowfollowupdate.getDate() + 1);
        // this.newcNowshowfollowupdate = this.formatDateForInput(this.newcNowshowfollowupdate);
        // console.log('this.newcNowshowfollowupdate', this.newcNowshowfollowupdate);
        //this.getFollowupdetails();
        //this.getFgetTestRidesdetails();
    }

    formatDateForInput(date) {
        const isoString = date.toISOString();
        return isoString.slice(0, 16); // Format to 'YYYY-MM-DDTHH:mm'
    }

    getLeadDetails() {
        getList()
            .then(result => {
                console.log('hcvsshshs=' + JSON.stringify(result));
                //  this.testridescount=result;
                // console.log('getTestRidesdetail'+(this.testridescount.length));
                this.records = result;
                //consol.log('records '+this.records);
            })
            .catch(error => {
                console.log(error);
                // this.handleErrorClick();
            })
    }

    getFollowupdetails() {
        getFllowups({

        })
            .then(result => {
                console.log('result : ' + JSON.stringify(result));
                let valueArr = result.lstFollowUp;
                let dataWhenfollowUp = [];
                let arrData = [];
                for (let i = 0; i < valueArr.length; i++) {
                    let val = {
                        LeadName: valueArr[i].Lead__c ? valueArr[i].Lead__r.Name : '',
                        Veiw_lead: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Lead_Age__c : '',
                        FollowupDate: this.followupconvertToIST(valueArr[i].Follow_Up_Date__c),
                        Follow_Up__c: valueArr[i].Follow_Up__c ? valueArr[i].Follow_Up__c : '',
                        // Folllow_Up1_Summary__c: valueArr[i].Folllow_Up1_Summary__c ? valueArr[i].Folllow_Up1_Summary__c : '',
                        // Previousfollowupdate: result.oldValue[valueArr[i].Id] ? result.oldValue[valueArr[i].Id].OldValue : '',
                        Previous_Feedback__c: valueArr[i].Feedback__c ? valueArr[i].Feedback__c : '',
                        Previous_Followup_date__c: this.followupconvertToIST(valueArr[i].Previous_Followup_date__c),
                        Subject: valueArr[i].Subject__c ? valueArr[i].Subject__c : '',
                        FollupId: valueArr[i].Id,
                        Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        Phone__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Phone__c : '',
                        Country: valueArr[i].Lead__c ? valueArr[i].Lead__r.Country : '',
                        State: valueArr[i].Lead__c ? valueArr[i].Lead__r.State : '',
                        City: valueArr[i].Lead__c ? valueArr[i].Lead__r.City : '',
                        Street: valueArr[i].Lead__c ? valueArr[i].Lead__r.Street : '',
                        PostalCode: valueArr[i].Lead__c ? valueArr[i].Lead__r.PostalCode : ''


                    }
                    console.log('phone=' + JSON.stringify(val.Country));
                    arrData.push(val);

                    this.recordId = valueArr[i].Lead__c ? valueArr[i].Lead__c : '';

                    /* 
                    this.followUpsId = result[i].Id ? result[i].Id : '';
                    console.log('followUpsId : ',this.followUpsId); */
                }
                console.log('OUTPUT : ', arrData);

                this.dataFolloUp = arrData
                this.followupscount = this.dataFolloUp.length;
                //this.data

                if (result.lstLead) {
                    //  this.records = result.lstLead;
                    console.log('hhhh=' + JSON.stringify(this.records));
                }
            })
            .catch(error => {
                console.log('Error ' + error);
                this.handleErrorClick();
            })
    }
    getFgetTestRidesdetails() {
        getTestRidesdetail()
            .then(result => {


                let arrdata = [];

                let valueArr = result.lstTestRide;
                for (let i = 0; i < valueArr.length; i++) {
                    console.log('valueArr[i].MobilePhone__c>>>>' + JSON.stringify(valueArr[i].MobilePhone__c));
                    let value = {
                        LeadName: valueArr[i].Lead__c ? valueArr[i].Lead__r.Name : '',
                        Mobile: valueArr[i].MobilePhone__c ? valueArr[i].MobilePhone__c : '',
                        Ride_Type__c: valueArr[i].Ride_Type__c ? valueArr[i].Ride_Type__c : '',
                        Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r.Lead_Age__c : '',
                        //  datandtime: valueArr[i].Test_Drive_Date__c ? valueArr[i].Test_Drive_Date__c : '',
                        Indemnity__c: valueArr[i].Indemnity__c ? valueArr[i].Indemnity__c : '',
                        Drivers_License_Number__c: valueArr[i].Drivers_License_Number__c ? valueArr[i].Drivers_License_Number__c : '',
                        TestRideTime: this.convertToIST(valueArr[i].Test_Ride_Date__c),
                        Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                        TestRideId: valueArr[i].Id,
                        //  TestRideTime: this.convertToIST(TestRideTime)

                    }
                    console.log('phone=' + JSON.stringify(value.TestRideTime));

                    arrdata.push(value);
                    this.recordId = valueArr[i].Id ? valueArr[i].Id : '';
                }


                if (result.lstLead) {
                    // this.isTodaysTestRideList = result.lstLead;
                }
                this.datatestRides = arrdata;
                this.testridescount = this.datatestRides.length;
                //console.log('getTestRidesdetail'+(this.testridescou));
            })
            .catch(error => {
                console.log(error);
                this.handleErrorClick();
            });
    }

    handleLeadName(event) {
        this.Searchkey = event.target.value;
        console.log('Searchkey value: ', this.Searchkey);
    }
    handleSearchClick() {
        console.log('entering'+this.ntlist)
        let searchkey = this.Searchkey;
            console.log('entering2nlist'+this.nlist)

    
if(this.ntlist==true){
        if (searchkey) {
                    console.log('ntlist');
            SearchLead({ searchKeyword: this.Searchkey })
                .then(result => {
                    console.log('result=' + JSON.stringify(result))
                    // this.Allleads=false;
                    //  this.searchlead=true;
                    this.records = result
                })
                .catch(error => {
                    console.log('error2');
                    this.handleErrorClick();
                })
        }
        else {
            console.log('else getleaddetails');
            this.getLeadDetails();
        }
}else if(this.nlist==true){
    if (searchkey) {
        console.log('nlist');
            newSearchLead({ searchKeyword: this.Searchkey })
                .then(result => {
                    console.log('result=' + JSON.stringify(result))
                    // this.Allleads=false;
                    //  this.searchlead=true;
                    this.records = result
                })
                .catch(error => {
                    console.log('error2');
                    this.handleErrorClick();
                })
        }
        else {
            console.log('else getleaddetails');
    this.newgetLeadsmethod();
        }

}

    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedrow = row;
        switch (actionName) {
            case 'Deatils':
                this.allleadlist = false
                    ;
                this.leaddetailspageopen = true;
                this.leaddetails = true;
                this.edittrue = false;
                this.ifFollowUp = false;
                this.ifTesTRideUp = false;
                this.getleaddetails();
                console.log(this.selectedrow.Id);
                this.selectedLeadId = this.selectedrow.Id
                let cmp = this.template.querySelector('c-follow-up-components');
                if (cmp) {
                    console.log('Commong : ', cmp);
                    cmp.getFollowUp(this.selectedrow.Id);
                }
                let cmp2 = this.template.querySelector('c-test-ride-list');
                if (cmp2) {
                    console.log('Commong : ', cmp2);
                    cmp2.getTestRides(this.selectedrow.Id);
                }

                break;
            default:
        }
    }
    handleFeedbackChange(event) {



        this.FeedbackValue = event.target.value;
    }
    submitTestRideFeedback() {
        if (confirm('Are you sure you want to save the changes?')) {
            console.log('id' + this.selectedrow.TestRideId);
            console.log('ggf' + JSON.stringify(this.FeedbackValue));
            completeride({ testrideId: this.selectedrow.TestRideId, feedback: this.FeedbackValue })
                .then(result => {
                    console.log('success', result);
                    this.FeedbackValue = null
                    this.showFeedbackModal = false;
                    this.getFgetTestRidesdetails();
                    const message = 'Test Ride Feedback Saved Successfully';
                    this.handleSuccessClick(message);
                })
                .catch(error => {
                    console.log('error3');
                    this.handleErrorClick();
                });
        } else {
            console.log('Action canceled');
        }



    }
    handlefeedbacksubmit() {
        if (confirm('Are you sure you want to save the changes?')) {
            console.log('FollowUp Id:::', this.selectedrow.FollupId);
            Feedback({ followupId: this.selectedrow.FollupId, Feedback: this.FeedbackValue })
                .then(result => {
                    console.log('Result', result);
                    this.FeedbackValue = null;
                    this.showFeedbackModal = false;
                    this.getFollowupdetails();
                    const message = 'Followup Feedback Created Successfully';
                    this.handleSuccessClick(message);
                })
                .catch(error => {
                    console.log('error4');
                });
        } else {
            console.log('Action canceled');

        }
    }
    @track Status;
    getleaddetails() {
        console.log(this.selectedrow.Id);
        getleadrecord({ leadid: this.selectedrow.Id })
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
                console.log('error5');
                this.handleErrorClick();
            })

    }

    handleNewFeedValue(event) {
        this.newFollowUpFeedBack = event.target.value;

    }

    handleFolluwUpRowAction(event) {
        console.log('OUTPUT : ');
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedrow = row;
        console.log('This Selected Row:::', JSON.stringify(this.selectedrow));
        switch (actionName) {
            case 'complete':
                // console.log(this.selectedrow.FollowupDate);
                // let followUpId = this.selectedrow.FollupId;
                // this.formattedDate = this.selectedrow.Previousfollowupdate;
                this.shownewfollowupModal = true;
                this.recordId = this.selectedrow.Lead__c;
                // console.log('NewFollowup');
                // getPreviousfollowUpSummary({
                //     currentFollowUpId: followUpId
                // }).then(result => {
                //     console.log('getPreviousfollowUpSummary result:', result);
                //     this.PreviousFeedBackValue = result != null && result.Folllow_Up1_Summary__c ? result.Folllow_Up1_Summary__c : '';
                // })
                //     .catch(error => {
                //         console.log('getPreviousfollowUpSummary error:', error);
                //         this.handleErrorClick();
                //     })

                break;

            case 'Complete':
                this.showFeedbackModal = true;
                this.recordId = this.selectedrow.Lead__c;
                console.log('Complete');
                break;
            case 'Veiw_lead':
                console.log('veiw lead' + this.selectedrow.Lead__c);
                this.navigateToLead(this.selectedrow.Lead__c);
            //       this[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: this.selectedrow.Lead__c,
            //         objectApiName: 'Lead', // Specify the object API name
            //         actionName: 'view'      // Action to view the record
            //     }
            // });
            default:
        }


    }


    handleTestRideRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedrow = row;
        switch (actionName) {
            case 'Reschedule':
                this.openreschedule();
                console.log('roeww');
                break;

            case 'Cancel':
                const currentDateTime = new Date();

                const tomorrowDateTime = new Date(currentDateTime);
                tomorrowDateTime.setDate(currentDateTime.getDate() + 1);

                this.newcNowshowfollowupdate = tomorrowDateTime.toISOString();
                if (this.newcNowshowfollowupdate < this.todaysDate) {
                    this.errordateMessage = 'Please select today (or) a Future Date';
                    console.log('enter' + this.errordateMessage);
                } else {
                    this.errordateMessage = '';
                }
                this.showcancelModal = true;
                console.log('Cancel');

                break;

            case 'Complete':
                console.log('hhhhhh' + this.selectedrow.Drivers_License_Number__c + 'jbdcjj' + this.selectedrow.Indemnity__c)
                if (this.selectedrow.Drivers_License_Number__c != null && this.selectedrow.Indemnity__c == true) {
                    this.testridefeedbackmodale = true;
                    console.log('Complete' + this.selectedrow.TestRideId);
                } else {
                    this.handleupdateErrorClick();
                }
                break;
            case 'Veiw_lead':
                console.log('eneter1' + JSON.stringify(this.selectedrow));
                this.navigateToLead(this.selectedrow.Lead__c);
                break;
            case 'Start':
                console.log('eneter1' + JSON.stringify(this.selectedrow));
                this.istart = true;
                this.homeIndemnity = this.selectedrow.Indemnity__c;
                this.homedlnumber = this.selectedrow.Drivers_License_Number__c;
                if (this.homeIndemnity == true) {
                    this.homeIndemnity = true;
                } else {
                    this.homeIndemnity = false;
                }
                console.log('kkk' + this.homeIndemnity);
                break;
            default:
        }

    }

    openreschedule() {
        this.Rescheduledate = true;
    }
    handledatevalue(event) {
        this.datevalue = event.target.value;

    }
    get todaysDate() {
        var today = new Date();
        return today.toISOString();
    }
    ReschedulehandleClickcancel() {
        this.datevalue = null;
        this.Rescheduledate = false;
        this.typevalue = null;
    }

    reschedulesavehandleClick() {
        if (this.datevalue == null && this.typevalue == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.datevalue < this.todaysDate) {
                //this.todaysDate
            } else {


                if (confirm('Are you sure you want to save the changes?')) {
                    console.log('id' + this.selectedrow.TestRideId);
                    Updaterescheduledate({ rescheduledate: this.datevalue, testdriverid: this.selectedrow.TestRideId, rideType: this.typevalue })
                        .then(result => {
                            console.log('success', result);
                            this.datevalue = null;
                            this.Rescheduledate = false;
                            this.getFgetTestRidesdetails();
                            const message = 'Test Ride rescheduled successfully!';
                            this.handleSuccessClick(message);
                        })
                        .catch(error => {
                            console.log('error6');
                            this.handleErrorClick();
                        });
                } else {
                    console.log('Action canceled');
                }
            }

        }
    }
    navigateToLead(recordId) {
        console.log('eneter' + recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Lead', // Specify the object API name
                actionName: 'view' // Use 'view' for viewing the record
            }
        });
    }

    closesnewfollowupModal() {
        this.shownewfollowupModal = false;
        this.Followupname = null;
        this.Followupdate = null;
    }
    closeFeedbackModal() {
        this.showFeedbackModal = false;
        this.showTestRideFeedbackModal = false;
        this.FeedbackValue = null;
        this.followoptionchoosevalue = null;


    }

    closeTestRideFeedbackModal() {
        this.showTestRideFeedbackModal = false;
        this.FeedbackValue = null;
    }

    newfollowupsubmit() {
        console.log('newfollowupsubmit');
        if (this.newfollowupdate == null) {
            console.log('null value');
        } else {
            if (this.newfollowupdate < this.todaysDate) {
                //this.todaysDate
            } else {
                createnewfollowup({ leadid: this.selectedrow.Veiw_lead, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                    .then(result => {
                        console.log('sucess');
                        this.handlebookidcancelClick();
                        this.newfollowupdate = null;
                        this.newfollowupname = null;
                        //  this.newfollowuptrue = false;
                        this.newFollowupfeedbck = null;
                        this.shownewfollowupModal = false;
                        this.newfollowupModal = false;
                        this.todayfollowupchooseoptionsvalue = null;
                        const message = 'New Follow up Created Successfully';
                        this.handleSuccessClick(message);
                        this.updatefollowupcomplete();
                        this.getFollowupdetails();

                    })
                    .catch(error => {
                        console.log('error====');
                        this.handleErrorClick();
                    })
            }
        }
    }

    get currentRecords() {
        const start = (this.currentPage - 1) * this.pageSize;
        return this.records;

    }

    handleEdit() {
        this.edittrue = true;
        this.isConvert = false;
        this.leaddetailspageopen = false;
        // this.leaddetails=false;
    }
    handleConvert() {
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[LEAD_STATUS_FIELD.fieldApiName] = 'Converted'; // Set the desired status

        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.edittrue = true;
                this.leaddetailspageopen = false;
                // Handle success (e.g., show a success message or navigate to the new record)
            })
            .catch(error => {
                // Handle error (e.g., show an error message)
                console.error('Error updating lead status:', error);
                this.handleErrorClick();
            });
    }


    steps = [
        { label: 'New', value: 'New' },
        { label: 'Test Ride', value: 'Test Ride' },
        { label: 'Follow Up', value: 'Follow Up' },
        { label: 'Ready For Booking', value: 'Ready For booking' },
        { label: 'Convert', value: 'Convert' },
        { label: 'Close Lost', value: 'close lost' }
    ];
    cancelridetypepopup() {
        this.Ridetypetrue = false;
        this.Ridetypevale = null;
        this.chooseoption = null;
        console.log('popupcancled');
    }
    Ridetypeoptionschange(event) {
        this.Ridetypevale = event.detail.value;

        this.performAction(this.Ridetypevale);
    }

    performAction(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Home Ride') {
            console.log('Option 1 was selected!');
            this.Ridetypetrue = false;
            this.showTestRideModalBoxhome();
        } else if (selectedValue === 'Store Ride') {
            console.log('Option 2 was selected!');
            this.Ridetypetrue = false;
            this.showTestRideModalBoxstore();
        }
    }
    ridetypemodelshow() {
        this.Ridetypetrue = true;
        console.log('neter')
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
    Convertclick() {
        if (this.selectedrow.Id) {
            console.log(this.selectedrow.Id)
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.selectedrow.Id,
                    objectApiName: 'Lead',
                    actionName: 'convert'
                }
            });
        } else {
            // Handle case where Lead ID is not provided
            console.error('Lead ID is required to navigate to conversion.');
        }
    }

    get chooseactionoptions() {
        return [
            { label: 'Test Ride', value: 'Test Ride' },
            { label: 'Follow Up', value: 'Follow up' },
        ];
    }
    ChooseAnyaction(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Test Ride') {
            console.log('Option 1 was selected!');
            this.ridetypemodelshow();
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
            this.choosefollowupoption();
            this.Ridetypetrue = false;
        }
    }
    ChooseAnyactionchange(event) {
        this.chooseoption = event.detail.value;

        this.ChooseAnyaction(this.chooseoption);
    }
    get followoptionchooseoptions() {
        return [
            { label: 'Ready For Booking', value: 'Ready For Booking' },
            { label: 'Follow Up', value: 'Follow up' },
            { label: 'Lost', value: 'Lost' },
        ];
    }
    followoptionchooseoptionsradio(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.showcancelModal = false;
            this.readyforbookingoptiontruemethod();
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
            this.handlefollowuppopup();
        }

    }
    testRidefollowoptionchooseoptionsradio(selectedValue) {
        console.log('testRidefollowoptionchooseoptionsradio : ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.handleLeadConvert1();
            this.followoptionchoosevalue = null;
            this.showFeedbackModal = false;
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
            this.handlefollowuppopup();
        } else if (selectedValue === 'Lost') {
            console.log('Option 2 was selected!');
            this.showTestRideFeedbackModal = false;
            this.followoptionchoose = false;
            this.lostleadtrue = true;;
        }

    }
    followoptionchoosechange(event) {
        this.followoptionchoosevalue = event.detail.value;

        this.testRidefollowoptionchooseoptionsradio(this.followoptionchoosevalue);
        this.followoptionchooseoptionsradio(this.followoptionchoosevalue);
    }
    choosefollowupoption() {
        this.followoptionchoose = true;
    }
    cancelfollowoptionchoose() {
        this.followoptionchoose = false;
        this.followoptionchoosevalue = null;
        this.chooseoption = null;
    }
    get readyforbookingoptions() {
        return [
            { label: 'Booked', value: 'Booked' },
            { label: 'Follow up', value: 'Follow p' },
        ];
    }
    readyforbookingoptionradio(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Booked') {
            console.log('Option 1 was selected!');
            this.bookedtruemethod();
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
            this.handlefollowuppopup();
        }
    }
    readyforbookingoptionchange(event) {
        this.readyforbookingoption = event.detail.value;

        this.readyforbookingoptionradio(this.readyforbookingoption);
    }
    readyforbookingoptiontruemethod() {
        this.readyforbookingoptiontrue = true;
    }
    cancelreadyforbookingoption() {
        this.followoptionchoose = false;
        this.followoptionchoosevalue = null;
        this.chooseoption = null;
        this.readyforbookingoptiontrue = null;
    }
    bookingidhandler(event) {
        this.bookingId = event.target.value;
    }
    handlebookidcancelClick() {
        this.followoptionchoose = false;
        this.followoptionchoosevalue = null;
        this.chooseoption = null;
        this.readyforbookingoptiontrue = null;
        this.bookingId = null;
        this.bookedtrue = false;

    }
    bookedtruemethod() {
        this.bookedtrue = true;
    }
    handlebookidsaveClick() {
        console.log('id=' + this.selectedrow.Id)
        bookingid({ leadid: this.selectedrow.Id, bookingid: this.bookingId })
            .then(result => {
                console.log('sucess')
                this.handlebookidcancelClick();
                const message = 'Booking Successfull';
                this.handleSuccessClick(message);
            })
            .catch(error => {
                console.log('error7')
                this.handleErrorClick();
            })
    }
    cancelbookedtruecancel() {
        this.handlebookidcancelClick();
    }
    followupnamehandler(event) {
        this.newfollowupname = event.target.value;
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
    handlefollowuppopup() {
        // console.log('entry'+this.newfollowuptrue = true;);
        this.showFeedbackModal = false;
        this.newfollowuptrue = true;
        this.showTestRideFeedbackModal = false;
        console.log('entry' + this.newfollowuptrue);

    }
    lastFollowUpSummaryHandler(event) {
        this.lastFollowUpSummary = event.target.value;
    }
    handlenewfollowupsaveClick() {
        console.log('handlenewfollowupsaveClick');
        if (this.newfollowupdate == null) {
            console.log('null value');
        } else {
            if (this.newfollowupdate < this.todaysDate) {
                //this.todaysDate
            } else {
                createnewfollowup({ leadid: this.recordId, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                    .then(result => {
                        console.log('sucess+++=' + this.selectedrow.TestRideId);
                        this.updatedtestridecomplete();
                        this.handlenewfollowupcancelClick();
                        this.newfollowupdate = null;
                        this.newfollowupname = null;
                        this.newfollowuptrue = false;
                        this.newFollowupfeedbck = null;
                        this.todayfollowupchooseoptionsvalue = null;
                        const message = 'New Follow up Created Successfully';
                        this.handleSuccessClick(message);
                        //this.getFgetTestRidesdetails();
                        this.getFollowupdetails();
                    })
                    .catch(error => {
                        console.log('error' + error);
                        this.handleErrorClick();
                    })
            }
        }
        // completeride({ testrideId: this.selectedrow.TestRideId, feedback: ''})
        //     .then(result => {
        //         console.log('success', result);
        //         this.FeedbackValue = null
        //         this.showFeedbackModal = false;
        //         this.getFgetTestRidesdetails();
        //     })
        //     .catch(error => {
        //         console.log('error8');
        //         this.handleErrorClick();
        //     });
    }
    handlenewfollowupcancelClick() {
        this.handlebookidcancelClick();
        this.newfollowupdate = null;
        this.newfollowupname = null;
        this.newfollowuptrue = false;
        this.newFollowupfeedbck = null;
        this.shownewfollowupModal = false;
        this.newfollowupModal = false;
        this.todayfollowupchooseoptionsvalue = null;
    }
    handleNewLead() {
        // Use NavigationMixin to navigate to the standard New Lead page
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Lead',  // Specify the object API name
                actionName: 'new'       // Action to create a new record
            }
        });
    }
    @track isshowTestRideModalstore = false;
    @track isshowTestRideModalhome = false;
    showTestRideModalBoxstore() {
        this.isshowTestRideModalstore = true;
        this.isshowTestRideModalhome = false;
    }
    showTestRideModalBoxhome() {
        this.isshowTestRideModalhome = true;
        this.isshowTestRideModalstore = false;
    }
    cancelNewTestRidestrore() {
        this.isshowTestRideModalstore = false;
        this.Ridetypevale = null;
        this.storedlnumber = null;
        this.storeExcutiveName = null;
        this.storeIndemnity = null;
        this.testridestorevaluedate = null;
        this.Ridetypetrue = true;
    }
    cancelNewTestRidehome() {
        this.isshowTestRideModalhome = false;
        this.Ridetypevale = null;
        this.homeExcutiveName = null;
        this.homedlnumber = null;
        this.homeIndemnity = null;
        this.testridehomevaluedate = null;

        this.Ridetypetrue = true;
    }

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
    handleLeadhomeAddressChange(event) {
        const { street, city, province, country, postalCode } = event.detail;
        this.street = street;
        this.city = city;
        this.state = province;
        this.country = country;
        this.postalCode = postalCode;
        console.log(this.homecity);
        console.log(this.homestate);

    }
    handlestoresaveClick() {
        if (this.testridestorevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridestorevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('hhhh' + this.storeExcutiveName)
                storeride({ leadid: this.selectedrow.Id, testridename: this.testridestorevalue, ridedate: this.testridestorevaluedate, Indemnity: this.storeIndemnity, dlnumber: this.storedlnumber, storeExcutiveName: this.storeExcutiveName })
                    .then(result => {
                        console.log('sucess');
                        this.testridestorevalue = null;
                        this.testridestorevaluedate = null;
                        this.leaddetails = false;
                        this.Ridetypevale = null;
                        this.isshowTestRideModalstore = false;
                        this.testridestorevaluedate = null;
                        this.storedlnumber = null;
                        this.chooseoption = null;
                        const message = 'A New Store Ride Created Successfully';
                        this.handleSuccessClick(message);
                        this.getFgetTestRidesdetails();
                        this.getFollowupdetails();

                    })
                    .catch(error => {
                        console.log('error9')
                        console.log('please enter the data')
                        this.handleErrorClick();
                    })
            }
        }
    }
    handlehomesaveClick() {
        if (this.testridehomevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridehomevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('ldvfhbg' + this.homecountry + 'jnjndsj' + this.homeExcutiveName);
                homerideaddress({ leadid: this.selectedrow.Id, testridename: this.leadname, ridedate: this.testridehomevaluedate, street: this.street, city: this.city, state: this.state, country: this.country, postalcode: this.postalCode, Indemnity: this.homeIndemnity, dlnumber: this.homedlnumber, homeExcutiveName: this.homeExcutiveName })
                    .then(result => {
                        this.cancelNewTestRidehome();
                        this.leaddetails = false;
                        this.Ridetypevale = null;
                        const message = 'A New Home Ride Created Successfully';
                        this.handleSuccessClick(message);
                        this.homedlnumber = null;
                        this.testridehomevaluedate = null;
                        this.getFgetTestRidesdetails();
                        this.getFollowupdetails();
                        this.chooseoption = null;
                    })
                    .catch(error => {
                        console.log('error10');
                        this.handleErrorClick();
                    })
            }
        }
    }
    followupfeedbackHandler(event) {
        this.newFollowupfeedbck = event.target.value;
    }

    handleSuccessClick(message) {
        LightningAlert.open({
            message: message,
            theme: 'success',
            label: 'Success!',
        });
        //Alert has been closed
    }

    handleErrorClick() {
        LightningAlert.open({
            message: 'Please Fill All The Mandatory Fields And Check Date ',
            theme: 'error',
            label: 'Error!',
        });

    }
    handlelfollowuplimitErrorClick() {
        LightningAlert.open({
            message: 'Please fill the mandatory indemnity form and check for valid DL format with State and RTO reference (Ex: KA12345657) ',
            theme: 'error',
            label: 'Error!',
        });

    }
    get todayfollowupchooseoptions() {
        return [
            { label: 'Ready For Booking', value: 'Ready For Booking' },
            { label: 'Test Ride', value: 'Test Ride' },
            { label: 'New FollowUp', value: 'New FollowUP' },
            { label: 'Lost', value: 'Lost' }
        ];
    }
    todayfollowupchooseoptionshandlechange(event) {
        this.todayfollowupchooseoptionsvalue = event.detail.value;
        this.todayfollowupchooseoptionshandlechangeradio(this.todayfollowupchooseoptionsvalue);
    }
    todayfollowupchooseoptionshandlechangeradio(selectedValue) {
        console.log('Selected Value is: ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.newfollowuptrue = false;
            this.Ridetypetrue = false;
            this.lostleadtrue = false
            this.navigateToNewAccount1();
        } else if (selectedValue === 'Test Ride') {
            console.log('Option 2 was selected!');
            this.newfollowuptrue = false;
            this.Ridetypetrue = true;
            this.LeadName = this.selectedrow.LeadName
            this.shownewfollowupModal = false;
            this.newfollowupModal = false;
            this.lostleadtrue = false
            this.country = this.selectedrow.Country;
            this.state = this.selectedrow.State;
            this.city = this.selectedrow.City;
            this.street = this.selectedrow.Street;
            this.postalCode = this.selectedrow.PostalCode;
        } else if (selectedValue === 'New FollowUP') {
            console.log('Option 3 was selected!');
            this.newfollowupModal = true;
            this.Ridetypetrue = false;
            this.lostleadtrue = false
            console.log('value' + this.newfollowuptrue)
        } else if (selectedValue === 'Lost') {
            console.log('Option 4 was selected!');
            this.newfollowuptrue = false;
            this.Ridetypetrue = false;
            this.shownewfollowupModal = false;
            this.lostleadtrue = true

        }
    }
    todaysfollowupRidetypetruecancel() {
        this.todayfollowupchooseoptionsvalue = null;
        this.shownewfollowupModal = true;
        this.Ridetypetrue = false;
        this.Ridetypevale = null;
    }
    todaysfollowuphandlestoresaveClick() {
        if (this.testridestorevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridestorevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('hhhh' + this.storeExcutiveName)
                storeride({ leadid: this.selectedrow.Lead__c, testridename: this.testridestorevalue, ridedate: this.testridestorevaluedate, Indemnity: this.storeIndemnity, dlnumber: this.storedlnumber, storeExcutiveName: this.storeExcutiveName })
                    .then(result => {
                        console.log('sucess');
                        this.testridestorevalue = null;
                        this.testridestorevaluedate = null;
                        this.leaddetails = false;
                        this.Ridetypevale = null;
                        this.isshowTestRideModalstore = false;
                        this.testridestorevaluedate = null;
                        this.storedlnumber = null;
                        this.Ridetypetrue = false;
                        this.todayfollowupchooseoptionsvalue = false;
                        const message = 'A New Store Ride Created Successfully';
                        this.handleSuccessClick(message);
                        this.updatefollowupcomplete();
                        this.handleFollowUp();


                    })
                    .catch(error => {
                        console.log('error19')
                        console.log('please enter the data')
                        this.handleErrorClick();
                    })
            }
        }
    }
    todaysfollowuphandlehomesaveClick() {
        if (this.testridehomevaluedate == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.testridehomevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('ldvfhbg' + this.homecountry + 'jnjndsj' + this.homeExcutiveName);
                homerideaddress({ leadid: this.selectedrow.Lead__c, testridename: this.leadname, ridedate: this.testridehomevaluedate, street: this.street, city: this.city, state: this.state, country: this.country, postalcode: this.postalCode, Indemnity: this.homeIndemnity, dlnumber: this.homedlnumber, homeExcutiveName: this.homeExcutiveName })
                    .then(result => {
                        this.cancelNewTestRidehome();
                        this.leaddetails = false;
                        this.Ridetypevale = null;
                        const message = 'A New Home Ride Created Successfully';
                        this.handleSuccessClick(message);
                        this.homedlnumber = null;
                        this.testridehomevaluedate = null;
                        this.Ridetypetrue = false;
                        this.todayfollowupchooseoptionsvalue = false;
                        this.updatefollowupcomplete();
                        this.connectedCallback();
                        window.location.reload();

                    })
                    .catch(error => {
                        console.log('error10');
                        this.handleErrorClick();
                    })
            }
        }
    }
    handleleadcancelreason(event) {
        this.leadcancelreason = event.target.value;
    }
    todaysfollowuplostleadsave() {
        if (this.reasonvalue != null && this.leadcancelreason != null) {
            leadcancellation({ leadid: this.selectedrow.Lead__c, reason: this.reasonvalue, reasonfeedback: this.leadcancelreason })
                .then(result => {
                    console.log('sucess');
                    this.todaysfollowuplostleadcancel();
                    this.followoptionchoosevalue = null;
                    const message = 'Lead has been lost';
                    this.handleSuccessClick(message);
                    this.updatefollowupcomplete();
                    this.getFgetTestRidesdetails();
                    this.getFollowupdetails();
                })
                .catch(error => {
                    console.log('eror11');
                    this.handleErrorClick();
                })
        } else {
            this.handleErrorClick();

        }
    }
    todaysfollowuplostleadcancel() {
        this.lostleadtrue = false;
        this.leadcancelreason = null;
        this.reasonvalue = null;
        this.todayfollowupchooseoptionsvalue = null
    }
    navigateToNewAccount() {
        console.log('account called>>>>' + this.selectedrow.Id);
        console.log('account called>>>>' + this.recordId);
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

    navigateToNewAccount1() {
        console.log('navigateToNewAccount1 called>>>>' + this.selectedrow.Id);
        console.log('account called>>>>' + this.recordId);
        if (this.url.includes('my.site')) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: { url: '/lead-conversion?id=' + this.recordId }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'runtime_sales_lead__convertDesktopConsole'
                },
                state: {
                    leadConvert__leadId: this.recordId //Pass your record Id here
                }
            });
        }
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
    reasonhandleChange(event) {
        this.reasonvalue = event.detail.value;
    }
    updatefollowupcomplete() {
        updatefollowup({ followupId: this.selectedrow.FollupId })
            .then(result => {
                console.log('sucess');
                this.getFollowupdetails();
            })
            .catch(error => {
                console.log('errror12');

            })
    }
    closestartModal() {
        this.istart = false;
    }
    startestride() {
        console.log('entering+' + this.homeIndemnity);
        if (this.homedlnumber != null && this.homeIndemnity == true) {
            updatetestridedl({ testrideId: this.selectedrow.TestRideId, Dlnumber: this.homedlnumber, Indemnity: this.homeIndemnity })
                .then(result => {
                    console.log('sucess');
                    this.istart = false;
                    this.homedlnumber = null;
                    this.homeIndemnity = null;
                    const message = 'Test Ride Successfully Started';
                    this.handleSuccessClick(message);
                    this.getFgetTestRidesdetails();
                })
                .catch(result => {
                    console.log('error');
                    this.handlelfollowuplimitErrorClick();
                })

        } else {
            this.handlelfollowuplimitErrorClick();
        }
    }
    handleupdateErrorClick() {
        LightningAlert.open({
            message: 'Please Select Start Button and Fill DL number and Indemnity ',
            theme: 'error',
            label: 'Error!',
        });


    }
    todaysfollowuplostleadsavedeatails() {
        if (this.reasonvalue != null && this.leadcancelreason) {

            leadcancellation({ leadid: this.selectedrow.Id, reason: this.reasonvalue, reasonfeedback: this.leadcancelreason })
                .then(result => {
                    console.log('sucess');
                    this.todaysfollowuplostleadcancel();
                    const message = 'Lead has Lost';
                    this.handleSuccessClick(message);
                    this.updatefollowupcomplete();
                    this.leaddetails = false;
                    this.Ridetypevale = null;
                    this.getFollowupdetails()
                    this.getFgetTestRidesdetails();
                })
                .catch(error => {
                    console.log('eror11');
                    this.handleErrorClick();
                })
        } else {
            this.handleErrorClick();
        }
    }
    todaysfollowuplostleadsavedeatailscancel() {
        this.lostleadtrue = false;
        this.leadcancelreason = null;
        this.reasonvalue = null;
        this.todayfollowupchooseoptionsvalue = null
    }
    handleNoshowsaveClick() {
        console.log('udshi' + this.selectedrow.Lead__c + 'ooooo' + this.newcNowshowfollowupdate + 'tyui' + this.newFollowupfeedbck);
        if (this.newcNowshowfollowupdate == null || this.newFollowupfeedbck == null) {
            console.log('null value');
            this.handleErrorClick();
        } else {
            if (this.newcNowshowfollowupdate < this.todaysDate) {
                //this.todaysDate
            } else {
                createnewfollowuptestride({ leadid: this.selectedrow.Lead__c, followupdate: this.newcNowshowfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                    .then(result => {
                        console.log('sucess');
                        this.showcancelModal = false;
                        this.newFollowupfeedbck = null;

                        updatedstatustestride({ testrideId: this.selectedrow.TestRideId })
                            .then(result => {
                                console.log('sucess');
                                this.getFgetTestRidesdetails();
                            })
                            .catch(error => {
                                console.log('error');
                            })

                        const message = 'New Follow up Created Successfully';
                        this.handleSuccessClick(message);
                    })
                    .catch(error => {
                        console.log('error14');
                        this.handleErrorClick();
                    })
            }
        }
    }
    handlecompletesaveClick() {
        console.log('ueieiiwiwwwwwwwwwwwwwwww');
        createnewfollowuptestride({ leadid: this.selectedrow.Lead__c, followupdate: this.newcNowshowfollowupdate, feedbackvalue: this.newFollowupfeedbck })
            .then(result => {
                const message = 'New Follow up Created Successfully';
                this.handleSuccessClick(message);
                updatedstatustestride({ testrideId: this.selectedrow.TestRideId })
                    .then(result => {
                        console.log('sucess');
                        this.getFgetTestRidesdetails();
                    })
                    .catch(error => {
                        console.log('error');
                    })

                this.showcancelModal = false;
                console.log('sucess');
                this.newcNowshowfollowupdate = null;
                this.newFollowupfeedbck = null;
                this.showTestRideFeedbackModal = false;
                this.followoptionchoosevalue = null;
                //  this.updatedtestridecomplete();

            })
            .catch(error => {
                console.log('error14');
            })

    }
    updatedtestridecomplete() {
        console.log('testrideId=' + this.selectedrow.TestRideId);
        updatedstatustestridecomplete({ testrideId: this.selectedrow.TestRideId })
            .then(result => {
                console.log('sucess');
                this.getFgetTestRidesdetails();

            })
            .catch(error => {
                console.log('error');
            })

    }
    convertToIST(utcDateString) {
        const timedate = utcDateString;
        // Parse the UTC date string
        console.log(timedate);
        const utcDate = new Date(timedate);

        // Convert to IST (UTC+5:30)
        // const istOffset = 5 * 60 * 60 * 1000; // 5 hours 30 minutes in milliseconds
        const istDate = new Date(utcDate.getTime());

        // Format to dd-MMM-yyyy hh:mm:ss a
        const options = {
            hour: '2-digit',
            minute: '2-digit',
            hour12: true
        };

        // Get the formatted time string
        const formattedTime = istDate.toLocaleString('en-IN', options).replace(',', '');

        return formattedTime;
    }
    followupconvertToIST(utcDateString) {
        const timedate = utcDateString;
        // Parse the UTC date string
        console.log(timedate);
        const utcDate = new Date(timedate);

        // Convert to IST (UTC+5:30)
        //const istOffset = 5 * 60 * 60 * 1000; // 5 hours 30 minutes in milliseconds
        const istDate = new Date(utcDate.getTime());

        // Format to dd-MMM-yyyy hh:mm:ss a
        const options = {
            day: '2-digit',
            month: 'short',
            year: 'numeric',

        };
        const formattedTime = istDate.toLocaleString('en-IN', options).replace(',', '');
        if (formattedTime == 'Invalid Date') {
            return null;
        } else {
            return formattedTime;
        }
    }
    testridefeedback;
    @track testridefeedbackmodale = false;

    handletestridebeedback(event) {
        this.testridefeedback = event.target.value;
    }
    updatedtestdrivefeedbacksave() {
        if (this.testridefeedback != null) {
            updatedtestdrivefeedback({ testrideId: this.selectedrow.TestRideId, feedback: this.testridefeedback })
                .then(result => {
                    this.testridefeedback = null;
                    this.showTestRideFeedbackModal = true;
                    this.testridefeedbackmodale = false;
                    this.recordId = this.selectedrow.Lead__c;

                })
                .catch(error => {
                    console.log('error')
                })
        } else {
            this.handleErrorClick();
        }
    }
    updatedtestdrivefeedbackcancel() {
        this.testridefeedback = null;
        this.testridefeedbackmodale = false;
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
}