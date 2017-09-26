global class AccountBatch implements Database.Batchable<sObject> {

	global String query;
	global String email;
	global String result;
	
	global AccountBatch() {
		result = CrmsConstants.EMPTY_STRING;
	}
	
	global Database.querylocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> accountIdsToShare = new Set<Id>();
		for (sObject s : scope) {
			Account a = (Account)s;
			accountIdsToShare.add(a.Id);
		}
		//result += AccountTriggerHandler.generateTeamShareForRelatedObjects(accountIdsToShare); 
		result += null;
		
	}
	
	global void finish(Database.BatchableContext BC) {
		if (result == CrmsConstants.EMPTY_STRING) {
			result = 'No errors occurred.';
		}
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {email});
		mail.setReplyTo(email);
		mail.setSenderDisplayName('Account Batch Process');
		mail.setSubject('Account Batch Process Completed');
		mail.setPlainTextBody('Account Batch Process has completed with result: ' + result);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}

}