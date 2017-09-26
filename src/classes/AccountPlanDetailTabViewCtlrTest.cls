@isTest
public class AccountPlanDetailTabViewCtlrTest {

	public static PageReference accountPlanDetailTabViewPage = Page.AccountPlanDetailTabView;
	public static Account account1;
	public static Account accountParent1;
 	public static Account_Plan__c accountPlan;
 	public static Account_Plan__c accountParentPlan;
	public static Opportunity opportunity1;
	public static Key_Initiative__c keyInitiative1;
 	

	public static void setup() {
       Test.setCurrentPage(accountPlanDetailTabViewPage);
       //create test account1 record with related opportunity and strategic initiative
       account1 = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY, 'TestAccountGroup', 'AccNo1', true);

       accountParent1 = TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_PARENT_ACCOUNT, 'TestAccountGroup', 'PAcNo1', true);
       
       opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
       keyInitiative1 = TestDataHelper.createKeyInitiative(account1.Id, 'Active', true);

       //create account plan for account1
       accountPlan = TestDataHelper.createAccountPlan(account1.Id, true);
       accountPlan = AccountPlanHelper.queryAccountPlan(accountPlan.Id);

       //create account plan for accountParent1
       accountParentPlan = TestDataHelper.createAccountPlan(accountParent1.Id, true);
       accountParentPlan = AccountPlanHelper.queryAccountPlan(accountParentPlan.Id);
	}

	public static void tearDown() {
	}

	public static testMethod void renderPage() {
		
		setup();
		
		AccountPlanDetailTabViewCtlr.getDummyRow();
		System.assertEquals(null, AccountPlanDetailTabViewCtlr.getSelectedTabParameter('testButtonId'));
		Apexpages.currentPage().getHeaders().put('User-Agent','testUA');
		Apexpages.currentPage().getParameters().put('testButtonIdSplit','split');
		System.assertEquals('Split', AccountPlanDetailTabViewCtlr.getSelectedTabParameter('testButtonId'));

 		AccountPlanDetailTabViewCtlr.getHeaders();
 		AccountPlanDetailTabViewCtlr.getIsIE8();
 		AccountPlanDetailTabViewCtlr.getIsChromeFrame();
 		AccountPlanDetailTabViewCtlr.getIsIE8ChromeFrame();
 		AccountPlanDetailTabViewCtlr.getIsIPad();
 		AccountPlanDetailTabViewCtlr.getInlineEditSupportEvent();
 		Apexpages.currentPage().getHeaders().put('User-Agent','testUA with iPad');
 		AccountPlanDetailTabViewCtlr.getInlineEditSupportEvent();
 		
		AccountPlanDetailTabViewCtlr.getMaxCategories();
		AccountPlanDetailTabViewCtlr.getMaxProducts();
		
		AccountPlanDetailTabViewCtlr controller = new AccountPlanDetailTabViewCtlr(new ApexPages.StandardController(accountPlan));

		controller.removeCategory = 5;
		controller.removeCategory();
		controller.addCategory();

		controller.removeProduct = 5;
		controller.removeProduct();
		controller.addProduct();

		controller.init();
		controller.pageAction();
		controller.cancel();
		
		controller.imageSizeData = '0EMO00000000156=88px9999px|';
        accountPlan.Market_101_Graphic__c = '<img alt="User-added image" height="199" src="https://c.cs5.content.force.com/servlet/rtaImage?eid=a0FO0000000wWaG&amp;feoid=00NO0000000IaQj&amp;refid=0EMO00000000156">';
		controller.save();

		controller.cloneAndRedirect();
		controller.sharingRedirect();
		controller.getRenderSharingRedirect();
		controller.changeOwnerRedirect();
		controller.refreshCharts();
 		controller.getViewPdf();
		controller.getViewPdf2();
		controller.getPreviewSlide();
		controller.getDownloadPdf2();
		controller.clearAllGraphics();

		controller.getRefreshFinancialPerformanceCharts();
		//controller.getSessionFrameSrc();
		//AccountPlanDetailTabViewCtlr.generateFinancialPerformanceCharts(account1.Id);
		controller.getIsParentAccountPlan();
		controller.attachPdf2();
		controller.postPdf2Link();
		controller.postPdf2();
		controller.emailPdf2();
		controller.getPdf2AsBlob();
		controller.chatterPostPdf2Link();
		controller.chatterPostPdf2();

		controller = new AccountPlanDetailTabViewCtlr(new ApexPages.StandardController(accountParentPlan));
		controller.init();
		controller.pageAction();

		tearDown();

	}

}