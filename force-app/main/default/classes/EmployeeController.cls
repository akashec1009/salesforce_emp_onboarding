public with sharing class EmployeeController {
    @AuraEnabled
    public static Employee__c createEmployee(String name, String email, String phone, String department, String jobTitle, Date startDate, String onboardingStatus) {
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

             System.debug('Employee created successfully with ID: ' + employee.Id);
 
             // Initiate onboarding workflow after creating employee
             WorkflowController.initiateOnboarding(employee.Id);

             System.debug('After the onboarding' + employee.Id);
 
             // Send notification to IT
             sendNotificationToIT(employee);
             System.debug('after sending notification to IT');
 
             return employee; // Return the created employee record for reference in LWC

        } catch (Exception e) {
            throw new AuraHandledException('Error creating employee: ' + e.getMessage());
        }
    }
    private static void sendNotificationToIT(Employee__c employee) {
        System.debug('send notification initiated');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'akashec1009@gmail.com'}); // Replace with your IT team's email
        mail.setSubject('New Employee Onboarding Notification');
        mail.setPlainTextBody('A new employee, ' + employee.Name + ', has been added for onboarding. Please set up the necessary equipment and accounts.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    @AuraEnabled(cacheable =true)
    public static Employee__c searchEmployeeById(string empId){
        string searchTerm = '%'+empId+'%';
        try {
            System.debug('run successfully' +searchTerm);
            return [SELECT Id, Name,Employee_ID__c, Department__c, Email__c FROM Employee__c WHERE Employee_ID__c LIKE :searchTerm];
        }catch(Exception ex){
            System.debug('exception block');
            throw new AuraHandledException('EmployeeID does not match ');
        }
        
    }
}