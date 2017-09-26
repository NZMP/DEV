/*
* Author:
* Description: Trigger for Case Object
* History:
*    03Mar2016 SBabu(DC): Initial version
*    16Sep2016 JSalna(DC): Created logic to call CaseTriggerClass.CommitShares()
*    02Nov2016 NBustillos(DC): FONCE-62 - Updated logic so that CaseTriggerClass.CommitShares() is called on after insert/update.
*    11May2017 JersonPoblete: Validate Case Closure
*/
trigger CaseTrigger on Case (before insert, before update,after insert, after update) {
    CaseTriggerClass caseHandler = new CaseTriggerClass();  //@author JersonPoblete 05/11
    
    if(Trigger.isInsert && Trigger.isBefore) {
        CaseTriggerClass.setCaseStatusMapping(Trigger.new);
    }
    if(Trigger.isInsert && Trigger.isAfter) {
        CaseTriggerClass.setActiveAssignmentRule(Trigger.newMap.keySet());
        caseHandler.updateCaseOwner(trigger.New);  //@author JersonPoblete 07/3
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
        CaseTriggerClass.setCaseStatusMapping(Trigger.new);
        caseHandler.validateCaseClose( trigger.newMap, trigger.oldMap);  //@author JersonPoblete 05/11
    }
    
    if ( (trigger.isUpdate || trigger.isInsert) &&  trigger.isAfter )
        CasetriggerClass.CommitShares ( trigger.new, trigger.oldmap );      // @author JS @Davanti 09/16

}