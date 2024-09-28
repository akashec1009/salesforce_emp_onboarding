public with sharing class DocumentController {
    @AuraEnabled
    public static void uploadDocument(String employeeId, String documentName, String documentType, String fileId) {
        // Existing upload document logic
        Document__c newDocument = new Document__c();
        newDocument.Name = documentName;
        newDocument.DocumentType__c = documentType;
        newDocument.Employee__c = employeeId;
        newDocument.Google_Drive_File_ID__c = fileId;
        newDocument.Uploaded_Date__c = Date.today();

        try {
            insert newDocument;
        } catch (Exception e) {
            throw new AuraHandledException('Error uploading document: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void triggerBackgroundCheck(String employeeId) {
        // Assuming an external service endpoint for background checks
        String backgroundCheckEndpoint = 'https://api.externalservice.com/background-check';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(backgroundCheckEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        // Constructing request body with employee details
        Map<String, String> requestBody = new Map<String, String>();
        requestBody.put('employeeId', employeeId);
        // Include other necessary details as per your API requirements
        
        req.setBody(JSON.serialize(requestBody));

        // Sending the request and handling the response
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Error triggering background check: ' + res.getBody());
        }

        // Optional: Process the response if needed
    }
}