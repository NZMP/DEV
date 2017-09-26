public without sharing class AccountPlanDetailTabViewCtlr {

    public static String getHeaders() {
        return ApexPages.currentPage().getHeaders()+'';
    }
    public static Boolean getIsIE8() {
        return ApexPages.currentPage().getHeaders().get('User-Agent').contains('MSIE 8.0'); 
    }
    public static Boolean getIsChromeFrame() {
        return ApexPages.currentPage().getHeaders().get('User-Agent').contains('chromeframe'); 
    }
    public static Boolean getIsIE8ChromeFrame() {
        return getIsIE8() && getIsChromeFrame(); 
    }
    public static Boolean getIsIPad() {
        return ApexPages.currentPage().getHeaders().get('User-Agent').contains('iPad'); 
    }
    public static String getInlineEditSupportEvent() {
        if (getIsIPad()) {
            return 'onclick';
        }
        return 'ondblclick'; 
    }

    public static List<Boolean> getDummyRow() {
        return new List<Boolean>{ true };
    }

    public static String getSelectedTabParameter(String buttonId) {
        for (String p : Apexpages.currentPage().getParameters().keySet()) {
            if (p.contains(buttonId)) {
                return p.split(buttonId)[1];
            }
        }
        return null;
    }

    public static Integer getMaxCategories() {
        return CrmsConstants.ACCOUNT_PLAN_MAX_CATEGORIES;
    }

    public static Integer getMaxProducts() {
        return CrmsConstants.ACCOUNT_PLAN_MAX_PRODUCTS;
    }

    public class RecordAccess {
        public Boolean hasEditAccess {get; set;}
        public RecordAccess() {}
    }

    private UserRecordAccess userRecAccess {get; set;}
    public RecordAccess userRecordAccess {get; set;}

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

    private ApexPages.StandardController controller;

    public String selectedTab { get; set; }

    public AccountPlanDetailTabViewCtlr(ApexPages.StandardController controller) {
        this.accountPlan = (Account_Plan__c)controller.getRecord();
        this.controller = controller;
        
        userRecAccess = AccountPlanHelper.getUserRecordAccess(UserInfo.getUserId(), accountPlan.Id);
        userRecordAccess = new RecordAccess();
        userRecordAccess.hasEditAccess = false;
        if ((userRecAccess.hasEditAccess) && (accountPlan.Status__c != CrmsConstants.ACCOUNT_PLAN_STATUS_READYFORAPPROVAL)) {
            userRecordAccess.hasEditAccess = true;
        }
        
        selectedTab = Apexpages.currentPage().getParameters().get('selectedTab');
        if (selectedTab == null) {
            selectedTab = 'Snapshot';
        } 
        init();
/*
        if (AccountHelper.refreshFinancialPerformanceCharts(account)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Account charts need refreshing, please go to the<a href="/' + account.Id + '" target="_blank" style="font-size:100%">' + account.Name + '</a>Account page to refresh the charts.'));
        }
        if (AccountHelper.refreshFinancialPerformanceCharts(account)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'New Account data has been loaded, Account Plan charts are now refreshing in the background.'));
        }
*/
    }

    public PageReference pageAction() {    

        if ((account.NDA_Agreement__c) &&
            (CrmsConstants.getProfileNameForId(UserInfo.getUserId()) == CrmsConstants.PROFILE_SALES_USER_RESTRICTED)) {
            return new PageReference('/' + accountPlan.Id + '?nooverride=1'); 
        }

        if (getIsParentAccountPlan()) {
            update [Select Id From Customer_Snapshot__c Where Account__r.ParentId = :accountPlan.Account__c];
            customerSnapshotMetricsAggregate = AccountPlanHelper.queryCustomerSnapshotMetricsAggregate(accountPlan.Account__c);
        } else {
            customerSnapshotMetrics = AccountPlanHelper.queryCustomerSnapshotMetrics(accountPlan.Account__c);
        }

        return null;
    }

    public PageReference init() {

        ChartGenerator.setSalesforceBaseUrl(System.URL.getSalesforceBaseUrl());
        
        numberOfCategories = AccountPlanHelper.getNumberOfCategories(accountPlan);
        numberOfProducts = AccountPlanHelper.getNumberOfProducts(accountPlan);

        //try {

            account = AccountPlanHelper.queryAccount(accountPlan.Account__c);


            competitorAnalyses = AccountPlanHelper.queryCompetitorAnalyses(accountPlan.Id);

            stakeholderAnalyses = AccountPlanHelper.queryStakeholderAnalyses(accountPlan.Id);

            cvmResults = AccountPlanHelper.queryCvmResults(accountPlan.Account__c, accountPlan.Start_Date__c, accountPlan.End_Date__c);

            keyOpportunities = AccountPlanHelper.queryKeyOpportunities(accountPlan.Account__c);

            keyInitiatives = AccountPlanHelper.queryKeyInitiatives(accountPlan.Account__c,accountPlan.Start_Date__c, accountPlan.End_Date__c);

            emailPdfTo = [Select Email From User Where Id = :UserInfo.getUserId()].Email;
            emailPdfCc = emailPdfTo + ',' + [Select Email From User Where Id = :account.OwnerId].Email;
            emailPdfMessage = '';

/*
        } catch (Exception e) {
            throw e;
        }
*/
        return null;
    }

    public PageReference addCategory() {
        AccountPlanHelper.setFieldValue(accountPlan, 'Category_', '__c', numberOfCategories + 1, '<Enter category name>');
        update accountPlan;
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        numberOfCategories = AccountPlanHelper.getNumberOfCategories(accountPlan);
        selectedTab = 'CustomerCategories';
        return null;
    }

    public Integer removeCategory { get; set; }
    public PageReference removeCategory() {
        AccountPlanHelper.copyCategoryFieldSet(accountPlan, null, removeCategory);
        AccountPlanHelper.fixCategoryFieldSetOrder(accountPlan);
        update accountPlan;
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        numberOfCategories = AccountPlanHelper.getNumberOfCategories(accountPlan);
        selectedTab = 'CustomerCategories';
        return null;
    }

    public PageReference addProduct() {
        AccountPlanHelper.setFieldValue(accountPlan, 'Product_', '_Name__c', numberOfProducts + 1, '<Enter product name>');
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_Dairy_Ingredients_pct__c', numberOfProducts + 1, 0);
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_all_Ingredients_pct__c', numberOfProducts + 1, 0);
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_Manufacturing_pct__c', numberOfProducts + 1, 0);
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_Sale_to_Brand_Owner_pct__c', numberOfProducts + 1, 0);
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_Wholesale_pct__c', numberOfProducts + 1, 0);
        AccountPlanHelper.setFieldValue(accountPlan, 'P', '_Cost_of_Retail_pct__c', numberOfProducts + 1, 0);
        update accountPlan;
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        numberOfProducts = AccountPlanHelper.getNumberOfProducts(accountPlan);
        selectedTab = 'ValueChainAnalysis';
        return null;
    }

    public Integer removeProduct { get; set; }
    public PageReference removeProduct() {
        AccountPlanHelper.copyProductFieldSet(accountPlan, null, removeProduct);
        AccountPlanHelper.fixProductFieldSetOrder(accountPlan);
        update accountPlan;
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        numberOfProducts = AccountPlanHelper.getNumberOfProducts(accountPlan);
        selectedTab = 'ValueChainAnalysis';
        return null;
    }

    public PageReference cancel() {
        controller.cancel();
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        selectedTab = getSelectedTabParameter('cancelButton');
        return null;
    }

    public String imageSizeData {get;set;}
    public PageReference save() {
        system.debug('!!imageSizeData='+imageSizeData);
        Map<String, String> resizedImageFieldDataMap = AccountPlanHelper.calculateImageResizeData(imageSizeData, (Account_Plan__c)controller.getRecord());
        for (String fieldName : resizedImageFieldDataMap.keySet()) {
            ((Account_Plan__c)controller.getRecord()).put(fieldName, resizedImageFieldDataMap.get(fieldName));
        }
        //system.debug('!!accountPlan='+accountPlan);
        controller.save();
        if (!Test.isRunningTest()) {
            controller.reset();
            accountPlan = (Account_Plan__c)controller.getRecord();
        }
        //system.debug('!!accountPlan2='+accountPlan);  
        selectedTab = getSelectedTabParameter('saveButton');
        return null;
    }

    public PageReference cloneAndRedirect() {
        Account_Plan__c accountPlanClone = accountPlan.clone(false, true, false, false);
        accountPlanClone.Name = accountPlanClone.Name + ' - Clone';
        //accountPlanClone.Start_Date__c = accountPlanClone.Start_Date__c.addYears(1);
        //accountPlanClone.End_Date__c = accountPlanClone.End_Date__c.addYears(1);
        //accountPlanClone.Status__c = CrmsConstants.ACCOUNT_PLAN_STATUS_DRAFT;
        //accountPlanClone.OwnerId = UserInfo.getUserId();
        insert accountPlanClone;
        String teamShareResult = AccountPlanDetailPageTriggerCtlr.generateTeamShareForRelatedObjects(account.Id);
        System.debug('cloneAndRedirect teamShareResult='+teamShareResult);
        return new PageReference('/' + accountPlanClone.Id);
    }

    public PageReference sharingRedirect() {
        selectedTab = getSelectedTabParameter('sharingButton');
        return new PageReference('/p/share/CustomObjectSharingDetail?parentId=' + accountPlan.Id);
    }

    public Boolean getRenderSharingRedirect() {
        Boolean renderSharingRedirect = (UserInfo.getUserId() == account.OwnerId);
        renderSharingRedirect |= (CrmsConstants.getProfileNameForId(UserInfo.getUserId()) == CrmsConstants.PROFILE_SYSTEM_ADMINISTRATOR);
        return renderSharingRedirect;
    }

    public PageReference changeOwnerRedirect() {
        selectedTab = 'Snapshot';
        return new PageReference('/' + accountPlan.Id + '/a?retURL=%2F' + accountPlan.Id);
    }

    public PageReference refreshCharts() {
/*
        Account accountRefresh = [Select Refresh_Financial_Performance_Charts__c From Account where Id = :accountPlan.Account__c];
        accountRefresh.Refresh_Financial_Performance_Charts__c = true;
        update accountRefresh;
        return new PageReference('/' + accountPlan.Id);
*/
        return null;
    }

    public PageReference clearAllGraphics() {
        Account_Plan__c ap = AccountPlanHelper.queryAccountPlan(accountPlan.Id);
        Map<String, Schema.DescribeFieldResult> fieldDescribeMap = AccountPlanHelper.getFieldDescribeMap();
        Schema.DescribeFieldResult fieldDescribe = null;
        for (String fieldName : fieldDescribeMap.keySet()) {
            fieldDescribe = fieldDescribeMap.get(fieldName);
            if ((fieldDescribe.getType() == Schema.DisplayType.TextArea) && (fieldDescribe.getLength() == Integer.valueOf(Label.ACC_PLAN_RTF_FLD_LNGTH))) {
                //String imgText = ap.get(fieldName)+'';
                //if (imgText.contains('<img')) {
                //system.debug(fieldName+'='+imgText);
                ap.put(fieldName, null);
                //}
            }
        }
        update ap;
        return new PageReference('/' + accountPlan.Id + '?selectedTab=Other');
    }

    public String getViewPdf() {
        return '/apex/AccountPlanPdf?id=' + accountPlan.Id;
    }

    public String getViewPdf2() {
        return '/apex/AccountPlanPdf2?id=' + accountPlan.Id + '&renderAs=pdf';
    }

    public String getPreviewSlide() {
        return '/apex/AccountPlanPdf2?id=' + accountPlan.Id + '#';
    }

    public String getDownloadPdf2() {
        return '/apex/AccountPlanPdf2?id=' + accountPlan.Id + '&renderAs=pdf&download=1';
    }

    public Boolean getRefreshFinancialPerformanceCharts() {
        return AccountHelper.refreshFinancialPerformanceCharts(account);
    }
/*
    public String getSessionFrameSrc() {
        return ChartGenerator.getSessionFrameSrc();
    }
    
    @RemoteAction
    public static String generateFinancialPerformanceCharts(String accountId) {
            //Account a = AccountPlanHelper.queryAccount(accountId);
            //a.Refresh_Financial_Performance_Charts__c = false;
            //update a;
            //return 'successful';
        Map<String, SObject> sObjectNameToSObjectMap = new Map<String, SObject>();
        sObjectNameToSObjectMap.put('Account', AccountPlanHelper.queryAccount(accountId));
        ChartGenerator.setSalesforceBaseUrl(System.URL.getSalesforceBaseUrl());
        String resultMessage = AccountHelper.generateFinancialPerformanceCharts(sObjectNameToSObjectMap);
        if (resultMessage == CrmsConstants.EMPTY_STRING) {
            resultMessage = 'Account Plan chart generation was successful.\nPlease click [OK] and wait for the Account Plan to reload with the new charts.';
        } else {
            resultMessage = 'Unable to generate Account Plan charts: ' + resultMessage;
        }
        return resultMessage;
    }
*/

    public Boolean getIsParentAccountPlan() {
        return account.RecordType.Name == CrmsConstants.ACCOUNT_RECORD_TYPE_PARENT_ACCOUNT;
    }

    public PageReference attachPdf2() {
        saveBlobAsAttachment(getPdf2AsBlob(), 'application/pdf', accountPlan.Id);
        selectedTab = 'Other';
        return null;
    }

    public PageReference postPdf2Link() {
        chatterPostPdf2Link();
        selectedTab = 'Other';
        return null;
    }

    public PageReference postPdf2() {
        chatterPostPdf2();
        selectedTab = 'Other';
        return null;
    }
    
    public String emailPdfTo {get; set;}
    public String emailPdfCc {get; set;}
    public String emailPdfMessage {get; set;}
    public PageReference emailPdf2() {
        Blob pdfBlob = getPdf2AsBlob();
        Attachment pdfAttachment = saveBlobAsAttachment(pdfBlob, 'application/pdf', accountPlan.Id);
        emailPdf2(
            emailPdfTo, 
            emailPdfCc, 
            accountPlan.Name + ' Account Plan PDF (attached)',
            emailPdfMessage,
            new Map<String, Attachment>{
                accountPlan.Name => pdfAttachment 
            });
        delete pdfAttachment;
        Task activityTask = CrmsConstants.createTask('Account Plan PDF has been emailed', 'Account Plan PDF emailed to: ' + emailPdfTo + ' with message: ' + emailPdfMessage, account.Id, null, null, null, CrmsConstants.TASK_STATUS_COMPLETED, false, null, 0, null);
        insert activityTask;
        //pdfAttachment = saveBlobAsAttachment(pdfBlob, 'application/pdf', activityTask.Id);
        selectedTab = 'Other';
        return null;
    }

    public Blob getPdf2AsBlob() {
        PageReference pdfPage = new PageReference(getViewPdf2());
        Blob pdfBlob = null;
        if (!Test.isRunningTest()) {
            pdfBlob = pdfPage.getContentAsPDF();
        } else {
            pdfBlob = Blob.valueOf('test');
        }
        return pdfBlob;
    }
    
    public Attachment saveBlobAsAttachment(Blob blobToAttach, String contentType, Id parentId) {
        Attachment blobAttach = new Attachment();        
        blobAttach.Name = accountPlan.Name;
        blobAttach.Body = blobToAttach;
        blobAttach.ContentType = contentType;
        blobAttach.ParentId = parentId;
        insert blobAttach;
        return blobAttach;
    }
        
    public static void emailPdf2(String to, String cc, String subject, String message, Map<String, Attachment> attachments) {
        if (to != null) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(subject);
            mail.setToAddresses(to.split(','));
            if (cc != null) {
                mail.setCcAddresses(cc.split(','));
            }
            mail.setPlainTextBody(message);
            //mail.setUseSignature(false);
            List<Messaging.EmailFileAttachment> mailAttachments = new List<Messaging.EmailFileAttachment>();
            for (String attachmentName : attachments.keySet()) {        
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType(attachments.get(attachmentName).ContentType);
                attach.setFileName(attachmentName + attachments.get(attachmentName).ContentType.split('/')[1]);
                attach.setInline(false);
                attach.Body = attachments.get(attachmentName).Body;
                mailAttachments.add(attach);
            }
            mail.setFileAttachments(mailAttachments);
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
        }
    }

    public FeedItem chatterPostPdf2Link() {
        FeedItem post = new FeedItem();
        post.ParentId = account.Id;
        post.Body = 'View latest Account Plan PDF (link)';
        post.LinkUrl = getViewPdf2();
        insert post;
        return post;
    }

    public FeedItem chatterPostPdf2() {
        FeedItem post = new FeedItem();
        post.ParentId = account.Id;
        post.Body = 'Download latest Account Plan PDF (attached)';
        post.ContentData = getPdf2AsBlob();
        post.ContentFileName = accountPlan.Name + '.pdf';
        insert post;
        return post;
    }

}