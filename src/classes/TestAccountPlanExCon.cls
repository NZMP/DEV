/***
* @Author:      Shailendra Singh
* @Date:        18/09/2014
* @Description: Test Class
*/


@IsTest
public class TestAccountPlanExCon{

    static Account acc;
    static Account acc2, acc3;
    static Revised_Account_Plan__c objRAP;
    static Customer_Target__c objCT;
    static Competitor_Analysis__c objCA;
    static Competitor__c objComp;
    static Engagement_Plan__c ep;
    static Audit__c aud;
    static Audit_Notes__c audNote;
    static Partner part;
    
    static String accRTNameSupplier=[Select Id from RecordType Where SobjectType='Account' AND Name='Supplier Accounts' limit 1].Id;
    static String accRTNameReseller=[Select Id from RecordType Where SobjectType='Account' AND Name='Sold To Party' limit 1].Id;
    static String accRTNameResellerCust = [Select Id from RecordType Where SobjectType='Account' AND Name='Reseller Customer' limit 1].Id;
    
    private static void init(string accRTName) {
        
   		List<Account> listAccount = new List<Account>();
        
        listAccount.add(new Account(Name='Test Account',RecordTypeId=accRTName));
        listAccount.add(new Account(Name='Test ResellerCust Account',RecordTypeId=accRTNameResellerCust));
       	listAccount.add(new Account(Name='Test ResellerCust Account 2',RecordTypeId=accRTNameResellerCust));
        insert listAccount;
        acc = listAccount[0];
        acc2 = listAccount[1];
        acc3 = listAccount[2];
        
        Opportunity oppObject = new Opportunity();
        oppObject.AccountId = acc.id;
        oppObject.Name = 'Opp Test 1';
        oppObject.StageName = 'Prospect';
        oppObject.Stage_in_Buying_Cycle__c = 'Implementation';
        oppObject.CloseDate = date.today();
        oppObject.Channel__c = 'Spot';
        oppObject.Sales_Type__c = 'Product Innovation';
        oppObject.Opportunity_Type_Overview__c = 'Increase Volume';
        oppObject.Opportunity_Sub_Type__c = 'New Demand';
        
        
        insert oppObject;
        
        objRAP=new Revised_Account_Plan__c();
        objRAP.Name='Test Acc Plan';
        objRAP.Account_Name__c=acc.Id;
        objRAP.Account_Planning_Status__c = 'Draft';
        objRAP.Submitted_for_Approval__c=true;
        insert objRAP;
        
        objCT=new Customer_Target__c();
        objCT.Account__c=acc.Id;
        insert objCT;
        
        objComp=new Competitor__c();
        objComp.Name='Test Comp';
        objComp.Type__c='Company';
        insert objComp;
        
        objCA=new Competitor_Analysis__c();
        objCA.Opportunity__c = oppObject.id;
        objCA.Account__c=acc.Id;
        objCA.Competitor__c=objComp.Id;
        insert objCA;
                
        ep = new Engagement_Plan__c(Account_Plan__c = objRAP.Id, Customer_Department__c='Executive');
        insert ep;
        
        part = new Partner(AccountFromId=acc.Id, AccountToId=acc2.Id);
        insert part;
        
        aud = new Audit__c(Reseller__c = acc.Id, Conducted_On__c=Date.today());
        insert aud;
        
        audNote = new Audit_Notes__c(Audit__c = aud.Id,Consequence__c='Fundamental',Likelihood__c='Likely');
        insert audNote;
        
        Task ta = new Task(WhatId=audNote.Id, Status='In Progress',Subject='test');
        insert ta;
    }
    
    static testMethod void TestMethodAssignmentControllerClass() {
        init(accRTNameSupplier);
                
        ApexPages.StandardController conExt = new ApexPages.StandardController(objRAP);
        AccountPlanExCon ext = new AccountPlanExCon (conExt);
        
        PageReference pageRef = Page.AccountPlan;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('retUrl', acc.Id);
        pageRef.getParameters().put('retURL', acc.Id);
        pageRef.getParameters().put('cancelURL', acc.Id);
		test.setCurrentPage(pageRef);
	        
        Test.startTest();
        ext.validate();
        ext.getPreviewSlide();
        ext.save();
        ext.getOpenKeyMetricsDashboard();
        ext.createOpp();
        ext.cancel();
        ext.getTabInFocus();
        ext.setTabInFocus('');
        ext.tabMethod();
        ext.createInitiative();
        ext.getOpenGrowthMetricsDashboard();
        ext.cloneAP();
        ext.addPageMessage('Error');
		List<Revised_Account_Plan__c> listRAP = ext.accountPlanAssessment;
		listRAP = ext.accountPlanOperational;
		List<CVM_Results__c> listCVMResults = ext.listCVMResults;
		List<Competitor__c> listCompetitor = ext.listCompetitor;
		Key_Initiative__c keyInititative = ext.keyInititative;
		Key_Initiative__c keyInitiativeCVM = ext.keyInitiativeCVM;
		Boolean bHistoricalAccountPlan = ext.bHistoricalAccountPlan;
		
        //Historical
        objRAP.Account_Planning_Status__c = 'Historical';
        update objRAP;
        bHistoricalAccountPlan = ext.bHistoricalAccountPlan;
        
        ApexPages.StandardController conHistExt = new ApexPages.StandardController(objRAP);
        AccountPlanExCon extHist = new AccountPlanExCon (conHistExt);
        
        String getTabInFocus = ext.getTabInFocus();
        Integer selectedRowEP = ext.selectedRowEP;
        String departmentStr = ext.departmentStr;
        
        boolean isReseller = ext.isResellerAP;
        List<Task> listAuditTasks = ext.listAuditTasks;
        Test.stopTest();
        
    } 
    
    static testMethod void TestMethodAssignmentControllerClass_Reseller() {
        init(accRTNameReseller);
                
        ApexPages.StandardController conExt = new ApexPages.StandardController(objRAP);
        AccountPlanExCon ext = new AccountPlanExCon (conExt);
        
        PageReference pageRef = Page.AccountPlan;
        pageRef.getParameters().put('accountId', acc.Id);
        pageRef.getParameters().put('retUrl', acc.Id);
        pageRef.getParameters().put('retURL', acc.Id);
        pageRef.getParameters().put('cancelURL', acc.Id);
        pageRef.getParameters().put('acctSelectedId', acc3.Id);
        pageRef.getParameters().put('rowIndex','0');
		test.setCurrentPage(pageRef);
		
        Test.startTest();
        ext.validate();
        ext.getPreviewSlide();
        ext.strAcctNameSearch = 'te';
        ext.runAccountSearch();
        ext.addAssociation();
        ext.removeAssociation();
        ext.undoRemoveAssociation();
        ext.save();
        ext.getOpenKeyMetricsDashboard();
        ext.createOpp();
        ext.cancel();
        ext.getTabInFocus();
        ext.setTabInFocus('');
        ext.tabMethod();
        ext.createInitiative();
        ext.getOpenGrowthMetricsDashboard();
        ext.cloneAP();
        ext.addPageMessage('Error');
        //Historical
        objRAP.Account_Planning_Status__c = 'Historical';
        update objRAP;
        Boolean bHistoricalAccountPlan = ext.bHistoricalAccountPlan;
        boolean isReseller = ext.isResellerAP;
        String audDate = ext.mapAuditWrapper.get(aud.Id).auditConductedDate;
        Integer mapSize = ext.mapAuditWrapper.get(aud.Id).intAuditNoteMapSize;
        
        ApexPages.StandardController conHistExt = new ApexPages.StandardController(objRAP);
        AccountPlanExCon extHist = new AccountPlanExCon (conHistExt);
        Test.stopTest();
        
    } 
}