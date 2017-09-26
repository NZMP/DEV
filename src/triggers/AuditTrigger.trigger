trigger AuditTrigger on Audit__c (before insert,after insert, before update, after update) {

    map<string,List<Id>> resellersetMap = new map<string,List<id>>();
    AuditTriggerClass atc = new AuditTriggerClass();
    if(Trigger.isInsert && Trigger.isBefore) {
        AuditTriggerClass.calculateQuestionScores(Trigger.new);
        resellersetMap = atc.gatherResellerInfo(Trigger.new);     
    }
    
    if(Trigger.isInsert && Trigger.isAfter) {
        AuditTriggerClass.copyPreviousAuditScores(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isBefore){
        AuditTriggerClass.calculateQuestionScores(Trigger.new);
    }

    if(Trigger.isUpdate && Trigger.isAfter){
        AuditTriggerClass.updateMultipleAuditRecords(Trigger.new);
    }

}