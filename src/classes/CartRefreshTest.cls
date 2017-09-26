@isTest 
public class CartRefreshTest{
@isTest 
    public static void testCartRefresh() {
        Test.StartTest();
       
        CartRefresh cart = new CartRefresh();
        CartRefresh.QuoteParams param= new CartRefresh.QuoteParams();
    
       //create test quote records
       CameleonCPQ__Quote__c quote= TestDataHelper.createQuote(true);

       param.QuoteID=quote.id;
       param.activeRelease ='1';
       
       List<CartRefresh.QuoteParams> params = new List<CartRefresh.QuoteParams>();
       params.add(param);
      
      
       CartRefresh.CartRefresh(params);
       Test.StopTest();  
   
      
      }
      }