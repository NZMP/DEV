public with sharing class GDTPriceBetTriggerHandler {
	
	// firstRun variables and properties to avoid recursive calls
	private static boolean firstRun = true;
	public static boolean isFirstRun(){ return firstRun; }
	public static void setFirstRunFalse(){ firstRun = false;}
	
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public GDTPriceBetTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	public void onAfterInsert(List<GDT_Price_Bet__c> newGDTPriceBets){
		createFollowupGDTPriceBet(newGDTPriceBets);
	}
	
	public void onAfterUpdate(Map<Id, GDT_Price_Bet__c> updatedGDTPriceBetsMap){
		updateFollowupGDTPriceBet(updatedGDTPriceBetsMap);
	}
	
	// Creates followup GDT Price bet records, but only if this is the first run
	public static void createFollowupGDTPriceBet(List<GDT_Price_Bet__c> gdtPriceBets){
		System.debug('### GDTPriceBetTriggerHandler gdtPriceBets: ' + gdtPriceBets);
		List<GDT_Price_Bet__c> betsToCopy = new List<GDT_Price_Bet__c>();
		List<GDT_Price_Bet__c> followupBetsToCreate = new List<GDT_Price_Bet__c>(); // holds the new records to create
		
		Set<Integer> futureGdtEvents = new Set<Integer>(); // Holds the Event numbers to query for
		map<Integer, Id> eventNumberIdMap = new map<Integer, Id>();  // map<Event_Number__c, Id>

		// Create a list of events to query for
		for(GDT_Price_Bet__c bet : gdtPriceBets){
			if(bet.AMF_Bet_8__c != null || bet.SMP_Bet_8__c != null || bet.WMP_Bet_8__c != null){
				betsToCopy.add(bet);
				if(bet.GDT_Event_8__c != null){
					futureGdtEvents.add(integer.valueof(bet.GDT_Event_8__c));
				}
			}
		}
		System.debug('### GDTPriceBetTriggerHandler futureGdtEvents: ' + futureGdtEvents);
		
		// Find the IDs of the events, and arrange into a map of map<Event_Number__c, Id>
		List<GDT_Event__c> gdtEvents = [SELECT Id, Name, Event_Number__c FROM GDT_Event__c WHERE Event_Number__c IN :futureGdtEvents];
		for(GDT_Event__c gdtEvent : gdtEvents){
			eventNumberIdMap.put(integer.valueof(gdtEvent.Event_Number__c), gdtEvent.id);
		}
		System.debug('### GDTPriceBetTriggerHandler eventNumberIdMap: ' + eventNumberIdMap);
		
		// Create the follow up records
		for(GDT_Price_Bet__c bet : betsToCopy){
			System.debug('### GDTPriceBetTriggerHandler betToCopy: ' + bet);
			GDT_Price_Bet__c newbet = new GDT_Price_Bet__c(AMF_Bet__c = bet.AMF_Bet_8__c, SMP_bet__c = bet.SMP_Bet_8__c, WMP_bet__c = bet.WMP_Bet_8__c,
												Forecasted_AMF_Bet__c = bet.AMF_Bet_8__c, Forecasted_SMP_Bet__c = bet.SMP_Bet_8__c, Forecasted_WMP_Bet__c = bet.WMP_Bet_8__c,
												System_Update__c = true, Parent_GDT_Price_Bet__c = bet.Id);
			
			if(eventNumberIdMap.containsKey(integer.valueof(bet.GDT_Event_8__c))){
				newbet.GDT_Event__c = eventNumberIdMap.get(integer.valueof(bet.GDT_Event_8__c));
				followupBetsToCreate.add(newBet);
			}
			else{
				bet.GDT_Event_8__c.addError('No future GDT event record exists for ' + string.valueof(bet.GDT_Event_8__c));				
			}			
		}
		System.debug('### GDTPriceBetTriggerHandler followupBetsToCreate: ' + followupBetsToCreate); 
		GDTPriceBetTriggerHandler.setFirstRunFalse();

		try{
			Database.SaveResult[] results = Database.insert(followupBetsToCreate, false);
			for(integer i = 0; i< results.size(); i++ ){
				if(!results[i].isSuccess()){
					string errorMessage = '';
					for(Database.Error err : results[i].getErrors()) {
            			errorMessage += err.getMessage();
        			}
        			followupBetsToCreate[i].addError('Record could not be added.');
				}
			}
		}
		catch(DmlException ex){
			System.debug(LoggingLevel.ERROR, '### ex: ' + ex);
		}
	}
	
	// Updates related existing GDT Price bet records
	public static void updateFollowupGDTPriceBet(Map<Id, GDT_Price_Bet__c> gdtPriceBetsMap){
		List<GDT_Price_Bet__c> childBetsList = [select Id, Parent_GDT_Price_Bet__c from GDT_Price_Bet__c where Parent_GDT_Price_Bet__c in :gdtPriceBetsMap.keySet()];
		List<GDT_Price_Bet__c> betsToCreate = new List<GDT_Price_Bet__c>();
		List<GDT_Price_Bet__c> betsToUpdate = new List<GDT_Price_Bet__c>();
		Map<GDT_Price_Bet__c, Id> sourceTargetBetMap = new Map<GDT_Price_Bet__c, Id>();
		Map<Id, Id> parentGDTBetChildBetMap = new Map<Id,Id>();
		
		for (GDT_Price_Bet__c bet : childBetsList){
			parentGDTBetChildBetMap.put(bet.Parent_GDT_Price_Bet__c, bet.Id);
		}
		
		for (GDT_Price_Bet__c bet : gdtPriceBetsMap.values()){
			if (!parentGDTBetChildBetMap.keySet().contains(bet.Id)){ // if it does not have a child bet, create new
				betsToCreate.add(bet);
			}
			else { // if it is already in the system
				sourceTargetBetMap.put(bet, parentGDTBetChildBetMap.get(bet.Id));
			}
		}
		
		//create the bets
		createFollowupGDTPriceBet(betsToCreate);
		
		// now update
		
		for(GDT_Price_Bet__c bet : sourceTargetBetMap.keySet()){
			System.debug('### GDTPriceBetTriggerHandler betToCopy: ' + bet);
			GDT_Price_Bet__c newbet = new GDT_Price_Bet__c(Id = sourceTargetBetMap.get(bet), AMF_Bet__c = bet.AMF_Bet_8__c, SMP_bet__c = bet.SMP_Bet_8__c, WMP_bet__c = bet.WMP_Bet_8__c,
												Forecasted_AMF_Bet__c = bet.AMF_Bet_8__c, Forecasted_SMP_Bet__c = bet.SMP_Bet_8__c, Forecasted_WMP_Bet__c = bet.WMP_Bet_8__c,
												System_Update__c = true);
			betsToUpdate.add(newbet);
		}
		
		try{
			Database.SaveResult[] results = Database.update(betsToUpdate, false);
			for(integer i = 0; i< results.size(); i++ ){
				if(!results[i].isSuccess()){
					string errorMessage = '';
					for(Database.Error err : results[i].getErrors()) {
            			errorMessage += err.getMessage();
        			}
        			betsToUpdate[i].addError('Record could not be updated.');
				}
			}
		}
		catch(DmlException ex){
			System.debug(LoggingLevel.ERROR, '### ex: ' + ex);
		}
		/*
		System.debug('### GDTPriceBetTriggerHandler gdtPriceBets: ' + gdtPriceBets);
		List<GDT_Price_Bet__c> betsToCopy = new List<GDT_Price_Bet__c>();
		List<GDT_Price_Bet__c> followupBetsToUpdate = new List<GDT_Price_Bet__c>(); // holds the new records to create
		
		Set<Integer> futureGdtEvents = new Set<Integer>(); // Holds the Event numbers to query for
		map<Integer, Id> eventNumberIdMap = new map<Integer, Id>();  // map<Event_Number__c, Id>

		
		
		
		
		// Create a list of events to query for
		for(GDT_Price_Bet__c bet : gdtPriceBets){
			if(bet.AMF_Bet_8__c != null || bet.SMP_Bet_8__c != null || bet.WMP_Bet_8__c != null){
				betsToCopy.add(bet);
				if(bet.GDT_Event_8__c != null){
					futureGdtEvents.add(integer.valueof(bet.GDT_Event_8__c));
				}
			}
		}
		System.debug('### GDTPriceBetTriggerHandler futureGdtEvents: ' + futureGdtEvents);
		
		// Find the IDs of the events, and arrange into a map of map<Event_Number__c, Id>
		List<GDT_Event__c> gdtEvents = [SELECT Id, Name, Event_Number__c FROM GDT_Event__c WHERE Event_Number__c IN :futureGdtEvents];
		for(GDT_Event__c gdtEvent : gdtEvents){
			eventNumberIdMap.put(integer.valueof(gdtEvent.Event_Number__c), gdtEvent.id);
		}
		System.debug('### GDTPriceBetTriggerHandler eventNumberIdMap: ' + eventNumberIdMap);
		
		// Create the follow up records
		for(GDT_Price_Bet__c bet : betsToCopy){
			System.debug('### GDTPriceBetTriggerHandler betToCopy: ' + bet);
			GDT_Price_Bet__c newbet = new GDT_Price_Bet__c(AMF_Bet__c = bet.AMF_Bet_8__c, SMP_bet__c = bet.SMP_Bet_8__c, WMP_bet__c = bet.WMP_Bet_8__c,
												Forecasted_AMF_Bet__c = bet.AMF_Bet_8__c, Forecasted_SMP_Bet__c = bet.SMP_Bet_8__c, Forecasted_WMP_Bet__c = bet.WMP_Bet_8__c,
												System_Update__c = true);
			
			if(eventNumberIdMap.containsKey(integer.valueof(bet.GDT_Event_8__c))){
				newbet.GDT_Event__c = eventNumberIdMap.get(integer.valueof(bet.GDT_Event_8__c));
				followupBetsToCreate.add(newBet);
			}
			else{
				bet.GDT_Event_8__c.addError('No future GDT event record exists for ' + string.valueof(bet.GDT_Event_8__c));				
			}			
		}
		System.debug('### GDTPriceBetTriggerHandler followupBetsToCreate: ' + followupBetsToCreate); 
		GDTPriceBetTriggerHandler.setFirstRunFalse();

		try{
			Database.SaveResult[] results = Database.insert(followupBetsToCreate, false);
			for(integer i = 0; i< results.size(); i++ ){
				if(!results[i].isSuccess()){
					string errorMessage = '';
					for(Database.Error err : results[i].getErrors()) {
            			errorMessage += err.getMessage();
        			}
        			followupBetsToCreate[i].addError('Record could not be added.');
				}
			}
		}
		catch(DmlException ex){
			System.debug(LoggingLevel.ERROR, '### ex: ' + ex);
		}
	*/
	}
	
}