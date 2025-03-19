global class PeriodicServiceReminderScheduleClass implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		PeriodicServiceReminderEmailBatch b = new PeriodicServiceReminderEmailBatch(); 
		database.executeBatch(b);
	}
}