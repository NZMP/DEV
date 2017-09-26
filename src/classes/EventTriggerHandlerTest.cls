@isTest
private class EventTriggerHandlerTest {

	public static Event event; 	
	public static Call_Plan__c callPlan; 	

	public static void setup() {
	}

	public static void tearDown() {
	}

	public static testMethod void deleteEventWithCallPlan() {

		setup();

		Account testAccount = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);
		event = TestDataHelper.createEvent(true);
		
		callPlan = new Call_Plan__c();
		String eventId = String.valueOf(event.Id).substring(0,15); 
		callPlan.Event_ID__c = eventId;
		callPlan.Account__c=testAccount.id;

		insert callPlan;		
		
/* 19th July 2013.  Trigger has been switch off on callplan object, invalid test
		//check that event is now connected to call plan
		event = [select Id, Call_Plan_ID__c from Event where Id = :event.Id];
		System.assertEquals(callPlan.Id, event.Call_Plan_ID__c);
*/
		//delete the event
		delete event;
		
		//check that the call plan has been deleted by the trigger
		List<Call_Plan__c> callPlans = [select Id from Call_Plan__c where Id = :callPlan.Id];
		System.assertEquals(true, callPlans.isEmpty());
				
		tearDown();
	}

	public static testMethod void updateEventWithCallPlan() {

		setup();

		String oldSubject = 'Old subject';
		String newSubject = 'New subject';

		event = TestDataHelper.createEvent(true);
		event.Subject = oldSubject;
		update event;
		
		event = [select Id, Subject from Event where Id = :event.Id];
		System.assertEquals(oldSubject, event.Subject);
		
		Account testAccount = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);
		callPlan = new Call_Plan__c();
		String eventId = String.valueOf(event.Id).substring(0,15); 
		callPlan.Event_ID__c = eventId;
		callPlan.Event_Subject__c = oldSubject;
		callPlan.Account__c=testAccount.id;
		insert callPlan;		
		
		//check that event is now connected to call plan
/* 19th July 2013.  Trigger has been switch off on callplan object, invalid test
		event = [select Id, Call_Plan_ID__c from Event where Id = :event.Id];
		System.assertEquals(callPlan.Id, event.Call_Plan_ID__c);
*/
		//check that call plan has old subject
		callPlan = [select Id, Event_Subject__c from Call_Plan__c where Id = :callPlan.Id];
		System.assertEquals(oldSubject, callPlan.Event_Subject__c);

		//update the event
		event.Subject = newSubject;
		update event;
		
		//check that call plan has been updated by trigger to have new subject
		callPlan = [select Id, Event_Subject__c from Call_Plan__c where Id = :callPlan.Id];
		System.assertEquals(newSubject, callPlan.Event_Subject__c);
				
		tearDown();

	}


}