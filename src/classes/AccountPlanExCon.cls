public without sharing class AccountPlanExCon {
    /* Page Variables */
    public Account account {get;set;}  // Account
    public List<Revised_Account_Plan__c> listAccountPlan {get;set;}  // Account Plan 
    public List<Account> listAccount {get;set;}    
    public List<Customer_Target__c> listCustomerTargets {get;set;}   
    public Revised_Account_Plan__c accountPlan {get;set;}    
    public List<Revised_Account_Plan__c> accountPlanAssessment {get;set;}    
    public List<Revised_Account_Plan__c> accountPlanOperational {get;set;}    
    public List<CVM_Results__c> listCVMResults {get;set;}    
    public List<Opportunity> listOpportunities {get;set;}    
    public List<Engagement_Plan__c> listEngagementPlans {get;set;}    
    public List<Competitor__c> listCompetitor {get;set;}    
    public Key_Initiative__c keyInititative {get;set;}      
    public Key_Initiative__c keyInitiativeCVM {get;set;}   
    public List<Key_Initiative__c> listKeyInititatives {get;set;}    
    public List<Key_Initiative__c> listCVMActionPlan {get;set;}    
    public List<Competitor_Analysis__c> listCompetitorA {get;set;}    
    public List<Competitor_Analysis__c> listCompetitorAnaOpp {get;set;}    
    public List<Competitor_Analysis__c> listDisplayCompetitorA {get;set;}   
    public List<Competitor_Analysis_Snapshot__c> listDisplayCompetitorASnapshot {get;set;}   
    public List<AccountPlanExConHelper.EngagementPlanWrapper> engagementPlanWrapper {get;set;}   
    public Revised_Account_Plan__c accountPlanStart;
    public Date fiscalYearStart;   
    public Date fiscalYearEnd;
    public Integer startMonth {get;set;} 
    public List<AccountPlanExConHelper.OperationalMetricsWrapper> operationalMetricsWrapperList {get;set;}
    public List<AccountPlanExConHelper.AssessmentWrapper> assessmentWrapperList {get;set;}
    public Boolean bIsAdmin {get{return (bIsAdmin != null)? bIsAdmin:false;}set;}
    public Boolean loadConga {get;set;}
    public Boolean bHistoricalAccountPlan {get{
        if(accountPlan.Id != null && accountPlan.Account_Planning_Status__c == 'Historical'){
            return true;  
            
        }else if(accountPlan.Submitted_for_Approval__c == true)
            return true;    
        else 
            return false; 
        }set;}
    String tabInFocus = System.currentPageReference().getParameters().get('tab'); 
    public String getTabInFocus() {
        if(tabInFocus == null) {
            tabInFocus = '1';           
        }
        
        return tabInFocus;
    }
    public void setTabInFocus(String s) {
        this.tabInFocus = s;        
    }   
    public void tabMethod() {  
        
    }
    public Integer selectedRowEP {get;set;}
    public String departmentStr {get;set;}
    public AccountPlanExConHelper.EngagementPlanWrapper ePWrapper = new AccountPlanExConHelper.EngagementPlanWrapper();
    public ApexPages.StandardController controller;
    
    
    // Reseller logic Mar2016
    string resellerRTId =  Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sold To Party').getRecordTypeId();
    string resellerCustomerRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Reseller Customer').getRecordTypeId();
    string resellerAPRTId = Schema.SObjectType.Revised_Account_Plan__c.getRecordTypeInfosByName().get('Reseller Account Plan').getRecordTypeId();
    
    string ingredOpptyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Fonterra Ingredients').getRecordTypeId();
    string resellerOpptyRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Reseller').getRecordTypeId();
    
    List<string> listAgreementStatusToExclude = new List<String>{'Expired','Cancelled', 'Rejected'};
    List<string> listAuditNoteRiskRatingsToExclude = new List<String>{'N/A'};
    static string PARTNER_ROLE_RESELLER_CUSTOMER = 'Reseller Customer';
    
    public List<Agreement__c> listAgreements {get; set;}
    public List<PartnerWrapper> listPartnerWrappers {get; set;}
    public List<Task> listAuditTasks {get; set;}
    public Map<Id, AuditWrapper> mapAuditWrapper {get; set;} // map<auditId, wrapper item>
    
    public boolean isResellerAP{
    	get {
    		if(accountPlan != null && accountPlan.RecordTypeId != null) {
    			return (accountPlan.RecordTypeId == resellerAPRTId);
    		}
    		else return false;
    	}
    	 
    	private set;
    }
    public Map<Id,Account> mapAcctsSearched { get; set;} // Accounts searched for
    public string strAcctNameSearch {get; set;}
    
    public list<Opportunity> listResellerOpportunities {get; set;}
    // end Reseller logic Mar2016
    
    
    // ============ Constructor ==================
    public AccountPlanExCon (ApexPages.StandardController std) { 
        loadConga = false;
        listDisplayCompetitorASnapshot = new List<Competitor_Analysis_Snapshot__c>();
        // Check if System Administrator
        if (UserInfo.getProfileId() == [select Id from Profile where Name = 'System Administrator' limit 1].Id) 
            bIsAdmin = true;
        else
            bIsAdmin = false;   
        // diplay "Saved" message when successful save 
        if(ApexPages.currentPage().getParameters().get('success') != null && 
            (String)ApexPages.currentPage().getParameters().get('success') == '1') {
            addPageMessage('Saved');    
        } 
        // default tab focus                        
        if(tabInFocus == null) {
            tabInFocus = '1';
        }
        // Instantiate Account Plan      
        controller = std;             
        accountPlan = (Revised_Account_Plan__c) std.getRecord(); 
        if(accountPlan == null) {
            accountPlan = new Revised_Account_Plan__c(Name = '');
        }
        listAccountPlan = new List<Revised_Account_Plan__c>([select Financial_Metrics_Insights__c, Customer_Background__c, Vision__c, Strategies_Goals__c, 
                                                                Major_Risks_Threats_Challenges__c, Fonterra_Share_of_Business__c, Market_Insight__c, 
                                                                Account_Name__c, Name, Start_Date__c, End_Date__c, Account_Planning_Status__c, Fiscal_Year__c, Commentary__c, 
                                                                DIFOT_Flag__c, DSO__c, DSO_Flag__c, Complaints__c, Complaints_Flag__c, Perfect_Order_Consumption__c, 
                                                                C2S_Consumption__c,C2S_Consumption_Flag__c, DIFOT__c,  DIFOT_Insights__c, DSO_Insights__c, Complaints_Insights__c,
                                                                Perfect_Order_Consumption_Insights__c, Perfect_Order_Consumption_Flag__c, C2S_Consumption_Insights__c, 
                                                                SWOTCustomer_Strengths__c, SWOT_Customer_Opportunities__c, SWOTCust_Thingsto_develop_capitiliseon__c, 
                                                                Growth_Metrics_Insights__c, SWOT_Customer_Weaknesses__c, SWOT_Customer_Threats__c, SWOTCust_Things_to_monitor_mitigate__c, 
                                                                SWOTFonterra_Strengths__c, CVM_Insights__c, SWOT_Fonterra_Opportunities__c, SWOTFont_Things_to_develop_capitilise_on__c, 
                                                                SWOT_Fonterra_Weaknesses__c, SWOT_Fonterra_Threats__c, SWOTFont_Things_to_monitor_mitigate__c, 
                                                                Customer_Postioning_Statement__c, Total_PA_Goal_0_1_yr__c, Total_PA_Goal_1_2_yrs__c, 
                                                                Total_PA_Goal_3_5_yrs__c, Strategic_Goal_0_1_yr__c, Strategic_Goal_1_2_yrs__c, Strategic_Goal_3_5_yrs__c, 
                                                                Theme_0_1_yr__c, Theme_1_2_yrs__c, Theme_3_5_yrs__c, Customer_Overview__c, Customer_Overview_Rating__c, 
                                                                Customer_Overview_Weight__c, Financial_Metrics__c,Financial_Metrics_Rating__c, Financial_Metrics_Weight__c, 
                                                                Operational_Metrics__c, Operational_Metrics_Rating__c, Operational_Metrics_Weight__c, Growth_Metrics__c,
                                                                Growth_Metrics_Rating__c, Growth_Metrics_Weight__c, Competitors_Insights__c, CVM_Metrics__c, CVM_Metrics_Rating__c, 
                                                                CVM_Metrics_Weight__c, SWOT__c, SWOT_Rating__c, SWOT_Weight__c, Needs_vs_Capability__c, Needs_vs_Capability_Rating__c, 
                                                                Needs_vs_Capability_Weight__c, Engagement_Plan__c, Engagement_Plan_Rating__c, Engagement_Plan_Weight__c, 
                                                                Competitors__c, Competitors_Rating__c, Competitors_Weight__c, X5yr_Strategy__c, X5_yr_Strategy_Rating__c, 
                                                                X5_yr_Strategy_Weight__c, Progress_against_plan__c, Progress_against_plan_rating__c, Progress_against_plan_weight__c,
                                                                Account_Plan_Score_label__c, Customer_Overview_Score__c, Customer_Overview_Rational_Explanation__c, 
                                                                Financial_Metrics_Score__c, Financial_Metrics_Rationale_Explanation__c, Operational_Metrics_Score__c, 
                                                                Operation_Metrics_Rationale_Explanation__c, Growth_Metrics_Score__c, Growth_Metrics_Rationale_Explanation__c, 
                                                                CVM_Metrics_Score__c, CVM_Metrics_Rationale_Explanation__c, SWOT_Score__c, SWOT_Rationale_Explanation__c, 
                                                                Needs_vs_Capability_Score__c, Needs_vs_CapabilityRationale_Explanatio__c, Engagement_Plan_Score__c, 
                                                                Engagement_Plan_Rationale_Explanation__c, Competitors_Score__c, Competitors_Rationale_Explanation__c, 
                                                                X5_yr_Strategy_Score__c, X5yr_Strategy_Rationale_Explanation__c, Progress_against_plan_Score__c, 
                                                                Progress_against_plan_Rationale__c, Account_Plan_Score__c, Account_Plan_Score_Assessment__c, 
                                                                Detailed_Needs_1__c, Detailed_Needs_2__c, Detailed_Needs_3__c, Detailed_Needs_4__c, 
                                                                Detailed_Needs_5__c,Potential_Opportunity_1__c, Potential_Opportunity_2__c,
                                                                Potential_Opportunity_3__c, Potential_Opportunity_4__c, Potential_Opportunity_5__c, 
                                                                Fonterra_s_Strength_1__c, Fonterra_s_Strength_2__c,Fonterra_s_Strength_3__c,
                                                                Fonterra_s_Strength_4__c, Fonterra_s_Strength_5__c,
                                                                Customer_Need_1__c, Customer_Need_2__c,Customer_Need_3__c, Customer_Need_4__c, Customer_Need_5__c,
                                                                Submitted_for_Approval__c, Account_Name__r.Name, Volume_Invoiced_Tracking_YTD_vs_LY__c, Price_Achievement_YTD__c, 
                                                                Volume_Invoiced_YTD__c, Volume_Invoiced_LY__c, Price_Achievement_LY__c, PA_Tracking_YTD_vs_Target__c,
                                                                Volume_Contracted_YTD__c, Revenue_YTD__c, Volume_Contracted_LY__c, Revenue_LY__c, Vol_Contracted_Tracking_YTD_vs_LY__c,
                                                                Revenue_Tracking__c, Key_Metrics_Last_Update__c,YTD_Key_Metrics_as_at__c,
                                                                Business_Development__c, Key_Annual_Objectives__c, Learnings_from_last_year__c, Resource_Requirements__c,  // Reseller logic Mar2016
                                                                Reseller_Growth__c, Reseller_Growth_Rating__c, Reseller_Growth_Weight__c, Reseller_Growth_Score__c, Reseller_Growth_Rationale_Explanation__c, // Reseller logic Mar2016
                                                                Action_Plan__c, Action_Plan_Rating__c, Action_Plan_Rationale_Explanation__c, Action_Plan_Score__c, Action_Plan_Weight__c, // Reseller logic Mar2016
                                                                Associated_Customers__c, Associated_Customers_Rating__c, Associated_Cust_Rationale_Explanation__c, Associated_Customers_Score__c, Associated_Customers_Weight__c, // Reseller logic Mar2016
                                                                Account_Name__r.RecordTypeId, RecordTypeId // Reseller logic Mar2016
                                                                from Revised_Account_Plan__c where Id = :accountPlan.Id]);         
        if(listAccountPlan != null && listAccountPlan.size()>0) {
            accountPlan = listAccountPlan[0];     
        }     
        
        if(ApexPages.currentPage().getParameters().get('accountId') != null) {
            account = new Account(Id = ApexPages.currentPage().getParameters().get('accountId'));       
        }
        else if(accountPlan.Id != null) {
            account = new Account(Id = accountPlan.Account_Name__c);  
        }     
          
        if(accountPlan.Total_PA_Goal_0_1_yr__c == null) accountPlan.Total_PA_Goal_0_1_yr__c = 0.0;
        if(accountPlan.Total_PA_Goal_1_2_yrs__c == null) accountPlan.Total_PA_Goal_1_2_yrs__c = 0.0;
        if(accountPlan.Total_PA_Goal_3_5_yrs__c == null) accountPlan.Total_PA_Goal_3_5_yrs__c = 0.0;
        if(accountPlan.Strategic_Goal_0_1_yr__c == null) accountPlan.Strategic_Goal_0_1_yr__c = ' ';        
        if(accountPlan.Strategic_Goal_1_2_yrs__c == null) accountPlan.Strategic_Goal_1_2_yrs__c = ' ';
        if(accountPlan.Strategic_Goal_3_5_yrs__c == null) accountPlan.Strategic_Goal_3_5_yrs__c = ' ';
        if(accountPlan.Theme_0_1_yr__c == null) accountPlan.Theme_0_1_yr__c = ' ';
        if(accountPlan.Theme_1_2_yrs__c == null) accountPlan.Theme_1_2_yrs__c = ' ';
        if(accountPlan.Theme_3_5_yrs__c == null) accountPlan.Theme_3_5_yrs__c = ' ';
        if(accountPlan.Detailed_Needs_1__c == null) accountPlan.Detailed_Needs_1__c = ' ';
        if(accountPlan.Detailed_Needs_2__c == null) accountPlan.Detailed_Needs_2__c = ' ';
        if(accountPlan.Detailed_Needs_3__c == null) accountPlan.Detailed_Needs_3__c = ' ';
        if(accountPlan.Detailed_Needs_4__c == null) accountPlan.Detailed_Needs_4__c = ' ';
        if(accountPlan.Detailed_Needs_5__c == null) accountPlan.Detailed_Needs_5__c = ' ';
        if(accountPlan.Potential_Opportunity_1__c == null) accountPlan.Potential_Opportunity_1__c = ' ';
        if(accountPlan.Potential_Opportunity_2__c == null) accountPlan.Potential_Opportunity_2__c = ' ';
        if(accountPlan.Potential_Opportunity_3__c == null) accountPlan.Potential_Opportunity_3__c = ' ';
        if(accountPlan.Potential_Opportunity_4__c == null) accountPlan.Potential_Opportunity_4__c = ' ';
        if(accountPlan.Potential_Opportunity_5__c == null) accountPlan.Potential_Opportunity_5__c = ' ';
        if(accountPlan.Fonterra_s_Strength_1__c == null) accountPlan.Fonterra_s_Strength_1__c = ' ';
        if(accountPlan.Fonterra_s_Strength_2__c == null) accountPlan.Fonterra_s_Strength_2__c = ' ';
        if(accountPlan.Fonterra_s_Strength_3__c == null) accountPlan.Fonterra_s_Strength_3__c = ' ';
        if(accountPlan.Fonterra_s_Strength_4__c == null) accountPlan.Fonterra_s_Strength_4__c = ' ';
        if(accountPlan.Fonterra_s_Strength_5__c == null) accountPlan.Fonterra_s_Strength_5__c = ' ';
        if(accountPlan.Account_Planning_Status__c == null) accountPlan.Account_Planning_Status__c = 'Draft';
        // Fiscal Year
        //startMonth = [select FiscalYearStartMonth from Organization where id = :Userinfo.getOrganizationId() limit 1].FiscalYearStartMonth;
        startMonth = 8;
        Integer startYear = System.today().year();
        fiscalYearStart = Date.newinstance(startYear, startMonth, 1);
        //todo : hardcoded day
        fiscalYearEnd = Date.newinstance(startYear+1, startMonth-1, 31);
                        
        if(accountPlan.Start_Date__c == null) {
            if(fiscalYearStart <= System.today()) {
                accountPlan.Start_Date__c = fiscalYearStart;
            } else {
                accountPlan.Start_Date__c = Date.newinstance(startYear-1, startMonth, 1);
            }                       
        }
        if(accountPlan.End_Date__c == null) {
            // Incorrect logic: if(fiscalYearEnd >= System.today()) {
             if(fiscalYearStart <= System.today()) {
                accountPlan.End_Date__c = fiscalYearEnd; 
            } else {
                //todo : hardcoded day
                accountPlan.End_Date__c = Date.newinstance(startYear, startMonth-1, 31);
               // fiscalYearEnd = Date.newinstance(startYear, startMonth-1, 31);
            }
        } 
        // Account Information
        if(account == null) {
            account = new Account(Id = accountPlan.Account_Name__c);
        }
        listAccount = new List<Account>([select Name, Market_Insight__c , Customer_Background__c, Vision__c, Strategies_Goals__c, 
                                                Major_Risks_Threats_Challenges__c, Fonterra_Share_of_Total_Dairy_Purchases__c, Invoiced_Volume_YTD__c, 
                                                Invoiced_Volume_LY__c, Volume_Invoiced_Tracking__c, Volume_Contracted_Target_FY__c, 
                                                Contracted_Volume_YTD__c, Contracted_Volume_LY__c, Contracted_Volume_Tracking__c, 
                                                Price_Achievement_Target_FY__c,Price_Achievement_YTD__c, Price_Achievement_LFY__c, Price_Achievement_Tracking__c, 
                                                Revenue_YTD__c, Revenue_LY__c, Revenue_Tracking__c, Customer_Needs_1__c, Customer_Needs_2__c, Customer_Needs_3__c, 
                                                Customer_Needs_4__c, Customer_Needs_5__c,Key_Metrics_Last_Update__c, YTD_Key_Metrics_as_at__c, Account_Group__c,
                                                RecordTypeId,RecordType.Name, RecordType.DeveloperName, Markets__c,// Reseller logic Mar2016
                                                (select Name, LastModifiedDate, Account__c, Status__c, CreatedDate, CVM_Action__c, Target_Date__c, RecordType.DeveloperName, 
                                                    Status2__c from Strategic_Initiatives__r 
                                                    where (RecordType.DeveloperName = 'CVM_Action_Plan' or RecordType.DeveloperName = 'Initiative')) 
                                                    //or (RecordType.DeveloperName = 'Initiative') 
                                                    //or (RecordType.DeveloperName = 'CVM_Action_Plan'))
                                                from Account where Id = :account.Id]);       
        
        // Key initiatives
        List<Key_Initiative__c> listTempKeyInititatives = new List<Key_Initiative__c>();                                            
        if(listAccount != null && listAccount.size()>0) {
            account = listAccount[0]; // Reseller logic Mar2016
            for(Account a:listAccount) {
                account = a;
                system.debug('###: a ' + a);
                if(a.Strategic_Initiatives__r !=null && a.Strategic_Initiatives__r.size()>0) {
                    listTempKeyInititatives = a.Strategic_Initiatives__r;
                }
            }   
        }   
        // Account Information (more) 
        if(accountPlan.Account_Name__c == null) {
            accountPlan.Account_Name__c = account.Id;
        }
        if(accountPlan.Account_Planning_Status__c != 'Historical') {                       
            accountPlan.Fonterra_Share_of_Business__c = account.Fonterra_Share_of_Total_Dairy_Purchases__c;
            accountPlan.Customer_Background__c = account.Customer_Background__c;
            accountPlan.Strategies_Goals__c = account.Strategies_Goals__c;
            accountPlan.Major_Risks_Threats_Challenges__c = account.Major_Risks_Threats_Challenges__c;
            accountPlan.Vision__c = account.Vision__c;
            accountPlan.Market_Insight__c = account.Market_Insight__c;          
            accountPlan.Customer_Need_1__c = account.Customer_Needs_1__c;
            accountPlan.Customer_Need_2__c = account.Customer_Needs_2__c;           
            accountPlan.Customer_Need_3__c = account.Customer_Needs_3__c;           
            accountPlan.Customer_Need_4__c = account.Customer_Needs_4__c;
            accountPlan.Customer_Need_5__c = account.Customer_Needs_5__c;
            //2/10/2014
            accountPlan.Volume_Invoiced_YTD__c = account.Invoiced_Volume_YTD__c;
            accountPlan.Volume_Invoiced_LY__c = account.Invoiced_Volume_LY__c;
            accountPlan.Volume_Invoiced_Tracking_YTD_vs_LY__c = account.Volume_Invoiced_Tracking__c;
            accountPlan.Volume_Contracted_YTD__c = account.Contracted_Volume_YTD__c;
            accountPlan.Volume_Contracted_LY__c = account.Contracted_Volume_LY__c;
            accountPlan.Vol_Contracted_Tracking_YTD_vs_LY__c = account.Contracted_Volume_tracking__c;
            accountPlan.Price_Achievement_YTD__c = account.Price_Achievement_YTD__c;
            accountPlan.Price_Achievement_LY__c = account.Price_Achievement_LFY__c;
            accountPlan.PA_Tracking_YTD_vs_Target__c = account.Price_Achievement_Tracking__c;
            accountPlan.Revenue_YTD__c = account.Revenue_YTD__c;
            accountPlan.Revenue_LY__c = account.Revenue_LY__c;
            accountPlan.Revenue_Tracking__c = account.Revenue_Tracking__c;
           // accountPlan.Key_Metrics_Last_Update__c = account.Key_Metrics_Last_Update__c;                           
            accountPlan.YTD_Key_Metrics_as_at__c= account.YTD_Key_Metrics_as_at__c;                           
        } 
        if(accountPlan.Name == null)  {
            accountPlan.Name = account.name + ' - Plan FY ' + accountPlan.End_Date__c.year();
        }                       
        system.debug('###: accountPlan ' + accountPlan);                                               
        // Key initiatives (more)                                               
        listCVMActionPlan = new List<Key_Initiative__c>();  
        listKeyInititatives = new List<Key_Initiative__c>();
        for(Key_Initiative__c ki:listTempKeyInititatives) {
            if(ki.RecordType.DeveloperName == 'Initiative') {
                //filter the list
                if((ki.target_date__c >= accountplan.Start_Date__c && ki.target_date__c <= accountPlan.End_Date__c) || (ki.CreatedDate >= accountplan.Start_Date__c && ki.CreatedDate <= accountPlan.End_Date__c)) 
                listKeyInititatives.add(ki);
                system.debug('###: ki - Key ' + ki);
            } 
            else if(ki.RecordType.DeveloperName == 'CVM_Action_Plan') {
                if((ki.target_date__c >= accountplan.Start_Date__c && ki.target_date__c <= accountPlan.End_Date__c) || (ki.CreatedDate >= accountplan.Start_Date__c && ki.CreatedDate <= accountPlan.End_Date__c)) 
                listCVMActionPlan.add(ki);
                system.debug('###: ki - CVM ' + ki);
            }       
        }  
        // Competitor / Customer Targets                       
        listCompetitorA = new List<Competitor_Analysis__c>();
        listDisplayCompetitorA = new List<Competitor_Analysis__c>();
        listCompetitorAnaOpp = new List<Competitor_Analysis__c>();
        listCustomerTargets = new List<Customer_Target__c>();                       
        List<Customer_Target__c> listTempCustomerTargets = new List<Customer_Target__c>([select Name, Year__c, Status__c, Target_Visits_Total__c, Actuals_Total__c, 
                                                                Q1_on_target__c, Q2_on_target__c, Q3_on_target__c, Q4_on_target__c, FY_Start_Date__c 
                                                                from Customer_Target__c 
                                                                where Account__c = :account.Id]);      
        if(listTempCustomerTargets != null && listTempCustomerTargets.size() > 0) {
            //filter the list
            for(Customer_Target__c ct : listTempCustomerTargets){
                if(ct.FY_Start_Date__c >= accountplan.Start_Date__c && ct.FY_Start_Date__c <= accountPlan.End_Date__c) 
                listCustomerTargets.add(ct);
            }
        }  
        // Top 3 Competitors
        List<Competitor_Analysis__c> listCompetitorAna = [select Id, Name, Account__c, Competitor__c, 
                                                            RecordType.DeveloperName, Ranking_New__c, Opportunity__c, 
                                                            Share_Percent__c, Commodity_Class__c  
                                                            from Competitor_Analysis__c  
                                                            where (Account__c = :account.Id and RecordType.DeveloperName = 'Account_Competitor')
                                                            order by Ranking_New__c
                                                            limit 3];                                                       
        listOpportunities = [select Total_PA_Volume__c, CloseDate, Total_Estimated_PA__c,
                                Total_Quantity__c,
                                (select Name, Competitor__r.Name, Commodity_Class__c from Competitor_Analysis__r 
                                    where RecordType.DeveloperName ='Opportunity_Competitor' 
                                    and Competitor__r.Name != null)  
                                from Opportunity 
                                where AccountId = :account.Id 
                                order by Total_Estimated_PA__c limit 10];
        // Competitor analysis                                                                                   
        Map<Opportunity, List<Competitor_Analysis__c>> mapOppComp = new Map<Opportunity, List<Competitor_Analysis__c>>();       
        for(Opportunity opp:listOpportunities) {
            List<Competitor_Analysis__c> listComp = new List<Competitor_Analysis__c>();                    
            if(opp.Competitor_Analysis__r != null && opp.Competitor_Analysis__r.size()>0) {
                listComp = opp.Competitor_Analysis__r;  
                mapOppComp.put(opp, listComp);  
            }              
        }
        List<Opportunity> listOpportunities = new List<Opportunity>();  
        Competitor_Analysis__c tempCA = new Competitor_Analysis__c(); 
        Set<Id> setCompetitorIds = new Set<Id>();                           
        CompetitorWrapper compWrapper = new CompetitorWrapper(account, listCompetitorAna, mapOppComp);
        if(accountPlan.Account_Planning_Status__c != 'Historical') {            
            listDisplayCompetitorA = compWrapper.listCompetitors;
        } else {
            if(accountPlan.Id != null) {
                List<Competitor_Analysis_Snapshot__c> compAnalysisSnapshotList = [Select Id, Name, Competitor__c, 
                                                            Ranking__c, Share_Percent__c, Commodity_Class__c  
                                                            from Competitor_Analysis_Snapshot__c where Account_Plan__c=:accountPlan.Id];
                if(compAnalysisSnapshotList.size() > 0) 
                      listDisplayCompetitorASnapshot =  compAnalysisSnapshotList;                                                         
            }                                                
        }
        listCompetitorAnaOpp = compWrapper.listCompetitorsOpp;
        operationalMetricsWrapperList = new List<AccountPlanExConHelper.OperationalMetricsWrapper>();
        operationalMetricsWrapperList = AccountPlanExConHelper.opMetricsWrapperList(this.accountPlan);
        assessmentWrapperList = new List<AccountPlanExConHelper.AssessmentWrapper>();
        assessmentWrapperList = AccountPlanExConHelper.assessmentWrapperList(this.accountPlan, this.accountPlan.RecordTypeId);
        // Engagement Plans
        List<Engagement_Plan__c> engagementPlans = new List<Engagement_Plan__c>([select Id, Account_Plan__c, Customer_Department__c, Objective__c, Responsibility__c, Approach__c, Display_Order__c 
                                                                                from Engagement_Plan__c 
                                                                                where Account_Plan__c = :accountPlan.Id 
                                                                                order by Display_Order__c asc]);
        engagementPlanWrapper = new List<AccountPlanExConHelper.EngagementPlanWrapper>();       
        if(engagementPlans.size()>0) {
            engagementPlanWrapper = ePWrapper.populateEngagementPlanWrapper(accountPlan, engagementPlans);
        }
        else {
            engagementPlanWrapper = ePWrapper.defaultEngagementPlanWrapper(accountPlan);
        }
        
        // Reseller logic Mar2016 - get Agreements
        Date twoFiscalYearsStart = accountPlan.Start_Date__c.addYears(-2); 
        mapAuditWrapper = new Map<Id, AuditWrapper>();
        listAgreements = [SELECT Id, Name, Agreement_Name__c, Status__c, Start_Date__c, End_Date__c 
        					FROM Agreement__c
        					WHERE Account__c = :account.Id
        					AND Status__c NOT IN :listAgreementStatusToExclude 
        					AND End_Date__c >= :twoFiscalYearsStart
        					ORDER BY End_Date__c];
        
        // Find Audits associated with the account
        for(Audit__c aud : [SELECT Id, Conducted_On__c, Location__c, Next_Assessment_Due__c, General_Questions_Score__c, 
        						Stock_Management_System_Score__c, Total_Audit_Score__c, 
        						Warehouse_Facilities_Score__c, Warehouse_Office_Assessed__c 
        					FROM Audit__c 
        					WHERE Reseller__c = :account.Id
        					AND Conducted_On__c >= :twoFiscalYearsStart
        					ORDER BY Conducted_On__c]){
        	mapAuditWrapper.put(aud.Id, new AuditWrapper(aud));
        }
        // Find partners associated to the account
        listPartnerWrappers = new List<PartnerWrapper>();
        
        for(Partner part : [SELECT Id, AccountToId, AccountTo.Name, AccountFrom.Name, AccountTo.AccountNumber, 
								AccountTo.Industry, AccountTo.Markets__c, AccountTo.Estimated_Annual_Volume__c
        				FROM Partner 
        				WHERE AccountFromId = :account.id
        				ORDER BY AccountTo.Name]){
        	
        	PartnerWrapper partnerWrap = new PartnerWrapper(part, new Account(Id=part.AccountToId, Name=part.AccountTo.Name, 
        													Industry = part.AccountTo.Industry, Markets__c = part.AccountTo.Markets__c, 
        													Estimated_Annual_Volume__c = part.AccountTo.Estimated_Annual_Volume__c));
        	partnerWrap.rowIndex = listPartnerWrappers.size();
        	listPartnerWrappers.add(partnerWrap);
        }
        
        // Default the account being searched
        mapAcctsSearched = new map<Id, Account>();
        strAcctNameSearch = '';
        
        // Find Audit Notes associated with the Audits
		map<Id, List<Task>> mapAudNoteTasks = new map<Id, List<Task>>(); //Class wide map of all audit notes map<auditNoteId, List<Task>>
		List<Audit_Notes__c> listAuditNotes = [SELECT Id, Audit__c, Name, Audit_Question__c, Description__c, Notes__c, Risk_Rating__c, Title__c
										FROM Audit_Notes__c
										WHERE Audit__c IN :mapAuditWrapper.keyset()
										AND Risk_Rating__c NOT IN : listAuditNoteRiskRatingsToExclude
										ORDER BY Risk_Rating__c ASC, Audit_Question__c];
		system.debug('### listAuditNotes: ' + listAuditNotes );										
		for(Audit_Notes__c audNote :  listAuditNotes){
			AuditWrapper wrapper = mapAuditWrapper.containsKey(audNote.Audit__c) ? mapAuditWrapper.get(audNote.Audit__c) : new AuditWrapper(new Audit__c(Id=audNote.Audit__c));
			wrapper.mapAuditNoteWrapper.put(audNote.Id, new AuditNoteWrapper(audNote));
			mapAudNoteTasks.put(audNote.Id, new List<Task>());						
		}
		
		// Find tasks associated to Audit Notes
		for(Task audNoteTask : [SELECT Id, ActivityDate, OwnerId, Priority, ReminderDateTime, Subject, status, Task_Type__c, Type, WhatId
			        					FROM Task
			        					WHERE WhatId IN :mapAudNoteTasks.keyset()
			        					AND Status <> 'Completed' ]){
  			 List<Task> listAudNoteTasks = mapAudNoteTasks.containskey(audNoteTask.WhatId) ? mapAudNoteTasks.get(audNoteTask.WhatId) : new List<Task>();
  			 listAudNoteTasks.add(audNoteTask);
  			 mapAudNoteTasks.put(audNoteTask.WhatId, listAudNoteTasks); 
		}
		
		// Associate the tasks in the above query back to the Audit Notes in the class wide mapAuditWrapper
		for(AuditWrapper audWrapper : mapAuditWrapper.Values()){
			for(Id audNoteId : audWrapper.mapAuditNoteWrapper.keyset()){
				if(mapAudNoteTasks.containsKey(audNoteId)){
					AuditNoteWrapper noteWrapper = audWrapper.mapAuditNoteWrapper.get(audNoteid); 
					noteWrapper.listAuditTasks.addAll(mapAudNoteTasks.get(audNoteId));
					audWrapper.mapAuditNoteWrapper.put(audNoteId, noteWrapper);					
				}
			}
		}
		
		system.debug('### accountPlan.Start_Date__c: ' + accountPlan.Start_Date__c + ' __ accountPlan.End_Date__c: ' + accountPlan.End_Date__c);
		
		listResellerOpportunities = [SELECT Id, Name, Customer_Name__c, CloseDate, Description, StageName, Issues_to_Resolve__c, Support_Required__c, recordType.Name,
										 (Select Id, OpportunityId, ProductCode, Name, Quantity, UnitPrice From OpportunityLineItems)
		                                from Opportunity 
		                                where AccountId = :account.Id
		                                and CloseDate >= :accountPlan.Start_Date__c
		                                and CloseDate <= :accountPlan.End_Date__c
		                                and (recordTypeid = :ingredOpptyRTId
		                                or recordTypeid = :resellerOpptyRTId)
		                                order by recordType.Name]; 
		
        // end Reseller logic Mar2016

        listAccountPlan = new List<Revised_Account_Plan__c>();
        listAccountPlan.add(accountPlan);
    }
    
    // ============ End of Constructor ==================
    
    public String getPreviewSlide() {
        if(accountPlan != null) {
            return '/apex/RevisedAccountPlanPDF?id=' + accountPlan.Id;
        } 
        else {
            return null;
        }
    }
    // VALIDATION
    public Boolean validate() {
        Boolean bReturnValue = true;
        if(accountPlan.Name == null) {
            addPageMessage(ApexPages.severity.ERROR, 'Please provide Account Plan Name');
            bReturnValue = false;
            tabInFocus = '1';
        }
        
        if(accountPlan.End_Date__c <= accountPlan.Start_Date__c) {
            addPageMessage(ApexPages.severity.ERROR, 'Start Date cannot be later than End Date');
            bReturnValue = false;
            tabInFocus = '1';
        }
        
        return bReturnValue;
    }
    // SAVE method
    public PageReference save() { 
        system.debug('## engagementPlanWrapper =>' + engagementPlanWrapper);              
        PageReference pref = null;
        if(validate() == false) return pref;
        try {
            if(accountPlan.Account_Planning_Status__c != 'Historical') {
                account.Fonterra_Share_of_Total_Dairy_Purchases__c = accountPlan.Fonterra_Share_of_Business__c ;
                account.Customer_Background__c = accountPlan.Customer_Background__c;
                account.Strategies_Goals__c = accountPlan.Strategies_Goals__c;
                account.Major_Risks_Threats_Challenges__c = accountPlan.Major_Risks_Threats_Challenges__c;
                account.Vision__c = accountPlan.Vision__c;
                account.Market_Insight__c = accountPlan.Market_Insight__c;
                account.Customer_Needs_1__c = accountPlan.Customer_Need_1__c;
                account.Customer_Needs_2__c = accountPlan.Customer_Need_2__c;           
                account.Customer_Needs_3__c = accountPlan.Customer_Need_3__c;           
                account.Customer_Needs_4__c = accountPlan.Customer_Need_4__c;
                account.Customer_Needs_5__c = accountPlan.Customer_Need_5__c;                        
                accountPlan.Volume_Invoiced_YTD__c = account.Invoiced_Volume_YTD__c;
                accountPlan.Volume_Invoiced_LY__c = account.Invoiced_Volume_LY__c;
                accountPlan.Volume_Invoiced_Tracking_YTD_vs_LY__c = account.Volume_Invoiced_Tracking__c;
                accountPlan.Volume_Contracted_YTD__c = account.Contracted_Volume_YTD__c;
                accountPlan.Volume_Contracted_LY__c = account.Contracted_Volume_LY__c;
                accountPlan.Vol_Contracted_Tracking_YTD_vs_LY__c = account.Contracted_Volume_tracking__c;
                accountPlan.Price_Achievement_YTD__c = account.Price_Achievement_YTD__c;
                accountPlan.Price_Achievement_LY__c = account.Price_Achievement_LFY__c;
                accountPlan.PA_Tracking_YTD_vs_Target__c = account.Price_Achievement_Tracking__c;
                accountPlan.Revenue_YTD__c = account.Revenue_YTD__c;
                accountPlan.Revenue_LY__c = account.Revenue_LY__c;
                accountPlan.Revenue_Tracking__c = account.Revenue_Tracking__c;
              //  accountPlan.Key_Metrics_Last_Update__c = account.Key_Metrics_Last_Update__c;
                accountPlan.YTD_Key_Metrics_as_at__c= account.YTD_Key_Metrics_as_at__c;
            }
            
            if(accountPlan.Id != null) {
                List<Needs_vs_Capability__c> needs = [select Id from Needs_vs_Capability__c where Account_Plan__c = :accountPlan.Id];
                    if(needs.size()>0) {
                        Database.delete(needs);
                    }
                AccountPlanExConHelper.createNeedsCapabilities(AccountPlan);      
            }
            AccountPlanExConHelper.saveOpMetrics(accountPlan, operationalMetricsWrapperList);                                                      
            AccountPlanExConHelper.saveAssessMent(accountPlan, assessmentWrapperList);                                     
            if(accountPlan.Id == null) {
                Database.insert(accountPlan); system.debug('###: insert ');
                AccountPlanExConHelper.createNeedsCapabilities(AccountPlan);                                         
            } 
            else {
                Database.update(accountPlan); system.debug('###: update ');
            }
            // Save Engagement Plans
            List<Engagement_Plan__c> listEngagementPlansForDelete = new List<Engagement_Plan__c>();
            listEngagementPlansForDelete = [select Id from Engagement_Plan__c where Account_Plan__c = :accountPlan.Id];
            if(listEngagementPlansForDelete.size()>0) {
                Database.delete(listEngagementPlansForDelete);
            }
            listEngagementPlans = new List<Engagement_Plan__c>();
            listEngagementPlans = ePWrapper.retrieveEngagementPlans(engagementPlanWrapper);
            if(listEngagementPlans.size()>0) {
                Set<Id> engagementIdSet = new Set<Id>();
                List<Engagement_Plan__c> engagementPlanSaveList = new List<Engagement_Plan__c>();
                List<Engagement_Plan__c> engagementPlanTempList = new List<Engagement_Plan__c>();
                for(Engagement_Plan__c ep : listEngagementPlans){
                    if(ep.Responsibility__c != null){
                        engagementPlanSaveList.add(ep);
                    }
                }
                Database.saveResult[] saveEngagementPlanResults = Database.insert(engagementPlanSaveList, false);
                Integer i = 0;
                for(Database.saveResult sr:saveEngagementPlanResults) {
                    if(!sr.isSuccess()) {
                         engagementIdSet.add(sr.getId());
                    }
                    i++;
                }
                if(engagementIdSet.size() > 0) {
                    List<Engagement_Plan__c> engagementPlanNewSaveList = new List<Engagement_Plan__c>([select Id, Account_Plan__c, Customer_Department__c, Objective__c, Display_Order__c,                                                                  
                                                                                Responsibility__c, Approach__c 
                                                                                from Engagement_Plan__c 
                                                                                where Id in :engagementIdSet 
                                                                                order by Display_Order__c asc]);
                    if(engagementPlanTempList.size()>0) {
                        engagementPlanWrapper = ePWrapper.populateEngagementPlanWrapper(accountPlan, engagementPlanTempList);
                    }
                }
            } 
            // Update Account                                    
            Database.update(account); 
            
            // Update Partners/Associations. Reseller logic Mar2016.
            List<Partner> listPartnerCreateList = new List<Partner>();
            List<Partner> listPartnerDeleteList = new List<Partner>();
            
            for(PartnerWrapper partWrap: listPartnerWrappers){
            	if(partWrap.toDelete && partWrap.acctPartner.Id != null){
            		listPartnerDeleteList.add(partWrap.acctPartner);
            	}
            	if(partWrap.toDelete == false && partWrap.acctPartner.Id == null){
            		listPartnerCreateList.add(partWrap.acctPartner);
            	}	
            }
            
            if(listPartnerCreateList.size() > 0){
            	Database.insert(listPartnerCreateList);
            }
            if(listPartnerDeleteList.size()> 0 ){
            	Database.delete(listPartnerDeleteList);
            }
            
            // Build Return URL
            if(accountPlan.Id != null){
                pref = new PageReference('/apex/AccountPlan?id=' + accountPlan.Id);
                if(ApexPages.currentPage().getParameters().get('accountId') != null) 
                    pref.getParameters().put('accountId', ApexPages.currentPage().getParameters().get('accountId'));
                if(ApexPages.currentPage().getParameters().get('retUrl') != null)   
                    pref.getParameters().put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));  
                pref.getParameters().put('tab', tabInFocus);
                pref.getParameters().put('success', '1');
                if(loadConga){
                    loadConga = false;
                    return pref;
                }           
                pref.setRedirect(true);
            }                                                                
        }  
        catch(System.DMLException e) { 
            system.debug('## e =>' + e);
            addPageMessage(ApexPages.severity.ERROR, e);
            return pref;
        }  
                               
        return pref;
    } 
    // TODO: FIX THIS
    public String getOpenKeyMetricsDashboard() {
        if(account != null) {
            return '/apex/ReportChart?id=' + account.Id;  
        }
        else {
            return null;
        }
    }
    // TODO: FIX THIS
    public String getOpenGrowthMetricsDashboard() {
        if(account != null) {
            return '/apex/ReportChart?id=' + account.Id;
        }
        else {
            return null;
        }
    }  
    // WHAT IS THIS FOR?
    public PageReference createOpp() {
        return null;
    }
    // Cancel
    public PageReference cancel() {
        PageReference pref = null;
        if(ApexPages.currentPage().getParameters().get('retURL') != null) {
            pref = new PageReference(ApexPages.currentPage().getParameters().get('retURL'));       
        }
        else if(ApexPages.currentPage().getParameters().get('cancelURL') != null) {
            pref = new PageReference(ApexPages.currentPage().getParameters().get('cancelURL'));       
        }               
        else if(accountPlan.Id != null) {
            pref = new PageReference('/' + accountPlan.Account_Name__c); 
        } 
        else {
            pref = new PageReference('/home/home.jsp'); 
        }
        return pref;
    }
     // WHAT IS THIS FOR?
    public PageReference createInitiative() {
        return null;
    }
    
    // Reseller logic Mar2016.  
    // Adds a new Partnership to the current associations list using the id selected and passed in a param
    public PageReference addAssociation(){
    	
    	string strAcctSelectedId = System.currentPageReference().getParameters().get('acctSelectedId');
    	
    	if(string.isNotBlank(strAcctSelectedId) && mapAcctsSearched.containsKey(strAcctSelectedId)){
    		
    		Partner tempPartner = new Partner(AccountFromId = account.Id,AccountToId=strAcctSelectedId, Role = PARTNER_ROLE_RESELLER_CUSTOMER);
    		Account tempAccount = mapAcctsSearched.get(strAcctSelectedId);
    		system.debug('### tempAccount: ' + tempAccount);
    		PartnerWrapper partnerWrap = new PartnerWrapper(tempPartner, new Account(Id=tempAccount.Id, Name=tempAccount.Name, 
        													Industry = tempAccount.Industry, Markets__c = tempAccount.Markets__c, 
        													Estimated_Annual_Volume__c = tempAccount.Estimated_Annual_Volume__c));
    		partnerWrap.rowIndex = listPartnerWrappers.size();
    		listPartnerWrappers.add(partnerWrap);
    		tempAccount = mapAcctsSearched.remove(strAcctSelectedId);
    		system.debug('### listPartnerWrappers: ' + listPartnerWrappers);
    	}
    	
    	return null;
    }
    
    // Reseller logic Mar2016.  
    // Marks a Partnership for removal/deletion.  
    // Sets the toDelete flag to true using the row number passed in the param
    public PageReference removeAssociation(){
    	
    	string strRowIndex = System.currentPageReference().getParameters().get('rowIndex');
    	
    	if(string.isNotBlank(strRowIndex) && strRowIndex.isNumeric()){
    		Integer rowIndex = Integer.valueof(strRowIndex);
    		listPartnerWrappers[rowIndex].toDelete = true;
    	}
    	
    	return null;
    }
    
    // Reseller logic Mar2016.  
    // Undoes removing Partnership change by setting the toDelete flag to false 
    // using the row number passed in the param
    public PageReference undoRemoveAssociation(){
    	string strRowIndex = System.currentPageReference().getParameters().get('rowIndex');
    	
    	if(string.isNotBlank(strRowIndex) && strRowIndex.isNumeric()){
    		Integer rowIndex = Integer.valueof(strRowIndex);
    		listPartnerWrappers[rowIndex].toDelete = false;
    	}
    	
    	return null;
    }
    
    // Reseller logic Mar2016. Searches for accounts with 'Reseller Customer' record type
    // Builds a query dynamically - includes the name provided in the search box and 
    // excludes accounts already in partnership with the reseller
    public PageReference runAccountSearch(){
		if(string.isNotBlank(strAcctNameSearch)){
			mapAcctsSearched.clear();
			// construct list of existing partners, want to exclude these from the query.
			string strPartnerList = '';
			for(PartnerWrapper part: listPartnerWrappers){ 
				if(part.accountTo.Id != null){
					strPartnerList += (string.isNotBlank(strPartnerList) ? ',' : '') + '\'' + part.accountTo.Id + '\'';
				}
			}
			
	 		string soqlQuery = 'Select Id, Name, Industry, Markets__c, Estimated_Annual_Volume__c FROM Account '; 
	 		soqlQuery += ' WHERE (RecordTypeId = \'' + resellerCustomerRTId + '\'';
	 		soqlQuery += ' OR RecordTypeId = \'' + resellerRTId + '\')';
	 		soqlQuery += ' AND name LIKE \'' + String.escapeSingleQuotes(strAcctNameSearch) + '%\'';
	 		
	 		if(string.isNotBlank(strPartnerList)){
	 			soqlQuery += ' AND Id NOT IN (' + strPartnerList + ')';
	 		}
	 		soqlQuery += ' ORDER BY Name LIMIT 20';
	 		
	 		system.debug('### soqlQuery: ' + soqlQuery);

 			List<Account> listAcctsSearched = Database.query(soqlQuery);
 			for(Account tempAcct : listAcctsSearched){
 				mapAcctsSearched.put(tempAcct.Id, tempAcct);
 			}
 		}
 		return null;		
    }
    
    /* WRAPPER CLASSES */
    public class CompetitorWrapper {
        public List<Competitor_Analysis__c> listCompetitors {get; set;}
        public List<Competitor_Analysis__c> listCompetitorsOpp {get; set;}
        Competitor_Analysis__c tempComp = new Competitor_Analysis__c();
        List<Competitor_Analysis__c> templist = new List<Competitor_Analysis__c>();
        public CompetitorWrapper(Account account, List<Competitor_Analysis__c> listCommAnalysis, Map<Opportunity, List<Competitor_Analysis__c>> mapOppComp) {
            // First Table          
            listCompetitors = new List<Competitor_Analysis__c>();
            if(account.Fonterra_Share_of_Total_Dairy_Purchases__c != null) {
                tempComp.Share_Percent__c = Decimal.valueOf(account.Fonterra_Share_of_Total_Dairy_Purchases__c);    
            }                                   
            listCompetitors.add(tempComp);          
            listCompetitors.addAll(listCommAnalysis);
            listCompetitorsOpp = new List<Competitor_Analysis__c>();
            for(Opportunity opp:mapOppComp.keySet()) {
                tempComp = new Competitor_Analysis__c();                
                tempComp.Opportunity__c = opp.Id;
                tempComp.Opportunity__r = opp;
                templist = mapOppComp.get(opp);             
                if(templist != null && templist.size()>0) {
                    String competitors = '';
                    String commodity = '';
                    for(Competitor_Analysis__c comp:templist) {
                        if(competitors != '') {
                            competitors += ', ';
                        }
                        competitors += comp.Competitor__r.Name;
                        if(commodity != '') {
                            commodity += ', ';
                        }
                        if(comp.Commodity_Class__c != null)
                        commodity += comp.Commodity_Class__c;
                    }
                    if(commodity.endsWith(', '))
                        commodity = commodity.removeEnd(', ');
                    tempComp.Commodity_Class__c = commodity;
                    tempComp.Competitor_Display__c = competitors;
                }
                listCompetitorsOpp.add(tempComp);
            }                       
        }       
    }
    
    /* Wrapper class for Audit and child records.  Created for Reseller logic Mar2016 */
    public class AuditWrapper {
    	public Audit__c audit {get; set;}
    	public String auditConductedDate{
    		get {
    			if(audit.Conducted_On__c != null){
    				return audit.Conducted_On__c.Day() + '/' + audit.Conducted_On__c.Month() +'/'+  audit.Conducted_On__c.Year();
    			}
    			else return 'None entered'; 
    		} 
    		private set;
    	}
    	public map<Id, AuditNoteWrapper> mapAuditNoteWrapper {get; set;} // map<auditNoteId, AuditNoteWrapper>
    	public integer intAuditNoteMapSize{
    		get{return mapAuditNoteWrapper!= null ? mapAuditNoteWrapper.size() : 0;}
    		private set;
    	}
    	
    	//wrapper constructor
    	public AuditWrapper(Audit__c audit){
    		this.audit = audit;
    		mapAuditNoteWrapper = new map<Id, AuditNoteWrapper>();
    	}
    }
    
	/* Wrapper class for Audit Notes and task records.  Created for Reseller logic Mar2016 */
    public class AuditNoteWrapper {
    	public Audit_Notes__c auditNote {get; set;}
    	public List<Task> listAuditTasks {get; set;}
    	public integer intAuditTaskListSize{
    		get{return listAuditTasks != null ? listAuditTasks.size() : 0;}
    		private set;
    	}
    	
    	//wrapper constructor
    	public AuditNoteWrapper(Audit_Notes__c auditNote){
    		this.auditNote = auditNote;
    		listAuditTasks = new List<Task>();
    	}
    }
    
    /* Wrapper class for Partner (associated account).  Created for Reseller logic Mar2016 */
    public class PartnerWrapper{
    	public Partner acctPartner {get; set;}
    	public Account accountTo {get; private set;}
    	public integer rowIndex {get; set;}
    	public boolean toDelete {get; set;}
    	
    	//wrapper constructor
    	public PartnerWrapper(Partner acctPartner, Account accountTo){
    		this.acctPartner = acctPartner;
    		this.accountTo = accountTo;
    		toDelete = false;
    	}
    }
    
    // Clone Existing Account Plan
    public pageReference cloneAP() {
        Revised_Account_Plan__c clonedAccountPlan = accountPlan.clone();
        clonedAccountPlan.Account_Planning_Status__c = 'Draft';
        String strAPName = '[CLONE] ' + accountPlan.Name;
        //TODO clear out the rating and rationale,explanations__c  
        
        if(strAPName.length()>80) strAPName = strAPName.substring(0, 79);
        clonedAccountPlan.Name = strAPName;
        // Set the dates
       // clonedAccountPlan.Start_Date__c = fiscalYearStart;
       // clonedAccountPlan.End_Date__c = fiscalYearEnd; 
        clonedAccountPlan.Start_Date__c = null;
        clonedAccountPlan.End_Date__c = null;
        // Reset the assessment
        clonedAccountPlan.Customer_Overview_Rating__c = null;
        clonedAccountPlan.Customer_Overview_Rational_Explanation__c = null;     
        clonedAccountPlan.Financial_Metrics_Rating__c = null;
        clonedAccountPlan.Financial_Metrics_Rationale_Explanation__c = null;     
        clonedAccountPlan.Operational_Metrics_Rating__c = null;
        clonedAccountPlan.Operation_Metrics_Rationale_Explanation__c = null;     
        clonedAccountPlan.Growth_Metrics_Rating__c = null;
        clonedAccountPlan.Growth_Metrics_Rationale_Explanation__c = null;     
        clonedAccountPlan.CVM_Metrics_Rating__c = null;
        clonedAccountPlan.CVM_Metrics_Rationale_Explanation__c = null;     
        clonedAccountPlan.Engagement_Plan_Rating__c = null;
        clonedAccountPlan.Engagement_Plan_Rationale_Explanation__c = null;     
        clonedAccountPlan.Competitors_Rating__c = null;
        clonedAccountPlan.Competitors_Rationale_Explanation__c = null;     
        clonedAccountPlan.Needs_vs_Capability_Rating__c = null;
        clonedAccountPlan.Needs_vs_CapabilityRationale_Explanatio__c = null;     
        clonedAccountPlan.SWOT_Rating__c = null;
        clonedAccountPlan.SWOT_Rationale_Explanation__c = null;     
        clonedAccountPlan.X5_yr_Strategy_Rating__c = null;
        clonedAccountPlan.X5yr_Strategy_Rationale_Explanation__c = null;     
        clonedAccountPlan.Progress_against_plan_Rating__c = null;
        clonedAccountPlan.Progress_against_plan_Rationale__c = null;     
        clonedAccountPlan.Account_Plan_Score_Assessment_Display__c = null;     
        Database.saveResult sr = Database.insert(clonedAccountPlan);
        // Related Engagement plans
        List<Engagement_Plan__c> listEngagementPLan = new List<Engagement_Plan__c>();
        for(Engagement_Plan__c e:[select Id, Account_Plan__c, Customer_Department__c, Objective__c, Responsibility__c, Approach__c,
                                    Display_Order__c
                                    from Engagement_Plan__c where Account_Plan__c = :accountPlan.Id]) {
            Engagement_Plan__c eClone = e.clone(); 
            eClone.Account_Plan__c = clonedAccountPlan.Id;                          
            listEngagementPLan.add(eClone);
        }
        if(listEngagementPlan.size()>0) {
            Database.saveResult[] srsEP = Database.insert(listEngagementPlan);
        }
        // Needs vs Capability
        List<Needs_vs_Capability__c> listNeedsVsCapability = new List<Needs_vs_Capability__c>();
        for(Needs_vs_Capability__c n:[select Id, Ranking__c, Potential_Opportunity__c, Fonterra_s_Strength__c, Detailed_Needs__c, 
                           Customer_Need__c, Account_Plan__c 
                                    from Needs_vs_Capability__c where Account_Plan__c = :accountPlan.Id]) {  
            Needs_vs_Capability__c needsClone = n.clone(); 
            needsClone.Account_Plan__c = clonedAccountPlan.Id;                                                             
            listNeedsVsCapability.add(needsClone);
        } 
        if(listNeedsVsCapability.size()>0) {
            Database.saveResult[] srsNvsCap = Database.insert(listNeedsVsCapability);
        }
        PageReference pageRef = new PageReference('/' + clonedAccountPlan.id);
        return pageRef;
    }
    // Add engagement plan row
    public void removeEPRow() {
        if(selectedRowEP != null) {
            if(engagementPlanWrapper.size() > 0) {
                for(AccountPlanExConHelper.EngagementPlanWrapper ep:engagementPlanWrapper) {
                    if(ep.listEPInnerWrapper.size()>0){
                        List<AccountPlanExConHelper.EPInnerWrapper> listInnerW = new List<AccountPlanExConHelper.EPInnerWrapper>();
                        for(AccountPlanExConHelper.EPInnerWrapper innerW:ep.listEPInnerWrapper) {
                            if(innerW.engagementPlan.Display_Order__c != selectedRowEP) {
                                listInnerW.add(innerW);
                            } 
                        }
                        ep.listEPInnerWrapper = listInnerW;
                    }
                }

            }
        }
    }
    // remove engagement plan row
    public void addEPRow() {
        if(departmentStr != null) {
            if(engagementPlanWrapper.size() > 0) {
                for(AccountPlanExConHelper.EngagementPlanWrapper ep:engagementPlanWrapper) {
                    Integer lastDisplayOrder = 1;
                    for(AccountPlanExConHelper.EPInnerWrapper epInner : ep.listEPInnerWrapper) {
                        if(epInner.engagementPlan.Display_Order__c != null && lastDisplayOrder < Integer.valueOf(epInner.engagementPlan.Display_Order__c)) {
                            lastDisplayOrder = Integer.valueOf(epInner.engagementPlan.Display_Order__c);
                        }
                    }
                    if(departmentStr == ep.strDepartmentName){
                        AccountPlanExConHelper.EPInnerWrapper innerW = new AccountPlanExConHelper.EPInnerWrapper();
                        Engagement_Plan__c e = new Engagement_Plan__c();
                        e.Display_Order__c = lastDisplayOrder + 1; 
                        e.Customer_Department__c = departmentStr;
                        e.Account_Plan__c = accountPlan.Id;
                        innerW.strDepartmentName = departmentStr;
                        innerW.engagementPlan = e;
                        ep.listEPInnerWrapper.add(innerW);
                    }
                }
            }
        }
       
    }    
    // Add Page Messages
    public void addPageMessage(ApexPages.severity severity, Object objMessage) {
        ApexPages.Message pMessage = new ApexPages.Message(severity, String.valueOf(objMessage));
        ApexPages.addMessage(pMessage);
    }
    public void addPageMessage(Object objMessage) {
        addPageMessage(ApexPages.severity.INFO, objMessage);
    }       
}