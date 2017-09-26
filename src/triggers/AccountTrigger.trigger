trigger AccountTrigger on Account (before update, before insert, after update) {
    if ( trigger.isafter && trigger.isupdate ){
        CaseTriggerClass.recalculate(trigger.new, trigger.oldMap);
    }
    
    InformaticaHelperClass helper = new InformaticaHelperClass(Trigger.isExecuting, Trigger.size);

    if (Trigger.isInsert && Trigger.isBefore) {
        helper.OnBeforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore) {
        helper.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
    }
    

}