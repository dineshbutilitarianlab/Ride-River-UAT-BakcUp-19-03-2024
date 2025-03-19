public class InsuranceTriggerHandler {
    public static void checkForDuplicateNames(List<Insurance__c> newInsuranceRecords) {
        Set<String> insurancePrefixes = new Set<String>();

        // Collect the first 4 letters of each new insurance record's Name
        for (Insurance__c ins : newInsuranceRecords) {
            if (ins.Name != null && ins.Name.length() >= 4) {
                insurancePrefixes.add(ins.Name.substring(0, 4));
            }
        }

        if (!insurancePrefixes.isEmpty()) {
            // Query existing records where the Name starts with any of the collected prefixes
            List<Insurance__c> existingInsuranceList = [
                SELECT Id, Name FROM Insurance__c 
                WHERE (
                    Name LIKE :('%' + String.join(new List<String>(insurancePrefixes), '%') + '%')
                )
            ];

            for (Insurance__c ins : newInsuranceRecords) {
                if (ins.Name != null && ins.Name.length() >= 4) {
                    String prefix = ins.Name.substring(0, 4);
                    for (Insurance__c existingIns : existingInsuranceList) {
                        if (existingIns.Name.startsWith(prefix)) {
                            ins.addError('Duplicate record found with a similar name: ' + existingIns.Name);
                            break;
                        }
                    }
                }
            }
        }
    }
}