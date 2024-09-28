trigger EmployeeTrigger on Employee__c (before insert) {
    EmployeeIdGenerator.generateUniqueEmployeeIds(Trigger.new);
}