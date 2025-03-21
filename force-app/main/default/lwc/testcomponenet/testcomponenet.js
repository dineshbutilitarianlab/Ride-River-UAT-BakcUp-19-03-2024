import { LightningElement, api, wire, track } from 'lwc';
import getList from '@salesforce/apex/LeadCompController.getLeads';
import getFllowups from '@salesforce/apex/LeadCompController.TodaysFollowUp';
import getPreviousfollowUpSummary from '@salesforce/apex/LeadCompController.getPreviousfollowUp';
import getTestRidesdetail from '@salesforce/apex/LeadCompController.getTestDriveRecords';
import Updaterescheduledate from '@salesforce/apex/LeadCompController.rescheduledate';
import cancelride from '@salesforce/apex/LeadCompController.leadstatuscancel';
import completeride from '@salesforce/apex/LeadCompController.leadstatuscomplete';
import Feedback from '@salesforce/apex/LeadCompController.followupfeedback';
import SearchLead from '@salesforce/apex/LeadCompController.getLeadsListBySearchKeyWord';
import getleadrecord from '@salesforce/apex/LeadCompController.getLeaddeatails';
import leadupdate from '@salesforce/apex/LeadCompController.updatelead';
import updateLeadStatus from '@salesforce/apex/LeadCompController.updateLeadStatusToClosedLost';
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
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LEAD_SOURCE_FIELD from '@salesforce/schema/Lead.LeadSource';
import getLeadsDetailsByDateRange from '@salesforce/apex/LeadCompController.getLeadsDetailsByDateRange';


export default class Testcomponenet extends NavigationMixin(LightningElement) {
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
    @track bRecordFound = false;
    @track leadsRecordFound = false;
    @track btestRideRecordFound = false;
    @track leaddetailspageopen = false;
    @track leaddetails = false;
    @track ifFollowUp = false;
    @track showLeadDetails = false;
    @track ifTesTRideUp = false;
    @track selectedLeadId = '';
    @track data;
    @track dataFolloUp;
    // for lead pagination
    @track dataLeads;
    @track allLeadsData = []; // storing all data 
    @track currentPage1 = 1;
    @track totalPages = 0;
    @track pageSize1 = 50; // Records per page
    @track visibleRows1 = 12; // Number of visible records per scroll

    // for test ride pagination
    @track allTestRides = [];  // Store all test ride records
    @track datatestRides; // Current records being displayed
    @track totalTestRides = 0;
    @track activePage = 1;
    @track totalRidePages = 0;
    @track ridesPerBatch = 50; // Records per page
    @track visibleTestRideRows = 12; // Number of visible records per scroll

    // pagination var for Follow ups
    @track allFollowUps = [];  // Store all follow-up records
    //@track displayedFollowUps = []; // Current records being displayed
    @track totalFollowUps = 0;
    @track currentFollowUpPage = 1;
    @track totalFollowUpPages = 0;
    @track followUpsPerBatch = 50; // Records per page
    @track maxVisibleFollowUps = 12; // Number of visible records per scroll

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
    leadsCount;
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
   @track homerideAddress=false;
         psname;

    @track url = '';
     leadSourceOptions = [];
    recordTypeId;

    // for pagination of Leads 
    @track pageNumber = 1;
    pageSize = 50;
    disablePrevious = true;
    disableNext = false;

    // for closed lost 
    @track showConfirmModal = false; 

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
            const leadSourceOp= data.values;
             this.leadSourceOptions = leadSourceOp.map(picklist => ({
                label: picklist.label,
                value: picklist.value
            }));
                    


        } else if (error) {
            this.error = error;
        }
    }
     

    
    handlestreet(event){
        this.street=event.target.value;
    }
    handlecity(event){
        this.city=event.target.value;
    }
    handlepostalcode(event){
        this.postalCode=event.target.value;
    }
     handlecountry(event) {
        this.country = event.detail.value;
    }
     handlestate(event) {
        this.state = event.detail.value;
    }
    handlepsname(event){
        this.psname=event.target.value;
    }
    @wire(CurrentPageReference)
    getStateParameters(CurrentPageReference) {
        
        this.url = window.location.origin;
    }

    connectedCallback() {
        this.loadLeadDetails();
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
        if(this.typevalue=='Home Ride'){
           this.homerideAddress=true;
        }else{
            this.homerideAddress=false;
        }
    }


    columns = [
        { label: 'Name', fieldName: 'Name', typeAttributes: { label: { fieldName: 'Name' }, name: 'leadName', variant: 'base' } },
        { label: 'Mobile', fieldName: 'Phone', cellAttributes: { class: 'fixed-width' } },
        { label: 'Lead Age', fieldName: 'Lead_Age__c', cellAttributes: { class: 'fixed-width' } },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', cellAttributes: { class: 'fixed-width' } },
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

    leadsColumns = [
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
        { label: 'Lead Age', fieldName: 'Lead_Age__c' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
    ];
    

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
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Follow-Up Date', fieldName: 'FollowupDate', type: 'date' },
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
            label: 'Schedule Date',
            fieldName: 'Test_Ride_Date__c',
            initialWidth: 100
        },
        // {
        //     label: 'Lead Age',
        //     fieldName: 'Lead_Age__c',
        //     initialWidth: 100
        // },
        // {
        //     label: 'Reschedule Date',
        //     fieldName: 'Reschedule_Date__c',
        //     initialWidth: 100
        // },
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
                label: 'Closed Lost',
                name: 'Closed Lost',
                title: 'Closed Lost',
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
        debugger;
        console.info('handleFollowUp');
        this.getFollowupdetails(this.fromDate,this.toDate);
        this.showLeadDetails = false;
        this.Allleads=false;
        this.ifFollowUp = true;
        this.leaddetails = false;
        this.ifTesTRideUp = false;
        this.Ridetypetrue = false;
        this.shownewfollowupModal = false;
    }
    handleTestRides() {
        console.info('handleTestRides');
        this.getFgetTestRidesdetails(this.fromDate, this.toDate);
        this.showLeadDetails = false;
        this.Allleads = false;
        this.ifFollowUp = false;
        this.leaddetails = false;
        this.ifTesTRideUp = true;
        this.Ridetypetrue = false;
        this.shownewfollowupModal = false;
    }

    // added on 25 feb 2025
    handleLeadsDetails() {
        console.info('handleLeadsDetails');
        //this.getFgetTestRidesdetails();
        this.showLeadDetails = true;
        this.Allleads = false;
        this.ifFollowUp = false;
        this.leaddetails = false;
        this.ifTesTRideUp = false;
        this.Ridetypetrue = false;
        this.shownewfollowupModal = false;
    }

    // lead transfer
    handleTransferRequest() {
        if (!this.selectedrow.Id) {
            this.showToast('Error', 'No Lead found to submit for approval', 'error');
            return;
        }

        submitLeadForApproval({ leadId: this.selectedrow.Id })
            .then(result => {
                this.showToast('Success', result, 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body ? error.body.message : 'Approval failed', 'error');
            });
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

    @track fromDate;
    @track toDate;

    // Handle From Date Change
    handleFromDateChange(event) {
        this.fromDate = event.target.value;
    }

    // Handle To Date Change
    handleToDateChange(event) {
        this.toDate = event.target.value;
    }

    
    filterLeadsByDateRange() {
        debugger;
        // if (!this.fromDate || !this.toDate) {
        //     alert('Please select both From Date and To Date.');
        //     return;
        // }

        this.leadsRecordFound = true;
        this.getLeadsDetails(this.fromDate, this.toDate);
    }

    filterLeads() {
        debugger;
        // if (!this.fromDate || !this.toDate) {
        //     alert('Please select both From Date and To Date.');
        //     return;
        // }

        this.bRecordFound = true;
        this.getFollowupdetails(this.fromDate, this.toDate);
    }

    filterTestRides() {
        debugger;
 

        this.btestRideRecordFound = true;
        this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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
                        this.Ridetypevale=null;
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
        
        leadupdate({ id: this.selectedrow.Id, lead_source: this.source, phone: this.MobilePhone, Age: this.CustomerAge, email: this.leademail, city: this.city, Country: this.country, PostalCode: this.postalCode, State: this.state, Street: this.street, Status: this.LeadStatus,psname:this.psname})
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

        // for pagination added by rohit
// ------------------------------  //
handlePrevious() {
    if (this.pageNumber > 1) {
        this.pageNumber--;
        this.getLeadDetails();
    }
}

handleNext() {
    this.pageNumber++;
    this.getLeadDetails();
}

// ------------------------------  //

// for all leads searcing next and previous
    // Handle Next Page
    handleNext1() {
        if (this.currentPage1 < this.totalPages) {
            this.currentPage1++;
            this.updatePageData();
        }
    }

    // Handle Previous Page
    handlePrevious1() {
        if (this.currentPage1 > 1) {
            this.currentPage1--;
            this.updatePageData();
        }
    }

    // Getters for Button Enable/Disable Logic
    get disablePrevious1() {
        return this.currentPage1 === 1;
    }

    get disableNext1() {
        return this.currentPage1 >= this.totalPages;
    }

    connectedCallback() {
        this.getLeadDetails();

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
        getList({ pageSize: this.pageSize, pageNumber: this.pageNumber })
            .then(result => {
                console.log('hcvsshshs=' + JSON.stringify(result));
                //  this.testridescount=result;
                // console.log('getTestRidesdetail'+(this.testridescount.length));
                this.records = result;
                //consol.log('records '+this.records);

                // Disable Next if less than pageSize records are returned
                this.disableNext = result.length < this.pageSize;
                this.disablePrevious = this.pageNumber === 1;
            })
            .catch(error => {
                console.log(error);
                // this.handleErrorClick();
            })
    }

    getLeadsDetails(fromDate, toDate) {
        debugger;
        getLeadsDetailsByDateRange({fromDate, toDate })
            .then(result => {
                debugger;
                console.log('result : ' + JSON.stringify(result));
    
                let arrData = result.map(lead => {
                    return {
                        id: lead.id,  // Ensure Id is present
                        LeadName: lead.name,  // Matches datatable column fieldName
                        Phone__c: lead.phone,  // Matches datatable column fieldName
                        CreatedDate: lead.createdDate,  // Matches datatable column fieldName
                        Lead_Age__c: lead.age , // Matches datatable column fieldName
                        Status: lead.status
                    };
                });
                
                this.allLeadsData = arrData;
                this.leadsCount = this.allLeadsData.length;
                this.totalPages = Math.ceil(this.leadsCount / this.pageSize1);
                this.currentPage1 = 1;
                this.updatePageData();
                    
            })
            .catch(error => {
                console.log('Error ' + error);
                this.handleErrorClick();
            })
    }

        // Update Data for Current Page
        updatePageData() {
            const startIndex = (this.currentPage1 - 1) * this.pageSize1;
            const endIndex = startIndex + this.pageSize1;
            this.dataLeads = this.allLeadsData.slice(startIndex, endIndex);
        }


    getFollowupdetails(fromDate, toDate) {
        debugger;
        getFllowups({fromDate, toDate })
            .then(result => {
                debugger;
                console.log('result : ' + JSON.stringify(result));
                    let valueArr = result.lstFollowUp;
                    let dataWhenfollowUp = [];
                    let arrData = [];
                    for (let i = 0; i < valueArr.length; i++) {
                        let val = {
                           LeadName: valueArr[i]?.Lead__c ? valueArr[i]?.Lead__r?.Name || '' : '',
                            Veiw_lead: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                           Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r?.Lead_Age__c ||'' : '',
                            FollowupDate: this.followupconvertToIST(valueArr[i].Follow_Up_Date__c),
                            Follow_Up__c: valueArr[i].Follow_Up__c ? valueArr[i].Follow_Up__c : '',
                            // Folllow_Up1_Summary__c: valueArr[i].Folllow_Up1_Summary__c ? valueArr[i].Folllow_Up1_Summary__c : '',
                            // Previousfollowupdate: result.oldValue[valueArr[i].Id] ? result.oldValue[valueArr[i].Id].OldValue : '',
                            Previous_Feedback__c: valueArr[i].Feedback__c ? valueArr[i].Feedback__c : '',
                            Previous_Followup_date__c: this.followupconvertToIST(valueArr[i].Previous_Followup_date__c),
                            Subject: valueArr[i].Subject__c ? valueArr[i].Subject__c : '',
                            FollupId: valueArr[i].Id,
                            Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                            Phone__c: valueArr[i].Lead__c ? valueArr[i].Lead__r?.Phone ||'' : '',
                            Status__c: valueArr[i].Status__c ? valueArr[i].Status__c : '',
                           //State: valueArr[i].Lead__c ? valueArr[i].Lead__r.State : '',
                          // City: valueArr[i].Lead__c ? valueArr[i].Lead__r.City : '',
                         //  Street: valueArr[i].Lead__c ? valueArr[i].Lead__r.Street : '',
                          // PostalCode: valueArr[i].Lead__c ? valueArr[i].Lead__r.PostalCode : ''


                        }
                        console.log('phone=' + JSON.stringify(val.Phone__c));
                        arrData.push(val);

                        this.recordId = valueArr[i].Lead__c ? valueArr[i].Lead__c : '';

                        /* 
                        this.followUpsId = result[i].Id ? result[i].Id : '';
                        console.log('followUpsId : ',this.followUpsId); */
                    }
                    console.log('OUTPUT : ', arrData);

                    //this.dataFolloUp = arrData
                   // this.followupscount = this.dataFolloUp.length;
                    
                    this.allFollowUps = arrData;
                    this.totalFollowUps = this.allFollowUps.length;
                    this.followupscount = this.allFollowUps.length;
                    this.totalFollowUpPages = Math.ceil(this.totalFollowUps / this.followUpsPerBatch);
                    this.currentFollowUpPage = 1; // Reset to first page
                    this.refreshFollowUpData();
                
                if (result.lstLead) {
                    this.records = result.lstLead;
                    console.log('hhhh=' + JSON.stringify(this.records));
                }
            })
            .catch(error => {
                console.log('Error ' + error);
               // this.handleErrorClick();
            })
    }

        // Refresh Follow-Up Data Based on Current Page
        refreshFollowUpData() {
            const firstIndex = (this.currentFollowUpPage - 1) * this.followUpsPerBatch;
            const lastIndex = firstIndex + this.followUpsPerBatch;
            this.dataFolloUp = this.allFollowUps.slice(firstIndex, lastIndex);
    
            // Apply visible limit
            this.dataFolloUp = followUpBatch.slice(0, this.maxVisibleFollowUps);
        }

            // Navigate to Next Page
    moveToNextFollowUpPage() {
        if (this.currentFollowUpPage < this.totalFollowUpPages) {
            this.currentFollowUpPage++;
            this.refreshFollowUpData();
        }
    }

    // Navigate to Previous Page
    moveToPreviousFollowUpPage() {
        if (this.currentFollowUpPage > 1) {
            this.currentFollowUpPage--;
            this.refreshFollowUpData();
        }
    }

    // Disable Button Logic
    get disableFollowUpPrev() {
        return this.currentFollowUpPage === 1;
    }

    get disableFollowUpNext() {
        return this.currentFollowUpPage >= this.totalFollowUpPages;
    }

    getFgetTestRidesdetails(fromDate, toDate) {
        debugger;
        getTestRidesdetail({fromDate, toDate })
            .then(result => {


                let arrdata = [];
            
                    let valueArr = result.lstTestRide;
                    for (let i = 0; i < valueArr.length; i++) {
                        console.log('valueArr[i].MobilePhone__c>>>>' + JSON.stringify(valueArr[i].MobilePhone__c));
                        let value = {
                           LeadName: valueArr[i]?.Lead__c ? valueArr[i]?.Lead__r?.Name || '' : '',
                            Mobile: valueArr[i].MobilePhone__c ? valueArr[i].MobilePhone__c : '',
                            Ride_Type__c: valueArr[i].Ride_Type__c ? valueArr[i].Ride_Type__c : '',
                            Lead_Age__c: valueArr[i].Lead__c ? valueArr[i].Lead__r?.Lead_Age__c ||'' : '',
                            //  datandtime: valueArr[i].Test_Drive_Date__c ? valueArr[i].Test_Drive_Date__c : '',
                            Test_Ride_Date__c: this.followupconvertToIST(valueArr[i].Test_Ride_Date__c),
                            Reschedule_Date__c: this.followupconvertToIST(valueArr[i].Reschedule_Date__c),
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
                    this.isTodaysTestRideList = result.lstLead;
                }
                // this.datatestRides = arrdata;
               // this.testridescount = this.datatestRides.length;

                this.allTestRides = arrdata;
                this.testridescount = this.allTestRides.length;
                this.totalTestRides = this.allTestRides.length;
                this.totalRidePages = Math.ceil(this.totalTestRides / this.ridesPerBatch);
                this.activePage = 1; // Reset to first page
                this.refreshRideData();
                //console.log('getTestRidesdetail'+(this.testridescou));
            })
            .catch(error => {
                console.log(error);
               // this.handleErrorClick();
            });
    }

        // Refresh Test Ride Data Based on Current Page
        refreshRideData() {
            const firstIndex = (this.activePage - 1) * this.ridesPerBatch;
            const lastIndex = firstIndex + this.ridesPerBatch;
            this.datatestRides = this.allTestRides.slice(firstIndex, lastIndex);
        }

            // Navigate to Next Page
    goToNextRidePage() {
        if (this.activePage < this.totalRidePages) {
            this.activePage++;
            this.refreshRideData();
        }
    }

    // Navigate to Previous Page
    goToPreviousRidePage() {
        if (this.activePage > 1) {
            this.activePage--;
            this.refreshRideData();
        }
    }

    // Disable Button Logic
    get disableRidePrev() {
        return this.activePage === 1;
    }

    get disableRideNext() {
        return this.activePage >= this.totalRidePages;
    }

    handleLeadName(event) {
        this.Searchkey = event.target.value;
        console.log('Searchkey value: ', this.Searchkey);
    }
    handleSearchClick() {
        let searchkey = this.Searchkey;
        this.Allleads=true; // added for lead view 
        this.ifFollowUp = false;
        this.ifTesTRideUp = false;
        this.showLeadDetails = false;
        this.leaddetails = false;
        if (searchkey) {
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
            this.connectedCallback();
        }
    }
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        this.selectedrow = row;
        switch (actionName) {
            case 'Deatils':
                this.leaddetailspageopen = true;
                this.leaddetails = true;
                this.Allleads = false;
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
                    this.getFollowupdetails(this.fromDate,this.toDate);
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
                this.psname=result.PS_Name__c;
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
                console.log('veiw lead');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.selectedrow.Lead__c,
                        objectApiName: 'Lead',
                        actionName: 'view'
                    }
                });
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
            case 'Closed Lost':  // New action added
                debugger;
                this.openShowModalForClosedLost();
                //this.closeLead(row);
                
                console.log('Lead marked as Closed Lost: ' + row.Id);
                break;    
            default:
        }

    }

    openreschedule() {
        this.Rescheduledate = true;
    }

    openShowModalForClosedLost() {
        this.showConfirmModal = true;
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
        this.typevalue=null;
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
                            this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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

    // for closed lost modal 

    confirmClosedLost() {
        debugger;
        if (!this.selectedrow && this.reasonvalue != null && this.leadcancelreason != null) {
            console.error('No row selected!');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select all mandatory fields.',
                    variant: 'error'
                })
            );
            return;
        }
        // Call Apex method to update the Lead's Status to 'Closed Lost'
        if (this.reasonvalue != null && this.leadcancelreason) {
        updateLeadStatus({ testDriveId: this.selectedrow.TestRideId,reason: this.reasonvalue, reasonfeedback: this.leadcancelreason})
            .then(() => {
                debugger;
                console.log('Lead successfully marked as Closed Lost.');
               // this.refreshData();  // Refresh the data if needed
               this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Lead has been marked as Closed Lost.',
                    variant: 'success'
                })
            );
               //close the modal
               this.showConfirmModal = false;

               // Refresh the data 
               this.getFgetTestRidesdetails(this.fromDate, this.toDate);
            })
            .catch(error => {
                console.error('Error updating Lead: ', error);
            });
        }else {
            this.handleErrorClick();
        }
    }

        // Handle Cancel Button in Modal
        handleCancel() {
            this.showConfirmModal = false;
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
                        //this.updatefollowupcomplete();
                        this.getFollowupdetails(this.fromDate,this.toDate);

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
        debugger;
        console.log('handlenewfollowupsaveClick');
        if (this.newfollowupdate == null) {
            console.log('null value');
        } else {
            if (this.newfollowupdate < this.todaysDate) {
                //this.todaysDate 
            } else {
                let leadIdValue = this.selectedrow.Lead__c ? this.selectedrow.Lead__c : this.selectedrow.Id;
                createnewfollowup({ leadid: leadIdValue, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
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
                       this.getFgetTestRidesdetails(this.fromDate,this.toDate);
                       this.getFollowupdetails(this.fromDate,this.toDate);
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
                        this.getFgetTestRidesdetails(this.fromDate, this.toDate);
                        this.getFollowupdetails(this.fromDate,this.toDate);

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
                        this.getFgetTestRidesdetails(this.fromDate, this.toDate);
                        this.getFollowupdetails(this.fromDate,this.toDate);
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
            this.country=this.selectedrow.Country;
            this.state=this.selectedrow.State;
            this.city=this.selectedrow.City;
            this.street=this.selectedrow.Street;
            this.postalCode=this.selectedrow.PostalCode;
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
                    this.updatedtestridecomplete();
                    this.getFgetTestRidesdetails(this.fromDate,this.toDate);
                    this.getFollowupdetails(this.fromDate,this.toDate);
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
        console.log('account called>>>>'+this.selectedrow.Id);
        console.log('account called>>>>'+this.recordId);
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
        console.log('navigateToNewAccount1 called>>>>'+this.selectedrow.Id);
        console.log('account called>>>>'+this.recordId);
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
        { label: 'Out of Delivery Area', value: 'Out of Delivery Area' },
        { label: 'Lack of Budget', value: 'Lack of Budget' },
        { label: 'No Buying Intent', value: 'No Buying Intent' },
        { label: 'Wrong Product Fit', value: 'Wrong Product Fit' },
        { label: 'Unresponsive- Max Attempt', value: 'Unresponsive- Max Attempt' },
        { label: 'Already Purchased Elsewhere', value: 'Already Purchased Elsewhere' },
        { label: 'Not the Decision Maker', value: 'Not the Decision Maker' },
        { label: 'Timing Not Right', value: 'Timing Not Right' },
        { label: 'Location Issue', value: 'Location Issue' },
        { label: 'Invalid Contact Information', value: 'Invalid Contact Information' },

    ];
    reasonhandleChange(event) {
        this.reasonvalue = event.detail.value;
    }
    updatefollowupcomplete() {
        updatefollowup({ followupId: this.selectedrow.FollupId })
            .then(result => {
                console.log('sucess');
                this.getFollowupdetails(this.fromDate,this.toDate);
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
                    this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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
        debugger;
        if (this.reasonvalue != null && this.leadcancelreason) {

            leadcancellation({ leadid: this.selectedrow.Id, reason: this.reasonvalue, reasonfeedback: this.leadcancelreason })
                .then(result => {
                    console.log('sucess');
                    this.getFollowupdetails(this.fromDate,this.toDate);
                    this.todaysfollowuplostleadcancel();
                    const message = 'Lead has Lost';
                    this.handleSuccessClick(message);
                    this.updatefollowupcomplete();
                    this.leaddetails = false;
                    this.Ridetypevale = null;
                    
                    this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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
                                this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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
                        this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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
                this.getFgetTestRidesdetails(this.fromDate, this.toDate);

            })
            .catch(error => {
                console.log('error');
            })

    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
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
                    this.getFollowupdetails(this.fromDate,this.toDate);
                    this.getFgetTestRidesdetails(this.fromDate, this.toDate);
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