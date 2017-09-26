global class CartRefresh
{


   global class QuoteParams{
   @InvocableVariable(
               Label='QuoteID'
               Description='Quote ID'
               Required=True)
    global String QuoteID;
    @InvocableVariable(
               Label='ActiveRelease'
               Description='Active release to clone'
               Required=True)
    global String activeRelease;
}
 @InvocableMethod
  public static void CartRefresh(list<QuoteParams> quoteParams){ 
  for(QuoteParams quote : quoteParams){
      system.debug(quote.quoteID);
      system.debug(quote.activeRelease);
    asyncCartRefresh(quote.quoteID,quote.activeRelease);
    }
}

@future (callout=true)
    public static void asyncCartRefresh(string quoteId, string activerelease) 
    {
    
        if(!Test.isRunningTest()) final String[] CPQResult = CameleonCPQ.CPQRequestFormatter.executeCPQAction(quoteId, activerelease, 'openReleaseStateless', 'RefreshQuote','');
    }  
}