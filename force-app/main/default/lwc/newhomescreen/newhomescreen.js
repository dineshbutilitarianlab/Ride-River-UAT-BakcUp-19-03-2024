import { LightningElement, api, wire, track } from 'lwc';
import getList from '@salesforce/apex/LeadCompController.getLeads';
import getFllowups from '@salesforce/apex/LeadCompController.TodaysFollowUp';
import getPreviousfollowUpSummary from '@salesforce/apex/LeadCompController.getPreviousfollowUp';
import getTestRidesdetail from '@salesforce/apex/LeadCompController.getTestDriveRecords';
import Updaterescheduledate from '@salesforce/apex/LeadCompController.rescheduledate';
import cancelride from '@salesforce/apex/LeadCompController.leadstatuscancel';
import completeride from '@salesforce/apex/LeadCompController.leadstatuscomplete';
import Feedback from '@salesforce/apex/LeadCompController.followupfeedback';
import newfollowup from '@salesforce/apex/LeadCompController.newfollowup';
import SearchLead from '@salesforce/apex/homecontroller.getLeadsList';
import getleadrecord from '@salesforce/apex/LeadCompController.getLeaddeatails';
import leadupdate from '@salesforce/apex/LeadCompController.updatelead';
import bookingid from '@salesforce/apex/homecontroller.bookingid';
//import createnewfollowup from '@salesforce/apex/homecontroller.createnewfollowup';
import createnewfollowup from '@salesforce/apex/LeadCompController.createnewfollowup';
import updateLeadStatus from '@salesforce/apex/LeadCompController.updateLeadStatus';
import leadcancellation from '@salesforce/apex/homecontroller.leadcancelreason';
import homerideaddress from '@salesforce/apex/homecontroller.createhomeride';
import storeride from '@salesforce/apex/homecontroller.createstoreride';
//import leadcancellation from '@salesforce/apex/homecontroller.leadcancelreason';
import updatefollowup from '@salesforce/apex/homecontroller.updatefollowup';
import updatetestridedl from '@salesforce/apex/homecontroller.updatedltestride';
import createnewfollowupFromFollowup from '@salesforce/apex/LeadCompController.createnewfollowupFromFollowup';


import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import LightningAlert from 'lightning/alert';

export default class LeadComponent extends NavigationMixin(LightningElement) {
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
    @track homeIndemnity;
    leadowner;
    storedlnumber;
    homedlnumber;
    @track errorMessage = '';
    errordateMessage = '';
    homeExcutiveName;
    storeExcutiveName;
   @track todayfollowupchooseoptionsvalue=null;
   @track newfollowupModal=false;
   leadcancelreason=null;
   @track lostleadtrue=false;
   reasonvalue=null;
   @track istart=false;
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
        this.homeIndemnity = event.target.unchecked;
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

    get leadsourceoptions() {
        return [
            { label: 'Walk-In', value: 'Walk-In' },
            { label: 'Calendly', value: 'Calendly' },
            { label: 'Telephone', value: 'Telephone' },
            { label: 'Bike Dekho', value: 'Bike Dekho' },
            { label: 'CRM - Meta HTR', value: 'CRM - Meta HTR' },
            { label: 'Employee Referral', value: 'Employee Referral' },
            { label: 'External Referral', value: 'External Referral' },
            { label: 'Partner', value: 'Partner' },
            { label: 'Trade Show', value: 'Trade Show' },
            { label: 'Web', value: 'Web' },
            { label: 'Word of mouth', value: 'Word of mouth' },
            { label: 'Email-To-Lead', value: 'Email-To-Lead' },
            { label: 'CTI', value: 'CTI' },
            { label: 'Public Relations', value: 'Public Relations' },
            { label: 'Seminar - Internal', value: 'Seminar - Internal' },
            { label: 'Seminar - Partner', value: 'Seminar - Partner' },
            { label: 'Other', value: 'Other' },
            { label: 'WhatsApp', value: 'WhatsApp' },

        ];
    }

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
                label: 'Completed',
                name: 'NewFollowup',
                title: 'New Followup',
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
            typeAttributes: {
                label: { fieldName: 'LeadName' },
                name: 'Veiw_lead',
                initialWidth: 120,
                variant: 'base'
            }
        },
        { label: 'Mobile', fieldName: 'Mobile', type: 'Number' },
        { label: 'Ridetype', fieldName: 'Ride_Type__c' },
        { label: 'Lead Age', fieldName: 'Lead_Age__c' },
        {
            label: 'Test Ride Time', fieldName: 'TestRideTime',
            type: 'date', typeAttributes: {
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            }
        },
         {
            type: 'button',
            initialWidth: 120,
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
        },

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
    }
    handleTestRides() {
        console.info('handleTestRides');
        this.getFgetTestRidesdetails();
        this.ifFollowUp = false;
        this.leaddetails = false;
        this.ifTesTRideUp = true;
        this.Ridetypetrue = false;
    }

    handleLeadConvert1(){
        console.log('>>>>>>>');
    }

    handleLeadConvert() {
        console.log('method called>>>>>>');
        /*this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'runtime_sales_lead__convertDesktopConsole'
            },
            state: {
                leadConvert__leadId: this.recordId //Pass your record Id here
            }
        });*/
        /*this[NavigationMixin.Navigate]({ 
            type: 'standard__webPage', 
            attributes: { url: '/lead/leadconvert.jsp?retURL=/{!recordId}&id=' + this.recordId } 
        });*/
    }

    handleChangeleadstatus(event) {
        this.LeadStatus = event.detail.value;
    }
    handleChangeleadReason(event) {
        this.leadReason = event.detail.value;
        console.log('handleChangeleadReason: ', this.leadReason);
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
            cancelride({ testrideId: this.selectedrow.TestRideId, cancelreason: this.cancelreason })
                .then(result => {
                    console.log('success');
                    this.cancelreason = null;
                    this.showcancelModal = false;
                    this.getFgetTestRidesdetails();
                    const message = 'Test Ride Cancel Successfully';
                    //this.handleSuccessClick(message);
                })
                .catch(error => {
                    console.log('error handelcancelreason', error);
                    this.errorMessage = error;
                    this.handleErrorClick();
                });
            console.log('',);
            createnewfollowup({ testrideId: this.testrideId ? this.testrideId : null, leadid: this.recordId, followupdate: this.newcNowshowfollowupdate, feedbackvalue: this.newFollowupfeedbck })
                .then(result => {
                    console.log('sucess');
                    this.handlenewfollowupcancelClick();
                    this.newfollowupdate = null;
                    this.newfollowupname = null;
                    this.showcancelModal = false;
                    this.newFollowupfeedbck = null;
                    this.getFollowupdetails();
                    const message = 'New Follow up Created Successfully';
                    this.handleSuccessClick(message);
                })
        } else {
            console.log('Action canceled');
        }
    }
    closecancelModal() {
        this.showcancelModal = false;
        this.cancelreason = null;
    }
    @track errorforclosedLost = false;
    handlesave() {
        console.log('save lead', this.city);
        console.log('save leadReason', this.leadReason);
        if (this.LeadStatus == 'close lost' && this.leadReason == null && this.leadReason == undefined) {
            this.errorforclosedLost = true;
            LightningAlert.open({
                message: 'Please provide the Closer Reason',
                theme: 'error',
                label: 'Error!',
            });

        } else {
            this.errorforclosedLost = false;
            leadupdate({ id: this.selectedrow.Id, lead_source: this.source, phone: this.MobilePhone, Age: this.CustomerAge, email: this.leademail, city: this.city, Country: this.country, PostalCode: this.postalCode, State: this.state, Street: this.street, Status: this.LeadStatus })
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

        let today = new Date();
        this.newcNowshowfollowupdate = new Date(today);
        this.newcNowshowfollowupdate.setDate(this.newcNowshowfollowupdate.getDate() + 1);
        this.newcNowshowfollowupdate = this.newcNowshowfollowupdate.toISOString();
        console.log('this.newcNowshowfollowupdate', this.newcNowshowfollowupdate);
        //this.getFollowupdetails();
        //this.getFgetTestRidesdetails();
    }

    formatDateForInput(date) {
        let isoString = date.toISOString();
        return isoString.slice(0, 19); // Format to 'YYYY-MM-DDTHH:mm'
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
                if (result.lstFollowUp.length > 0) {
                    let valueArr = result.lstFollowUp;
                    let dataWhenfollowUp = [];
                    let arrData = [];
                    for (let i = 0; i < valueArr.length; i++) {
                        if (valueArr[i].Lead__r) {
                            let val = {
                                LeadName: valueArr[i].Lead__c && valueArr[i].Lead__r ? valueArr[i].Lead__r.Name : '',
                                Veiw_lead: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                                Lead_Age__c: valueArr[i].Lead__c && valueArr[i].Lead__r ? valueArr[i].Lead__r.Lead_Age__c : '',
                                FollowupDate: valueArr[i].Follow_Up_Date__c ? valueArr[i].Follow_Up_Date__c : '',
                                Follow_Up__c: valueArr[i].Follow_Up__c ? valueArr[i].Follow_Up__c : '',
                                // Folllow_Up1_Summary__c: valueArr[i].Folllow_Up1_Summary__c ? valueArr[i].Folllow_Up1_Summary__c : '',
                                // Previousfollowupdate: result.oldValue[valueArr[i].Id] ? result.oldValue[valueArr[i].Id].OldValue : '',
                                Previous_Feedback__c: valueArr[i].Previous_Feedback__c ? valueArr[i].Previous_Feedback__c : '',
                                Previous_Followup_date__c: valueArr[i].Previous_Followup_date__c ? valueArr[i].Previous_Followup_date__c : '',
                                Subject: valueArr[i].Subject__c ? valueArr[i].Subject__c : '',
                                FollupId: valueArr[i].Id,
                                leadId: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                                Phone__c: valueArr[i].Lead__c && valueArr[i].Lead__r ? valueArr[i].Lead__r.Phone__c : ''

                            }
                            console.log('phone=' + JSON.stringify(val));
                            arrData.push(val);

                            this.recordId = valueArr[i].Lead__c ? valueArr[i].Lead__c : '';
                        }


                        /* 
                        this.followUpsId = result[i].Id ? result[i].Id : '';
                        console.log('followUpsId : ',this.followUpsId); */
                    }
                    console.log('OUTPUT : ', arrData);

                    this.dataFolloUp = arrData
                    this.followupscount = this.dataFolloUp.length;
                    //this.data
                } else {
                    this.dataFolloUp = [];
                }
                if (result.lstLead) {
                    this.records = result.lstLead;
                    console.log('hhhh=' + JSON.stringify(this.records));
                }
            })
            .catch(error => {
                console.log('Error getfollowUps' + error);
                this.handleErrorClick();
            })
    }
    getFgetTestRidesdetails() {
        getTestRidesdetail()
            .then(result => {


                let arrdata = [];
                if (result.lstTestRide.length > 0) {
                    let valueArr = result.lstTestRide;
                    for (let i = 0; i < valueArr.length; i++) {
                        console.log('valueArr[i].MobilePhone__c>>>>' + JSON.stringify(valueArr[i].MobilePhone__c));
                        let value = {
                            LeadName: valueArr[i].Lead__c ? valueArr[i].Lead__r.Name : '',
                            Mobile: valueArr[i].MobilePhone__c ? valueArr[i].MobilePhone__c : '',
                            Ride_Type__c: valueArr[i].Ride_Type__c ? valueArr[i].Ride_Type__c : '',
                            Lead_Age__c: valueArr[i].Lead__r.Lead_Age__c ? valueArr[i].Lead__r.Lead_Age__c : '',
                            TestRideTime: valueArr[i].Test_Drive_Date__c ? valueArr[i].Test_Drive_Date__c : '',
                             Indemnity__c: valueArr[i].Indemnity__c ? valueArr[i].Indemnity__c : '',
                            Drivers_License_Number__c: valueArr[i].Drivers_License_Number__c ? valueArr[i].Drivers_License_Number__c : '',
                            Lead__c: valueArr[i].Lead__c ? valueArr[i].Lead__c : '',
                            TestRideId: valueArr[i].Id
                        }
                        arrdata.push(value);
                        this.recordId = valueArr[i].Id ? valueArr[i].Id : '';
                    }

                }
                if (result.lstLead) {
                    this.records = result.lstLead;
                }
                this.datatestRides = arrdata;
                this.testridescount = this.datatestRides.length;
                //console.log('getTestRidesdetail'+(this.testridescou));
            })
            .catch(error => {
                console.log('getTestRidesdetail',error);
                this.handleErrorClick();
            });
    }

    handleLeadName(event) {
        this.Searchkey = event.target.value;
        console.log('Searchkey value: ', this.Searchkey);
    }
    handleSearchClick() {
        let searchkey = this.Searchkey;
        if (searchkey) {
            SearchLead({ searchKeyword: this.Searchkey })
                .then(result => {
                    console.log('handleSearchClick result=' + JSON.stringify(result))
                    this.Allleads = false;
                    this.searchlead = true;
                    this.records = result;
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
    @track leadReason;
    getleaddetails() {
        console.log('getleaddetails : ');
        getleadrecord({ leadid: this.selectedrow.Id })
            .then(result => {
                if (result) {
                    console.log('getleaddetails =' + JSON.stringify(result))
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
                    this.leadReason = result.Lost_Reason__c;

                    console.log(this.leadowner);
                    console.log('LeadReason', this.leadReason);
                }



            })
            .catch(error => {
                console.log('error5', error);
                this.handleErrorClick();
            })

    }

    handleNewFeedValue(event) {
        this.newFollowUpFeedBack = event.target.value;

    }
    @track completeValue;
    get completeoptions() {
        return [
            { label: 'Ready for booking', value: 'Ready for booking' },
            { label: 'Test Ride', value: 'Test Ride' },
            { label: 'New Follow Up', value: 'New Follow Up' },
            { label: 'Lost', value: 'Lost' }
        ];
    }
    @track completeNewFollowup = false;
    @track isLostonTestRideComplete = false;
    reasonvalue = null;
    leadcancelreason = null;
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

    handleleadcancelreason(event) {
        this.leadcancelreason = event.target.value;
    }
    todaysfollowuplostleadsave() {
        console.log('leadcancellation', this.selectedrow.Veiw_lead);
        console.log('leadcancellation', this.recordId);
        console.log('leadcancellation', this.reasonvalue);
        console.log('leadcancellation', this.leadcancelreason);
        leadcancellation({ leadid: this.recordId, reason: this.reasonvalue, reasonfeedback: this.leadcancelreason })
            .then(result => {
                console.log('todaysfollowuplostleadsave sucess', result);
                this.todaysfollowuplostleadcancel();
                const message = 'Lead has Lost';
                this.handleSuccessClick(message);
                this.getFgetTestRidesdetails();
                this.getFollowupdetails();
                this.shownewfollowupModal = false;
                this.showFeedbackModal = false;
            })
            .catch(error => {
                console.log('eror11' + JSON.stringify(error));
                this.handleErrorClick();
            })
    }

    todaysfollowuplostleadcancel() {
        this.isLostonTestRideComplete = false;
        this.leadcancelreason = null;
        this.reasonvalue = null;
        this.followoptionchoosevalue = null;
        this.todayfollowupchooseoptionsvalue = null
    }

    hanleCompleteactions(event) {
        let completevalue = event.target.value;
        console.log('handlefeedbacksubmit value', completevalue)
        if (completevalue == 'New Follow Up') {
            this.completeNewFollowup = true;
        } else if (completevalue == 'Test Ride') {
            this.getLeadDetailFromFollowUp();
            this.showTestRideModalBoxhome()
            this.showFeedbackModal = false;
            this.shownewfollowupModal = false;
        } else if (completevalue == 'Ready for booking') {
            this.handleLeadConvert();
        } else if (completevalue == 'Lost') {
            this.isLostonTestRideComplete = true;
            //this.updateLeadClosedLost();
        }
    }

    updateLeadClosedLost() {

        updateLeadStatus({ leadId: this.selectedrow.leadId })
            .then(result => {
                this.getFollowupdetails();
                this.shownewfollowupModal = false;
                this.showFeedbackModal = false;

            })
            .catch(error => {
                console.log('error5');
                this.handleErrorClick();
            })
    }

    getLeadDetailFromFollowUp() {
        getleadrecord({ leadid: this.selectedrow.leadId })
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

                console.log(this.leadowner)


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
            case 'NewFollowup':
                // console.log(this.selectedrow.FollowupDate);
                // let followUpId = this.selectedrow.FollupId;
                // this.formattedDate = this.selectedrow.Previousfollowupdate;
                this.shownewfollowupModal = true;
                this.recordId = this.selectedrow.leadId;
                this.selectedLeadId = this.selectedrow.leadId;
                console.log('Complete this.selectedLeadId', this.selectedLeadId);
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
                this.recordId = this.selectedrow.leadId;
                this.selectedLeadId = this.selectedrow.leadId;
                console.log('handleFolluwUpRowAction Complete');
                break;
            case 'Veiw_lead':
                console.log('veiw lead');
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.selectedrow.leadId,
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
                this.showcancelModal = true;
                this.recordId = this.selectedrow.Lead__c;
                console.log('Cancel');

                break;

            case 'Complete':
            console.log('hhhhhh'+this.selectedrow.Drivers_License_Number__c+'jbdcjj'+this.selectedrow.Indemnity__c)
            if(this.selectedrow.Drivers_License_Number__c!=null && this.selectedrow.Indemnity__c==true){
                this.showFeedbackModal = true;
                this.recordId = this.selectedrow.Lead__c;
                console.log('Complete');
        }else {
            this.handleupdateErrorClick();
        }
                break;
            case 'Veiw_lead':
                console.log('eneter1' + JSON.stringify(this.selectedrow));
                this.navigateToLead(this.selectedrow.Lead__c);
                break;
                case 'Start':
                console.log('eneter1' + JSON.stringify(this.selectedrow));
                this.istart=true;
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
    }

    reschedulesavehandleClick() {
        if (this.datevalue == null) {
            console.log('null value');
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
                            const message = 'Rescheduled of a Test Ride is created Successfully';
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
        this.FeedbackValue = null;
    }

    closeTestRideFeedbackModal() {
        this.showTestRideFeedbackModal = false;
        this.FeedbackValue = null;
    }

    newfollowupsubmit() {
        console.log('this.selectedrow', this.selectedrow);
        createnewfollowupFromFollowup({ followUpId: this.selectedrow.FollupId ? this.selectedrow.FollupId : null, leadid: this.selectedrow.leadId, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
            .then(result => {
                console.log('sucess');
                this.handlebookidcancelClick();
                this.newfollowupdate = null;
                this.newfollowupname = null;
                this.getFollowupdetails();
                //  this.newfollowuptrue = false;
                this.completeNewFollowup = false
                this.newFollowupfeedbck = null;
                this.shownewfollowupModal = false;
                const message = 'New Follow up Created Successfully';
                this.handleSuccessClick(message);
            })
            .catch(error => {
                console.log('error====', error);
                this.errorMessage = this.extractErrorMessage(error);
                this.handleErrorClick();
            })
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

    leadReasonOption = [
        { label: 'Lost to Competitor', value: 'Lost to Competitor' },
        { label: 'Pricing too High', value: 'Pricing too High' },
        { label: 'Not Interested in Buying', value: 'Not Interested in Buying' },
        { label: 'Product Quality Issues', value: 'Product Quality Issues' },
        { label: 'Battery not Detachable', value: 'Battery not Detachable' },
        { label: 'Out of Delivery Area', value: 'Out of Delivery Area' },
        { label: 'Others', value: 'Others' }
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
            this.showTestRideModalBoxhome();
        } else if (selectedValue === 'Store Ride') {
            console.log('Option 2 was selected!');
            this.showTestRideModalBoxstore();
        }
    }
    ridetypemodelshow() {
        this.Ridetypetrue = true;
        console.log('neter')
    }
    handleStepClick(event) {
        const clickedStepValue = event.target.dataset.value;

        // this.currentStep = clickedStepValue;

        this.LeadStatus = clickedStepValue;

        console.log('handleStepClick clickedStepValue : ', this.LeadStatus);
    }
    Convertclick() {
        console.log('>>>>>>>>>');
        if (this.selectedrow.Id) {
            console.log(this.selectedrow.Id)
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.selectedrow.Id,
                    actionName: 'convert',
                    objectApiName: 'Lead'
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
            { label: 'Lost', value: 'Lost' }
        ];
    }
    followoptionchooseoptionsradio(selectedValue) {
        console.log('followoptionchooseoptionsradio Selected Value is: ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.readyforbookingoptiontruemethod();
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 followUp  was selected!');
            this.handlefollowuppopup();
        }

    }
    testRidefollowoptionchooseoptionsradio(selectedValue) {
        console.log('testRidefollowoptionchooseoptionsradio : ' + selectedValue);

        if (selectedValue === 'Ready For Booking') {
            console.log('Option 1 was selected!');
            this.handleLeadConvert();
        } else if (selectedValue === 'Follow up') {
            console.log('Option 2 was selected!');
            this.handlefollowuppopup();
        } else if (selectedValue === 'Lost') {
            console.log('testRidefollowoptionchooseoption Option 3 was selected!');
            this.isLostonTestRideComplete = true;
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
    }
    handlefollowuppopup() {
        // console.log('entry');
        this.newfollowuptrue = true;
    }
    lastFollowUpSummaryHandler(event) {
        this.lastFollowUpSummary = event.target.value;
    }
    handlenewfollowupsaveClick() {
        console.log('handlenewfollowupsaveClick');
        console.log('handlenewfollowupsaveClick followupdate', this.newfollowupdate);
        console.log('handlenewfollowupsaveClick TestRideId', this.selectedrow.TestRideId);
        createnewfollowup({ testrideId: this.selectedrow.TestRideId, leadid: this.recordId, followupdate: this.newfollowupdate, feedbackvalue: this.newFollowupfeedbck })
            .then(result => {
                console.log('sucess');
                this.handlenewfollowupcancelClick();
                this.newfollowupdate = null;
                this.newfollowupname = null;
                this.newfollowuptrue = false;
                this.completeNewFollowup = false
                this.newFollowupfeedbck = null;
                this.getFgetTestRidesdetails();
                this.showFeedbackModal = false;
                const message = 'New Follow up Created Successfully';
                this.handleSuccessClick(message);
            })
            .catch(error => {
                // console.log('error'+error);
                //  this.handleErrorClick();
            })
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
        this.completeNewFollowup = false
        this.newfollowupdate = null;
        this.newfollowupname = null;
        this.newfollowuptrue = false;
        this.newFollowupfeedbck = null;
        this.shownewfollowupModal = false;
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
        // isshowTestRideModalstore=false;
    }
    showTestRideModalBoxhome() {
        this.isshowTestRideModalhome = true;
        //isshowTestRideModalhome=false;
    }
    cancelNewTestRidestrore() {
        this.isshowTestRideModalstore = false;
        this.Ridetypevale = null;
        this.storedlnumber = null;
        this.storeExcutiveName = null;
        this.storeIndemnity = null;
        this.testridestorevaluedate = null;
    }
    cancelNewTestRidehome() {
        this.isshowTestRideModalhome = false;
        this.Ridetypevale = null;
        this.homeExcutiveName = null;
        this.homedlnumber = null;
        this.homeIndemnity = null;
        this.testridehomevaluedate = null;
        this.street = null;
        this.city = null;
        this.state = null;
        this.postalCode = null;
        this.country = null;
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
            this.errordateMessage = 'Please select today (or) a Future Date';
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
                        const message = 'A New Store Ride Created Successfully';
                        this.handleSuccessClick(message);
                    })
                    .catch(error => {
                        console.log('error9')
                        console.log('please enter the data')
                        this.errorMessage = this.extractErrorMessage(error);
                        this.handleErrorClick();
                    })
            }
        }
    }
    handlehomesaveClick() {
        if (this.testridehomevaluedate == null) {
            console.log('null value');
        } else {
            if (this.testridehomevaluedate < this.todaysDate) {
                //this.todaysDate
            } else {
                console.log('ldvfhbg' + this.homecountry + 'jnjndsj' + this.homeExcutiveName);
                console.log('handlehomesaveClick', this.selectedLeadId);
                homerideaddress({ leadid: this.selectedLeadId, testridename: this.leadname, ridedate: this.testridehomevaluedate, street: this.street, city: this.city, state: this.state, country: this.country, postalcode: this.postalCode, Indemnity: this.homeIndemnity, dlnumber: this.homedlnumber, homeExcutiveName: this.homeExcutiveName })
                    .then(result => {
                        this.cancelNewTestRidehome();
                        this.leaddetails = false;
                        this.getFollowupdetails();
                        this.Ridetypevale = null;
                        const message = 'A New Ride Created Successfully';
                        this.handleSuccessClick(message);
                        this.homedlnumber = null;
                        this.testridehomevaluedate = null;


                    })
                    .catch(error => {
                        console.log('error10', error);
                        console.log('Extracting error:', JSON.stringify(error));
                        this.errorMessage = this.extractErrorMessage(error);
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
            label: 'success!',
        });
        //Alert has been closed
    }

    handleErrorClick() {
        console.log('Error message to display:', this.errorMessage);
        LightningAlert.open({
            message: this.errorMessage,
            theme: 'error',
            label: 'Error!',
        });

    }
    handlelfollowuplimitErrorClick() {
        LightningAlert.open({
            message: 'Lead Has Contain  Already 3 FollowUps',
            theme: 'error',
            label: 'Error!',
        });

    }

    extractErrorMessage(error) {

        if (error.body && error.body.fieldErrors && error.body.fieldErrors.Indemnity__c) {
            return error.body.fieldErrors.Indemnity__c[0].message; // Extract the field error message
        }

        else if (error.body && error.body.message) {
            return error.body.message;
        }
        else if (error.message) {
            return error.message;
        }
        else if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        }
        return 'An unknown error occurred';
    }
     closestartModal(){
        this.istart=false;
    }
    startestride(){
        updatetestridedl({testrideId:this.selectedrow.TestRideId,Dlnumber:this.homedlnumber,Indemnity:this.homeIndemnity})
        .then(result=>{
           console.log('sucess');
           this.istart=false;
           this.homedlnumber=null;
           this.homeIndemnity=null;
           const message='Test Ride Successfully Started';
           this.handleSuccessClick(message);
        })
        .catch(result=>{
            console.log('error');
             this.handleErrorClick();
        })
    }
        handleupdateErrorClick(){
             LightningAlert.open({
            message:'Please Select Start Button and Fill DL number and inddemnity ',
            theme: 'error',
            label: 'Error!',
        });

        
    }

}