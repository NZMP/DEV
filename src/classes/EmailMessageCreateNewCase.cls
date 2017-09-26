/*/**
* @author: Jerson Poblete
* @date JUL-3-2017
* @description: webservice class calls from custom button
*/
global with sharing class EmailMessageCreateNewCase {
     webservice static Id createNewCase(Id emailId){
         Id ret = null;
         for(EmailMessage em: [SELECT  Id, Status, Incoming, TextBody, HTMLBody, FromName, FromAddress, ToAddress, CcAddress, Subject,
                               ParentId, Parent.Status, Parent.Record_Type_Name__c, Parent.ContactId, Parent.OwnerId
                               FROM EmailMessage WHERE Id =:emailId])
         {
             if(em.Parent.Status == 'In Progress' && em.Parent.Record_Type_Name__c == 'Customer Cases' && em.Incoming){		//&& em.Status == '1'
                 Id caseId = createCase(em);
                 Case c = new Case();
                 c.Id = em.ParentId;
                 c.Status = 'Closed';
                 c.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Cases Closed').getRecordTypeId();
                 update c;
                 ret = caseId;
             }
         } 
        return ret;
    }
    private static Id createCase(EmailMessage em)
    {
        Id ret;
        Id ccType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Customer Cases').getRecordTypeId();
        String htmlbody = em.HTMLBody.replaceAll('\\<img.*?\\>', '<p style="font-size:11px;"><i>[See the attachment for inline image]</i></p>');
        //String htmlbody = em.HTMLBody.replaceAll('\\<img.*?src="cid:.*?\\>', '<p style="font-size:11px;"><i>[See the attachment for inline image]</i></p>');
        Case c = new Case();
        c.Status = 'New';
        c.Origin = 'Email';
        c.ContactId = em.Parent.ContactId;
        c.OwnerId = em.Parent.OwnerId;
        c.RecordTypeId = ccType;
        c.Description = em.TextBody;
        c.Related_Case__c = em.ParentId;
        c.Subject = em.Subject;
        insert c;
        ret = c.Id;
        EmailMessage email = new EmailMessage();
        email.FromAddress = em.FromAddress;
        email.ToAddress = em.ToAddress;
        email.Subject = em.Subject;
        email.CcAddress = em.CcAddress;
        email.TextBody = em.TextBody;
        email.HtmlBody = htmlbody;
        email.FromName = em.FromName;
        email.ParentId = c.Id;
        email.RelatedToId = c.Id;
        email.Status = '0';
        email.Incoming = true;
        insert email;
        Id oldParent = em.Id;
        Id newParent = email.Id;
        reparentAttachment(oldParent, newParent);
        return ret;
    }
    /*******************************************************************************************************
    * @description method to reparent the attachment to the new email message
    ********************************************************************************************************/
    @future
    private static void reparentAttachment(Id oldparent, Id newParent){
        EmailMessage message = [SELECT Id, TextBody, HTMLBody FROM EmailMessage WHERE Id=:newParent];
        List<Attachment> att = [SELECT Id, Name, Body, ContentType, Description FROM Attachment WHERE ParentId =:oldparent];
        List<Attachment> attList = new List<Attachment>();
        
        for(Attachment a : att){
            Attachment at = New Attachment(Name = a.Name, Body = a.Body);
            at.ParentId = newParent;
            attList.add(at);
        }
        if(attList.size()>0){
            insert attList;
            delete att;
        }
    }
}