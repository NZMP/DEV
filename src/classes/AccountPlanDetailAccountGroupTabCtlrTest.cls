@isTest
public class AccountPlanDetailAccountGroupTabCtlrTest {

	//public static PageReference accountPlanDetailAccountGroupTabsPage = new Page.AccountPlanDetailAccountGroupTabs;
	public static Account account1;
	public static Account account2;
 	public static Account_Plan__c accountPlan;
	public static Opportunity opportunity1;
	public static Opportunity opportunity2;
	public static Key_Initiative__c keyInitiative1;
	public static Key_Initiative__c keyInitiative2;
 	

	public static void setup() {
       //Test.setCurrentPage(accountPlanDetailAccountGroupTabsPage);
       //create test account1 record with related opportunity and strategic initiative
       account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
       opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
       keyInitiative1 = TestDataHelper.createKeyInitiative(account1.Id, 'Active', true);
       
       //create test account2 with same account group as account1 for group related queries
       account2 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo2', true);
       opportunity2 = TestDataHelper.createOpportunity(account2.Id, true);
       keyInitiative2 = TestDataHelper.createKeyInitiative(account2.Id, 'Active', true);
       
       //create account plan for account1
       accountPlan = TestDataHelper.createAccountPlan(account1.Id, true);
       accountPlan = [SELECT Account__c, Account_Group__c FROM Account_Plan__c
					  WHERE Id = :accountPlan.Id];
	}

	public static void tearDown() {
	}

	public static testMethod void getOpportunitiesAndStrategicInitiatives() {
		
		setup();
		
		AccountPlanDetailAccountGroupTabsCtlr controller = new AccountPlanDetailAccountGroupTabsCtlr(new ApexPages.StandardController(accountPlan));

		//check related open opportunity is returned for account plan's account1
		List<Opportunity> opportunities = controller.getOpportunities();
		System.assertEquals(1, opportunities.size());
		System.assertEquals(opportunity1.Id, opportunities[0].Id);

		//check related active key initiative is returned for account plan's account1
		List<Key_Initiative__c> keyInitiatives = controller.getKeyInitiatives();
		System.assertEquals(1, keyInitiatives.size());
		System.assertEquals(keyInitiative1.Id, keyInitiatives[0].Id);

		//check related account2's open opportunity is returned for account plan's account1's account group
		List<Opportunity> groupOpportunities = controller.getGroupOpportunities();
		System.assertEquals(1, groupOpportunities.size());
		System.assertEquals(opportunity2.Id, groupOpportunities[0].Id);

		//check related account2's active key initiative is returned for account plan's account1's account group
		List<Key_Initiative__c> groupKeyInitiatives = controller.getGroupKeyInitiatives();
		System.assertEquals(1, groupKeyInitiatives.size());
		System.assertEquals(keyInitiative2.Id, groupKeyInitiatives[0].Id);

		tearDown();

	}

}