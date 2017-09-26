@isTest
public class AccountHelperTest {

	public static Account account1;
 	
	public static void setup() {
       //create test account1 record
       account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
	}

	public static void tearDown() {
	}

	public static testMethod void generateFinancialPerformanceCharts() {

		setup();
		
		AccountHelper.refreshFinancialPerformanceCharts(account1);
		
		account1.Refresh_Financial_Performance_Charts__c = true;
		update account1;
        Map<String, SObject> sObjectNameToSObjectMap = new Map<String, SObject>();
        sObjectNameToSObjectMap.put('Account', AccountPlanHelper.queryAccount(account1.Id));

		Test.startTest();

        String resultMessage = AccountHelper.generateFinancialPerformanceCharts(sObjectNameToSObjectMap);
		System.assertEquals(CrmsConstants.EMPTY_STRING, resultMessage);

		//repeat test to perform chart attachement updates
		account1 = AccountPlanHelper.queryAccount(account1.Id);
		account1.Refresh_Financial_Performance_Charts__c = true;
		update account1;
        sObjectNameToSObjectMap.put('Account', account1);
        resultMessage = AccountHelper.generateFinancialPerformanceCharts(sObjectNameToSObjectMap);
		System.assertEquals(CrmsConstants.EMPTY_STRING, resultMessage);

		Test.stopTest();

		tearDown();

	}

}