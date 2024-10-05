import { LightningElement, wire, track } from 'lwc';
import getWorkflowSteps from '@salesforce/apex/WorkflowController.getWorkflowSteps';
import updateWorkflowStep from '@salesforce/apex/WorkflowController.updateWorkflowStep';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
    { label: 'Employee Name', fieldName: 'employeeName', type: 'text' },
    { label: 'Employee ID', fieldName: 'employeeId', type: 'text' },
    { label: 'Email', fieldName: 'email', type: 'email' },
    { label: 'Department', fieldName: 'department', type: 'text' },
    { label: 'Step', fieldName: 'step', type: 'text' },
    { label: 'Status', fieldName: 'status', type: 'text' },
    {
        type: 'button',
        typeAttributes: {
            label: { fieldName: 'buttonLabel' },
            name: 'complete',
            variant: 'brand',
            disabled: { fieldName: 'isCompleted' }
        }
    }
];

export default class WorkflowTrackingComponent extends LightningElement {
    @track workflowSteps = [];
    @track error;
    columns = COLUMNS;

    @wire(getWorkflowSteps)
    wiredSteps(result) {
        this.wiredData = result;
        const { data, error } = result;
        if (data) {
            this.workflowSteps = data.map(item => {
                // Add safety checks to handle missing or null related data
                const employee = item.Employee__r || {};
                return {
                    id: item.Id,
                    employeeName: employee.Name || 'N/A', // Default to 'N/A' if the employee name is missing
                    employeeId: employee.Employee_ID__c || 'N/A', // Default to 'N/A' if Employee ID is missing
                    email: employee.Email__c || 'N/A', // Default to 'N/A' if Email is missing
                    department: employee.Department__c || 'N/A', // Default to 'N/A' if Department is missing
                    step: item.Step__c,
                    status: item.Status__c,
                    buttonLabel: item.Status__c === 'Completed' ? 'Completed' : 'Mark as Completed',
                    isCompleted: item.Status__c === 'Completed'
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.workflowSteps = undefined;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'complete' && row.status !== 'Completed') {
            this.completeStep(row.id);
        }
    }

    completeStep(workflowId) {
        updateWorkflowStep({ workflowId:workflowId , status: 'Completed' })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Step marked as completed.',
                        variant: 'success',
                    })
                );
                // Refresh the datatable to update button visibility
                return refreshApex(this.wiredData);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating step',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }
}