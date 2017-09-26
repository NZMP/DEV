global class AccountSchedule implements Schedulable {

	global void execute(SchedulableContext sc) {
		AccountBatch accountBatch = new AccountBatch();
		//accountBatch.query = 'SELECT Id FROM Account Where Id = \'' + account.Id + '\'';
		accountBatch.query = 'SELECT Id FROM Account Where RecordTypeId = \'' + CrmsConstants.getRecordTypeId('Account', CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY) + '\'';
		accountBatch.email = System.Label.ACCOUNT_SCHEDULE_EMAIL;
		Id accountBatchProcessid = Database.executeBatch(accountBatch, 10);
	}

	public static testMethod void executeAccountSchedule() {

		String cronExpression = '0 0 0 3 9 ? 2099';
		
		Test.startTest();

		//schedule the test job
		String jobId = System.schedule('testExecuteAccountSchedule',
			cronExpression,
			new AccountSchedule());
		//get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
			FROM CronTrigger WHERE id = :jobId];
		//verify the expressions are the same
		System.assertEquals(cronExpression, ct.CronExpression);
		//verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);
		//verify the next time the job will run
		System.assertEquals('2099-09-03 00:00:00', String.valueOf(ct.NextFireTime));

		Test.stopTest();

	}

}