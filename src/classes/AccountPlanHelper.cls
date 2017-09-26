public without sharing class AccountPlanHelper {

    public static Object getFieldValue(SObject sObj, String fieldNamePrefix, String fieldNameSuffix, Integer index) { 
        return sObj.get(fieldNamePrefix + index + fieldNameSuffix);
    }

    public static void setFieldValue(SObject sObj, String fieldNamePrefix, String fieldNameSuffix, Integer index, Object value) { 
        sObj.put(fieldNamePrefix + index + fieldNameSuffix, value);
    }

    public static void copyFieldValue(SObject sObj, String fieldNamePrefix, String fieldNameSuffix, Integer fromIndex, Integer toIndex) {
        Object newValue = null;
        if (fromIndex != null) {
            newValue = getFieldValue(sObj, fieldNamePrefix, fieldNameSuffix, fromIndex);
        }
        setFieldValue(sObj, fieldNamePrefix, fieldNameSuffix, toIndex, newValue);       
    }

    public static void copyCategoryFieldSet(SObject sObj, Integer fromIndex, Integer toIndex) {
        copyFieldValue(sObj, 'Category_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Customer_Product_Graphic_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'of_total_revenue_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Brands_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Formats_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Channels_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Positioning_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Share_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Competitors_', '__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Ingredients_', '__c', fromIndex, toIndex);
    }

    public static void fixCategoryFieldSetOrder(SObject sObj) {
        for (Integer i = 1; i < CrmsConstants.ACCOUNT_PLAN_MAX_CATEGORIES; i++) {
            if (getFieldValue(sObj, 'Category_', '__c', i) == null) {
                copyCategoryFieldSet(sObj, i + 1, i);
                copyCategoryFieldSet(sObj, null, i + 1);
            }
        }
    }

    public static Integer getNumberOfCategories(Account_Plan__c accountPlan) {
        for (Integer i = 1; i <= CrmsConstants.ACCOUNT_PLAN_MAX_CATEGORIES; i++) {          
            if (getFieldValue(accountPlan, 'Category_', '__c', i) == null) {
                return i - 1;
            }
        }
        return CrmsConstants.ACCOUNT_PLAN_MAX_CATEGORIES;
    }   

    public static void copyProductFieldSet(SObject sObj, Integer fromIndex, Integer toIndex) {
        copyFieldValue(sObj, 'Product_', '_Name__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'Product_', '_Graphic__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Dairy_Ingredients__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Dairy_Ingredients_pct__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_all_Ingredients__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_all_Ingredients_pct__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Manufacturing__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Manufacturing_pct__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Sale_to_Brand_Owner__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Sale_to_Brand_Owner_pct__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Wholesale__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Wholesale_pct__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Retail__c', fromIndex, toIndex);
        copyFieldValue(sObj, 'P', '_Cost_of_Retail_pct__c', fromIndex, toIndex);
    }

    public static void fixProductFieldSetOrder(SObject sObj) {
        for (Integer i = 1; i < CrmsConstants.ACCOUNT_PLAN_MAX_PRODUCTS; i++) {
            if (getFieldValue(sObj, 'Product_', '_Name__c', i) == null) {
                copyProductFieldSet(sObj, i + 1, i);
                copyProductFieldSet(sObj, null, i + 1);
            }
        }
    }

    public static Integer getNumberOfProducts(Account_Plan__c accountPlan) {
        for (Integer i = 1; i <= CrmsConstants.ACCOUNT_PLAN_MAX_PRODUCTS; i++) {
            if (getFieldValue(accountPlan, 'Product_', '_Name__c', i) == null) {
                return i - 1;
            }
        }
        return CrmsConstants.ACCOUNT_PLAN_MAX_PRODUCTS;
    }

    public static Map<String, Schema.DescribeFieldResult> getFieldDescribeMap() {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account_Plan__c.fields.getMap();
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = new Map<String, Schema.DescribeFieldResult>();
        Schema.DescribeFieldResult fieldDescribe = null;
        for (String fieldKey : fieldMap.keySet()) {
            fieldDescribe = fieldMap.get(fieldKey).getDescribe();
            fieldDescribeMap.put(fieldDescribe.getName(), fieldDescribe);
        }
        return fieldDescribeMap;
    }       

    public static UserRecordAccess getUserRecordAccess(Id userId, Id recordId) {
        return [Select RecordId, HasReadAccess, HasEditAccess, HasTransferAccess, HasAllAccess, HasDeleteAccess, MaxAccessLevel
            From UserRecordAccess
            Where UserId = :userId
            And RecordId = :recordId];
    }

    public static Account_Plan__c queryAccountPlan(String accountPlanId) {
        String soql = 'Select a.Group_Category_1__c, a.Group_Category_2__c, a.Group_Category_3__c, a.Group_Category_4__c, a.Group_Category_5__c, a.of_total_revenue_5__c, a.of_total_revenue_4__c, a.of_total_revenue_3__c, a.of_total_revenue_2__c, a.of_total_revenue_1__c, a.Value_Chain_Analysis_Insights__c, a.Target_Visits_Total__c, a.Target_Visits_Q4__c, a.Target_Visits_Q3__c, a.Target_Visits_Q2__c, a.Target_Visits_Q1__c, a.SystemModstamp, a.Strategies__c, a.Strategic_Goal_3__c, a.Strategic_Goal_2__c, a.Strategic_Goal_1__c, a.Status__c, a.Start_Date__c, a.Snapshot_Metrics__c, a.Share_of_Business_Insights__c, a.Share_5__c, a.Share_4__c, a.Share_3__c, a.Share_2__c, a.Share_1__c, a.Section_4_3_Insights__c, a.Section_3_1_Insights__c, a.SWOT_Font_Weaknesses__c, a.SWOT_Font_Threats__c, a.SWOT_Font_Thingsto_develop_capitilise_on__c, a.SWOT_Font_Things_to_monitor_mitigate__c, a.SWOT_Font_Strengths__c, a.SWOT_Font_Opportunities__c, a.SWOT_Cust_Weaknesses__c, a.SWOT_Cust_Threats__c, a.SWOT_Cust_Thingsto_develop_capitilise_on__c, a.SWOT_Cust_Things_to_monitor_mitigate__c, a.SWOT_Cust_Strengths__c, a.SWOT_Cust_Opportunities__c, a.Region__c, a.Product_5_Name__c, a.Product_5_Graphic__c, a.Product_4_Name__c, a.Product_4_Graphic__c, a.Product_3_Name__c, a.Product_3_Graphic__c, a.Product_2_Name__c, a.Product_2_Graphic__c, a.Product_1_Name__c, a.Product_1_Graphic__c, a.Priority_5__c, a.Priority_4__c, a.Priority_3__c, a.Priority_2__c, a.Priority_1__c, a.Positioning_5__c, a.Positioning_4__c, a.Positioning_3__c, a.Positioning_2__c, a.Positioning_1__c, a.Payment_Performance__c, a.P5_Cost_of_all_Ingredients_pct__c, a.P5_Cost_of_all_Ingredients__c, a.P5_Cost_of_Wholesale_pct__c, a.P5_Cost_of_Wholesale__c, a.P5_Cost_of_Sale_to_Brand_Owner_pct__c, a.P5_Cost_of_Sale_to_Brand_Owner__c, a.P5_Cost_of_Retail_pct__c, a.P5_Cost_of_Retail__c, a.P5_Cost_of_Manufacturing_pct__c, a.P5_Cost_of_Manufacturing__c, a.P5_Cost_of_Dairy_Ingredients_pct__c, a.P5_Cost_of_Dairy_Ingredients__c, a.P4_Cost_of_all_Ingredients_pct__c, a.P4_Cost_of_all_Ingredients__c, a.P4_Cost_of_Wholesale_pct__c, a.P4_Cost_of_Wholesale__c, a.P4_Cost_of_Sale_to_Brand_Owner_pct__c, a.P4_Cost_of_Sale_to_Brand_Owner__c, a.P4_Cost_of_Retail_pct__c, a.P4_Cost_of_Retail__c, a.P4_Cost_of_Manufacturing_pct__c, a.P4_Cost_of_Manufacturing__c, a.P4_Cost_of_Dairy_Ingredients_pct__c, a.P4_Cost_of_Dairy_Ingredients__c, a.P3_Cost_of_all_Ingredients_pct__c, a.P3_Cost_of_all_Ingredients__c, a.P3_Cost_of_Wholesale_pct__c, a.P3_Cost_of_Wholesale__c, a.P3_Cost_of_Sale_to_Brand_Owner_pct__c, a.P3_Cost_of_Sale_to_Brand_Owner__c, a.P3_Cost_of_Retail_pct__c, a.P3_Cost_of_Retail__c, a.P3_Cost_of_Manufacturing_pct__c, a.P3_Cost_of_Manufacturing__c, a.P3_Cost_of_Dairy_Ingredients_pct__c, a.P3_Cost_of_Dairy_Ingredients__c, a.P2_Cost_of_all_Ingredients_pct__c, a.P2_Cost_of_all_Ingredients__c, a.P2_Cost_of_Wholesale_pct__c, a.P2_Cost_of_Wholesale__c, a.P2_Cost_of_Sale_to_Brand_Owner_pct__c, a.P2_Cost_of_Sale_to_Brand_Owner__c, a.P2_Cost_of_Retail_pct__c, a.P2_Cost_of_Retail__c, a.P2_Cost_of_Manufacturing_pct__c, a.P2_Cost_of_Manufacturing__c, a.P2_Cost_of_Dairy_Ingredients_pct__c, a.P2_Cost_of_Dairy_Ingredients__c, a.P1_Cost_of_all_Ingredients_pct__c, a.P1_Cost_of_all_Ingredients__c, a.P1_Cost_of_Wholesale_pct__c, a.P1_Cost_of_Wholesale__c, a.P1_Cost_of_Sale_to_Brand_Owner_pct__c, a.P1_Cost_of_Sale_to_Brand_Owner__c, a.P1_Cost_of_Retail_pct__c, a.P1_Cost_of_Retail__c, a.P1_Cost_of_Manufacturing_pct__c, a.P1_Cost_of_Manufacturing__c, a.P1_Cost_of_Dairy_Ingredients_pct__c, a.P1_Cost_of_Dairy_Ingredients__c, a.Overview_of_Key_Issues_Risks__c, a.Opportunity_Pipeline_Chart_URL__c, a.Name, a.Mitigation_5__c, a.Mitigation_4__c, a.Mitigation_3__c, a.Mitigation_2__c, a.Mitigation_1__c, a.Market_Graphic_Title__c, a.Market_101_Insights__c, a.Market_101_Graphic__c, a.LastModifiedDate, a.LastModifiedById, a.LastActivityDate, a.Key_Challenges__c, a.Issue_Risk_5__c, a.Issue_Risk_4__c, a.Issue_Risk_3__c, a.Issue_Risk_2__c, a.Issue_Risk_1__c, a.IsDeleted, a.Ingredients_5__c, a.Ingredients_4__c, a.Ingredients_3__c, a.Ingredients_2__c, a.Ingredients_1__c, a.Id, a.Horizon_Theme_3_5_yrs__c, a.Horizon_Theme_1_2_yrs__c, a.Horizon_Theme_0_1_yr__c, a.Horizon_Revenue_Goal_3_5_yrs__c, a.Horizon_Revenue_Goal_1_2_yrs__c, a.Horizon_Revenue_Goal_0_1_yr__c, a.Formats_5__c, a.Formats_4__c, a.Formats_3__c, a.Formats_2__c, a.Formats_1__c, a.Fonterra_s_share_of_customer_s_business__c, a.Fonterra_Strength_5__c, a.Fonterra_Strength_4__c, a.Fonterra_Strength_3__c, a.Fonterra_Strength_2__c, a.Fonterra_Strength_1__c, a.Fonterra_Competition__c, a.Fiscal_Year_End__c, a.Financial_perf_Insights__c, a.Financial_Performance_Commentary__c, a.Financial_Performance_Charts__c, a.Executive_Sponsor__c, a.End_Date__c, a.DIFOT__c, a.Customers_Business_by_Product__c, a.Customers_Business_by_Competitor__c, a.Customer_s_Vision__c, a.Customer_s_Financial_Performance__c, a.Customer_s_Financial_Performace_Graphic__c, a.Customer_s_Competitive_Landscape__c, a.Customer_s_Business_Model__c, a.Customer_Product_Graphic_5__c, a.Customer_Product_Graphic_4__c, a.Customer_Product_Graphic_3__c, a.Customer_Product_Graphic_2__c, a.Customer_Product_Graphic_1__c, a.Customer_Positioning_Statement__c, a.Customer_Overview_Strategies__c, a.Customer_Need_5__c, a.Customer_Need_4__c, a.Customer_Need_3__c, a.Customer_Need_2__c, a.Customer_Need_1__c, a.Customer_Competition__c, a.Customer_Background__c, a.CreatedDate, a.CreatedById, a.Complaints__c, a.Competitors_Insights__c, a.Competitors_5__c, a.Competitors_4__c, a.Competitors_3__c, a.Competitors_2__c, a.Competitors_1__c, a.Competitor_4__c, a.Competitor_3__c, a.Competitor_2__c, a.Competitor_1__c, a.Channels_5__c, a.Channels_4__c, a.Channels_3__c, a.Channels_2__c, a.Channels_1__c, a.Category_Insights__c, a.Category_5__c, a.Category_4__c, a.Category_3__c, a.Category_2__c, a.Category_1__c, a.CVM_results__c, a.CVM_Insights__c, a.Brands_5__c, a.Brands_4__c, a.Brands_3__c, a.Brands_2__c, a.Brands_1__c, a.Account__c, a.Account_Plan_Customer_Graphic__c, a.Account_Group__c' 
                    + ', a.Account__r.Name, a.Account__r.Account_Number__c, a.Account__r.Owner.Name, a.Account__r.Site, a.Account__r.Customer_s_Opty_Pipeline_Chart_URL__c, a.Account__r.ParentId, a.Account__r.Parent.RecordType.Name '+
            'From Account_Plan__c a '+
            'Where Id = :accountPlanId';
        return (Account_Plan__c)Database.Query(soql);
    }

    public static Account queryAccount(String accountId) {
        String soql = 'Select a.Name, a.Account_Number__c, a.NDA_Agreement__c, a.OwnerId, a.Refresh_Financial_Performance_Charts__c, Customer_s_Financial_Perf_Chart_URL_1__c, Customer_s_Financial_Perf_Chart_URL_2__c, Customer_s_Financial_Perf_Chart_URL_3__c, Customer_s_Opty_Pipeline_Chart_URL__c, RecordTypeId, RecordType.Name, ParentId, Parent.RecordType.Name '+
            'From Account a '+
            'Where Id = :accountId';
        return (Account)Database.Query(soql);
    }

    public static List<Customer_Snapshot__c> queryCustomerSnapshotMetrics(String accountId) {
        String soql = 'Select c.YTG_Forecast__c, c.YTD_Actual__c, c.TY_Budget__c, c.TY_2_Forecast__c, c.TY_1_Forecast__c, c.SystemModstamp, c.Name, c.Metric_Type__c, c.LastModifiedDate, c.LastModifiedById, c.LY_Budget__c, c.LY_Actual__c, c.IsDeleted, c.Id, c.Full_Year_Forecast__c, c.Financial_Year__c, c.External_Id__c, c.Edit_URL__c, c.CreatedDate, c.CreatedById, c.Action__c, c.Account__c '+
            'From Customer_Snapshot__c c '+
            'Where Account__c = :accountId '+
            'Order By Metric_Type__c asc';
        return (List<Customer_Snapshot__c>)Database.Query(soql);
    }

    public static List<AggregateResult> queryCustomerSnapshotMetricsAggregate(String parentAccountId) {
        String soql = 'Select Sum(c.YTG_Forecast__c) YTG_Forecast__c, Sum(c.YTD_Actual__c) YTD_Actual__c, Sum(c.TY_Budget__c) TY_Budget__c, Sum(c.TY_2_Forecast__c) TY_2_Forecast__c, Sum(c.TY_1_Forecast__c) TY_1_Forecast__c, Sum(c.LY_Budget__c) LY_Budget__c, Sum(c.LY_Actual__c) LY_Actual__c, Sum(c.Full_Year_Forecast__c) Full_Year_Forecast__c, Max(c.Financial_Year__c) Financial_Year__c, c.Metric_Type_For_Aggregate__c '+
            'From Customer_Snapshot__c c '+
            'Where c.Account__r.ParentId = :parentAccountId '+
            'Group By c.Metric_Type_For_Aggregate__c '+
            'Order By c.Metric_Type_For_Aggregate__c asc';
        return (List<AggregateResult>)Database.Query(soql);
    }

    public static List<Competitor_Analysis__c> queryCompetitorAnalyses(String accountPlanId) {
        String soql = 'Select c.SystemModstamp, c.Share_Volume__c, c.Share_Percent__c, c.RecordTypeId, c.Opportunity__c, c.Name, c.Mitigation__c, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.CreatedDate, c.CreatedById, c.Competitor__c, c.Competitor__r.Name, c.Competitive_Advantages__c, c.Account__c, c.Account_Plan__c '+
            'From Competitor_Analysis__c c '+
            'Where Account_Plan__c = :accountPlanId '+
            'Order By Ranking__c asc nulls last '+
            'Limit 4';
        return (List<Competitor_Analysis__c>)Database.Query(soql);      
    }

    public static List<Contact_Role__c> queryStakeholderAnalyses(String accountPlanId) {
        String soql = 'Select c.SystemModstamp, c.Role__c,c.Customer_Role__c, c.Role_Description__c, c.Reports_to__c, c.RecordTypeId, c.Priority__c, c.Position_Department__c, c.Opportunity__c, c.Name, c.Mobile__c, c.LastModifiedDate, c.LastModifiedById, c.LastActivityDate, c.IsDeleted, c.Insights__c, c.Id, c.Future_Relationship_state__c, c.Future_Relationship__c, c.Future_Indicator__c, c.Email__c, c.Current_relationship_state__c, c.Current_Relationship__c, c.Current_Indicator__c, c.CreatedDate, c.CreatedById, c.Contact__c, c.Contact__r.Name, c.Attitude__c, c.Account__c, c.Account__r.Name, c.Account_Plan__c '+
            'From Contact_Role__c c '+
            'Where Account_Plan__c = :accountPlanId '+
            'Order By Priority__c asc nulls last '+
            'Limit 4';
        return (List<Contact_Role__c>)Database.Query(soql);
    }

    public static List<CVM_Results__c > queryCvmResults(String accountId, Date accountPlanStartDate, Date accountPlanEndDate) {
        String soql = 'Select c.Regional_Result__c, c.Weighting__c, c.SystemModstamp, c.RVS__c, c.Name, c.LastModifiedDate, c.LastModifiedById, c.IsDeleted, c.Id, c.Date__c, c.CreatedDate, c.CreatedById, c.Category__c, c.CVM_3__c, c.CVM_2__c, c.CVM_1__c, c.Account__c '+
            'From CVM_Results__c c '+
            'Where Account__c = :accountId '+
            'And (Date__c >= :accountPlanStartDate) And (Date__c <= :accountPlanEndDate) ';
        return (List<CVM_Results__c>)Database.Query(soql);
    }

    public static List<Opportunity> queryKeyOpportunities(String accountId) {
        String soql = 'Select Account_Name__c, Name, StageName, Probability, Amount, CloseDate, Owner.Name '+
            'From Opportunity '+
            'Where AccountId = :accountId '+
            'And IsClosed = false '+
            'Order BY Amount desc nulls last, Probability desc nulls last '+
            'Limit 10';
        return (List<Opportunity>)Database.Query(soql);
    }

    public static List<Opportunity> queryKeyOpportunitiesForParentAccount(String accountId, Boolean includeSelf) {
        String soql = 'Select Account_Name__c, AccountId, Name, StageName, Probability, Amount, CloseDate, Owner.Name '+
            'From Opportunity '+
            'Where ((Account.ParentId = :accountId) ';
        if (includeSelf) {
            soql += ' Or (AccountId = :accountId) ';
        }
            soql += ') And IsClosed = false '+
            'Order BY Amount desc nulls last, Probability desc nulls last '+
            'Limit 10';
        return (List<Opportunity>)Database.Query(soql);
    }

    public static List<Key_Initiative__c> queryKeyInitiatives(String accountId,Date accountPlanStartDate, Date accountPlanEndDate) {
        String soql = 'Select k.Target_Outcome__c, k.Target_Date__c, k.SystemModstamp, k.Strategy__c, k.Strategy_Detail__c, k.Status__c, k.Name, k.LastModifiedDate, k.LastModifiedById, k.LastActivityDate, k.IsDeleted, k.Id, k.Deactivated_Date__c, k.Created_By__c, k.CreatedDate, k.CreatedById, k.Account__c, k.Account__r.Name '+
            'From Key_Initiative__c k '+
            'Where Account__c = :accountId '+
            'And (Target_Date__c >= :accountPlanStartDate) And (Target_Date__c <= :accountPlanEndDate) '+
            'Order By Target_Date__c asc nulls last '+
            'Limit 10';
        return (List<Key_Initiative__c>)Database.Query(soql);
    }

    public static List<Key_Initiative__c> queryKeyInitiativesForParentAccount(String accountId, Boolean includeSelf,Date accountPlanStartDate, Date accountPlanEndDate) {
        String soql = 'Select k.Target_Outcome__c, k.Target_Date__c, k.SystemModstamp, k.Strategy__c, k.Strategy_Detail__c, k.Status__c, k.Name, k.LastModifiedDate, k.LastModifiedById, k.LastActivityDate, k.IsDeleted, k.Id, k.Deactivated_Date__c, k.Created_By__c, k.CreatedDate, k.CreatedById, k.Account__c, k.Account__r.Name '+
            'From Key_Initiative__c k '+
            'Where ((Account__r.ParentId = :accountId) ';
        if (includeSelf) {
            soql += ' Or (Account__c = :accountId) ';
        }
            soql += ') And (Target_Date__c >= :accountPlanStartDate) And (Target_Date__c <= :accountPlanEndDate) '+
            'Order By Target_Date__c asc nulls last '+
            'Limit 10';
        return (List<Key_Initiative__c>)Database.Query(soql);
    }

    public static Map<String, String> getImageUrlFromHtml(String htmlWithImage, Boolean asRelativeUrl) {
        String imageSrc = CrmsConstants.URL_S_GIF;
        String imgWidth = CrmsConstants.EMPTY_STRING;
        String imgHeight = CrmsConstants.EMPTY_STRING;
        Map<String, String> imageAttributes = new Map<String, String>();
        if (htmlWithImage != null) {
            List<String> imageSrcs = htmlWithImage.split(CrmsConstants.HTML_IMG_TAG_START);
            if (imageSrcs.size() > 1) {
                if (imageSrcs[1].contains(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)) {
                    imgWidth = imageSrcs[1].split(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0];
                }
                if (imageSrcs[1].contains(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)) {
                    imgHeight = imageSrcs[1].split(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0];
                }
                imageSrcs = imageSrcs[1].split(CrmsConstants.HTML_IMG_TAG_ATTR_SRC_START);
                if (imageSrcs.size() > 1) {
                    imageSrc = imageSrcs[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0].replaceAll(CrmsConstants.AMPERSAND_STRING_XML, CrmsConstants.AMPERSAND_STRING);
                    if (asRelativeUrl) {
                        imageSrc = getRelativeUrl(imageSrc);
                    }
                }
            }
        }
        imageAttributes.put(CrmsConstants.HTML_IMG_TAG_ATTR_SRC, imageSrc);
        imageAttributes.put(CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH, imgWidth);
        imageAttributes.put(CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT, imgHeight);
        return imageAttributes;
    }

    public static Map<String, String> calculateImageResizeData(String imageSizeData, Account_Plan__c accountPlan) {
        Map<String, String> resizedImageFieldDataMap = new Map<String, String>();
        Map<String, String> imageSizeDataMap = null;
        if ((imageSizeData != null) && (imageSizeData.length() > 0)) {
            imageSizeDataMap = new Map<String, String>();
            for (String feoid : imageSizeData.split(CrmsConstants.COLON_STRING)) {
                imageSizeDataMap.put(feoid.split(CrmsConstants.EQUAL_STRING)[0], feoid.split(CrmsConstants.EQUAL_STRING)[1]);
            }
            imageSizeData = null;
            Map<String, Schema.DescribeFieldResult> fieldDescribeMap = getFieldDescribeMap();
            Schema.DescribeFieldResult fieldDescribe = null;
            for (String fieldName : fieldDescribeMap.keySet()) {
                fieldDescribe = fieldDescribeMap.get(fieldName);
                if ((fieldDescribe.getType() == Schema.DisplayType.TextArea) && (fieldDescribe.getLength() == Integer.valueOf(Label.ACC_PLAN_RTF_FLD_LNGTH))) {
                    String imgText = accountPlan.get(fieldName)+CrmsConstants.EMPTY_STRING;
                    system.debug('!!imgText='+imgText);
                    if (imgText.contains(CrmsConstants.HTML_IMG_TAG_START) && imgText.contains(CrmsConstants.URL_RICHTEXTAREA_IMG_SRC_PARAM_REFID_START)) {
                        try {
                            Double maxWidth = 10000;
                            Double maxHeight = 10000;
                            if ((fieldDescribe.getInlineHelpText() != null) && fieldDescribe.getInlineHelpText().contains('[max') && (fieldDescribe.getInlineHelpText().split('~').size() > 2)) {
                                maxWidth = Integer.valueOf(fieldDescribe.getInlineHelpText().split('~')[1].split('x')[0].trim());
                                maxHeight = Integer.valueOf(fieldDescribe.getInlineHelpText().split('~')[2].split(CrmsConstants.HTML_UNIT_PX)[0].trim());
                                system.debug('!!maxWidth='+maxWidth);
                                system.debug('!!maxHeight='+maxHeight);
                            }
                              
                            String feoid = imgText.split(CrmsConstants.URL_RICHTEXTAREA_IMG_SRC_PARAM_REFID_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0];
                            if (imageSizeDataMap.containsKey(feoid)) {
                                Long oldWidth = Integer.valueOf(imageSizeDataMap.get(feoid).split(CrmsConstants.HTML_UNIT_PX)[0]);
                                Long oldHeight = Integer.valueOf(imageSizeDataMap.get(feoid).split(CrmsConstants.HTML_UNIT_PX)[1]);
                                Long newWidth = Integer.valueOf(imageSizeDataMap.get(feoid).split(CrmsConstants.HTML_UNIT_PX)[0]);
                                Long newHeight = Integer.valueOf(imageSizeDataMap.get(feoid).split(CrmsConstants.HTML_UNIT_PX)[1]);
                                Double newWidthRatio = newWidth / maxWidth;
                                Double newHeightRatio = newHeight / maxHeight;  
                                system.debug('!!newWidthRatio='+newWidthRatio);
                                system.debug('!!newHeightRatio='+newHeightRatio);
                                if ((newWidthRatio > 1) && (newHeightRatio > 1)) {
                                    if (newWidthRatio > newHeightRatio) {
                                        newWidth = (newWidth / newWidthRatio).round();
                                        newHeight = (newHeight / newWidthRatio).round();
                                    } else {
                                        newWidth = (newWidth / newHeightRatio).round();
                                        newHeight = (newHeight / newHeightRatio).round();                                       
                                    }
                                } else if (newWidthRatio > 1) {
                                    newWidth = (newWidth / newWidthRatio).round();
                                    newHeight = (newHeight / newWidthRatio).round();                                    
                                } else if (newHeightRatio > 1) {
                                    newWidth = (newWidth / newHeightRatio).round();
                                    newHeight = (newHeight / newHeightRatio).round();                                       
                                }
                                system.debug('!!newWidth='+newWidth);
                                system.debug('!!newHeight='+newHeight);
                                resizedImageFieldDataMap.put(fieldName, CrmsConstants.HTML_IMG_TAG_START + CrmsConstants.SPACE_STRING + 
                                    CrmsConstants.HTML_IMG_TAG_ATTR_SRC_START + 
                                    imgText.split(CrmsConstants.HTML_IMG_TAG_START)[1].split(CrmsConstants.HTML_IMG_TAG_ATTR_SRC_START)[1].split(CrmsConstants.DOUBLEQUOTE_STRING)[0] + CrmsConstants.DOUBLEQUOTE_STRING + CrmsConstants.SPACE_STRING +  
                                    CrmsConstants.HTML_IMG_TAG_ATTR_WIDTH_START + newWidth + CrmsConstants.DOUBLEQUOTE_STRING + CrmsConstants.SPACE_STRING + 
                                    CrmsConstants.HTML_IMG_TAG_ATTR_HEIGHT_START + newHeight + CrmsConstants.DOUBLEQUOTE_STRING + CrmsConstants.SPACE_STRING + 
                                    CrmsConstants.HTML_TAG_END);
                            }
                        } catch (Exception e) {
                            system.debug(e);
                        }
                    }
                }
            }           
        }
        system.debug('!!resizedImageFieldDataMap='+resizedImageFieldDataMap);
        return resizedImageFieldDataMap;
    }

    public static String getRelativeUrl(String url) {
        if ((url != null) && url.contains(CrmsConstants.HTTP_PROTOCOL_SUFFIX)) {
            return CrmsConstants.FORWARDSLASH_STRING + url.split(CrmsConstants.HTTP_PROTOCOL_SUFFIX)[1].split(CrmsConstants.FORWARDSLASH_STRING, 2)[1];
        }
        return url;
    }
    
}