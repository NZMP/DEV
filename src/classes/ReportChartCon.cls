public class ReportChartCon {
	public list<AggregateResult> aggregateInvoicedVolumeList{get;set;}
	public list<AggregateResult> totalInvoicedVolumeList{get;set;}
	public list<Key_Metrics__c> keyMetricsList{get;set;}
	public integer sumOfInvoicedVolume {get;set;}
	public integer sumOfInvoicedVolumeMapTotalValue {get;set;}
	public integer sumOfPriceAchievement {get;set;}
	public integer sumOfPriceAchievementMapTotalValue {get;set;}
	public map<String,Integer> sumInvoicedVolumeMap {get;set;}	
	public map<String,Integer> sumPriceAchievementMap {get;set;}
	public String accountName {get;set;}
	public Date keyMetricslastUpdateDate {get;set;}
	public String volumeTargetVsActual {get;set;}
	public String paTargetVsActual {get;set;}
	public String volumeByFY {get;set;}
	public String paByFY {get;set;}
	
	public  List<sortWrapperForPriceAchievement> stWrapperListForPriceAchievement {get;set;}
	public  List<sortWrapperForInvoicedVolume> stWrapperListForInvoicedVolume {get;set;}
	
	public ReportChartCon(ApexPages.StandardController controller){
		// Financial year logic
		date currentFinancialYearStartDate = null;
		date currentFinancialYearEndDate = null;
		integer currentYear = system.today().year();
		integer previousYear = currentYear-1;
		integer currentMonth = system.today().month();		
		Integer FiscalYearStartMonth = [select FiscalYearStartMonth from Organization where id=:Userinfo.getOrganizationId()].FiscalYearStartMonth;// returns 8
		
		// Calculate Start & End Dates
		if(currentMonth < FiscalYearStartMonth){
			currentFinancialYearStartDate = date.newInstance(previousYear, FiscalYearStartMonth,01);
			currentFinancialYearEndDate = currentFinancialYearStartDate.addYears(1);
			currentFinancialYearEndDate = currentFinancialYearEndDate.addDays(-1);
		}else{
			currentFinancialYearStartDate = date.newInstance(currentYear, FiscalYearStartMonth,01); 
			currentFinancialYearEndDate = currentFinancialYearStartDate.addYears(1);
			currentFinancialYearEndDate = currentFinancialYearEndDate.addDays(-1);	
		}
		// Financial year logic ends	
			
		if(sumOfInvoicedVolume == null)
			sumOfInvoicedVolume = 0;
		if(sumOfPriceAchievement == null)
			sumOfPriceAchievement = 0;
		if(sumInvoicedVolumeMap == null)
			sumInvoicedVolumeMap = new Map<String,Integer>();
		if(sumPriceAchievementMap == null)
			sumPriceAchievementMap = new Map<String,Integer>();
		if(sumOfInvoicedVolumeMapTotalValue == null)
			sumOfInvoicedVolumeMapTotalValue = 0; 
		if(sumOfPriceAchievementMapTotalValue == null)
			sumOfPriceAchievementMapTotalValue = 0;   
		
		String accountID = ApexPages.currentPage().getParameters().get('id');
		String financialYearDisplay = null;
		
		Account acc = [select Id, Name,Key_Metrics_Last_Update__c from Account where id= :accountID];
		accountName=acc.Name;
		keyMetricslastUpdateDate = Date.valueOf(acc.Key_Metrics_Last_Update__c);
		// gets the sum of invoiced volume and sum of price achievments grouped by commodity for the current FY
		aggregateInvoicedVolumeList = [select SUM(Invoiced_Volume__c) sumOfInvoicedVolume,SUM(Price_Achievement__c) sumOfPriceAchievement,Material__r.Commodity_Group_Description__c commodityGroup from Key_Metrics__c where Sold_to_party__c= :accountID and FY_Date__c >= :currentFinancialYearStartDate and FY_Date__c <= :currentFinancialYearEndDate group by Material__r.Commodity_Group_Description__c order by SUM(Invoiced_Volume__c) desc];		
		
		// display total Invoiced volume and price achievements grouped by commodity for the current FY 
		//Also creates a map which stores the total invoiced volume and price achievement for the current FY(FY2013) - this is for 3Yrs Trend dashboard component
		for(AggregateResult agg :aggregateInvoicedVolumeList){
			if(agg.get('sumOfInvoicedVolume') != null){
				sumOfInvoicedVolume +=  Integer.valueof(agg.get('sumOfInvoicedVolume'));
			}
			if(agg.get('sumOfPriceAchievement') != null){
				sumOfPriceAchievement += Integer.valueof(agg.get('sumOfPriceAchievement'));				
			}
		}
		financialYearDisplay = 'FY'+string.valueOf(currentFinancialYearStartDate.year());
		sumInvoicedVolumeMap.put(financialYearDisplay,sumOfInvoicedVolume);
		sumOfInvoicedVolumeMapTotalValue +=sumOfInvoicedVolume;
		sumPriceAchievementMap.put(financialYearDisplay,sumOfPriceAchievement);
		sumOfPriceAchievementMapTotalValue += sumOfPriceAchievement;
		
		//calculate the total Invoiced volume and price achievements for previous - this is for 3Yrs Trend dashboard component
		keyMetricsList= [select Id,Invoiced_Volume__c,Price_Achievement__c,FY_Date__c from Key_Metrics__c where Sold_to_party__c= :accountID];
		system.debug('### keyMetricsList:' +keyMetricsList);
		Integer invoicedVolumeSumFY1 = 0;
		Integer invoicedVolumeSumFY2 = 0;
		Integer priceAchievementSumFY1 = 0;
		Integer priceAchievementSumFY2 = 0;
		for(Key_Metrics__c keyMtList : keyMetricsList){		
			// last year	
			if(keyMtList.FY_Date__c >= currentFinancialYearStartDate.addYears(-1) && keyMtList.FY_Date__c <= currentFinancialYearEndDate.addYears(-1)){
				financialYearDisplay = 'FY'+string.valueOf(currentFinancialYearStartDate.addYears(-1).year());
				if(keyMtList.Invoiced_Volume__c != null){
					invoicedVolumeSumFY1 += Integer.valueof(keyMtList.Invoiced_Volume__c);
					sumInvoicedVolumeMap.put(financialYearDisplay,invoicedVolumeSumFY1);
					sumOfInvoicedVolumeMapTotalValue +=Integer.valueof(keyMtList.Invoiced_Volume__c);
				}
				if(keyMtList.Price_Achievement__c !=null){
					priceAchievementSumFY1 += Integer.valueof(keyMtList.Price_Achievement__c);
					sumPriceAchievementMap.put(financialYearDisplay,priceAchievementSumFY1);
					sumOfPriceAchievementMapTotalValue += Integer.valueof(keyMtList.Price_Achievement__c);
				}
			}
			//last before year
			else if(keyMtList.FY_Date__c >= currentFinancialYearStartDate.addYears(-2) && keyMtList.FY_Date__c <= currentFinancialYearEndDate.addYears(-2)){
				financialYearDisplay = 'FY'+string.valueOf(currentFinancialYearStartDate.addYears(-2).year());
				if(keyMtList.Invoiced_Volume__c != null){
					invoicedVolumeSumFY2 += Integer.valueof(keyMtList.Invoiced_Volume__c);
					sumInvoicedVolumeMap.put(financialYearDisplay,invoicedVolumeSumFY2);
					sumOfInvoicedVolumeMapTotalValue +=Integer.valueof(keyMtList.Invoiced_Volume__c);
				}
				if(keyMtList.Price_Achievement__c != null){
					priceAchievementSumFY2 += Integer.valueof(keyMtList.Price_Achievement__c);
					sumPriceAchievementMap.put(financialYearDisplay,priceAchievementSumFY2);
					sumOfPriceAchievementMapTotalValue += Integer.valueof(keyMtList.Price_Achievement__c);
				}
			}
		}
		sortAggPriceAchievementList();
		sortAggInvoicedVolumeList();
	}

	public pageReference invoicedVolumeReportpage() {
		system.debug('### report1 = ' + volumeTargetVsActual);
        Pagereference pageRef = new PageReference('/'+ volumeTargetVsActual +'?drilldown=1&drillcol=ACCOUNT_ID&drillval='+ApexPages.currentPage().getParameters().get('id')+'&drillop=equals');
        pageRef.setRedirect(true);
        return pageRef;
	}
	public pageReference priceAchievementReportpage() {
        Pagereference pageRef = new PageReference('/'+paTargetVsActual+'?drilldown=1&drillcol=ACCOUNT_ID&drillval='+ApexPages.currentPage().getParameters().get('id')+'&drillop=equals');
        pageRef.setRedirect(true);
        return pageRef;
	}
	public pageReference invoicedVolume3YrsReportpage() {
        Pagereference pageRef = new PageReference('/'+volumeByFY+'?drilldown=1&drillcol=ACCOUNT_ID&drillval='+ApexPages.currentPage().getParameters().get('id')+'&drillop=equals');
        pageRef.setRedirect(true);
        return pageRef;
	}
	public pageReference priceAchievement3YrsReportpage() {
        Pagereference pageRef = new PageReference('/'+paByFY+'?drilldown=1&drillcol=ACCOUNT_ID&drillval='+ApexPages.currentPage().getParameters().get('id')+'&drillop=equals');
        pageRef.setRedirect(true);
        return pageRef;
	}	
	//to sort the sum of price achievement values in desc 
	public List<sortWrapperForPriceAchievement> sortAggPriceAchievementList() {
	  	if(stWrapperListForPriceAchievement == null)
	  		stWrapperListForPriceAchievement = new List<sortWrapperForPriceAchievement>();
	  	if(aggregateInvoicedVolumeList != null && aggregateInvoicedVolumeList.size()>0){
	  		for(AggregateResult agg : aggregateInvoicedVolumeList){
	  	 		sortWrapperForPriceAchievement stWrapper = new sortWrapperForPriceAchievement(Integer.ValueOf(agg.get('sumOfInvoicedVolume')),Integer.ValueOf(agg.get('sumOfPriceAchievement')),String.valueOf(agg.get('commodityGroup')));
	  	 		stWrapperListForPriceAchievement.add(stWrapper);
	  	 	}	  	 	
	  	 }
	  	 stWrapperListForPriceAchievement.sort();
	  	 return stWrapperListForPriceAchievement;
	}
	//to sort the sum of invoiced volume values in desc
	public List<sortWrapperForInvoicedVolume> sortAggInvoicedVolumeList() {
	  	if(stWrapperListForInvoicedVolume == null)
	  		stWrapperListForInvoicedVolume = new List<sortWrapperForInvoicedVolume>();
	  	if(aggregateInvoicedVolumeList != null && aggregateInvoicedVolumeList.size()>0){
	  		for(AggregateResult agg : aggregateInvoicedVolumeList){
	  	 		sortWrapperForInvoicedVolume stWrapperForVolume = new sortWrapperForInvoicedVolume(Integer.ValueOf(agg.get('sumOfInvoicedVolume')),Integer.ValueOf(agg.get('sumOfPriceAchievement')),String.valueOf(agg.get('commodityGroup')));
	  	 		stWrapperListForInvoicedVolume.add(stWrapperForVolume);
	  	 	}	  	 	
	  	 }
	  	 stWrapperListForInvoicedVolume.sort();
	  	 return stWrapperListForInvoicedVolume;
	}
	//wrapper class to sort price achievement values in desc
	public class sortWrapperForPriceAchievement implements Comparable {
		public Integer sumOfInvoicedVolumeSort {get;set;}
	    public Integer sumOfPriceAchievementSort {get;set;}
	    public String commodityGroupSort {get;set;}
		public sortWrapperForPriceAchievement(Integer i, Integer j, String s) {
	        sumOfInvoicedVolumeSort = i;
	        if(j!= null)
	        	sumOfPriceAchievementSort =j;
	        else
	        	sumOfPriceAchievementSort =0;
	        commodityGroupSort = s;
	    }
	    public Integer compareTo(Object compareTo) {
	        sortWrapperForPriceAchievement compareToEmp = (sortWrapperForPriceAchievement)compareTo;
	        if (sumOfPriceAchievementSort == compareToEmp.sumOfPriceAchievementSort) return 0;
	        if (sumOfPriceAchievementSort < compareToEmp.sumOfPriceAchievementSort) return 1;
	        return -1;        
	    }
	} 
	//wrapper class to sort the invoiced volume values in desc
	public class sortWrapperForInvoicedVolume implements Comparable {
		public Integer sumOfInvoicedVolumeSort {get;set;}
	    public Integer sumOfPriceAchievementSort {get;set;}
	    public String commodityGroupSort {get;set;}
		public sortWrapperForInvoicedVolume(Integer i, Integer j, String s) {
	        sumOfInvoicedVolumeSort = i;
	        sumOfPriceAchievementSort =j;
	        commodityGroupSort = s;
	    }
	    public Integer compareTo(Object compareTo) {
	        sortWrapperForInvoicedVolume compareToEmp = (sortWrapperForInvoicedVolume)compareTo;
	        if (sumOfInvoicedVolumeSort == compareToEmp.sumOfInvoicedVolumeSort) return 0;
	        if (sumOfInvoicedVolumeSort < compareToEmp.sumOfInvoicedVolumeSort) return 1;
	        return -1;        
	    }
	}
}