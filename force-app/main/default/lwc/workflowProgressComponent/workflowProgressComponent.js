import { LightningElement, wire, track } from 'lwc';
import getWorkflowSteps from '@salesforce/apex/WorkflowController.getWorkflowSteps';

export default class WorkflowProgressComponent extends LightningElement {
    @track workflowSteps = [];

    @wire(getWorkflowSteps)
    
    wiredWorkflowSteps({ error, data }) {
        if (data) {
            this.workflowSteps = data.map(step => {
                return {
                    id: step.Id,
                    name: step.Step__c,
                    statusClass: step.Status__c === 'Completed' ? 'slds-text-color_success' : 'slds-text-color_error'
                };
            });
        } else if (error) {
            console.error('Error fetching workflow steps:', error);
        }
    }
}