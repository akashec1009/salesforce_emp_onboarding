import { LightningElement, track } from 'lwc';
import createEmployee from '@salesforce/apex/EmployeeController.createEmployee';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import initiateOnboarding from '@salesforce/apex/WorkflowController.initiateOnboarding';

export default class OnboardingFormComponent extends LightningElement {
    @track employeeName = '';
    @track email;
    @track phoneNumber;
    @track department;
    @track jobTitle;
    @track startDate;
    @track onboardingStatus = 'In Progress';
    
    get departmentOptions() {
        return [
            { label: 'HR', value: 'HR' },
            { label: 'Finance', value: 'Finance' },
            { label: 'IT', value: 'IT' },
            { label: 'Marketing', value: 'Marketing' }
        ];
    }

    get statusOptions() {
        return [
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Completed', value: 'Completed' },
            { label: 'Pending', value: 'Pending' }
        ];
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        if (field === 'name') {
            this.employeeName = event.target.value;
        } else if (field === 'email') {
            this.email = event.target.value;
        } else if (field === 'phone') {
            this.phoneNumber = event.target.value;
        } else if (field === 'department') {
            this.department = event.target.value;
        } else if (field === 'jobTitle') {
            this.jobTitle = event.target.value;
        } else if (field === 'startDate') {
            this.startDate = event.target.value;
        } else if (field === 'status') {
            this.onboardingStatus = event.target.value;
        }
    }

    handleSubmit() {
        createEmployee({ 
            name: this.employeeName, 
            email: this.email, 
            phone: this.phoneNumber, 
            department: this.department, 
            jobTitle: this.jobTitle, 
            startDate: this.startDate, 
            onboardingStatus: this.onboardingStatus 
        })
        .then(() => {
            this.showToast('Success', 'Employee onboarded successfully!', 'success');
            initiateOnboarding({ employeeId: result.Id })
            .then(() => {
                this.showToast('Success', 'Onboarding workflow initiated for ' + result.Name, 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error initiating onboarding workflow: ' + error.body.message, 'error');
            });
            // Clear the form fields after submission
            this.clearForm();
        })
        .catch(error => {
            this.showToast('Error', 'Failed to onboard employee: ' + error.body.message, 'error');
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

    clearForm() {
        this.employeeName = '';
        this.email = '';
        this.phoneNumber = '';
        this.department = '';
        this.jobTitle = '';
        this.startDate = '';
        this.onboardingStatus = 'In Progress';
    }
}