public with sharing class WorkflowController {

    @AuraEnabled
    public static void initiateOnboarding(Id employeeId) {
        try {
            System.debug('Initiating onboarding for employee ID: ' + employeeId);

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

                System.debug('Workflow initiated successfully for employee ID: ' + employeeId);

            } else {
                throw new AuraHandledException('Employee not found.');
            }

        } catch (Exception e) {
            System.debug('Error during onboarding initiation: ' + e.getMessage());
            throw new AuraHandledException('Error initiating onboarding: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateWorkflowStep(Id workflowId, String status) {
        try {
            System.debug('Updating workflow step for workflow ID: ' + workflowId + ' to status: ' + status);
            
            // Fetch workflow step and related employee
            OnboardingWorkflow__c workflow = [SELECT Id, Status__c, Step__c, Employee__c, Employee__r.Email__c, Employee__r.Name 
                                              FROM OnboardingWorkflow__c 
                                              WHERE Id = :workflowId 
                                              LIMIT 1];
    
            // Ensure workflow record exists
            if (workflow == null) {
                throw new AuraHandledException('No workflow found for the given ID: ' + workflowId);
            }
    
            // Update status
            workflow.Status__c = status;
            update workflow;
    
            // Send notification if the step is marked as completed
            if (status == 'Completed') {
                sendCompletionNotification(workflow);
            }
            
        } catch (Exception e) {
            System.debug('Error updating workflow step: ' + e.getMessage());
            throw new AuraHandledException('Error updating workflow step for ID ' + workflowId + ': ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OnboardingWorkflow__c> getWorkflowSteps() {
        try {
            System.debug('Fetching workflow steps.');
            return [SELECT Id, Step__c, Status__c, Employee__r.Name, Employee__r.Email__c 
            FROM OnboardingWorkflow__c 
            ORDER BY Step__c];
        } catch (Exception e) {
            System.debug('Error fetching workflow steps: ' + e.getMessage());
            throw new AuraHandledException('Error fetching workflow steps: ' + e.getMessage());
        }
    }

    private static void sendCompletionNotification(OnboardingWorkflow__c workflow) {
        try {
            System.debug('Sending completion notification for workflow ID: ' + workflow.Id);
            
            Employee__c employee = [SELECT Id, Name, Email__c 
                                    FROM Employee__c 
                                    WHERE Id = :workflow.Employee__c];

            String subject = 'Onboarding Step Completed';
            String body = 'The following onboarding step has been completed:\n' +
                          'Employee Name: ' + employee.Name + '\n' +
                          'Step: ' + workflow.Step__c + '\n' +
                          'Status: Completed';

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(subject);
            email.setPlainTextBody(body);
            email.setToAddresses(new String[] { employee.Email__c });

            // Send the email
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
            
            System.debug('Notification sent successfully to: ' + employee.Email__c);

        } catch (Exception e) {
            System.debug('Error sending notification: ' + e.getMessage());
            throw new AuraHandledException('Error sending notification: ' + e.getMessage());
        }
    }
}
