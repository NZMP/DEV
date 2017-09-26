public with sharing class AccountPlanDetailAccountGroupTabsCtlr {

    private static final Integer RELATED_LIST_PAGE_SIZE = 5;
    private final Account_Plan__c accountPlan;

    public AccountPlanDetailAccountGroupTabsCtlr(ApexPages.StandardController controller) {
        this.accountPlan = (Account_Plan__c)controller.getRecord();
    }

    public ApexPages.StandardSetController opportunityRecords {
        get {
            if (opportunityRecords == null) {
                opportunityRecords = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Account_Name__c, Name, StageName, Amount, CloseDate FROM Opportunity 
                     WHERE AccountId IN (SELECT Id FROM Account WHERE Id = :accountPlan.Account__c) 
                     AND IsClosed = false]));
                opportunityRecords.setPageSize(RELATED_LIST_PAGE_SIZE);
            }
            return opportunityRecords;
        }
        private set;
    }

    public List<Opportunity> getOpportunities() {
        return (List<Opportunity>) opportunityRecords.getRecords();
    }

    public ApexPages.StandardSetController groupOpportunityRecords {
        get {
            if (groupOpportunityRecords == null) {
                groupOpportunityRecords = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Account_Name__c, Name, StageName, Amount, CloseDate FROM Opportunity 
                     WHERE AccountId IN (SELECT Id FROM Account WHERE (Account_Group__c = :accountPlan.Account_Group__c) AND (Id != :accountPlan.Account__c)) 
                     AND IsClosed = false]));
                groupOpportunityRecords.setPageSize(RELATED_LIST_PAGE_SIZE);
            }
            return groupOpportunityRecords;
        }
        private set;
    }

    public List<Opportunity> getGroupOpportunities() {
        return (List<Opportunity>) groupOpportunityRecords.getRecords();
    }

    public ApexPages.StandardSetController keyInitiativeRecords {
        get {
            if (keyInitiativeRecords == null) {
                keyInitiativeRecords = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Strategy_Detail__c, Status__c, Name, CreatedDate, Created_By__c FROM Key_Initiative__c
                     WHERE Account__c IN (SELECT Id FROM Account WHERE Id = :accountPlan.Account__c)
                     AND Status__c = 'Active']));
                keyInitiativeRecords.setPageSize(RELATED_LIST_PAGE_SIZE);
            }
            return keyInitiativeRecords;
        }
        private set;
    }

    public List<Key_Initiative__c> getKeyInitiatives() {
        return (List<Key_Initiative__c>) keyInitiativeRecords.getRecords();
    }

    public ApexPages.StandardSetController groupKeyInitiativeRecords {
        get {
            if (groupKeyInitiativeRecords == null) {
                groupKeyInitiativeRecords = new ApexPages.StandardSetController(Database.getQueryLocator(
                    [SELECT Strategy_Detail__c, Status__c, Name, CreatedDate, Created_By__c FROM Key_Initiative__c
                     WHERE Account__c IN (SELECT Id FROM Account WHERE (Account_Group__c = :accountPlan.Account_Group__c) AND (Id != :accountPlan.Account__c)) 
                     AND Status__c = 'Active']));
                groupKeyInitiativeRecords.setPageSize(RELATED_LIST_PAGE_SIZE);
            }
            return groupKeyInitiativeRecords;
        }
        private set;
    }

    public List<Key_Initiative__c> getGroupKeyInitiatives() {
        return (List<Key_Initiative__c>) groupKeyInitiativeRecords.getRecords();
    }

}