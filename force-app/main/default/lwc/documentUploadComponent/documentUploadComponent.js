import { LightningElement, api, track } from 'lwc';
import uploadDocument from '@salesforce/apex/DocumentController.uploadDocument';
import triggerBackgroundCheck from '@salesforce/apex/DocumentController.triggerBackgroundCheck';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DocumentUploadComponent extends LightningElement {
    @api employeeId; // Passed from the parent component
    @track documentName = '';
    @track documentType = '';
    documentTypeOptions = [
        { label: 'Offer Letter', value: 'Offer Letter' },
        { label: 'ID Proof', value: 'ID Proof' },
        { label: 'Resume', value: 'Resume' },
        { label: 'Others', value: 'Others' },
    ];
    acceptedFormats = ['.pdf', '.png', '.jpg', '.doc', '.docx'];

    handleDocumentNameChange(event) {
        this.documentName = event.target.value;
    }

    handleDocumentTypeChange(event) {
        this.documentType = event.detail.value;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            const fileId = uploadedFiles[0].documentId; // Get the uploaded file ID
            this.submitDocument(fileId);
        }
    }

    async submitDocument(fileId) {
        try {
            await uploadDocument({ 
                employeeId: this.employeeId, 
                documentName: this.documentName, 
                documentType: this.documentType, 
                fileId: fileId 
            });

            // Trigger the background check after successful document upload
            await triggerBackgroundCheck({ employeeId: this.employeeId });

            // Show success message
            this.showToast('Success', 'Document uploaded and background check initiated successfully.', 'success');

            // Reset fields
            this.documentName = '';
            this.documentType = '';
        } catch (error) {
            // Handle errors
            console.error('Error uploading document or triggering background check:', error);
            this.showToast('Error', error.body.message || 'Error occurred while uploading document.', 'error');
        }
    }

    // Function to show toast messages
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}