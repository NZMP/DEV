@isTest
public with sharing class ReportChartConTest {
	public static testmethod void testClass(){
		Account acc = new Account();
		acc.Name ='Test Account';
		insert acc;
		Key_Metrics__c keyMetrics = new Key_Metrics__c();
		keyMetrics.Sold_to_party__c= acc.Id;
		keyMetrics.FY_Date__c = Date.newInstance(2012,09,30);
		keyMetrics.Invoiced_Volume__c = 12;
		keyMetrics.Price_Achievement__c = 12;
		insert keyMetrics;
		Key_Metrics__c keyMetrics1 = new Key_Metrics__c();
		keyMetrics1.Sold_to_party__c= acc.Id;
		keyMetrics1.Invoiced_Volume__c = 12;
		keyMetrics1.Price_Achievement__c = 12;
		keyMetrics1.FY_Date__c = Date.newInstance(2011,09,30);
		insert keyMetrics1;
		Key_Metrics__c keyMetrics3 = new Key_Metrics__c();
		keyMetrics3.Sold_to_party__c= acc.Id;
		keyMetrics3.Invoiced_Volume__c = 12;
		keyMetrics3.Price_Achievement__c = 12;
		keyMetrics3.FY_Date__c = Date.newInstance(2013,09,30);
		insert keyMetrics3;
		Apexpages.currentPage().getParameters().put('id',acc.id);
		Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(keyMetrics);
		ReportChartCon classInstance = new ReportChartCon(stdController);
		classInstance.priceAchievement3YrsReportpage();
		classInstance.priceAchievementReportpage();
		classInstance.invoicedVolume3YrsReportpage();
		
		Apexpages.Standardcontroller stdController1 = new Apexpages.Standardcontroller(keyMetrics1);
		ReportChartCon classInstance1 = new ReportChartCon(stdController1);
		classInstance1.invoicedVolumeReportpage();
		
		Apexpages.Standardcontroller stdController2 = new Apexpages.Standardcontroller(keyMetrics3);
		ReportChartCon classInstance2 = new ReportChartCon(stdController2);
		
		
	}
}