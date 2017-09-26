trigger CallPlanTrigger on Call_Plan__c (after insert
//after delete, after undelete, after update, before delete, before insert, before update 
) {

	CallPlanTriggerHandler handler = new CallPlanTriggerHandler(Trigger.isExecuting, Trigger.size);

	if( Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new);
	}

}