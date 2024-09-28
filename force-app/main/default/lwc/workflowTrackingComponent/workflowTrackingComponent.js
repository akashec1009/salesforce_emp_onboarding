import { LightningElement, wire, track } from 'lwc';
import getWorkflowSteps from '@salesforce/apex/WorkflowController.getWorkflowSteps';
import updateWorkflowStep from '@salesforce/apex/WorkflowController.updateWorkflowStep';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WorkflowTrackingComponent extends LightningElement {
    @track workflowSteps;
    @track error;

    @wire(getWorkflowSteps)
    wiredWorkflowSteps({ error, data }) {
        if (data) {
            this.workflowSteps = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.workflowSteps = undefined;
        }
    }

    handleCompleteStep(event) {
        const workflowId = event.target.dataset.id;
        updateWorkflowStep({ workflowId: workflowId, status: 'Completed' })
            .then(() => {
                this.showToast('Success', 'Workflow step marked as completed!', 'success');
                return refreshApex(this.wiredWorkflowSteps);
            })
            .catch(error => {
                this.showToast('Error', 'Failed to update workflow step: ' + error.body.message, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}