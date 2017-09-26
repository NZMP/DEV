public with sharing class AccountPlanTriggerHandler {
	public static void createCompetitorAnalysisSnapshot(List<Revised_Account_Plan__c> accountPlanOldList, List<Revised_Account_Plan__c> accountPlanNewList) {
		Set<Id> accountIdSet = new Set<Id>();
		Map<Id, Revised_Account_Plan__c> accountPlanMap = new Map<Id, Revised_Account_Plan__c>();
		List<Competitor_Analysis_Snapshot__c> compASnapInsertList = new List<Competitor_Analysis_Snapshot__c>();
		for(Integer i=0; accountPlanNewList.size() > i; i++) {
			if(accountPlanNewList[i].Account_Planning_Status__c != accountPlanOldList[i].Account_Planning_Status__c) {
				if(accountPlanNewList[i].Account_Planning_Status__c == 'Historical') {
					accountIdSet.add(accountPlanNewList[i].Account_Name__c);
					accountPlanMap.put(accountPlanNewList[i].Account_Name__c, accountPlanNewList[i]);
				}
			}
		}
		if(accountIdSet.size() > 0 ) {
		List<Account> accountList = [Select Id, (select Id, Name, Competitor__c, 
                                                            RecordType.DeveloperName, Ranking_New__c, Opportunity__c, 
                                                            Share_Percent__c, Commodity_Class__c  
                                                            from Competitors__r  
                                                            where RecordType.DeveloperName = 'Account_Competitor'
                                                            order by Ranking_New__c
                                                            limit 3 )From Account where id=:accountIdSet];
			if(accountList.size() > 0) {
				for(Account acc: accountList) {
					if(acc.Competitors__r.size() > 0) {
						for(Competitor_Analysis__c compA : acc.Competitors__r) {
							Competitor_Analysis_Snapshot__c compASnap = new Competitor_Analysis_Snapshot__c();
							compASnap.Account_Plan__c = accountPlanMap.get(acc.Id).Id;
							compASnap.Commodity_Class__c = compA.Commodity_Class__c;
							compASnap.Competitor__c = compA.Competitor__c;
							compASnap.Ranking__c = compA.Ranking_New__c;
							compASnap.Share_Percent__c = compA.Share_Percent__c;
							compASnapInsertList.add(compASnap);
						}
					}
				}
				
				if(compASnapInsertList.size() > 0) {
					insert compASnapInsertList;
				}
			}
		}
	}
}