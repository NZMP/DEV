/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Alternate_UoMTrigger on Alternate_UoM__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler();
}