global class CancelServiceAppointmentsScheduleClass implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		CancelServiceAppointmentsBatch b = new CancelServiceAppointmentsBatch(); 
		database.executeBatch(b);
	}
}