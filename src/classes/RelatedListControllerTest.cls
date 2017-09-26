public with sharing class RelatedListControllerTest {

	public static Account account1;
	public static Opportunity opportunity1;	
	public static Opportunity opportunity2;

	public static void setup() {
		account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
		opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
		opportunity2 = TestDataHelper.createOpportunity(account1.Id, true);
	}

	public static void tearDown() {
	}

	public static testMethod void relatedListController() {
		
		setup();

		//Setup controller for related list
		RelatedListController controller = new RelatedListController();
		controller.sortDirection = '';
		controller.getRecords();
		
		//Set attribute variables
		controller.objectName = 'Opportunity';
		controller.fieldsCSV = 'Id,Name,Amount,CloseDate';
		controller.parentFieldName = 'AccountId';
		controller.parentFieldId = account1.Id;
		controller.filter = 'Amount = 0';
		controller.orderByFieldName=  'Amount';
		controller.sortDirection = 'desc';
		controller.pageSize = 1;

		controller.getHideFieldsCSV2();
		controller.hideFieldsCSV = 'Id';
		controller.getHideFieldsCSV2();

		controller.getShowNewButton();

		//Call method to get records
		controller.getRecords();
	
		//Assert number of opps found = 2
		system.assertEquals(2, controller.ssc.getResultSize());

		controller.fieldsCSV = null;
		controller.fieldsList = new List<String>{'Id', 'Name'};
		controller.sortByField = 'Name';
		controller.parentFieldName = 'AccountId,Account.ParentId';
		controller.parentFieldId = account1.Id + ',' + account1.Id;
		controller.getRecords();

		//Delete an opp
		controller.deleteRecordId = opportunity1.Id;
		controller.deleteRecord();	
		
		//Assert size of opps is now 1
		system.assertEquals(1, controller.ssc.getResultSize());

		//Delete aother opp
		controller.deleteRecordId = opportunity2.Id;
		controller.deleteRecord();
		
		//Assert size of opps is now 0
		system.assertEquals(0, controller.ssc.getResultSize());
		
		//Sort by name
		controller.sortByField = 'Name';
		controller.sortByField(); //Clears list of records
		controller.getRecords(); //requeries list of records

		tearDown();

	}

}