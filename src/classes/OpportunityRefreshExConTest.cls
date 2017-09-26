@isTest
private class OpportunityRefreshExConTest {
    
    @isTest static void unitTest1() {
       // Id idAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier Accounts').getRecordTypeId();
    
        //Account a = new Account(Name='Test Account', RecordTypeId=idAccountRecType);
        Account a = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
       // insert a;
        
        Opportunity op = new Opportunity();
        op.AccountId = a.Id;
        op.Name = 'Test Op';
        op.StageName = 'Prospect';
        op.Opportunity_Type_Overview__c = 'Increase Volume';
        op.Opportunity_Sub_Type__c  = 'SKU Innovation';
        op.Stage_in_Buying_Cycle__c = 'Implementation';
        op.CloseDate = date.today();
        insert op;
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        OpportunityRefreshExCon obj = new OpportunityRefreshExCon(sc);

        system.debug('op: '  + op);

        Test.setCurrentPageReference(new PageReference('Page.OpportunityRefresh'));
        System.currentPageReference().getParameters().put('Id', op.Id);

        // nm - 25/11/2016
        obj.strAccountId = a.Id;
        obj.getStages();
        obj.conditionalRequiredString= 'test';
        obj.checkConditionalRequired = false;

        obj.getTabInFocus();
        obj.tabMethod();
        OpportunityRefreshExCon.isSF1();
        obj.redirect();
        obj.cancel();
        obj.saveCustom();
        //obj.submitForApproval();
        obj.editPage();
        obj.addPageMessage(ApexPages.severity.ERROR,'Error');
        obj.addPageMessage('error');
        obj.strOppId15 = 'Test';
        obj.setTabInFocus(null);

        op.Opportunity_Sub_Type__c  = null;
        op.CloseDate  = null;
        obj.saveCustom();

        obj.opp = new Opportunity();
        obj.saveCustom();
    }

    @isTest static void unitTest2() {
       // Id idAccountRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Supplier Accounts').getRecordTypeId();
     Account a = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
        //Account a = new Account(Name='Test Account', RecordTypeId=idAccountRecType);
        //insert a;
        
        Opportunity op = new Opportunity();
        op.AccountId = a.Id;       
        op.Name = 'Test Op';
        op.StageName = 'Prospect';
        op.Opportunity_Type_Overview__c = 'Increase Volume';
        op.Opportunity_Sub_Type__c  = 'SKU Innovation';
        op.Stage_in_Buying_Cycle__c = 'Implementation';
        op.CloseDate = date.today();
        insert op;
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        OpportunityRefreshExCon obj = new OpportunityRefreshExCon(sc);

        obj.opp = new Opportunity();
        obj.opp.Name = 'Test Op';
        obj.opp.StageName = 'Prospect';
        obj.opp.Opportunity_Type_Overview__c = 'Increase Volume';
        obj.opp.Opportunity_Sub_Type__c  = 'SKU Innovation';
        obj.opp.Stage_in_Buying_Cycle__c = 'Implementation';
        obj.opp.CloseDate = date.today();
        obj.saveCustom();
        
        
    }
    
    @isTest static void unitTest3() {  
    
         Account a = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
       
          Revised_Account_Plan__c actPlan = new Revised_Account_Plan__c (Name='Test Account Plan');
        actPlan.Account_Name__c= a.id;
        insert actPlan;
        
        Opportunity op = new Opportunity();
        op.AccountId = a.Id;
      
        op.Name = 'Test Op';
        op.StageName = 'Prospect';
        op.Opportunity_Type_Overview__c = 'Increase Volume';
        op.Opportunity_Sub_Type__c  = 'SKU Innovation';
        op.Stage_in_Buying_Cycle__c = 'Implementation';
        op.CloseDate = date.today();
        insert op;
        ApexPages.StandardController sc = new ApexPages.StandardController(op);
        
          system.debug('op: '  + op);

        Test.setCurrentPageReference(new PageReference('Page.OpportunityRefresh'));
        System.currentPageReference().getParameters().put('Id', op.Id);
        OpportunityRefreshExCon obj = new OpportunityRefreshExCon(sc);
     
        }
}