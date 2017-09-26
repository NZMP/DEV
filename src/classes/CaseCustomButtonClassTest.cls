@isTest
global class CaseCustomButtonClassTest {
	static testMethod void updateNotaCaseTest ()
    {
        List<Id> caseIds = new List<Id>();
        List<Case> cases = TestDataHelper.createCases(5, 'Customer Cases', 'Phone');
        insert cases;
        for(Case c:cases){
            caseIds.add(c.Id);
        }
        Test.startTest();
        Integer ret = CaseCustomButtonClass.updateNotaCase(caseIds);
		Test.stopTest();
		List<Case> c = [SELECT Id, Status FROM Case WHERE Id IN:caseIds AND Status = 'Not a Case'];
        system.assertEquals(5, c.size());
    }
}