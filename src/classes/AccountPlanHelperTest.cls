@isTest
public class AccountPlanHelperTest {

    public static Account account1;
    public static Account_Plan__c accountPlan;
    public static Opportunity opportunity1;
    public static Key_Initiative__c keyInitiative1;

    public static void setup() {
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

    public static testMethod void getSetFields() {
        
        setup();

        accountPlan.Category_1__c = 'testCategory1';
        System.assertEquals('testCategory1', AccountPlanHelper.getFieldValue(accountPlan, 'Category_', '__c', 1));
        AccountPlanHelper.setFieldValue(accountPlan, 'Category_', '__c', 1, 'testCategory1b');
        System.assertEquals('testCategory1b', accountPlan.Category_1__c);
        AccountPlanHelper.copyFieldValue(accountPlan, 'Category_', '__c', 1, 2);
        System.assertEquals('testCategory1b', accountPlan.Category_2__c);

        tearDown();

    }

    public static testMethod void getUserRecordAccess() {
        
        setup();

        System.assertNotEquals(null, AccountPlanHelper.getUserRecordAccess(UserInfo.getUserId(), accountPlan.Id));

        tearDown();

    }

    public static testMethod void gettersAndQueries() {
        
        setup();

        AccountPlanHelper.getNumberOfCategories(accountPlan);
        AccountPlanHelper.getNumberOfProducts(accountPlan);
        AccountPlanHelper.queryAccountPlan(accountPlan.Id);
        AccountPlanHelper.queryAccount(account1.Id);
        AccountPlanHelper.queryCustomerSnapshotMetrics(account1.Id);
        AccountPlanHelper.queryCustomerSnapshotMetricsAggregate(account1.Id);
        AccountPlanHelper.queryCompetitorAnalyses(accountPlan.Id);
        AccountPlanHelper.queryStakeholderAnalyses(accountPlan.Id);
        AccountPlanHelper.queryCvmResults(account1.Id, Date.today(), Date.today());
        AccountPlanHelper.queryKeyOpportunities(account1.Id);
        AccountPlanHelper.queryKeyInitiatives(account1.Id, Date.today(), Date.today());
        AccountPlanHelper.queryKeyOpportunitiesForParentAccount(account1.Id, true);
        AccountPlanHelper.queryKeyInitiativesForParentAccount(account1.Id, true,Date.today(), Date.today());

        accountPlan.Category_1__c = 'testCategory1';
        AccountPlanHelper.copyCategoryFieldSet(accountPlan, null, 1);
        System.assertEquals(null, accountPlan.Category_1__c);
        
        accountPlan.Category_2__c = 'testCategory2';
        AccountPlanHelper.fixCategoryFieldSetOrder(accountPlan);
        System.assertEquals('testCategory2', accountPlan.Category_1__c);
        System.assertEquals(4, AccountPlanHelper.getNumberOfCategories(accountPlan));

        accountPlan.Product_1_Name__c = 'testProduct1';
        AccountPlanHelper.copyProductFieldSet(accountPlan, null, 1);
        System.assertEquals(null, accountPlan.Product_1_Name__c);
        
        accountPlan.Product_2_Name__c = 'testProduct2';
        AccountPlanHelper.fixProductFieldSetOrder(accountPlan);
        System.assertEquals('testProduct2', accountPlan.Product_1_Name__c);
        System.assertEquals(4, AccountPlanHelper.getNumberOfProducts(accountPlan));

        tearDown();

    }

    public static testMethod void calculateImageResizeData() {
        
        setup();

        accountPlan.Market_101_Graphic__c = '<img alt="User-added image" height="199" src="https://c.cs5.content.force.com/servlet/rtaImage?eid=a0FO0000000wWaG&amp;feoid=00NO0000000IaQj&amp;refid=0EMO00000000156">';
        Map<String, String> calculateImageResizeData = AccountPlanHelper.calculateImageResizeData('0EMO00000000156=88px9999px|', accountPlan);
        String newImageTag = calculateImageResizeData.get('Market_101_Graphic__c');
        Integer newImageTagWidth = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagWidth < 88);
        Integer newImageTagHeight = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagHeight < 9999);

        accountPlan.Market_101_Graphic__c = '<img alt="User-added image" height="199" src="https://c.cs5.content.force.com/servlet/rtaImage?eid=a0FO0000000wWaG&amp;feoid=00NO0000000IaQj&amp;refid=0EMO00000000156">';
        calculateImageResizeData = AccountPlanHelper.calculateImageResizeData('0EMO00000000156=8888px99px|', accountPlan);
        newImageTag = calculateImageResizeData.get('Market_101_Graphic__c');
        newImageTagWidth = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagWidth < 8888);
        newImageTagHeight = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagHeight < 99);

        accountPlan.Market_101_Graphic__c = '<img alt="User-added image" height="199" src="https://c.cs5.content.force.com/servlet/rtaImage?eid=a0FO0000000wWaG&amp;feoid=00NO0000000IaQj&amp;refid=0EMO00000000156">';
        calculateImageResizeData = AccountPlanHelper.calculateImageResizeData('0EMO00000000156=8888px99999px|', accountPlan);
        newImageTag = calculateImageResizeData.get('Market_101_Graphic__c');
        newImageTagWidth = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagWidth < 8888);
        newImageTagHeight = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagHeight < 99999);

        accountPlan.Market_101_Graphic__c = '<img alt="User-added image" height="199" src="https://c.cs5.content.force.com/servlet/rtaImage?eid=a0FO0000000wWaG&amp;feoid=00NO0000000IaQj&amp;refid=0EMO00000000156">';
        calculateImageResizeData = AccountPlanHelper.calculateImageResizeData('0EMO00000000156=88888px9999px|', accountPlan);
        newImageTag = calculateImageResizeData.get('Market_101_Graphic__c');
        newImageTagWidth = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagWidth < 88888);
        newImageTagHeight = Integer.valueOf(newImageTag.split(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0]);
        System.assertEquals(true, newImageTagHeight < 9999);

        tearDown();

    }

    public static testMethod void getImageUrlFromHtml() {
        //get image url from null
        System.assertEquals(CrmsConstants.URL_S_GIF, AccountPlanHelper.getImageUrlFromHtml(null, true).get('src'));

        //get image url from no image html
        System.assertEquals(CrmsConstants.URL_S_GIF, AccountPlanHelper.getImageUrlFromHtml('no image html', true).get('src'));

        //get absolute image url with width and height from image html
        System.assertEquals('http://test/image.gif', AccountPlanHelper.getImageUrlFromHtml('<html><body><img src="http://test/image.gif" width="1" height="2"/></body></html>', false).get('src'));
        System.assertEquals('1', AccountPlanHelper.getImageUrlFromHtml('<html><body><img src="http://test/image.gif" width="1" height="2"/></body></html>', false).get('width'));
        System.assertEquals('2', AccountPlanHelper.getImageUrlFromHtml('<html><body><img src="http://test/image.gif" width="1" height="2"/></body></html>', false).get('height'));

        //get relative image url from image html
        System.assertEquals('/image.gif', AccountPlanHelper.getImageUrlFromHtml('<html><body><img src="http://test/image.gif"/></body></html>', true).get('src'));

        //get image url from image with parameters html
        System.assertEquals('/image.gif?param=1&param=2', AccountPlanHelper.getImageUrlFromHtml('<html><body><img src="/image.gif?param=1&amp;param=2"/></body></html>', true).get('src'));
    }

}