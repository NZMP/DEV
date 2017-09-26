public without sharing class GDTEventsController {
    @AuraEnabled
    public static List<GDT_Event__c> gdtEvents () {
        return [SELECT Id, Name, Event_Date__c  FROM GDT_Event__C WHERE Event_Date__c >= TODAY ORDER BY Event_Date__c ASC LIMIT 5];
    }   
}