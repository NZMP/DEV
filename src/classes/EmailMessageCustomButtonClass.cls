/*/**
* @author: Jerson Poblete
* @date SEPT-20-2017
* @description: webservice class calls from emailmessage custom button
*/
global with sharing class EmailMessageCustomButtonClass {
    webservice static Id createPDFattachment(Id emId){ 
        Id attId;
        EmailMessage em = [SELECT Id, HtmlBody, Subject FROM EmailMessage WHERE Id =: emId];
        Attachment att = new Attachment();
        //att.Body = Blob.toPDF(em.htmlBody);
        att.Body = Blob.valueof(em.htmlBody);
        att.Name = em.subject + '.html';
        att.ContentType = 'application/html';
        att.ParentId = em.Id;
        insert att;
        attId = att.Id;
        return attId;
    }
}