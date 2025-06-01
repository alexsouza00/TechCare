import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SLA_DEADLINE from '@salesforce/schema/Case_Request__c.SLA_Deadline__c';
import STATUS from '@salesforce/schema/Case_Request__c.Status__c';
import reopenCase from '@salesforce/apex/CaseRequestController.reopenCase';
import getSlaDuration from '@salesforce/apex/CaseHistoryController.getSlaDuration';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseRequestDetails extends LightningElement {
    @api recordId;
    data;
    error;

    deadline;
    slaDuration;
    timer;
    setTimeInterval;

    status;
    statusCheck;    

    @wire(getRecord, { recordId: '$recordId', fields: [SLA_DEADLINE, STATUS] })
    wiredCase({ data, error }) {
        if (data) {

            this.status = getFieldValue(data, STATUS);
            this.deadline = getFieldValue(data, SLA_DEADLINE);
            clearInterval(this.setTimeInterval);

            this.setTimeInterval = setInterval(() => {

                let slaDate = new Date(this.deadline);
                let slaTime = slaDate.getTime();

                let currentDateTime = new Date().getTime();

                let timeDifference = slaTime - currentDateTime;

                this.timer = 'I m timeDifference ' + timeDifference;

                if (data) {
                    this.status = getFieldValue(data, STATUS);
                    this.statusCheck = this.status === 'Closed';
                }

                if (timeDifference <= 0) {
                    clearInterval(this.setTimeInterval);
                    this.timer = 'SLA deadline has expired.';

                } else if (this.status === 'Closed') {
                    this.timer = 'Finished in ' + this.slaDuration;

                }
                else {
                    let hours = Math.floor((timeDifference % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    let minutes = Math.floor((timeDifference % (1000 * 60 * 60)) / (1000 * 60));
                    let seconds = Math.floor((timeDifference % (1000 * 60)) / 1000);

                    this.timer = hours + "hrs " + minutes + "mins " + seconds + "secs ";
                }
            }, 1000)

        } else if (error) {
            console.error('Erro ao buscar SLA:', error);
        }
    }

     connectedCallback() {
    getSlaDuration({ caseRequestId: this.recordId })
        .then(result => {
            this.slaDuration = result;
        })
        .catch(error => {
            console.error(error);
        });
}

    handleReopenCase() {
        reopenCase({ caseId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'sucess',
                        message: 'Case was reopened successfully!',
                    })
                );
                setTimeout(() => {
                    location.reload();
                }, 1500);
            }).catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro' + error.body.message,
                    })
                );
            });
    }
}
