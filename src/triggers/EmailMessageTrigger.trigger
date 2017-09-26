/*/**
* @author: Jerson Poblete
* @date 06/22/2017
* @description: trigger for EmailMessage object
*/
trigger EmailMessageTrigger on EmailMessage (before insert, after insert) {
    EmailMessageTriggerHandler emailMessageHandler = new EmailMessageTriggerHandler();
    if(Trigger.isAfter && Trigger.isInsert) {
         emailMessageHandler.handleAfterInsert(Trigger.newMap);    
    }
}