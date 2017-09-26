@isTest 
public class CartCopyTest{
@isTest 
    public static void testCartCopy() {
        Test.StartTest();
       
        CartCopy cart = new CartCopy();
        CartCopy.QuoteParams param= new CartCopy.QuoteParams();
    
       //create test quote records
       CameleonCPQ__Quote__c oldQuote= TestDataHelper.createQuote(true);

       param.quoteID = oldQuote.id;
       CameleonCPQ__Quote__c newQuote= TestDataHelper.createQuote(true);

       param.cloneID =newQuote.id;
       param.activeRelease ='1';
       
       List<CartCopy.QuoteParams> params = new List<CartCopy.QuoteParams>();
       params.add(param);
      
      
       CartCopy.CartCopy(params);
       Test.StopTest();  
   
      
      }
      }