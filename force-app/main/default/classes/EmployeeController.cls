public with sharing class EmployeeController {
    @AuraEnabled
    public static void createEmployee(String name, String email, String phone, String department, String jobTitle, Date startDate, String onboardingStatus) {
        try {
            Employee__c employee = new Employee__c();
            employee.Name = name;
            employee.Email__c = email;
            employee.Phone_Number__c = phone;
            employee.Department__c = department;
            employee.Job_Title__c = jobTitle;
            employee.Start_Date__c = startDate;
            employee.Onboarding_Status__c = onboardingStatus;

            // Insert employee record
            insert employee;

            // Initiate workflow after creating employee
            WorkflowController.initiateOnboarding(employee.Id);
            sendNotificationToIT(employee);
        } catch (Exception e) {
            throw new AuraHandledException('Error creating employee: ' + e.getMessage());
        }
        
    }
    private static void sendNotificationToIT(Employee__c employee) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'akashec1009@gmail.com'}); // Replace with your IT team's email
        mail.setSubject('New Employee Onboarding Notification');
        mail.setPlainTextBody('A new employee, ' + employee.Name + ', has been added for onboarding. Please set up the necessary equipment and accounts.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}