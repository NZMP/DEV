public with sharing class AccountPlanExConHelper {
	
	// Reseller logic Mar2016
    static string resellerAPRTId =  Schema.SObjectType.Revised_Account_Plan__c.getRecordTypeInfosByName().get('Reseller Account Plan').getRecordTypeId();
    // end of reseller logic Mar 2016
    
    
    // Operational Metrics Tab Method
    public static List<OperationalMetricsWrapper> opMetricsWrapperList(Revised_Account_Plan__c accountPlan) {
        List<OperationalMetricsWrapper> opMetricsWrapperList = new List<OperationalMetricsWrapper>();
        // DIFOT
        OperationalMetricsWrapper OpMetricsDifot = new OperationalMetricsWrapper();
        OpMetricsDifot.fieldName = 'DIFOT__c';
        OpMetricsDifot.tempAP.Measure_Label__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('DIFOT__c').getDescribe().getLabel(); 
        OpMetricsDifot.tempAP.DIFOT__c = accountPlan.DIFOT__c;
        OpMetricsDifot.tempAP.Display_Flag__c = accountPlan.DIFOT_Flag__c;
        OpMetricsDifot.tempAP.DIFOT_Insights__c = accountPlan.DIFOT_Insights__c;   
        opMetricsWrapperList.add(OpMetricsDifot);        
        // DSO
        OperationalMetricsWrapper OpMetricsDSO = new OperationalMetricsWrapper();
        OpMetricsDSO.fieldName = 'DSO__c';
        OpMetricsDSO.tempAP.Measure_Label__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('DSO__c').getDescribe().getLabel();
        OpMetricsDSO.tempAP.DSO__c = accountPlan.DSO__c;
        OpMetricsDSO.tempAP.Display_Flag__c = accountPlan.DSO_Flag__c;
        OpMetricsDSO.tempAP.DSO_Insights__c = accountPlan.DSO_Insights__c;   
        opMetricsWrapperList.add(OpMetricsDSO);        
        // Complaints
        OperationalMetricsWrapper OpMetricsComplaints = new OperationalMetricsWrapper();
        OpMetricsComplaints.fieldName = 'Complaints__c';
        OpMetricsComplaints.tempAP.Measure_Label__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Complaints__c').getDescribe().getLabel();
        OpMetricsComplaints.tempAP.Complaints__c = accountPlan.Complaints__c;
        OpMetricsComplaints.tempAP.Display_Flag__c = accountPlan.Complaints_Flag__c;
        OpMetricsComplaints.tempAP.Complaints_Insights__c = accountPlan.Complaints_Insights__c;
        opMetricsWrapperList.add(OpMetricsComplaints);  
        // Perfect Order Consumption 
        OperationalMetricsWrapper OpMetricsPerfectOrder = new OperationalMetricsWrapper();
        OpMetricsPerfectOrder.fieldName = 'Perfect_Order_Consumption__c';
        OpMetricsPerfectOrder.tempAP.Measure_Label__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Perfect_Order_Consumption__c').getDescribe().getLabel();
        OpMetricsPerfectOrder.tempAP.Perfect_Order_Consumption__c = accountPlan.Perfect_Order_Consumption__c;
        OpMetricsPerfectOrder.tempAP.Display_Flag__c = accountPlan.Perfect_Order_Consumption_Flag__c;
        OpMetricsPerfectOrder.tempAP.Perfect_Order_Consumption_Insights__c = accountPlan.Perfect_Order_Consumption_Insights__c;
        opMetricsWrapperList.add(OpMetricsPerfectOrder);    
        // C2S Consumption
        OperationalMetricsWrapper OpMetricsC2s = new OperationalMetricsWrapper();
        OpMetricsC2s.fieldName =  'C2S_Consumption__c';
        OpMetricsC2s.tempAP.Measure_Label__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('C2S_Consumption__c').getDescribe().getLabel();
        OpMetricsC2s.tempAP.C2S_Consumption__c = accountPlan.C2S_Consumption__c;
        OpMetricsC2s.tempAP.Display_Flag__c = accountPlan.C2S_Consumption_Flag__c;
        OpMetricsC2s.tempAP.C2S_Consumption_Insights__c = accountPlan.C2S_Consumption_Insights__c;
        opMetricsWrapperList.add(OpMetricsC2s);
        system.debug('## opMetricsWrapperList =>' + opMetricsWrapperList);
        return opMetricsWrapperList;    
    }
    // Operational Metrics Save Method
    public static Revised_Account_Plan__c saveOpMetrics(Revised_Account_Plan__c accountPlan, List<OperationalMetricsWrapper> opMetricsWrapperList) {
        if(opMetricsWrapperList.size() > 0){
            for(OperationalMetricsWrapper opMetricTemp : opMetricsWrapperList){
                if(opMetricTemp.tempAP.Measure_Label__c == Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('DIFOT__c').getDescribe().getLabel()){
                    accountPlan.DIFOT__c = opMetricTemp.tempAP.DIFOT__c;
                    accountPlan.DIFOT_Insights__c = opMetricTemp.tempAP.DIFOT_Insights__c;
                }
                if(opMetricTemp.tempAP.Measure_Label__c == Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('DSO__c').getDescribe().getLabel()){
                    accountPlan.DSO__c = opMetricTemp.tempAP.DSO__c;
                    accountPlan.DSO_Insights__c = opMetricTemp.tempAP.DSO_Insights__c;
                }
                if(opMetricTemp.tempAP.Measure_Label__c == Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Complaints__c').getDescribe().getLabel()){
                    accountPlan.Complaints__c = opMetricTemp.tempAP.Complaints__c;
                    accountPlan.Complaints_Insights__c = opMetricTemp.tempAP.Complaints_Insights__c;
                }
                if(opMetricTemp.tempAP.Measure_Label__c == Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Perfect_Order_Consumption__c').getDescribe().getLabel()){
                    accountPlan.Perfect_Order_Consumption__c = opMetricTemp.tempAP.Perfect_Order_Consumption__c;
                    accountPlan.Perfect_Order_Consumption_Insights__c = opMetricTemp.tempAP.Perfect_Order_Consumption_Insights__c;
                }
                if(opMetricTemp.tempAP.Measure_Label__c == Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('C2S_Consumption__c').getDescribe().getLabel()){
                    accountPlan.C2S_Consumption__c = opMetricTemp.tempAP.C2S_Consumption__c;
                    accountPlan.C2S_Consumption_Insights__c = opMetricTemp.tempAP.C2S_Consumption_Insights__c;
                }
            }
        }
        return accountPlan;
    }
    // Operational Metrics Wrapper  
    public class OperationalMetricsWrapper {                
        public Revised_Account_Plan__c tempAP {get;set;}
        public String fieldName {get;set;}
        public OperationalMetricsWrapper(){
            tempAP = new Revised_Account_Plan__c();
        }
    }
    // Assessment Tab Methods
    public static List<AssessmentWrapper>  assessmentWrapperList(Revised_Account_Plan__c accountPlan, Id accountRecordTypeId) {
        
        List<AssessmentWrapper> assessmentWrapperList = new List<AssessmentWrapper>();
        // Customer Overview
        AssessmentWrapper assCustomerOverview = new AssessmentWrapper();
        assCustomerOverview.fieldName = 'Customer_Overview__c';
        assCustomerOverview.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Customer_Overview__c').getDescribe().getLabel();
        assCustomerOverview.tempAP.Assessment_Rating_Infomation_Display__c = (String) accountPlan.get('Customer_Overview__c');
        assCustomerOverview.tempAP.Customer_Overview_Rating__c = accountPlan.Customer_Overview_Rating__c;
        assCustomerOverview.tempAP.Customer_Overview_Weight__c = accountPlan.Customer_Overview_Weight__c;
        assCustomerOverview.tempAP.Customer_Overview_Score__c = accountPlan.Customer_Overview_Score__c;
        assCustomerOverview.tempAP.Customer_Overview_Rational_Explanation__c = accountPlan.Customer_Overview_Rational_Explanation__c;
        assessmentWrapperList.add(assCustomerOverview);
        // Financial Metrics
        AssessmentWrapper assFinancialMetrics = new AssessmentWrapper();
        assFinancialMetrics.fieldName = 'Financial_Metrics__c';     
        assFinancialMetrics.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Financial_Metrics__c').getDescribe().getLabel();
        assFinancialMetrics.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Financial_Metrics__c;
        assFinancialMetrics.tempAP.Financial_Metrics_Rating__c = accountPlan.Financial_Metrics_Rating__c;
        assFinancialMetrics.tempAP.Financial_Metrics_Weight__c = accountPlan.Financial_Metrics_Weight__c;
        assFinancialMetrics.tempAP.Financial_Metrics_Score__c = accountPlan.Financial_Metrics_Score__c;
        assFinancialMetrics.tempAP.Financial_Metrics_Rationale_Explanation__c = accountPlan.Financial_Metrics_Rationale_Explanation__c;  
        assessmentWrapperList.add(assFinancialMetrics);
        
        
        // Operational Metrics
        AssessmentWrapper assOperationaMetrics = new AssessmentWrapper();
        assOperationaMetrics.fieldName = 'Operational_Metrics__c';      
        assOperationaMetrics.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Operational_Metrics__c').getDescribe().getLabel();
        assOperationaMetrics.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Operational_Metrics__c;
        assOperationaMetrics.tempAP.Operational_Metrics_Rating__c = accountPlan.Operational_Metrics_Rating__c;
        assOperationaMetrics.tempAP.Operational_Metrics_Weight__c = accountPlan.Operational_Metrics_Weight__c;
        assOperationaMetrics.tempAP.Operational_Metrics_Score__c = accountPlan.Operational_Metrics_Score__c;
        assOperationaMetrics.tempAP.Operation_Metrics_Rationale_Explanation__c = accountPlan.Operation_Metrics_Rationale_Explanation__c;  
        assessmentWrapperList.add(assOperationaMetrics);
        
        if(accountRecordTypeId != resellerAPRTId){ // Reseller logic Mar2016
        	// Growth Metrics
	        AssessmentWrapper assGrowthMetrics = new AssessmentWrapper();
	        assGrowthMetrics.fieldName = 'Growth_Metrics__c';           
	        assGrowthMetrics.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Growth_Metrics__c').getDescribe().getLabel();
	        assGrowthMetrics.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Growth_Metrics__c;
	        assGrowthMetrics.tempAP.Growth_Metrics_Rating__c = accountPlan.Growth_Metrics_Rating__c;
	        assGrowthMetrics.tempAP.Growth_Metrics_Weight__c = accountPlan.Growth_Metrics_Weight__c;
	        assGrowthMetrics.tempAP.Growth_Metrics_Score__c = accountPlan.Growth_Metrics_Score__c;
	        assGrowthMetrics.tempAP.Growth_Metrics_Rationale_Explanation__c = accountPlan.Growth_Metrics_Rationale_Explanation__c;     
	        assessmentWrapperList.add(assGrowthMetrics);
        
        }
        
        if(accountRecordTypeId == resellerAPRTId){ // Reseller logic Mar2016
	        // Reseller Growth Metrics
	        AssessmentWrapper assGrowthMetrics = new AssessmentWrapper();
	        assGrowthMetrics.fieldName = 'Reseller_Growth__c';           
	        assGrowthMetrics.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Reseller_Growth__c').getDescribe().getLabel();
	        assGrowthMetrics.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Reseller_Growth__c;
	        assGrowthMetrics.tempAP.Reseller_Growth_Rating__c = accountPlan.Reseller_Growth_Rating__c;
	        assGrowthMetrics.tempAP.Reseller_Growth_Weight__c = accountPlan.Reseller_Growth_Weight__c;
	        assGrowthMetrics.tempAP.Reseller_Growth_Score__c = accountPlan.Reseller_Growth_Score__c;
	        assGrowthMetrics.tempAP.Reseller_Growth_Rationale_Explanation__c = accountPlan.Reseller_Growth_Rationale_Explanation__c;     
	        assessmentWrapperList.add(assGrowthMetrics);
        }
        
        // CVM Metrics
        AssessmentWrapper assCVMMetrics = new AssessmentWrapper();
        assCVMMetrics.fieldName = 'CVM_Metrics__c';           
        assCVMMetrics.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('CVM_Metrics__c').getDescribe().getLabel();
        assCVMMetrics.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.CVM_Metrics__c;
        assCVMMetrics.tempAP.CVM_Metrics_Rating__c = accountPlan.CVM_Metrics_Rating__c;
        assCVMMetrics.tempAP.CVM_Metrics_Weight__c = accountPlan.CVM_Metrics_Weight__c;
        assCVMMetrics.tempAP.CVM_Metrics_Score__c = accountPlan.CVM_Metrics_Score__c;
        assCVMMetrics.tempAP.CVM_Metrics_Rationale_Explanation__c = accountPlan.CVM_Metrics_Rationale_Explanation__c;        
        assessmentWrapperList.add(assCVMMetrics);
        
        if(accountRecordTypeId != resellerAPRTId){ // Reseller logic Mar2016
	        // Engagement Plan
	        AssessmentWrapper assEngagementPlan = new AssessmentWrapper();
	        assEngagementPlan.fieldName = 'Engagement_Plan__c';           
	        assEngagementPlan.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Engagement_Plan__c').getDescribe().getLabel();
	        assEngagementPlan.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Engagement_Plan__c;
	        assEngagementPlan.tempAP.Engagement_Plan_Rating__c = accountPlan.Engagement_Plan_Rating__c;
	        assEngagementPlan.tempAP.Engagement_Plan_Weight__c = accountPlan.Engagement_Plan_Weight__c;
	        assEngagementPlan.tempAP.Engagement_Plan_Score__c = accountPlan.Engagement_Plan_Score__c;
	        assEngagementPlan.tempAP.Engagement_Plan_Rationale_Explanation__c = accountPlan.Engagement_Plan_Rationale_Explanation__c;        
	        assessmentWrapperList.add(assEngagementPlan);
        }
        if(accountRecordTypeId != resellerAPRTId){ // Reseller logic Mar2016
	        // Competitors
	        AssessmentWrapper assCompetitors = new AssessmentWrapper();
	        assCompetitors.fieldName = 'Competitors__c';           
	        assCompetitors.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Competitors__c').getDescribe().getLabel();
	        assCompetitors.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Competitors__c;
	        assCompetitors.tempAP.Competitors_Rating__c = accountPlan.Competitors_Rating__c;
	        assCompetitors.tempAP.Competitors_Weight__c = accountPlan.Competitors_Weight__c;
	        assCompetitors.tempAP.Competitors_Score__c = accountPlan.Competitors_Score__c;
	        assCompetitors.tempAP.Competitors_Rationale_Explanation__c = accountPlan.Competitors_Rationale_Explanation__c;        
	        assessmentWrapperList.add(assCompetitors);
        }
        if(accountRecordTypeId != resellerAPRTId){ // Reseller logic Mar2016
	        // Needs vs Capability
	        AssessmentWrapper assNeeds = new AssessmentWrapper();
	        assNeeds.fieldName = 'Needs_vs_Capability__c';           
	        assNeeds.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Needs_vs_Capability__c').getDescribe().getLabel();
	        assNeeds.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Needs_vs_Capability__c;
	        assNeeds.tempAP.Needs_vs_Capability_Rating__c = accountPlan.Needs_vs_Capability_Rating__c;
	        assNeeds.tempAP.Needs_vs_Capability_Weight__c = accountPlan.Needs_vs_Capability_Weight__c;
	        assNeeds.tempAP.Needs_vs_Capability_Score__c = accountPlan.Needs_vs_Capability_Score__c;
	        assNeeds.tempAP.Needs_vs_CapabilityRationale_Explanatio__c = accountPlan.Needs_vs_CapabilityRationale_Explanatio__c;      
	        assessmentWrapperList.add(assNeeds);
        }
        
        if(accountRecordTypeId == resellerAPRTId){ // Reseller logic Mar2016
        	// ASSOCIATED CUSTOMERS
        	AssessmentWrapper assNeeds = new AssessmentWrapper();
	        assNeeds.fieldName = 'Associated_Customers__c';           
	        assNeeds.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Associated_Customers__c').getDescribe().getLabel();
	        assNeeds.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Associated_Customers__c;
	        assNeeds.tempAP.Associated_Customers_Rating__c = accountPlan.Associated_Customers_Rating__c;
	        assNeeds.tempAP.Associated_Customers_Weight__c = accountPlan.Associated_Customers_Weight__c;
	        assNeeds.tempAP.Associated_Customers_Score__c = accountPlan.Associated_Customers_Score__c;
	        assNeeds.tempAP.Associated_Cust_Rationale_Explanation__c = accountPlan.Associated_Cust_Rationale_Explanation__c;      
	        assessmentWrapperList.add(assNeeds);
        }
        
        if(accountRecordTypeId == resellerAPRTId){ // Reseller logic Mar2016
        	// ACTION PLAN
        	AssessmentWrapper assNeeds = new AssessmentWrapper();
	        assNeeds.fieldName = 'Action_Plan__c';           
	        assNeeds.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Action_Plan__c').getDescribe().getLabel();
	        assNeeds.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Action_Plan__c;
	        assNeeds.tempAP.Action_Plan_Rating__c = accountPlan.Action_Plan_Rating__c;
	        assNeeds.tempAP.Action_Plan_Weight__c = accountPlan.Action_Plan_Weight__c;
	        assNeeds.tempAP.Action_Plan_Score__c = accountPlan.Action_Plan_Score__c;
	        assNeeds.tempAP.Action_Plan_Rationale_Explanation__c = accountPlan.Action_Plan_Rationale_Explanation__c;      
	        assessmentWrapperList.add(assNeeds);
        }
        
        
        // SWOT
        AssessmentWrapper assSWOT = new AssessmentWrapper();    
        assSWOT.fieldName = 'SWOT__c';
         
        assSWOT.tempAP.Assessment_Row_Title__c = (accountPlan.Account_Name__r.RecordTypeId != resellerAPRTId) ?  // Reseller logic Mar2016
        	Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('SWOT__c').getDescribe().getLabel() : '8. SWOT'; 
        assSWOT.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.SWOT__c;
        assSWOT.tempAP.SWOT_Rating__c = accountPlan.SWOT_Rating__c;
        assSWOT.tempAP.SWOT_Weight__c = accountPlan.SWOT_Weight__c;
        assSWOT.tempAP.SWOT_Score__c = accountPlan.SWOT_Score__c;
        assSWOT.tempAP.SWOT_Rationale_Explanation__c = accountPlan.SWOT_Rationale_Explanation__c;       
        assessmentWrapperList.add(assSWOT);      
        // 5 Yr
        AssessmentWrapper ass5Yr = new AssessmentWrapper(); 
        ass5Yr.fieldName = 'X5yr_Strategy__c';           
        ass5Yr.tempAP.Assessment_Row_Title__c = (accountPlan.Account_Name__r.RecordTypeId != resellerAPRTId) ?  // Reseller logic Mar2016
        	Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('X5yr_Strategy__c').getDescribe().getLabel() : '9. 5yr Strategy';
        	
        ass5Yr.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.X5yr_Strategy__c;
        ass5Yr.tempAP.X5_yr_Strategy_Rating__c = accountPlan.X5_yr_Strategy_Rating__c;
        ass5Yr.tempAP.X5_yr_Strategy_Weight__c = accountPlan.X5_yr_Strategy_Weight__c;
        ass5Yr.tempAP.X5_yr_Strategy_Score__c = accountPlan.X5_yr_Strategy_Score__c;
        ass5Yr.tempAP.X5yr_Strategy_Rationale_Explanation__c = accountPlan.X5yr_Strategy_Rationale_Explanation__c;      
        assessmentWrapperList.add(ass5Yr);
        // Progress
        AssessmentWrapper assProgress = new AssessmentWrapper();    
        assProgress.fieldName = 'Progress_against_plan__c';           
        assProgress.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Progress_against_plan__c').getDescribe().getLabel();
        assProgress.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Progress_against_plan__c;
        assProgress.tempAP.Progress_against_plan_Rating__c = accountPlan.Progress_against_plan_Rating__c;
        assProgress.tempAP.Progress_against_plan_Weight__c = accountPlan.Progress_against_plan_Weight__c;
        assProgress.tempAP.Progress_against_plan_Score__c = accountPlan.Progress_against_plan_Score__c;
        assProgress.tempAP.Progress_against_plan_Rationale__c = accountPlan.Progress_against_plan_Rationale__c;      
        assessmentWrapperList.add(assProgress);
        // Account Plan
        AssessmentWrapper assAccountPlan = new AssessmentWrapper(); 
        assAccountPlan.fieldName = 'Account_Plan_Score_label__c';           
        assAccountPlan.tempAP.Assessment_Row_Title__c = Schema.getGlobalDescribe().get('Revised_Account_Plan__c').getDescribe().fields.getMap().get('Account_Plan_Score_label__c').getDescribe().getLabel();
        assAccountPlan.tempAP.Assessment_Rating_Infomation_Display__c = accountPlan.Account_Plan_Score_label__c;
        assAccountPlan.tempAP.Account_Plan_Score_Display__c = accountPlan.Account_Plan_Score__c;
        assAccountPlan.tempAP.Account_Plan_Score_Assessment_Display__c = accountPlan.Account_Plan_Score_Assessment__c;     
        assessmentWrapperList.add(assAccountPlan);
        return assessmentWrapperList;
        
    }
    //  Assessment Tab Methods
    public static Revised_Account_Plan__c saveAssessMent(Revised_Account_Plan__c accountPlan, List<AssessmentWrapper> assessmentWrapperList) {
        if(assessmentWrapperList.size() > 0){
            for(AssessmentWrapper assTemp : assessmentWrapperList){
                if(assTemp.fieldName == 'Customer_Overview__c') {
                    accountPlan.Customer_Overview_Rating__c = assTemp.tempAP.Customer_Overview_Rating__c;
                    accountPlan.Customer_Overview_Rational_Explanation__c = assTemp.tempAP.Customer_Overview_Rational_Explanation__c;
                }
                if(assTemp.fieldName == 'Financial_Metrics__c') {
                    accountPlan.Financial_Metrics_Rating__c = assTemp.tempAP.Financial_Metrics_Rating__c;
                    accountPlan.Financial_Metrics_Rationale_Explanation__c = assTemp.tempAP.Financial_Metrics_Rationale_Explanation__c;
                }
                if(assTemp.fieldName == 'Operational_Metrics__c') {
                    accountPlan.Operational_Metrics_Rating__c = assTemp.tempAP.Operational_Metrics_Rating__c;
                    accountPlan.Operation_Metrics_Rationale_Explanation__c = assTemp.tempAP.Operation_Metrics_Rationale_Explanation__c;
                }
                if(assTemp.fieldName == 'Growth_Metrics__c') {
                    accountPlan.Growth_Metrics_Rating__c = assTemp.tempAP.Growth_Metrics_Rating__c;
                    accountPlan.Growth_Metrics_Rationale_Explanation__c = assTemp.tempAP.Growth_Metrics_Rationale_Explanation__c;
                }
                
				if(assTemp.fieldName == 'Reseller_Growth__c') {
                    accountPlan.Reseller_Growth_Rating__c = assTemp.tempAP.Reseller_Growth_Rating__c;
                    accountPlan.Reseller_Growth_Rationale_Explanation__c = assTemp.tempAP.Reseller_Growth_Rationale_Explanation__c;
                }
                if(assTemp.fieldName == 'CVM_Metrics__c') {
                    accountPlan.CVM_Metrics_Rating__c = assTemp.tempAP.CVM_Metrics_Rating__c;
                    accountPlan.CVM_Metrics_Rationale_Explanation__c = assTemp.tempAP.CVM_Metrics_Rationale_Explanation__c;
                }
                
                if(assTemp.fieldName == 'Engagement_Plan__c') {
                    accountPlan.Engagement_Plan_Rating__c = assTemp.tempAP.Engagement_Plan_Rating__c;
                    accountPlan.Engagement_Plan_Rationale_Explanation__c = assTemp.tempAP.Engagement_Plan_Rationale_Explanation__c;        
                    
                }
                if(assTemp.fieldName == 'Competitors__c') {
                    accountPlan.Competitors_Rating__c = assTemp.tempAP.Competitors_Rating__c;
                    accountPlan.Competitors_Rationale_Explanation__c = assTemp.tempAP.Competitors_Rationale_Explanation__c;  
                }
                if(assTemp.fieldName == 'Needs_vs_Capability__c') {
                    accountPlan.Needs_vs_Capability_Rating__c = assTemp.tempAP.Needs_vs_Capability_Rating__c;
                    accountPlan.Needs_vs_CapabilityRationale_Explanatio__c = assTemp.tempAP.Needs_vs_CapabilityRationale_Explanatio__c; 
                }
                
                if(assTemp.fieldName == 'Associated_Customers__c'){
                	accountPlan.Associated_Customers_Rating__c = assTemp.tempAP.Associated_Customers_Rating__c;
                    accountPlan.Associated_Cust_Rationale_Explanation__c = assTemp.tempAP.Associated_Cust_Rationale_Explanation__c;
                }
                
                if(assTemp.fieldName == 'Action_Plan__c'){
                	accountPlan.Action_Plan_Rating__c = assTemp.tempAP.Action_Plan_Rating__c;
                    accountPlan.Action_Plan_Rationale_Explanation__c = assTemp.tempAP.Action_Plan_Rationale_Explanation__c;
                }
                
                if(assTemp.fieldName == 'SWOT__c') {
                    accountPlan.SWOT_Rating__c = assTemp.tempAP.SWOT_Rating__c;
                    accountPlan.SWOT_Rationale_Explanation__c = assTemp.tempAP.SWOT_Rationale_Explanation__c;   
                }
                if(assTemp.fieldName == 'X5yr_Strategy__c') {
                    accountPlan.X5_yr_Strategy_Rating__c = assTemp.tempAP.X5_yr_Strategy_Rating__c;
                    accountPlan.X5yr_Strategy_Rationale_Explanation__c = assTemp.tempAP.X5yr_Strategy_Rationale_Explanation__c;  
                }
                if(assTemp.fieldName == 'Progress_against_plan__c') {                   
                    accountPlan.Progress_against_plan_Rating__c = assTemp.tempAP.Progress_against_plan_Rating__c;
                    accountPlan.Progress_against_plan_Rationale__c = assTemp.tempAP.Progress_against_plan_Rationale__c; 
                }
                if(assTemp.fieldName == 'Account_Plan_Score_label__c') {                   
                    accountPlan.Account_Plan_Score_Assessment_Display__c = assTemp.tempAP.Account_Plan_Score_Assessment__c;  
                }
            }
        }
        return accountPlan;
    }
    //  Assessment Wrapper  
    public class AssessmentWrapper {
        public Revised_Account_Plan__c tempAP {get;set;}
        public string fieldName {get;set;}
        public AssessmentWrapper() {
            tempAP = new Revised_Account_Plan__c();
        }
    }
    // Engagement Wrapper
    public class EngagementPlanWrapper {
        public List<String> departments {get{   
            List<String> listReturnString = new List<String>();             
            Schema.sObjectType objType = Engagement_Plan__c.getSObjectType();
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();      
            map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();            
            for(Schema.PicklistEntry ple:fieldMap.get('Customer_Department__c').getDescribe().getPickListValues()) {
                listReturnString.add(ple.getValue());
            }
            return listReturnString;
            }set;}
        public String strDepartmentName {get;set;}
        public List<EPInnerWrapper> listEPInnerWrapper {get;set;}
        public EngagementPlanWrapper() {
            strDepartmentName = '';
            listEPInnerWrapper = new List<EPInnerWrapper>();
        }
        // Default Engagement Plan Wrapper
        public List<EngagementPlanWrapper> defaultEngagementPlanWrapper(Revised_Account_Plan__c accountPlan) {
            List<EngagementPlanWrapper> listWrapper = new List<EngagementPlanWrapper>();
            for(String s:this.departments) {
                EngagementPlanWrapper wrapper = new EngagementPlanWrapper();
                wrapper.strDepartmentName = s;
                listWrapper.add(wrapper);
            }
            Integer i = 0;
            for(EngagementPlanWrapper w:listWrapper) {
                List<EPInnerWrapper> listInnerW = new List<EPInnerWrapper>();
                EPInnerWrapper innerW = new EPInnerWrapper();
                innerW.strDepartmentName = w.strDepartmentName;
                innerW.engagementPlan = new Engagement_Plan__c(Account_Plan__c = accountPlan.Id, Display_Order__c = i, Customer_Department__c = w.strDepartmentName); 
                listInnerW.add(innerW);  
                i++;
                w.listEPInnerWrapper = listInnerW;
            }
            return listWrapper;         
        } 
        // Populate Engagement Plan Wrapper based on existing Engagement Plans      
        public List<EngagementPlanWrapper> populateEngagementPlanWrapper(Revised_Account_Plan__c accountPlan, List<Engagement_Plan__c> listEngagementPlans) {
            List<EngagementPlanWrapper> listWrapper = new List<EngagementPlanWrapper>();
            for(String s:this.departments) {
                EngagementPlanWrapper wrapper = new EngagementPlanWrapper();
                wrapper.strDepartmentName = s;
                listWrapper.add(wrapper);
            }
            Integer i = 0;
            for(EngagementPlanWrapper w:listWrapper) {
                List<EPInnerWrapper> listInnerW = new List<EPInnerWrapper>();           
                for(Engagement_Plan__c e:listEngagementPlans) {             
                    if(w.strDepartmentName == e.Customer_Department__c) {
                        EPInnerWrapper innerW = new EPInnerWrapper();
                        e.Display_Order__c = i;
                        innerW.strDepartmentName = w.strDepartmentName;
                        innerW.engagementPlan = e;
                        listInnerW.add(innerW);
                        i++;
                    } 
                }                   
                w.listEPInnerWrapper = listInnerW;
                if(w.listEPInnerWrapper.size() == 0) {                  
                    EPInnerWrapper innerW = new EPInnerWrapper();
                    innerW.strDepartmentName = w.strDepartmentName;
                    innerW.engagementPlan = new Engagement_Plan__c(Account_Plan__c = accountPlan.Id, Display_Order__c = i, Customer_Department__c = w.strDepartmentName);                   
                    listInnerW.add(innerW);             
                } 
                i++;
                w.listEPInnerWrapper = listInnerW;                  
            }
        
            return listWrapper;
        }
        // Retrieve engagement Plan records
        public List<Engagement_Plan__c> retrieveEngagementPlans(List<EngagementPlanWrapper> listWrappers) {
            List<Engagement_Plan__c> listReturnEngagementPlans = new List<Engagement_Plan__c>();
            for(EngagementPlanWrapper w:listWrappers) {
                for(EPInnerWrapper i:w.listEPInnerWrapper) {
                    listReturnEngagementPlans.add(i.engagementPlan.clone());
                }
            }
            return listReturnEngagementPlans;
        }
    }
    // Inner wrapper class for Engagement Plan wrapper
    public class EPInnerWrapper {
        public Boolean bSelected {get;set;}
        public String strDepartmentName {get;set;}
        public Engagement_Plan__c engagementPlan {get;set;}
        public String strMessage {get;set;}
        public EPInnerWrapper() {
            bSelected = false;
            strDepartmentName = '';
            engagementPlan = new Engagement_Plan__c();
            strMessage = '';
        }
    }
    
    //Account Plan Needs and Capabilities Create
    public static void createNeedsCapabilities(Revised_Account_Plan__c accountPlan) {
        List<Needs_vs_Capability__c> needs = new List<Needs_vs_Capability__c>();
        if(accountPlan.Detailed_Needs_1__c != null || accountPlan.Potential_Opportunity_1__c != null || accountPlan.Fonterra_s_Strength_1__c != null) {
            Needs_vs_Capability__c need = new Needs_vs_Capability__c(Ranking__c = 1.00, Account_Plan__c = accountPlan.Id);
            need.Customer_Need__c = accountPlan.Customer_Need_1__c;
            need.Detailed_Needs__c = accountPlan.Detailed_Needs_1__c;
            need.Potential_Opportunity__c = accountPlan.Potential_Opportunity_1__c;
            need.Fonterra_s_Strength__c = accountPlan.Fonterra_s_Strength_1__c;
            needs.add(need);
        }
        if(accountPlan.Detailed_Needs_2__c != null || accountPlan.Potential_Opportunity_2__c != null || accountPlan.Fonterra_s_Strength_2__c != null) {
            Needs_vs_Capability__c need = new Needs_vs_Capability__c(Ranking__c = 2.00, Account_Plan__c = accountPlan.Id);
          need.Customer_Need__c = accountPlan.Customer_Need_2__c;
            need.Detailed_Needs__c = accountPlan.Detailed_Needs_2__c;
            need.Potential_Opportunity__c = accountPlan.Potential_Opportunity_2__c;
            need.Fonterra_s_Strength__c = accountPlan.Fonterra_s_Strength_2__c;
            needs.add(need);
        }   
        if(accountPlan.Detailed_Needs_3__c != null || accountPlan.Potential_Opportunity_3__c != null || accountPlan.Fonterra_s_Strength_3__c != null) {
            Needs_vs_Capability__c need = new Needs_vs_Capability__c(Ranking__c = 3.00, Account_Plan__c = accountPlan.Id);
            need.Customer_Need__c = accountPlan.Customer_Need_3__c;
            need.Detailed_Needs__c = accountPlan.Detailed_Needs_3__c;
            need.Potential_Opportunity__c = accountPlan.Potential_Opportunity_3__c;
            need.Fonterra_s_Strength__c = accountPlan.Fonterra_s_Strength_3__c;
            needs.add(need);
        }   
        if(accountPlan.Detailed_Needs_4__c != null || accountPlan.Potential_Opportunity_4__c != null || accountPlan.Fonterra_s_Strength_4__c != null) {
            Needs_vs_Capability__c need = new Needs_vs_Capability__c(Ranking__c = 4.00, Account_Plan__c = accountPlan.Id);
            need.Customer_Need__c = accountPlan.Customer_Need_4__c;
            need.Detailed_Needs__c = accountPlan.Detailed_Needs_4__c;
            need.Potential_Opportunity__c = accountPlan.Potential_Opportunity_4__c;
            need.Fonterra_s_Strength__c = accountPlan.Fonterra_s_Strength_4__c;
            needs.add(need);
        }   
        if(accountPlan.Detailed_Needs_5__c != null || accountPlan.Potential_Opportunity_5__c != null || accountPlan.Fonterra_s_Strength_5__c != null) {
            Needs_vs_Capability__c need = new Needs_vs_Capability__c(Ranking__c = 5.00, Account_Plan__c = accountPlan.Id);
            need.Customer_Need__c = accountPlan.Customer_Need_5__c;
            need.Detailed_Needs__c = accountPlan.Detailed_Needs_5__c;
            need.Potential_Opportunity__c = accountPlan.Potential_Opportunity_5__c;
            need.Fonterra_s_Strength__c = accountPlan.Fonterra_s_Strength_5__c;
            needs.add(need);
        }   
        if(needs.size()>0)
            Database.insert(needs);                                                                         
    }    
}