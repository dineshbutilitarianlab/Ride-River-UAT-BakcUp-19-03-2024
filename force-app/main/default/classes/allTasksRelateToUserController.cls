public with sharing class allTasksRelateToUserController {
    @AuraEnabled(cacheable = true)
    public static List<Task> getAllTask(){
        try {
            return [Select id,OwnerId,Subject,Type,Priority,Status from Task LIMIT 10];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void updateTask(List<Task> allTaskList){
        try {
            update allTaskList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}