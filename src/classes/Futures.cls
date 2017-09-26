global class Futures implements schedulable{
    // @author JS @ Davanti Consulting 08/2016

    // Controller and hourly scheduller to retrieve futures pricing from
    // NZX website via yahoo parser
    // Yahoo parser scrapes 4 pages and concatinates them
    // result is then stored in platform cache as a json string

    // YQL query:
    /*
  	select td.content from yql.query.multi where queries="
		select * from html where url='http://www.nzxfutures.com/dairy/quotes/mkp?locale=en' 
			and xpath='//table/tbody/tr/td[count(//table/thead/tr/th[.=\\'Prior Settle\\']/preceding-sibling::th)+1]' limit 2;
		select * from html where url='http://www.nzxfutures.com/dairy/quotes/btr?locale=en' 
			and xpath='//table/tbody/tr/td[count(//table/thead/tr/th[.=\\'Prior Settle\\']/preceding-sibling::th)+1]' limit 2;
		select * from html where url='http://www.nzxfutures.com/dairy/quotes/smp?locale=en' 
			and xpath='//table/tbody/tr/td[count(//table/thead/tr/th[.=\\'Prior Settle\\']/preceding-sibling::th)+1]' limit 2;
		select * from html where url='http://www.nzxfutures.com/dairy/quotes/wmp?locale=en' 
			and xpath='//table/tbody/tr/td[count(//table/thead/tr/th[.=\\'Prior Settle\\']/preceding-sibling::th)+1]' limit 2" 
	
	Parser retrieves td.content from four pages;
		Parser looks for table column where header is Prior Settle, retrieve first two.
	*/

    public void execute (SchedulableContext sc) {
		setFutures();
    }
    
    @AuraEnabled public static string getFutures(){
        return (string)Cache.Org.get('local.Futures.values');
    }
    @future(callout=true) public static void setFutures(){
		//string url = 'https://query.yahooapis.com/v1/public/yql?q=select%20td.content%20from%20yql.query.multi%20where%20queries%3D%22select%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fmkp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fbtr%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fsmp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fwmp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Famf%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';
		string url = 'https://query.yahooapis.com/v1/public/yql?q=select%20td.content%20from%20yql.query.multi%20where%20queries%3D%22select%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fmkp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D|%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Last%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fbtr%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D|%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Last%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fsmp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D|%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Last%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Fwmp%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D|%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Last%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%3Bselect%20*%20from%20html%20where%20url%3D\'http%3A%2F%2Fwww.nzxfutures.com%2Fdairy%2Fquotes%2Famf%3Flocale%3Den\'%20and%20xpath%3D\'%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Prior%20Settle%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D|%2F%2Ftable%2Ftbody%2Ftr%2Ftd%5Bcount(%2F%2Ftable%2Fthead%2Ftr%2Fth%5B.%3D%5C%5C\'Last%5C%5C\'%5D%2Fpreceding-sibling%3A%3Ath)%2B1%5D\'%20limit%202%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys';
        // defines which tickers to call
		string results = getCalloutResponseContents(url);
        
        // sometimes results are incomplete, hence only caching valid response
        if ( results != null ){
            Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(results);
            if ( resultsMap != null ){
                resultsMap = (Map<String, Object>)resultsMap.get('query');
                if ( resultsMap != null && (integer)resultsMap.get('count') == 10 )
                    Cache.Org.Put('local.Futures.values', results);
            }
        }
	        
    

    }
  
    static String getCalloutResponseContents(String url) {
        // Instantiate a new http object
        Http h = new Http();
        
        // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        
        // Send the request, and return a response
        HttpResponse res = h.send(req);
        return res.getBody();
    }
   
}