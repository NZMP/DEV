public with sharing class ExchangeRateController {
    
    //public static Boolean isApexTest = false;
    
    @AuraEnabled
    public static List<Exchange_Currencies__c> allCurrencies() {
        //Returning Companies with Symbol and StockExchange
        return [SELECT Name,From_Currency__c,Exchange_Pair_Code__c FROM Exchange_Currencies__c];
    }
    
    //Returning Stock Data
    @AuraEnabled
    public static String getExchangeData(String currPairCode){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        //req.setEndpoint('https://query.yahooapis.com/v1/public/yql?q=select%20Symbol%2CName%2CDaysLow%2CDaysHigh%2CYearLow%20%2CYearHigh%2CLastTradePriceOnly%2CLastTradeDate%2CLastTradeTime%2CMarketCapitalization%20%2CChange_PercentChange%20%20from%20yahoo.finance.quotes%20where%20symbol%20%20%3D%20%22'+symbol+'%22%09&format=json&diagnostics=true&%20env=http%3A%2F%2Fdatatables.org%20%2Falltables.env%22%3Ehttps://query.yahooapis.com/v1/public/yql?q=select%20Symbol%2CName%20%2CDaysLow%2CDaysHigh%2CYearLow%2CYearHigh%2CLastTradePriceOnly%20%2CLastTradeDate%2CLastTradeTime%20%2CMarketCapitalization%2CChange%20_PercentChange%20from%20yahoo.finance.quotes%20%20where%20symbol%20%3D%20%22'+symbol+'%22%09&format=json&diagnostics=true%20&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys');
        //req.setEndpoint('https://query.yahooapis.com/v1/public/yql?q=select%20Symbol%2CName%2CDaysLow%2CDaysHigh%2CYearLow%20%2CYearHigh%2CLastTradePriceOnly%2CLastTradeDate%2CLastTradeTime%2CMarketCapitalization%20%2CChange_PercentChange%20%20from%20yahoo.finance.quotes%20where%20symbol%20%20%3D%20%22'+symbol+'%22%09&format=json&diagnostics=true&%20env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys');
        req.setEndpoint('https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20%3D%20%22'+currPairCode+'%22&format=json&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys');
        req.setMethod('GET');
        
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            system.debug(res.getBody());
            return res.getBody();
        }else{
            String stockjson = '{'+
                               ' "query": {'+
                                    '"results": {'+
                                        '"quote": {'+
                                            '"Change_PercentChange": +0.04 - +0.08%,'+
                                            '"LastTradeDate": 3:59pm,'+
                                            '"DaysLow":89,'+
                                            '"DaysHigh": 90,'+
                                            '"YearLow": 77,'+
                                            '"YearHigh": 89,'+
                                            '"MarketCapitalization": 90B,'+
                                            '"LastTradePriceOnly": 90,'+
                                            '"Name": Salesforce,'+
                                            '"Symbol": "CRM",'+
                                            '"LastTradeTime": 8/5/2015'+
                                        '}'+
                                    '}'+
                                '}'+
                            '}';
                            
            return stockjson;                        
        }
        
    } 

}