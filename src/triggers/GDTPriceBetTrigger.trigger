trigger GDTPriceBetTrigger on GDT_Price_Bet__c (after insert, before insert, after update, before update) {

    GDTPriceBetTriggerHandler handler = new GDTPriceBetTriggerHandler(Trigger.isExecuting, Trigger.size);
    
  /*  if(Trigger.isInsert && Trigger.isBefore){
        system.debug('### GDTPriceBetTrigger isFirstRun: ' + GDTPriceBetTriggerHandler.isFirstRun());
        if(GDTPriceBetTriggerHandler.isFirstRun()){
            handler.onAfterInsert(Trigger.new);
            GDTPriceBetTriggerHandler.setFirstRunFalse();
        }
    }
    
    if(Trigger.isUpdate && Trigger.isBefore){
        system.debug('### GDTPriceBetTrigger isFirstRun: ' + GDTPriceBetTriggerHandler.isFirstRun());
        if(GDTPriceBetTriggerHandler.isFirstRun()){
            handler.onAfterUpdate(Trigger.newMap);
            GDTPriceBetTriggerHandler.setFirstRunFalse();
        }
    }*/

}