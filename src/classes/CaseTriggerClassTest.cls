@isTest
private class CaseTriggerClassTest {
    static testMethod void testvalidateCaseClose() {
        //test method for validateCaseClose
        //Use start and stop test to avoid governor limits
        //catch the exception and assert using this System.assertEquals()
        
        //Create Test Case
        Case c = new Case();
            c.Status = 'New';
            c.Case_Type__c = 'General';
            c.Case_Sub_Type__c = 'GDT Inquiry';
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
            //t.OwnerId = 'Joseph Tatel';
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
    
    static testMethod void testupdateCaseOwner() {
        //test method for Case Assignment Logic
        //Use start and stop test to avoid governor limits
        //catch the exception and assert using this System.assertEquals()
    }

}