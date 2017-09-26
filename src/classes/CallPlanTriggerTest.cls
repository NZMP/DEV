public with sharing class CallPlanTriggerTest {

	public static Event event; 	
	public static Call_Plan__c callPlan; 	

	public static void setup() {
	}

	public static void tearDown() {
	}

	public static testMethod void insertCallPlanWithEventId() {

		setup();

		Account testAccount = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);

		event = TestDataHelper.createEvent(true);
		
		callPlan = new Call_Plan__c();
		callPlan.Event_ID__c = event.Id;
		callPlan.Account__c=testAccount.id;
		
		event = [select Id, Call_Plan_Id__c from Event where Id = :event.Id];

		//check that event is not connected to call plan yet 
		System.assertEquals(null, event.Call_Plan_ID__c);
		
		insert callPlan;		

/* 19th July 2013, the callplan trigger has been switch off, this test is now invalid
		//check that event is now connected to call plan
		event = [select Id, Call_Plan_ID__c from Event where Id = :event.Id];
		System.assertEquals(callPlan.Id, event.Call_Plan_ID__c);
*/
		tearDown();

	}
}