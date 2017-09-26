global with sharing class AccountPlanDetailPageTriggerCtlr {

    public Account account {get; set;}
    public Account_Plan__c accountPlan {get; set;}

    public PageReference init() {

        //try {

        	String accountId = null;
        	if ((accountPlan != null) && (accountPlan.Id != null)) {
	            accountPlan = AccountPlanHelper.queryAccountPlan(accountPlan.Id);
	            accountId = accountPlan.Account__c;
        	}            
			if ((account != null) && (account.Id != null)) {
            	accountId = account.Id;
			}
			if (accountId != null) {
            	account = AccountPlanHelper.queryAccount(accountId);
			}
/*
        } catch (Exception e) {
            throw e;
        }
*/
        return null;
    }
        
    public AccountPlanDetailPageTriggerCtlr(ApexPages.StandardController controller) {
    	try {
    		this.account = (Account)controller.getRecord();
    	} catch (System.TypeException te) {
        	this.accountPlan = (Account_Plan__c)controller.getRecord();
    	}
    	init();
    }

	public Boolean getRefreshFinancialPerformanceCharts() {
		return AccountHelper.refreshFinancialPerformanceCharts(account);
	}

	public String getSessionFrameSrc() {
		return ChartGenerator.getSessionFrameSrc();
	}

	@RemoteAction
	global static String generateFinancialPerformanceCharts(String accountId) {
        Map<String, SObject> sObjectNameToSObjectMap = new Map<String, SObject>();
        sObjectNameToSObjectMap.put('Account', AccountPlanHelper.queryAccount(accountId));
		ChartGenerator.setSalesforceBaseUrl(System.URL.getSalesforceBaseUrl());
        String resultMessage = AccountHelper.generateFinancialPerformanceCharts(sObjectNameToSObjectMap);
        if (resultMessage == CrmsConstants.EMPTY_STRING) {
        	resultMessage = 'Account charts refresh successful. Please wait while reloading the changes...';
        } else {
        	resultMessage = 'Unable to generate Account charts: ' + resultMessage;
        }
		return resultMessage;
	}

	@RemoteAction
	global static String generateTeamShareForRelatedObjects(String accountId) {
        //String resultMessage = AccountTriggerHandler.generateTeamShareForRelatedObjects(new Set<Id>{accountId});
        String resultMessage = null;
        if (resultMessage == CrmsConstants.EMPTY_STRING) {
        	resultMessage = 'Account Team related record sharing was successful.';
        } else {
        	resultMessage = 'Unable to share Account Team related records: ' + resultMessage;
        }
		return resultMessage; 
	}
	
	@RemoteAction
	global static String createAccountPlan(String accountId) {	
    	Account account = AccountPlanHelper.queryAccount(accountId);
		Account_Plan__c accountPlan = new Account_Plan__c();
		accountPlan.Account__c = accountId;
    	accountPlan.Name = account.Name + ' Plan ' + Date.today().year();
    	accountPlan.Start_Date__c = Date.today();
    	accountPlan.End_Date__c = accountPlan.Start_Date__c.addYears(1);
    	//accountPlan.Status__c = CrmsConstants.ACCOUNT_PLAN_STATUS_DRAFT;
    	insert accountPlan;
    	String teamShareResult = AccountPlanDetailPageTriggerCtlr.generateTeamShareForRelatedObjects(accountId);
    	System.debug('createAccountPlan teamShareResult='+teamShareResult);
    	return '/' + accountPlan.Id;
	}

/*
	public String getPageRequestHeader() {
		return Apexpages.currentPage().getHeaders()+'';
	}
*/
}