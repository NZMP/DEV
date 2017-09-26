public with sharing class CallPlanTriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public CallPlanTriggerHandler(boolean isExecuting, integer size) {
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterInsert(Call_Plan__c[] newCallPlans) {
		//when a call plan is inserted, if it has an event Id then that event should be updated to link to the call plan

		Set<Id> eventIds = new Set<Id>();
		
		for (Call_Plan__c callPlan : newCallPlans) {
			if (callPlan.Event_ID__c != null ) {
				eventIds.add(callPlan.Event_ID__c);
			}
		}

		if (!eventIds.isEmpty()){
			Map<Id, Event> events = new Map<Id, Event>([select Id, Call_Plan_ID__c from Event where Id in :eventIds]);
			List<Event> eventsToUpdate = new List<Event>();
			
			for (Call_Plan__c callPlan : newCallPlans) {
				if (callPlan.Event_ID__c != null ) {
					Event event = events.get(callPlan.Event_Id__c); 
					if (event != null) {
						event.Call_Plan_ID__c = callPlan.Id;
						eventsToUpdate.add(event);	
					}
				}
			}

			if (!eventsToUpdate.isEmpty()) {
				update eventsToUpdate;
			}
		}
				
	}	


}