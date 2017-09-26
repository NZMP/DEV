@isTest 
public class SmartPriceOfferViewTest{
@isTest 

    
    public static void testgetRedir() {
        Test.StartTest();
           //initialise;
           //create test quote records
        Account acc = TestDataHelper.createAccount('Sold To Party', 'grp','A1',true);
        Opportunity opp = TestDataHelper.createOpportunity(acc.id,true);
        Partner_Function__c pf =   TestDataHelper.createPartnerFunction(acc,acc,'Ship to party',true);
        opp.Ship_To__c=pf.id;
        CameleonCPQ__Quote__c quote= TestDataHelper.createQuote2(acc, opp, true);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        SmartPriceOfferView view = new SmartPriceOfferView(sc);
        
        PageReference pageRef = Page.ViewSmartPriceOffer;
        pageRef.getParameters().put('id', String.valueOf(quote.Id));
        Test.setCurrentPage(pageRef);
        
       //create test quote records
        //create first scenario for refresh
       quote.Contract_Start_Date__c=null;
       quote.Contract_End_Date__c =null;
       quote.TotalPrice2USD__c=null;
      // quote.CameleonCPQ__AccountId__c=acc.id;
      // quote.OpportunityId__c=opp.id;
       update(quote);
       
       pageRef= view.getRedir();
       
       //Update details for refresh
       quote.TotalPrice2USD__c=0;
       update(quote);
       
       pageRef= view.getRedir();
       Test.StopTest();  
   
      
      }
      }