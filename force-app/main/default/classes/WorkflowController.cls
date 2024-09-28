public with sharing class WorkflowController {
    
    @AuraEnabled
    public static void initiateOnboarding(Id employeeId) {
        // Check if employee exists
        Employee__c employee = [SELECT Id, Name FROM Employee__c WHERE Id = :employeeId LIMIT 1];

        if (employee != null) {
            // Create a new onboarding workflow record
            OnboardingWorkflow__c workflow = new OnboardingWorkflow__c();
            workflow.Employee__c = employeeId;
            workflow.Step__c = 'HR Approval'; // Initial step
            workflow.Status__c = 'In Progress'; // Status
            workflow.AssignedTo__c = UserInfo.getUserId(); // Assign to current user

            // Insert the onboarding workflow record
            insert workflow;
            
        }
    }
    
    @AuraEnabled
    public static void updateWorkflowStep(Id workflowId, String status) {
        OnboardingWorkflow__c workflow = [SELECT Id, Status__c, Step__c, Employee__c FROM OnboardingWorkflow__c WHERE Id = :workflowId LIMIT 1];

        // Update status
        workflow.Status__c = status;
        update workflow;

        // Send notification if milestone is completed
        if (status == 'Completed') {
            sendCompletionNotification(workflow);
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<OnboardingWorkflow__c> getWorkflowSteps() {
    return [SELECT Id, Step__c, Status__c, AssignedTo__c, Employee__c FROM OnboardingWorkflow__c ORDER BY Step__c];
}


    private static void sendCompletionNotification(OnboardingWorkflow__c workflow) {
        Employee__c employee = [SELECT Id, Name, Email__c FROM Employee__c WHERE Id = :workflow.Employee__c];
        String subject = 'Onboarding Step Completed';
        String body = 'The following onboarding step has been completed:\n' +
                      'Employee Name: ' + employee.Name + '\n' +
                      'Step: ' + workflow.Step__c + '\n' +
                      'Status: Completed';

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        // Set recipient email to the employee's email
        email.setToAddresses(new String[] { employee.Email__c });

        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    }


}