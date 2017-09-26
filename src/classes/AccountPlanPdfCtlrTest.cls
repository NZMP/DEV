@isTest
public class AccountPlanPdfCtlrTest {

	public static PageReference accountPlanPdfPage = Page.AccountPlanPdf;
	public static Account account1;
	public static Account accountParent1;
 	public static Account_Plan__c accountPlan;
 	public static Account_Plan__c accountParentPlan;
	public static Opportunity opportunity1;
	public static Key_Initiative__c keyInitiative1;
 	

	public static void setup() {
		Test.setCurrentPage(accountPlanPdfPage);
		//create test account1 record with related opportunity and strategic initiative
		account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
		opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
		keyInitiative1 = TestDataHelper.createKeyInitiative(account1.Id, 'Active', true);

		//create test parent account1 record 
		accountParent1 = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_PARENT_ACCOUNT, 'TestAccountGroup', 'PAcNo1', true);
       
		//create account plan for account1
		accountPlan = TestDataHelper.createAccountPlan(account1.Id, true);
		accountPlan = [SELECT Account__c, Account_Group__c FROM Account_Plan__c
			WHERE Id = :accountPlan.Id];

		//create account plan for accountParent1
		accountParentPlan = TestDataHelper.createAccountPlan(accountParent1.Id, true);
		accountParentPlan = AccountPlanHelper.queryAccountPlan(accountParentPlan.Id);
	}

	public static void tearDown() {
	}

	public static testMethod void renderPage() {
		
		setup();

		Apexpages.currentPage().getParameters().put('download','1');		
		AccountPlanPdfCtlr controller = new AccountPlanPdfCtlr(new ApexPages.StandardController(accountPlan));
		controller.pageAction();
		
		controller.getAccountPlanCustomerGraphicImageUrl();
		controller.getOpportunityPipelineChartImageUrl();
		controller.getMarket101ImageUrl();
		controller.getCustomersFinancialPerformaceImageUrl();
		controller.getCustomersFinancialPerformaceChart1ImageUrl();
		controller.getCustomersFinancialPerformaceChart2ImageUrl();
		controller.getCustomersFinancialPerformaceChart3ImageUrl();
		controller.getCustomerProduct1ImageUrl();
		controller.getCustomerProduct2ImageUrl();
		controller.getCustomerProduct3ImageUrl();
		controller.getCustomerProduct4ImageUrl();
		controller.getCustomerProduct5ImageUrl();
		controller.getProduct1ImageUrl();
		controller.getProduct2ImageUrl();
		controller.getProduct3ImageUrl();
		controller.getProduct4ImageUrl();
		controller.getProduct5ImageUrl();
		controller.getCVMResultsImageUrl();
		controller.getFonterrasShareOfBustomersBusinessImageUrl();
		controller.getDIFOTImageUrl();
		controller.getComplaintsImageUrl();
		controller.getCustomersBusinessByProductImageUrl();
		controller.getCustomersBusinessByCompetitorImageUrl();
		controller.getIsParentAccountPlan();

		Apexpages.currentPage().getParameters().put('download','1');				
		controller = new AccountPlanPdfCtlr(new ApexPages.StandardController(accountParentPlan));
		controller.pageAction();

		tearDown();

	}

}