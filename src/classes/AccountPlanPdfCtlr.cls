public without sharing class AccountPlanPdfCtlr {

    public Account account {get; set;}
    public Account_Plan__c accountPlan {get; set;}
    public Integer numberOfCategories {get; set;}
    public Integer numberOfProducts {get; set;}
    public List<Customer_Snapshot__c> customerSnapshotMetrics {get; set;}
    public List<AggregateResult> customerSnapshotMetricsAggregate {get; set;}
    public List<Competitor_Analysis__c> competitorAnalyses {get; set;}
    public List<Contact_Role__c> stakeholderAnalyses {get; set;}
    public List<CVM_Results__c > cvmResults {get; set;}
    public List<Opportunity> keyOpportunities {get; set;}
    public List<Key_Initiative__c> keyInitiatives {get; set;}

    public String readOnlyRenderAs {get; set;}
    
    public AccountPlanPdfCtlr(ApexPages.StandardController controller) {
        this.accountPlan = (Account_Plan__c)controller.getRecord();
        init();
        //ApexPages.currentPage().getHeaders().put('Content-Disposition', 'inline;filename=' + accountPlan.Name + '.pdf');
        if (ApexPages.currentPage().getParameters().get('download') != null) {
            ApexPages.currentPage().getHeaders().put('Content-Disposition', 'attachment;filename=' + accountPlan.Name + '.pdf');
        }
    }

    public Map<String, String> getAccountPlanCustomerGraphicImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Account_Plan_Customer_Graphic__c, false);
    }

    public String getOpportunityPipelineChartImageUrl() {
        return AccountPlanHelper.getRelativeUrl(account.Customer_s_Opty_Pipeline_Chart_URL__c);
    }

    public Map<String, String> getMarket101ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Market_101_Graphic__c, false);
    }

    public Map<String, String> getCustomersFinancialPerformaceImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_s_Financial_Performace_Graphic__c, false);
    }

    public String getCustomersFinancialPerformaceChart1ImageUrl() {
        return AccountPlanHelper.getRelativeUrl(account.Customer_s_Financial_Perf_Chart_URL_1__c);
    }

    public String getCustomersFinancialPerformaceChart2ImageUrl() {
        return AccountPlanHelper.getRelativeUrl(account.Customer_s_Financial_Perf_Chart_URL_2__c);
    }

    public String getCustomersFinancialPerformaceChart3ImageUrl() {
        return AccountPlanHelper.getRelativeUrl(account.Customer_s_Financial_Perf_Chart_URL_3__c);
    }

    public void setNumberOfCategories() {
        numberOfCategories = AccountPlanHelper.getNumberOfCategories(accountPlan);
    }
    
    public Map<String, String> getCustomerProduct1ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_Product_Graphic_1__c, false);
    }
    public Map<String, String> getCustomerProduct2ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_Product_Graphic_2__c, false);
    }
    public Map<String, String> getCustomerProduct3ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_Product_Graphic_3__c, false);
    }
    public Map<String, String> getCustomerProduct4ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_Product_Graphic_4__c, false);
    }
    public Map<String, String> getCustomerProduct5ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customer_Product_Graphic_5__c, false);
    }

    public void setNumberOfProducts() {
        numberOfProducts = AccountPlanHelper.getNumberOfProducts(accountPlan);
    }
    
    public Map<String, String> getProduct1ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Product_1_Graphic__c, false);
    }
    public Map<String, String> getProduct2ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Product_2_Graphic__c, false);
    }
    public Map<String, String> getProduct3ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Product_3_Graphic__c, false);
    }
    public Map<String, String> getProduct4ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Product_4_Graphic__c, false);
    }
    public Map<String, String> getProduct5ImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Product_5_Graphic__c, false);
    }

    public Map<String, String> getCVMResultsImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.CVM_results__c, false);
    }

    public Map<String, String> getFonterrasShareOfBustomersBusinessImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Fonterra_s_share_of_customer_s_business__c, false);
    }

    public Map<String, String> getDIFOTImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.DIFOT__c, false);
    }

    public Map<String, String> getComplaintsImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Complaints__c, false);
    }

    public Map<String, String> getCustomersBusinessByProductImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customers_Business_by_Product__c, false);
    }

    public Map<String, String> getCustomersBusinessByCompetitorImageUrl() {
        return AccountPlanHelper.getImageUrlFromHtml(accountPlan.Customers_Business_by_Competitor__c, false);
    }

    public PageReference init()
    {
//        try {
            accountPlan = AccountPlanHelper.queryAccountPlan(accountPlan.Id);
            setNumberOfCategories();
            setNumberOfProducts();
            
            account = AccountPlanHelper.queryAccount(accountPlan.Account__c);

            //customerSnapshotMetrics = AccountPlanHelper.queryCustomerSnapshotMetrics(accountPlan.Account__c);

            competitorAnalyses = AccountPlanHelper.queryCompetitorAnalyses(accountPlan.Id);

            stakeholderAnalyses = AccountPlanHelper.queryStakeholderAnalyses(accountPlan.Id);

            cvmResults = AccountPlanHelper.queryCvmResults(accountPlan.Account__c, accountPlan.Start_Date__c, accountPlan.End_Date__c);

            if (getIsParentAccountPlan()) {
                keyOpportunities = AccountPlanHelper.queryKeyOpportunitiesForParentAccount(accountPlan.Account__c, true);
    
                keyInitiatives = AccountPlanHelper.queryKeyInitiativesForParentAccount(accountPlan.Account__c, true, accountPlan.Start_Date__c, accountPlan.End_Date__c);
            } else {
                keyOpportunities = AccountPlanHelper.queryKeyOpportunities(accountPlan.Account__c);
    
                keyInitiatives = AccountPlanHelper.queryKeyInitiatives(accountPlan.Account__c, accountPlan.Start_Date__c, accountPlan.End_Date__c);
            }
/*
        } catch (Exception e) {
            throw e;
        }
*/
        return null;
    }

    public PageReference pageAction() {    

        if (getIsParentAccountPlan()) {
            update [Select Id From Customer_Snapshot__c Where Account__r.ParentId = :accountPlan.Account__c];
            customerSnapshotMetricsAggregate = AccountPlanHelper.queryCustomerSnapshotMetricsAggregate(accountPlan.Account__c);
        } else {
            customerSnapshotMetrics = AccountPlanHelper.queryCustomerSnapshotMetrics(accountPlan.Account__c);
        }

        readOnlyRenderAs = ApexPages.currentPage().getParameters().get('renderAs');
        if ((account.NDA_Agreement__c) &&
                (CrmsConstants.getProfileNameForId(UserInfo.getUserId()) == CrmsConstants.PROFILE_SALES_USER_RESTRICTED)) {
            if (readOnlyRenderAs != null) {
                readOnlyRenderAs = '';
            }
            return new PageReference('/' + accountPlan.Id + '/p?nooverride=1');
        }

        return null;
    }

    public Boolean getIsParentAccountPlan() {
        return account.RecordType.Name == CrmsConstants.ACCOUNT_RECORD_TYPE_PARENT_ACCOUNT;
    }

}