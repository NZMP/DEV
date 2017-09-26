public class EventTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public EventTriggerHandler(boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterUpdate(Event[] oldEvents, Event[] updatedEvents, Map<ID, Event> eventMap) {
		//when an event is updated, if it has an associated call plan then update the subject and date on it 

		//get events for which subject or date have changed
		Map<String, String> eventIdsMap = new Map<String, String>(); 
		for (Event oldEvent : oldEvents) {
			Event newEvent = eventMap.get(oldEvent.Id);
			if ((oldEvent.Subject != newEvent.Subject) || (oldEvent.ActivityDate != newEvent.ActivityDate)) {
				eventIdsMap.put(String.valueOf(oldEvent.Id).substring(0,15), oldEvent.Id);
			}
		}

		//get associated call plans
		List<Call_Plan__c> callPlans = [select Id, Event_ID__c, Date__c, Event_Subject__c from Call_Plan__c where Event_ID__c in :eventIdsMap.keySet()];

		//update call plans
		for (Call_Plan__c callPlan : callPlans) {
			Event event = eventMap.get(eventIdsMap.get(callPlan.Event_ID__c)); //use the short ID to find the event
			callPlan.Event_Subject__c = event.Subject;
			callPlan.Date__c = event.ActivityDate;
		}
		update callPlans;

	}

	public void OnAfterDelete(Event[] oldEvents, Map<Id, Event> oldEventsMap) {
		//when an event is deleted, if it has an associated call plan then delete that too 

		List<String> eventIdsShort = new List<String>(); 
		for (Event event : oldEvents) {
			eventIdsShort.add(String.valueOf(event.Id).substring(0,15));
		}

		//get call plans of deleted events
		List<Call_Plan__c> callPlans = [select Id from Call_Plan__c where Event_ID__c in :eventIdsShort];

		if (!callPlans.isEmpty()) {
			delete callPlans;
		}
				
	}	


}