@isTest
private class CaseTriggerTest {
	@isTest static void CaseTrigger() {
		Id COMPLAINTSRTID = [SELECT Id FROM RecordType WHERE Name = 'Complaints'].Id;
		//Id COMMCASERTID = [SELECT Id FROM RecordType WHERE Name = 'Community Case'].Id;
		User testUser = [SELECT Id FROM User WHERE isActive = true AND ROC__c = 'SEA' LIMIT 1];
		Test.startTest();
		system.runAs(testUser){
			Case cse1 = new Case();
			cse1.Status = 'New';
            cse1.Origin = 'Phone';
			//cse1.Origin = 'Reseller Community';
			cse1.RecordTypeID = COMPLAINTSRTID;
			insert cse1;
		}
		Case cseUpdateOwner = [SELECT Id, OwnerID ,RecordTypeId,Status FROM Case WHERE RecordTypeId =: COMPLAINTSRTID];
		//system.debug('##CASE OWNER: ' + cseUpdateOwner.OwnerID);
		//system.assert(cseUpdateOwner.OwnerID != testUser.Id);

		Complaints_Statuses__c cs = new Complaints_Statuses__c(Name='Close NCR', CC_Status__c = 'Completed');
		insert cs;

		cseUpdateOwner.RecordTypeID = COMPLAINTSRTID;
		cseUpdateOwner.Status = 'Close NCR';
		update cseUpdateOwner;

		Case cseUpdate = [SELECT Id, Status FROM Case WHERE RecordTypeID=: COMPLAINTSRTID];
		system.debug('##CASE STATUS: ' + cseUpdate);
		system.assertEquals(cseUpdate.Status, 'Completed');
		Test.stopTest();
	}
    static testMethod void updateOwnershipTestExistingContact() {
        Set<Id> casId = new Set<Id>();
        UserRole r = new UserRole(DeveloperName = 'SalesOperations', Name = 'Sales Operations');
        insert r;
        User u = TestDataHelper.createUser('testupdateOwnershipTestExistingContact@fonterra.com', 'SOE Full', false);
        u.UserRoleId = r.Id;
        u.ROC__c = 'SEA';
        u.UserRoleId = r.Id;
        insert u;
        system.runAs(u){
            TestDataHelper.createROC('SEA');
            Id accType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To Party').getRecordTypeId();
            Account a = new Account(RecordTypeId = accType, Name = 'Acme', Primary_Service_SOE__c = u.Id);
            insert a;
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'LastName';
            con.Email = 'test@yahoo.com';
            con.AccountId = a.id;
            insert con;
            /*Account a1 = new Account(RecordTypeId = accType, Name = 'Acme1');
            insert a1;
            Contact con1 = new Contact();
            con1.FirstName = 'Test1';
            con1.LastName = 'LastName1';
            con1.Email = 'test1@yahoo.com';
            con1.AccountId = a1.id;
            insert con1;*/
            Case cas = TestDataHelper.createCases(1, 'Customer Cases', 'Email')[0];
            cas.EmailMessagetoAddresses__c = 'test@fonterra.com';
            cas.ContactId = con.Id;
            insert cas;
            casId.add(cas.Id);
            /*Case cas1 = TestDataHelper.createCases(1, 'Customer Cases', 'Email')[0];
            cas1.EmailMessagetoAddresses__c = 'test@yahoo.com.test';
            cas1.ContactId = con1.Id;
            insert cas1;
            casId.add(cas1.Id);*/
        }
        test.startTest();
        CaseTriggerClass.updateOwnership(casId);
        test.stopTest();
        Case c = [SELECT Id, Owner.Id FROM Case LIMIT 1];
        system.assertEquals(u.Id, c.Owner.Id); //salesforce known issue - Owner cannot query in test class
        
    }
    static testMethod void updateOwnershipTestExistingContactPrimaryServiceNull() {
        Set<Id> casId = new Set<Id>();
        UserRole r = new UserRole(DeveloperName = 'SalesOperations', Name = 'Sales Operations');
        insert r;
        User u = TestDataHelper.createUser('testupdateOwnershipTestExistingContact@fonterra.com', 'SOE Full', false);
        u.UserRoleId = r.Id;
        u.ROC__c = 'SEA';
        u.UserRoleId = r.Id;
        insert u;
        system.runAs(u){
            TestDataHelper.createROC('SEA');
            Id accType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To Party').getRecordTypeId();
            Account a = new Account(RecordTypeId = accType, Name = 'Acme');
            insert a;
            Contact con = new Contact();
            con.FirstName = 'Test';
            con.LastName = 'LastName';
            con.Email = 'test@yahoo.com';
            con.AccountId = a.id;
            insert con;
            Case cas = TestDataHelper.createCases(1, 'Customer Cases', 'Email')[0];
            cas.EmailMessagetoAddresses__c = 'test@fonterra.com';
            cas.ContactId = con.Id;
            insert cas;
            casId.add(cas.Id);
        }
        test.startTest();
        CaseTriggerClass.updateOwnership(casId);
        test.stopTest();
        Case c = [SELECT Id, Owner.Id FROM Case LIMIT 1];
        system.assertEquals(u.Id, c.Owner.Id); //salesforce known issue - Owner cannot query in test class
        
    }
    static testMethod void updateOwnershipTestNoContact() {
        Set<Id> casId = new Set<Id>();
        UserRole r = new UserRole(DeveloperName = 'SalesOperations', Name = 'Sales Operations');
        insert r;
        User u = TestDataHelper.createUser('testupdateOwnershipTestNoContact@fonterra.com', 'SOE Full', false);
        u.UserRoleId = r.Id;
        u.ROC__c = 'SEA';
        u.UserRoleId = r.Id;
        insert u;
        system.runAs(u){
            TestDataHelper.createROC('SEA');
            Case cas = TestDataHelper.createCases(1, 'Customer Cases', 'Email')[0];
            cas.EmailMessagetoAddresses__c = 'test@fonterra.com';
            cas.EmailMessageCcAddresses__c = 'test1@fonterra.com';
            insert cas;
            casId.add(cas.Id);
        }
        test.startTest();
        CaseTriggerClass.updateOwnership(casId);
        test.stopTest();
        Case c = [SELECT Id, Owner.Id FROM Case LIMIT 1];
        system.assertEquals(u.Id, c.Owner.Id); //salesforce known issue - Owner cannot query in test class
    }
   	 static testMethod void updateOwnershipTestNoContactCC() {
        Set<Id> casId = new Set<Id>();
        UserRole r = new UserRole(DeveloperName = 'SalesOperations', Name = 'Sales Operations');
        insert r;
        User u = TestDataHelper.createUser('testupdateOwnershipTestNoContactCC@fonterra.com', 'SOE Full', false);
        u.UserRoleId = r.Id;
        u.ROC__c = 'SEA';
        u.UserRoleId = r.Id;
        insert u;
        system.runAs(u){
            TestDataHelper.createROC('SEA');
            Case cas = TestDataHelper.createCases(1, 'Customer Cases', 'Email')[0];
            cas.EmailMessagetoAddresses__c = '';
            cas.EmailMessageCcAddresses__c = 'testupdateOwnershipTestNoContactCC@fonterra.com';
            insert cas;
            casId.add(cas.Id);
        }
        test.startTest();
        CaseTriggerClass.updateOwnership(casId);
        test.stopTest();
        Case c = [SELECT Id, Owner.Id FROM Case LIMIT 1];
        system.assertEquals(u.Id, c.Owner.Id); //salesforce known issue - Owner cannot query in test class
    }
    
    /*
    * @description: Create Case with Task and Closed case and catching the error
    * author: Joseph Andrew Tatel
    */
    
    static testMethod void testvalidateCaseClose() {
        //test method for validateCaseClose
        //Use start and stop test to avoid governor limits
        //catch the exception and assert using this System.assertEquals()
        
        //Create Test Case
        Case c = new Case();
        c.Status = 'New';
        //c.Case_Type__c = 'General';
        //c.Case_Sub_Type__c = 'GDT Inquiry';
        c.Origin = 'Phone';
        c.Priority = 'Medium';
        c.Subject = 'Subject';
        c.Description = 'Description';
        insert c; 
        
        //Create Task inside the Case        
        Task t = new Task();
        t.Status = 'Not Started';
        t.Subject = 'Approval Requested';
        t.WhatId = c.Id;
        t.Priority = 'Medium';
        insert t;
        
        //Update Case to Closed and Catch error
        try{
            c.Status = 'Closed';
            update c;
        }catch(exception e){
            String message = e.getMessage();
            String errorMessage = 'Please close your open tasks before closing the case';
            System.assert(message.contains(errorMessage));
        }
                                        
    }
}