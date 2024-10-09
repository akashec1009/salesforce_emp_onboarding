public with sharing class BackgroundCheckController {
    @AuraEnabled
    public static String triggerBackgroundCheck(String employeeId) {
        // Prepare the request for the background check API
        // background check doesn;t required 
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://external-background-check-api.com/check'); // Replace with the actual API endpoint
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');

        // Construct the body of the request
        String body = JSON.serialize(new Map<String, Object>{
            'employeeId' => employeeId
        });
        req.setBody(body);

        // Send the HTTP request
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Check the response and return the result
        if (res.getStatusCode() == 200) {
            return 'Background check initiated successfully for employee ID: ' + employeeId;
        } else {
            throw new AuraHandledException('Failed to initiate background check: ' + res.getBody());
        }
    }
}