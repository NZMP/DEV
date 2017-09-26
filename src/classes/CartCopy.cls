global class CartCopy
{


   global class QuoteParams{
   
    @InvocableVariable(
               Label='OriginalID'
               Description='Original Quote ID'
               Required=True)
    global String quoteID;
   @InvocableVariable(
               Label='NewID'
               Description='New Quote ID'
               Required=True)
    global String cloneID;
    @InvocableVariable(
               Label='ActiveRelease'
               Description='Active release to clone'
               Required=True)
    global String activeRelease;
}
 @InvocableMethod
  public static void CartCopy(list<QuoteParams> quoteParams){ 
  for(QuoteParams quote : quoteParams){
      system.debug(quote.quoteID);
      system.debug(quote.cloneID);
      system.debug(quote.activeRelease);
    asyncCopyCartRelease(quote.quoteID,quote.cloneID,quote.activeRelease);
    }
}

@future (callout=true)
    public static void asyncCopyCartRelease(string quoteId, string cloneId, string activerelease) 
    {
        String sessionId2 = UserInfo.getSessionId();
        System.debug(LoggingLevel.INFO, 'Session id in CartCopy: ' + sessionId2);
        if(!Test.isRunningTest()) final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.sendCPQRequest(quoteId, cloneId, activerelease,'copyCartRelease','');
        
        CameleonCPQ__CAMCPQSettings__c CPQSettings = CameleonCPQ__CAMCPQSettings__c.getInstance();
        System.debug('Checking refresh for clone = ' + cloneId);    
        if(CPQSettings!=null && CPQSettings.CameleonCPQ__RefreshOnClone__c && CPQSettings.CameleonCPQ__CPQSession_RefreshAction__c!=null) {
           try {
                CameleonCPQ.CPQRequestFormatter.refreshQuoteContent(cloneId);
                System.debug('Refreshed quote = ' + cloneId);
           }
           catch (CameleonCPQ.CPQRequestFormatter.CPQRequestException e) {
                 // new PageReference((Site.getPathPrefix()!=null?Site.getPathPrefix():'')+Page.CPQErrorPage.getURL()+'?id='+cloneId+'&msgType=2&errMsg='+EncodingUtil.urlEncode(e.getMessage(),'UTF-8'));
                 system.debug('error refreshing ' + cloneId);
                 }
        }
    }  
}