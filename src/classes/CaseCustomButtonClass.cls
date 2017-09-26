/*/**
* @author: Jerson Poblete
* @date JUL-3-2017
* @description: webservice class calls from custom button
*/
global with sharing class CaseCustomButtonClass {
    //update status to not a case
    webservice static Integer updateNotaCase(List<Id> caseIds){ 
        List<Case> caseToUpdate = new List<Case>();
        List<Id> caseUpdatedSuccess = new List<Id>();
        Integer ret;
        for(Case c : [SELECT Id, Status FROM Case WHERE Id in: caseIds]){
            Case cas = new Case();
            cas.Id = c.Id;
            cas.Status = 'Not a Case';
            caseToUpdate.add(cas);
        }
        if(caseToUpdate.size()>0){
            Database.SaveResult[] srList = Database.update(caseToUpdate, false);
            for(Database.SaveResult sr : srList ){
                if (sr.isSuccess()) {
                    caseUpdatedSuccess.add(sr.getId());
                }
            }
            ret = caseUpdatedSuccess.size();
        }
        return ret;
    }
    webservice static Id cloneCustomerCasetoTamsRequest(Id caseId){
        Case c = [SELECT Id, Subject, Description, Origin, Status, AccountId, ContactId, Request_Type__c, Related_Case__c FROM Case WHERE Id =:caseId];
        Id tamsType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TAMs Request').getRecordTypeId();
        Id ret;
        Case ca = new Case();
        ca.RecordTypeId = tamsType;
        ca.ContactId = c.ContactId;
        ca.AccountId = c.AccountId;
        ca.Origin = 'Email';
        ca.Status = 'New';
        ca.Subject = c.Subject;
        ca.Description = c.Description;
        ca.Request_Type__c = c.Request_Type__c;
        ca.Related_Case__c = c.Id;
        ca.OwnerId = '005900000016n0P';
        insert ca;
        ret = ca.Id;
        return ret;
    }
}