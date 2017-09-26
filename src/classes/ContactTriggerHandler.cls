public with sharing class ContactTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public ContactTriggerHandler(boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterInsert(Contact[] newContacts) {
		//if the contact is being inserted with an account number but the account lookup
		//is not populated, then it is coming from Outlook. Find the appropriate account
		//using the account number and populate the account lookup

		Set<String> accountNumbersToLookUp = new Set<String>();
		Set<Id> contactsToUpdateIds = new Set<Id>();
		
		for (Contact contact : newContacts) {
			if (contact.Account_Number__c != null && contact.Account_Number__c != '' && contact.AccountId == null) {
				accountNumbersToLookUp.add(contact.Account_Number__c);
				contactsToUpdateIds.add(contact.Id);
			}
		}

		if (!accountNumbersToLookUp.isEmpty()){
			List<Account> accounts = [select Id, Account_Number__c from Account where Account_Number__c in :accountNumbersToLookUp];
			Map<String, Id> accountNumberIdMap = new Map<String, Id>();
			for (Account account : accounts) {
				accountNumberIdMap.put(account.Account_Number__c, account.Id);
			}
			
			List<Contact> contactsToUpdate = [select Id, Account_Number__c, AccountId from Contact where Id in :contactsToUpdateIDs];
			for (Contact contact : contactsToUpdate) {
				contact.AccountId = accountNumberIdMap.get(contact.Account_Number__c);
			}

			if (!contactsToUpdate.isEmpty()) {
				update contactsToUpdate;
			}
		}
				
	}	
}