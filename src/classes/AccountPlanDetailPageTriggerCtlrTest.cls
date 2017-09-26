@isTest
public class AccountPlanDetailPageTriggerCtlrTest {

	public static PageReference accountPlanDetailPageTriggerPage = Page.AccountPlanDetailPageTrigger;
	public static Account account1;
 	public static Account_Plan__c accountPlan;
	public static Opportunity opportunity1;
	public static Key_Initiative__c keyInitiative1;
 	
	public static void setup() {
       Test.setCurrentPage(accountPlanDetailPageTriggerPage);
       //create test account1 record with related opportunity and strategic initiative
       account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
       opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
       keyInitiative1 = TestDataHelper.createKeyInitiative(account1.Id, 'Active', true);

       //create account plan for account1
       accountPlan = TestDataHelper.createAccountPlan(account1.Id, true);
       accountPlan = AccountPlanHelper.queryAccountPlan(accountPlan.Id);
	}

	public static void tearDown() {
	}

	public static testMethod void renderPage() {

		setup();

		Test.startTest();
		
		AccountPlanDetailPageTriggerCtlr controller = new AccountPlanDetailPageTriggerCtlr(new ApexPages.StandardController(accountPlan));

		controller.init();
		
		controller = new AccountPlanDetailPageTriggerCtlr(new ApexPages.StandardController(account1));

		controller.getRefreshFinancialPerformanceCharts();
		controller.getSessionFrameSrc();
		AccountPlanDetailPageTriggerCtlr.generateFinancialPerformanceCharts(account1.Id);

		AccountPlanDetailPageTriggerCtlr.generateTeamShareForRelatedObjects(account1.Id);

		Test.stopTest();

		tearDown();

	}


	public static testMethod void createAccountPlan() {

		setup();

		Test.startTest();
		
		AccountPlanDetailPageTriggerCtlr controller = new AccountPlanDetailPageTriggerCtlr(new ApexPages.StandardController(new Account_Plan__c()));

		controller.init();

		String newAccountPlanRedirect = AccountPlanDetailPageTriggerCtlr.createAccountPlan(account1.Id);
		
		System.assertEquals(2, newAccountPlanRedirect.split('/').size());
		System.assertNotEquals(null, AccountPlanHelper.queryAccountPlan(newAccountPlanRedirect.split('/')[1]));

		Test.stopTest();

		tearDown();

	}

}