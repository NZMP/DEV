/***************************
* @description: Test class for SFtoSAPWebserviceHandler
* @author: Mahmood Zubair(DC)
* @history:
* 14March2016 MahmoodK(DC): Initial version
*
*
*******************************/
@isTest(SeeAllData = False)
public class SFtoSAPWebserviceHandlerTest{
    public static List<Opportunity> opportunityList;
    public static List<OpportunityLineItem> itemList;
    public static Product2 product;

    @testSetup 
    static void setup() {
        opportunityList = new List<Opportunity>();
        itemList = new List<OpportunityLineItem>();

        // add account
        Account customer =
            TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY,
                    'accountGroupCust', 'accountNumberCust', true) ;
        Account partner =
            TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY,
                    'accountGroupParnter', 'accountNumberPartner', true) ;

        Partner_Function__c partnerFunction =
            TestDataHelper.createPartnerFunction(customer, partner, 'test partner function 1', true);
        partnerFunction.Partner_Function_Description__c = 'Ship-to party';
        
        // create Customer_Sales_Area__c
        Customer_Sales_Area__c custSalesArea = new Customer_Sales_Area__c();
        custSalesArea.Deleted_in_SAP__c = false;
         //add incoTerm       
       // custSalesArea.Incoterms__c = 'CFR'; 
        insert custSalesArea;
        
        partnerFunction.Customer_Sales_Area__c = custSalesArea.Id;
        update partnerFunction;
        
        Opportunity opp1 = TestDataHelper.createOpportunity(customer.Id, true);
       // opp1.ship_to__c = partnerFunction.Id;
        
      //  update opp1;
        opportunityList.add(opp1);
        
        Id pricebookId = Test.getStandardPricebookId();
        PriceBook2 priceBook = new PriceBook2(id = pricebookId ,  IsActive = true);
        update priceBook;
       
        SmartFactory.FillAllFields = false;

        system.debug('Price book is active '+ priceBook.IsActive +' is standard '+ priceBook.IsStandard);
        
         system.debug('Price book is active '+ priceBook.IsActive +' is standard '+ priceBook.IsStandard);
        // add product
        Product2 prod= new Product2();
        prod.Name = 'product 1';
        
        prod.ProductCode ='prod 1';
        //prod.Pricebook2Id = priceBook.id;
        insert prod;
        
        PricebookEntry  priceBookEntry = [SELECT Id, Isactive, Product2Id  from PriceBookEntry where Product2Id =:prod.id LIMIT 1];
        priceBookEntry.isactive = true;
        update priceBookEntry; 
    
        // add opp item
         Map<String, Object> lineItemValues = new Map<String, Object> {
                                                'OpportunityId' => opp1.Id,
                                                'UnitPrice' => 1.0,
                                                'Target_Price__c' => 2.9,
                                                'Stretch_Price__c' => 3.0,
                                                'Floor_Price__c' => 4.0,
                                                'Raw_Target__c' => 5.0,
                                                'Raw_Stretch__c' => 6.0,
                                                'Raw_Floor__c' => 9.0,
                                                'Quantity' => 12.0,
                                                'Volumes__c' => '5',
                                                'Months__c' => '20161010',
                                                'Services__c' => 'S5501',
                                                'Service_Type__c' =>'M',
                                                'Value_Conditions__c' => '212,323,2,0',
                                                'PriceBookEntryId' => priceBookEntry.Id};
        OpportunityLineItem item1 = 
            (OpportunityLineItem)SmartFactory.createSObject('OpportunityLineItem', lineItemValues);
        insert item1;
        itemList.add(item1);
        
        CameleonCPQ__Quote__c CPQQuote = TestDataHelper.createQuote2(customer ,opp1 ,false);
        CPQQuote.OpportunityId__c =  opp1.Id;
        CPQQuote.Contract_Start_Date__c = Date.Today();
        CPQQuote.Contract_End_Date__c = Date.Today().adddays(10);
        //CPQQuote.Payment_Terms__c = 'dasdasd';
        //CPQQuote.IncoTerms__c ='asdasd';
        CPQQuote.Offer_Currency__c ='USD';
        CPQQuote.Offer_Valid_From__c = Date.Today().adddays(2);
        CPQQuote.Offer_Valid_To__c =Date.Today().adddays(22);
        CPQQuote.Approval_Comments__c = 'Testing Comments';
        insert CPQQuote;
  
    }
  
    static testMethod void test_OpportunityBtn(){
        Opportunity opp = [SELECT Id, Name FROM Opportunity LIMIT 1];
        Test.StartTest();       
         // This causes a fake response to be generated
        Test.setMock(WebServiceMock.class, new SAPWebserviceMock());
        
        SFtoSAPWebserviceHandler.opportunityBtnPress(string.valueof(opp.id));
        Test.StopTest();
    }
    
    static testMethod void test_OpportunityTrigger(){
        RecordType smartPriceRecordtype = [SELECT ID, Name  FROM RecordType Where SObjectType = 'Opportunity' AND DeveloperName='Fonterra_SmartPrice' LIMIT 1]; 
        Opportunity opp = [SELECT Id, Name, Offer_Status__c , RecordTypeId  FROM Opportunity LIMIT 1];
        
        Test.StartTest();       
         // This causes a fake response to be generated
          
        //Test.setMock(WebServiceMock.class, new PPSSPriceGuidanceWebserviceMock()); 
        //Test.setMock(WebServiceMock.class, new SAPWebserviceMock());
        opp.Offer_Status__c= 'Customer Accepted';
        opp.RecordTypeid = smartPriceRecordtype.Id;
        System.debug('Opp Trigger Old value ' +opp); 
        update opp;
        opp.Offer_Status__c= 'Customer_Accepted';
        update opp;
        System.debug('Opp Trigger new value ' +opp); 
        Test.StopTest();
    }
    
    static testMethod void test_WebServiceMethods(){
        
        Test.StartTest();       
        
        fonterraComGlobalCommon.BusinessDocumentMessageHeaderParty bDMHObj = new fonterraComGlobalCommon.BusinessDocumentMessageHeaderParty();
        fonterraComGlobalCommon.PlantID plantObj = new fonterraComGlobalCommon.PlantID ();
        
        fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateRequestMessage cQCRObj = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateRequestMessage();
        fonterraComGiSfMakeandmanageoffer.TextCollection_element textObj = new fonterraComGiSfMakeandmanageoffer.TextCollection_element();
        Test.setMock(WebServiceMock.class, new SAPWebserviceMock());
        fonterraComGiSfMakeandmanageoffer.HTTPS_Port callout = new fonterraComGiSfMakeandmanageoffer.HTTPS_Port();
        //callout.CustomerQuoteCreateRequestConfirmation(null,null);
      
    
     
        Test.StopTest();
    }
}