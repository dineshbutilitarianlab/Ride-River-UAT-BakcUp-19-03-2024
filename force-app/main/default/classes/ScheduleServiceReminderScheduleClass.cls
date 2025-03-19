global class ScheduleServiceReminderScheduleClass implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		ScheduleServiceReminderEmailBatch b = new ScheduleServiceReminderEmailBatch(); 
		database.executeBatch(b);
	}
}