@isTest
private class ContactTriggerHandlerTest {

	public static Account account; 	
	public static Contact contact; 	

	public static void setup() {
	}

	public static void tearDown() {
	}

	public static testMethod void insertContactWithAccountNumber() {

		setup();

       	account = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);

		contact = new Contact();
		contact.LastName = 'Test';
		contact.Account_Number__c = account.Account_Number__c;

		//check that contact is not yet connected to account
		//System.assertEquals(null, contact.AccountId);
		
		//insert contact to trip trigger
		//insert contact;
		
		//get updated contact
		//contact = [select AccountId from Contact where Id = :contact.Id];

		//check that contact is now connected to account
		//System.assertEquals(account.Id, contact.AccountId);
				
		tearDown();

	}

	public static testMethod void insertContactWithoutAccountNumber() {

		setup();

       	account = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_PARTNER_FUNCTION, 'TestAccountGroup', 'AccNo1', true);

		contact = new Contact();
		contact.LastName = 'Test';

		//check that contact is not yet connected to account
		System.assertEquals(null, contact.AccountId);
		
		//insert contact to trip trigger
		insert contact;

		//get updated contact
		contact = [select AccountId from Contact where Id = :contact.Id];

		//check that contact is still not connected to account
		System.assertEquals(null, contact.AccountId);
				
		tearDown();

	}


}