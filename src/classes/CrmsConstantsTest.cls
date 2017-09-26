@isTest
public class CrmsConstantsTest {

    public static testMethod void getRecordTypeInfoMap() {
    	System.assertNotEquals(null, CrmsConstants.getRecordTypeInfoMap('Account'));
    }

    public static testMethod void getRecordTypeId() {
    	System.assertNotEquals(null, CrmsConstants.getRecordTypeId('Account', CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY));
    }

    public static testMethod void getStandardPriceBook2Id() {
    	System.assertNotEquals(null, CrmsConstants.getStandardPriceBook2Id());
    }

    public static testMethod void getReport() {
    	System.assertEquals(null, CrmsConstants.getReport('testReportName'));
    }

    public static testMethod void getReportId() {
    	System.assertEquals(null, CrmsConstants.getReportId('testReportName'));
    }

    public static testMethod void getUserIdToUserMap() {
    	System.assertNotEquals(null, CrmsConstants.getUserIdToUserMap());
    }

    public static testMethod void getProfileNameForId() {
    	System.assertEquals(null, CrmsConstants.getProfileNameForId(null));
    	System.assertNotEquals(null, CrmsConstants.getProfileNameForId(UserInfo.getUserId()));
    }

	public static testMethod void createTask() {
		Account account = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
		Task testTask = CrmsConstants.createTask('testSubject', 'testDescription', account.Id, UserInfo.getUserId(), 'testTaskType', 'testPriority', CrmsConstants.TASK_STATUS_COMPLETED, true, 0, 0, null);
		System.assertEquals(account.Id, testTask.WhatId);
		System.assertEquals(UserInfo.getUserId(), testTask.OwnerId);
		System.assertEquals('testTaskType', testTask.Type);
		System.assertEquals('testPriority', testTask.Priority);
		System.assertEquals(CrmsConstants.TASK_STATUS_COMPLETED, testTask.Status);
		System.assertEquals(System.today(), testTask.ActivityDate);
		System.assertEquals(System.now(), testTask.ReminderDateTime);
		testTask = CrmsConstants.createTask('testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters testSubjectLargerThan255Characters ', 'testDescription', account.Id, UserInfo.getUserId(), 'testTaskType', CrmsConstants.TASK_PRIORITY_NORMAL, CrmsConstants.TASK_STATUS_COMPLETED, true, null, 0, System.now());
		System.assertEquals(account.Id, testTask.WhatId);
		System.assertEquals(UserInfo.getUserId(), testTask.OwnerId);
		System.assertEquals(System.today(), testTask.ActivityDate);
		System.assertEquals(System.now(), testTask.ReminderDateTime);
	}

}