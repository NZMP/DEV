trigger ContactTrigger on Contact (after insert
//after delete, after undelete, after update, before delete, before insert, before update 
) {

	ContactTriggerHandler handler = new ContactTriggerHandler(Trigger.isExecuting, Trigger.size);

	if( Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new);
	}

}