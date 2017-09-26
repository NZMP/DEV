@isTest
private class GDTPriceBetTriggerHandlerTest {

    public static GDT_Event__c gdtEvent;
    public static GDT_Event__c gdtEvent2;
    public static GDT_Price_Bet__c gdtBet;
    public static GDT_Price_Bet__c gdtBet2;
    
    public static void setup() {
    }
    public static void tearDown() {
    }
 
    public static testMethod void insertGDTPriceBet1() {
        // Unit Test where all events exist
        setup();
        
        gdtEvent = TestDataHelper.createGDTEvent(true);
        gdtEvent2 = TestDataHelper.createGDTEvent(false);
        gdtEvent2.Name = string.valueof(integer.valueof(gdtEvent.Name) + 8);
        insert gdtEvent2; 
        
        gdtBet = TestDataHelper.createGDTPriceBet(true, gdtEvent.id, 1, 2, 3, 4, 5, 6);
        
        List<GDT_Price_Bet__c> allgdtBets = [SELECT id, Name FROM GDT_Price_Bet__c WHERE GDT_Event__c = :gdtEvent2.Id];
      //  System.assert(allgdtBets.size() == 1);
    }
    
    public static testMethod void insertGDTPriceBet2() {
        // Unit Test where second event doesn't exist
        setup();
        
        gdtEvent = TestDataHelper.createGDTEvent(true);
        try{
            gdtBet = TestDataHelper.createGDTPriceBet(true, gdtEvent.id, 1, 2, 3, 4, 5, 6);
        }
        catch(DmlException ex){
           // System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION'  , ex.getDmlStatusCode(0));
        }
        
    }
    
    public static testMethod void insertGDTPriceBet3() {
        // Unit Test where gdt bet already exists for the user and event
        setup();
        
        gdtEvent = TestDataHelper.createGDTEvent(true);
        gdtEvent2 = TestDataHelper.createGDTEvent(false);
        gdtEvent2.Name = string.valueof(integer.valueof(gdtEvent.Name) + 8);
        insert gdtEvent2; 
        
        gdtBet = TestDataHelper.createGDTPriceBet(true, gdtEvent.id, 1, 2, 3, 4, 5, 6);
        
        try{
            gdtBet2 = TestDataHelper.createGDTPriceBet(true, gdtEvent.id, 1, 2, 3, 4, 5, 6);
        }
        catch(DmlException ex){
         //   System.assertEquals('DUPLICATE_VALUE'  , ex.getDmlStatusCode(0));
            
        }
    }
    
    
}