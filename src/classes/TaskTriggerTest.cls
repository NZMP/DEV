/*
* Author: Nino Bustillos
* Description:
* History:
*     12Oct2016 NBustillos(DC): initial version
*/
@isTest(SeeAlLData=false)
public with sharing class TaskTriggerTest {
    @TestSetup
    static void setup(){
    	// Create Account
    	Account testAccount = TestDataHelper.createAccount('Reseller Customer','TestGroup','12345',false);
    	insert testAccount;
    	
    	// Create Audit for the Account
    	Audit__c testAudit = TestDataHelper.createAudit();
    	testAudit.Reseller__c = testAccount.Id;
    	insert testAudit;
    	
    	// Create Audit Notes for the Account Audit record
    	List<Audit_Notes__c> testAuditNotesList = new List<Audit_Notes__c>();
    	Map<Id,List<Audit_Notes__c>> testAuditNotesMap = TestDataHelper.createAuditNotes(new Set<Id>{testAudit.Id}, 5);
    	for(Id auditId : testAuditNotesMap.keySet()){
    		testAuditNotesList.addAll(testAuditNotesMap.get(auditId));
    	}
    	insert testAuditNotesList;
    }
    
    static testmethod void auditNoteTaskInsertAndUpdate(){
    	// Query existing audit notes
    	List<Audit_Notes__c> auditNotesList = [SELECT Id FROM Audit_Notes__c];
    	
    	Test.startTest();
    	
    	// Insert task for audit notes. Assumption is that there is a 1-1 mapping between these object
    	Map<Id,Task> taskMap = new Map<Id,Task>();
    	for(Audit_Notes__c auditNote : auditNotesList){
    		Task t = TestDataHelper.createTask();
    		t.WhatId = auditNote.Id;
    		t.Type = 'Task';
    		t.Subject = 'Test Subject';
    		t.Status = 'Not Started';
    		t.Priority = 'Low';
    		t.ActivityDate = system.today().addMonths(1);
    		taskMap.put(auditNote.id,t);
    	}
    	insert taskMap.values();
    	
    	// Query the latest Audit Notes and check if task status is equal to the audit note status
    	for(Audit_Notes__c auditNote: [SELECT Id, Status__c FROM Audit_Notes__c WHERE Id IN :taskMap.keySet()]){
    			Task t = taskMap.get(auditNote.Id);
    			system.assertEquals(t.Status, auditNote.Status__c);
    	}
    	
    	
    	// Update existing task
    	for(Id auditNoteId : taskMap.keySet()){
    		Task t = taskMap.get(auditNoteId);
    		t.Status = 'In Progress';
    		taskMap.put(auditNoteId, t);
    	}
    	update taskMap.values();
    	
    	// Query the latest Audit Notes and check if task status is equal to the audit note status
    	for(Audit_Notes__c auditNote: [SELECT Id, Status__c FROM Audit_Notes__c WHERE Id IN :taskMap.keySet()]){
    			Task t = taskMap.get(auditNote.Id);
    			system.assertEquals(t.Status, auditNote.Status__c);
    	}
    	
    	Test.stopTest();
    }
}