public class EmployeeIdGenerator {
    public static void generateUniqueEmployeeIds(List<Employee__c> employees) {
        Set<String> existingIds = new Set<String>();
        // Collect existing Employee IDs to avoid duplicates
        for (Employee__c emp : [SELECT Employee_ID__c FROM Employee__c]) {
            existingIds.add(emp.Employee_ID__c);
        }

        for (Employee__c emp : employees) {
            emp.Employee_ID__c = generateUniqueEmployeeId(existingIds);
            existingIds.add(emp.Employee_ID__c); // Add the newly generated ID to the existing IDs set
        }
    }

    private static String generateUniqueEmployeeId(Set<String> existingIds) {
        String uniqueId;
        Boolean isUnique = false;

        while (!isUnique) {
            // Generate a random ID - customize the format as needed
            uniqueId = 'EMP' + String.valueOf(Math.abs(Crypto.getRandomInteger()));
            // Check if the ID is unique
            isUnique = !existingIds.contains(uniqueId) && !isIdDuplicate(uniqueId);
        }

        return uniqueId;
    }

    private static Boolean isIdDuplicate(String id) {
        // Query to check if the ID already exists in the database
        List<Employee__c> existingEmployees = [SELECT Id FROM Employee__c WHERE Employee_ID__c = :id LIMIT 1];
        return existingEmployees.size() > 0;
    }
}