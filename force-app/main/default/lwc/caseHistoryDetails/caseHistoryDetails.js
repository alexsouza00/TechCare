import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CaseHistoryViewer extends LightningElement {
    @api recordId;

    data;
    error;
    isLoading = true;

    connectedCallback() {
        fetch('/services/data/v60.0/', {
            method: 'GET',
            headers: {
                'Accept': 'application/json'
            }
        })
        .then(response => {
            if (!response.ok) {
                throw new Error(`Error: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log('Valid session, available APIs:', data);
        })
        .catch(error => {
            console.error('Invalid or expired session:', error);
        });

        if (this.recordId) {
            this.fetchCaseHistory();
        }
    }

    async fetchCaseHistory() {
        this.isLoading = true;
        try {
            const response = await fetch(`/services/apexrest/CaseHistory/${this.recordId}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                }
            });

            if (!response.ok) {
                throw new Error('Failed to fetch case history from API');
            }

            const result = await response.json();
            this.data = result;
            this.error = undefined;
        } catch (err) {
            this.error = err.message;
            this.data = undefined;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: err.message,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }
}
