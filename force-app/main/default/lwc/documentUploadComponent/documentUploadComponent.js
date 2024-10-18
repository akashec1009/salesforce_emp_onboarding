import { LightningElement, api, track } from 'lwc';
import uploadDocument from '@salesforce/apex/DocumentController.uploadDocument';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DocumentUploadComponent extends LightningElement {
    employeeId = '';
    documentName = '';
    documentType = '';
    documentContent = null;

    handleNameChange(event) {
        this.documentName = event.target.value;
    }

    handleTypeChange(event) {
        this.documentType = event.target.value;
    }

    handleEmployeeIdChange(event) {
        this.employeeId = event.target.value;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                this.documentContent = reader.result.split(',')[1]; // Base64 encoded file content
            };
            reader.readAsDataURL(file);
        }
    }

    handleUpload() {
        if (this.documentName && this.documentType && this.documentContent && this.employeeId) {
            uploadDocument({
                documentName: this.documentName,
                documentType: this.documentType,
                documentContent: this.documentContent,
                employeeId: this.employeeId
            })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Document uploaded successfully',
                        variant: 'success',
                    })
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error uploading document',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all fields and upload a file',
                    variant: 'error',
                })
            );
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png', '.jpg']; 
    }
}