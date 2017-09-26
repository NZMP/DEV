/*********************
 * Author: Mahmood Zubair (Davanti)
 * Description: Trigger to handle multi-reseller create implementation
 * History 
 * 11Aug16: inital version
 * 
 * 
 * ****************************/


trigger AuditNotesTrigger on Audit_Notes__c (before insert, after insert, after update) {
    
    If(Trigger.IsInsert && Trigger.IsAfter){
        AuditNotesTriggerHandler.createMultiResellerRecords(Trigger.new);      
    }
    
    if(trigger.isupdate && trigger.isafter) {
        AuditNotesTriggerHandler.updateMultipleAuditNoteRecords(Trigger.new);
    }

}