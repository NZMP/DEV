trigger Product2Trigger on Product2 (after insert,  after update
//after delete, after undelete, before delete, before insert, before update
) {

	Product2TriggerHandler handler = new Product2TriggerHandler(Trigger.isExecuting, Trigger.size);

	if( Trigger.isInsert && Trigger.isBefore){
		//handler.OnBeforeInsert(Trigger.new);
	}
	else if (Trigger.isInsert && Trigger.isAfter){
		handler.OnAfterInsert(Trigger.new);
		//Product2TriggerHandler.OnAfterInsertAsync(Trigger.newMap.keySet());
	}
	else if (Trigger.isUpdate && Trigger.isAfter){
		handler.OnAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
		//Product2TriggerHandler.OnAfterUpdateAsync(Trigger.newMap.keySet());
	}
/*	else if (Trigger.isUpdate && Trigger.isBefore){
		//handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
	}
	*/	
	/*else if(Trigger.isDelete && Trigger.isBefore){
		//handler.OnBeforeDelete(Trigger.old, Trigger.oldMap);
	}
	else if(Trigger.isDelete && Trigger.isAfter){
		//handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
		//Product2TriggerHandler.OnAfterDeleteAsync(Trigger.oldMap.keySet());
	}
	
	else if(Trigger.isUnDelete){
		//handler.OnUndelete(Trigger.new);	
	}
*/
}