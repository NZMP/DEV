@isTest
public class AccountBatchTest {

    public static Account account1;
    public static Account_Plan__c accountPlan;
    public static Key_Initiative__c keyInitiative1;
    public static User salesUser;

    public static void setup() {
        //create test account1 record with related opportunity and strategic initiative
        account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
        keyInitiative1 = TestDataHelper.createKeyInitiative(account1.Id, 'Active', true);

        //create account plan for account1
        accountPlan = TestDataHelper.createAccountPlan(account1.Id, true);
        accountPlan = [SELECT Account__c FROM Account_Plan__c WHERE Id = :accountPlan.Id];
        
        //create sales user
        salesUser = TestDataHelper.createUser('saleUser@test.com', 'Sales User 1 - Revised', true);
    }

    public static void tearDown() {
    }

    public static testMethod void gettersAndQueries() {
        
        setup();
        
        AccountShare accountTeamShare = new AccountShare(
            UserOrGroupId = salesUser.Id,
            OpportunityAccessLevel = CrmsConstants.SHARING_ACCESSLEVEL_READ,
            AccountId = account1.Id,
            AccountAccessLevel = CrmsConstants.SHARING_ACCESSLEVEL_READ);
        insert accountTeamShare;

        Test.StartTest();
        AccountBatch accountBatch = new AccountBatch();
        accountBatch.query = 'SELECT Id FROM Account Where Id = \'' + account1.Id + '\'';
        //accountBatch.query = 'SELECT Id FROM Account Where RecordTypeId = \'' + CrmsConstants.getRecordTypeId('Account', CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY) + '\'';
        accountBatch.email = System.Label.ACCOUNT_SCHEDULE_EMAIL;
        Id accountBatchProcessid = Database.executeBatch(accountBatch);
        Test.StopTest();
        
/* removed assertion as part of Visibility release on changing all the sharing rules on Accoun Plan, and Key Initative custom objects
        List<Account_Plan__Share> accountPlanShares = [Select a.Id, a.ParentId, a.RowCause From Account_Plan__Share a Where (ParentId = :accountPlan.Id) And (RowCause = :Schema.Account_Plan__Share.RowCause.Account_Team__c) And (AccessLevel = :accountTeamShare.OpportunityAccessLevel)];
        System.assertEquals(1, accountPlanShares.size());
        List<Key_Initiative__Share> keyInitiativeShares = [Select k.Id, k.ParentId, k.RowCause From Key_Initiative__Share k Where (ParentId = :keyInitiative1.Id) And (RowCause = :Schema.Key_Initiative__Share.RowCause.Account_Team__c) And (AccessLevel = :accountTeamShare.OpportunityAccessLevel)];
        System.assertEquals(1, keyInitiativeShares.size());
*/
        tearDown();

    }

}