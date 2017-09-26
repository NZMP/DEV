global class CustomerTargetActualScheduler implements Schedulable {
	global void execute(SchedulableContext ctx) {
		CustomerTargetActualBatch batchJob=new CustomerTargetActualBatch();
		ID jobID = Database.executeBatch(batchJob, 200);//200 batch size matches the batch job size
	}
}