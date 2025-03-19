global class LeadBatchScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        LeadBatchProcess batchJob = new LeadBatchProcess();
        Database.executeBatch(batchJob, 50); 
    }
}