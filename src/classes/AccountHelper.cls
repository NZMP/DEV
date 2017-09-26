public with sharing class AccountHelper {

	public static Boolean refreshFinancialPerformanceCharts(Account account) {
		return account.Refresh_Financial_Performance_Charts__c;
	}

    public static String generateFinancialPerformanceCharts(Map<String, SObject> sObjectNameToSObjectMap) {
    	String result = CrmsConstants.EMPTY_STRING;
    	Account account = (Account)sObjectNameToSObjectMap.get('Account');
    	if (account.Refresh_Financial_Performance_Charts__c) {
    		try {
	        account.Customer_s_Financial_Perf_Chart_URL_1__c = CrmsConstants.URL_S_GIF;
	        account.Customer_s_Financial_Perf_Chart_URL_2__c = CrmsConstants.URL_S_GIF;
	        account.Customer_s_Financial_Perf_Chart_URL_3__c = CrmsConstants.URL_S_GIF;
	        account.Customer_s_Opty_Pipeline_Chart_URL__c = CrmsConstants.URL_S_GIF;
    		Attachment chart1Attachment = new Attachment(Name = ChartGenerator.FINANCIAL_PERFORMANCE_CHART1_REPORT_NAME, ParentId = account.Id, ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN, Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA));
    		Attachment chart2Attachment = new Attachment(Name = ChartGenerator.FINANCIAL_PERFORMANCE_CHART2_REPORT_NAME, ParentId = account.Id, ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN, Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA));
    		Attachment chart3Attachment = new Attachment(Name = ChartGenerator.FINANCIAL_PERFORMANCE_CHART3_REPORT_NAME, ParentId = account.Id, ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN, Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA));
    		Attachment chart4Attachment = new Attachment(Name = ChartGenerator.METRICS_CHART1_REPORT_NAME, ParentId = account.Id, ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN, Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA));
    		for (Attachment a:  [Select Id, Name, ContentType, Body
    			From Attachment
    			Where ParentId = :account.Id
    			And (Name = :ChartGenerator.FINANCIAL_PERFORMANCE_CHART1_REPORT_NAME Or Name = :ChartGenerator.FINANCIAL_PERFORMANCE_CHART2_REPORT_NAME 
    			Or Name = :ChartGenerator.FINANCIAL_PERFORMANCE_CHART3_REPORT_NAME Or Name = :ChartGenerator.METRICS_CHART1_REPORT_NAME)]) {
				if (a.Name == ChartGenerator.FINANCIAL_PERFORMANCE_CHART1_REPORT_NAME ) {
					a.ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN;
					a.Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA);
					chart1Attachment = a;
				}
				if (a.Name == ChartGenerator.FINANCIAL_PERFORMANCE_CHART2_REPORT_NAME ) {
					a.ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN;
					a.Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA);
					chart2Attachment = a;
				}
				if (a.Name == ChartGenerator.FINANCIAL_PERFORMANCE_CHART3_REPORT_NAME ) {
					a.ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN;
					a.Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA);
					chart3Attachment = a;
				}			
				if (a.Name == ChartGenerator.METRICS_CHART1_REPORT_NAME ) {
					a.ContentType = ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN;
					a.Body = Blob.valueOf(ChartGenerator.ATTACHMENT_CHART_NA);
					chart4Attachment = a;
				}			
   			} 
	        HttpResponse chartResponse = ChartGenerator.getChartForReport(ChartGenerator.FINANCIAL_PERFORMANCE_CHART1_REPORT_NAME, ChartGenerator.FINANCIAL_PERFORMANCE_CHART1_REPORT_PARAMS, sObjectNameToSObjectMap, chart1Attachment);
			system.debug('chartResponse1='+chartResponse);
	        chartResponse = ChartGenerator.getChartForReport(ChartGenerator.FINANCIAL_PERFORMANCE_CHART2_REPORT_NAME, ChartGenerator.FINANCIAL_PERFORMANCE_CHART2_REPORT_PARAMS, sObjectNameToSObjectMap, chart2Attachment);
			system.debug('chartResponse2='+chartResponse);
	        chartResponse = ChartGenerator.getChartForReport(ChartGenerator.FINANCIAL_PERFORMANCE_CHART3_REPORT_NAME, ChartGenerator.FINANCIAL_PERFORMANCE_CHART3_REPORT_PARAMS, sObjectNameToSObjectMap, chart3Attachment);
			system.debug('chartResponse3='+chartResponse);
	        chartResponse = ChartGenerator.getChartForReport(ChartGenerator.METRICS_CHART1_REPORT_NAME, ChartGenerator.METRICS_CHART1_REPORT_PARAMS, sObjectNameToSObjectMap, chart4Attachment);
			system.debug('chartResponse4='+chartResponse);
	        //ChartGenerator.invalidateSessionId();
			upsert new List<Attachment>{chart1Attachment, chart2Attachment, chart3Attachment, chart4Attachment};
			if ((chart1Attachment.Id != null) && (chart1Attachment.ContentType != ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN)) {
				account.Customer_s_Financial_Perf_Chart_URL_1__c = ChartGenerator.ATTACHMENT_VIEW_URL_BASE + chart1Attachment.Id;
			}        
			if ((chart2Attachment.Id != null) && (chart2Attachment.ContentType != ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN)) {
				account.Customer_s_Financial_Perf_Chart_URL_2__c = ChartGenerator.ATTACHMENT_VIEW_URL_BASE + chart2Attachment.Id;
			}
			if ((chart3Attachment.Id != null) && (chart3Attachment.ContentType != ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN)) {
				account.Customer_s_Financial_Perf_Chart_URL_3__c = ChartGenerator.ATTACHMENT_VIEW_URL_BASE + chart3Attachment.Id;
			}
			if ((chart4Attachment.Id != null) && (chart4Attachment.ContentType != ChartGenerator.ATTACHMENT_CONTENT_TYPE_TEXTPLAIN)) {
				account.Customer_s_Opty_Pipeline_Chart_URL__c = ChartGenerator.ATTACHMENT_VIEW_URL_BASE + chart4Attachment.Id;
			}
	        account.Refresh_Financial_Performance_Charts__c = false;
	        update account;
    		} catch (Exception e) {
    			System.debug(e);
    			result = e.getMessage();
    		}
    	}
        return result;
    }

}