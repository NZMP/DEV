trigger AccountPlanTrigger on Revised_Account_Plan__c (before update) {
	if(Trigger.IsBefore && Trigger.IsUpdate)
		AccountPlanTriggerHandler.createCompetitorAnalysisSnapshot(Trigger.old, Trigger.new);

}