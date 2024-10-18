public with sharing class DocumentController {
    @AuraEnabled
    public static Id uploadDocument(String employeeId, String documentName, String documentType) {
        try{
             
        Document__c newDocument = new Document__c();
        newDocument.Name = documentName;
        newDocument.DocumentType__c = documentType;
        newDocument.Employee__c = employeeId;
        newDocument.Uploaded_Date__c = Date.today();

        insert newDocument;
        return newDocument.Id;
        }
       
         catch (Exception e) {
            throw new AuraHandledException('Error uploading document: ' + e.getMessage());
        }
    }
}