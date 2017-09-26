trigger EventTrigger on Event (after delete, after update) {
	//, after insert, after undelete, before delete, before insert, before update) {

	EventTriggerHandler handler = new EventTriggerHandler(Trigger.isExecuting, Trigger.size);

	if( Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}

	if( Trigger.isDelete && Trigger.isAfter){
		handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
	}

}