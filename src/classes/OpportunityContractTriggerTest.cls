/*
 * Copyright (c) 2016 by PROS, Inc.  All Rights Reserved.
 * This software is the confidential and proprietary information of
 * PROS, Inc. ("Confidential Information").
 * You may not disclose such Confidential Information, and may only
 * use such Confidential Information in accordance with the terms of
 * the license agreement you entered into with PROS.
 * 
 * author Shawn Wang
 */
@isTest (seeAllData=true)
public with sharing class OpportunityContractTriggerTest {
    public static List<Opportunity> opportunityList;
    public static List<OpportunityLineItem> itemList;
    public static Product2 product;
    
    public static void setup() {}

    public static void tearDown() {}
    
    static void init(){

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
        insert custSalesArea;
        
        partnerFunction.Customer_Sales_Area__c = custSalesArea.Id;
        
        update partnerFunction;
        Opportunity opp1 = TestDataHelper.createOpportunity(customer.Id, true);
        opp1.ship_to__c = partnerFunction.Id;
        
        update opp1;
        opportunityList.add(opp1);
        
        // add price book, need to make IsStandard = true
       // PriceBook2 priceBook = new PriceBook2(Name= 'Price book 1',  IsActive = true);
       // insert priceBook;
       // SmartFactory.FillAllFields = false;

        //system.debug('Price book is active '+ priceBook.IsActive +' is standard '+ priceBook.IsStandard);
        // add product
        product =TestDataHelper.createProduct2(true);
        //product.Name = 'product 1';
            //new Product2(Name =  'product 1');
        // product has a insert trigger to inert PricebookEntry
        //update product;
        PricebookEntry  priceBookEntries = [SELECT Id, Product2Id, Pricebook2Id, isActive From PricebookEntry 
                                WHERE Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id() and Product2Id = :product.Id];
        
        // add price book entry
        /* 
         Map<String, Object> priceBookEntryValues = new Map<String, Object> {
                                                'Pricebook2Id' => priceBook.Id, 
                                                'Product2Id' =>product.Id};
        PriceBookEntry priceBookEntry = 
            (PriceBookEntry)SmartFactory.createSObject('PriceBookEntry', priceBookEntryValues);
        
        insert priceBookEntry;
        */
        priceBookEntries.isActive =true;
        update priceBookEntries;
       
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
                                               // 'ProductCode' => 'prod 1',
                                                'PriceBookEntryId' => priceBookEntries.Id};
        OpportunityLineItem item1 = 
            (OpportunityLineItem)SmartFactory.createSObject('OpportunityLineItem', lineItemValues);
        insert item1;
        itemList.add(item1);
    }

    /** Test updating Offer field**/
    public static testMethod void testUpdateOffer() {
        setup();
        init();
        Test.startTest();

        // getting the first opportunity to update Offer__c
        Opportunity updateOpp = [
            SELECT Id, Offer__c
            FROM Opportunity
            WHERE Id =:opportunityList[0].Id];
        Recordtype recordtype = [SELECT ID, Name  FROM RecordType Where SObjectType = 'Opportunity' AND DeveloperName='Fonterra_SmartPrice' LIMIT 1];
        updateOpp.Offer__c = 'new contract';
        updateOpp.Offer_Status__c = 'Customer_Accepted';
        updateOpp.RecordTypeId =recordtype.id;
        System.Debug('****** opp id '+ updateOpp.Id +' ship to '+ updateOpp.ship_to__c);
        // mock webservice
        // Test.setMock(WebServiceMock.class, new PPSSPriceGuidanceWebserviceMock());        
        update updateOpp;

        // verify webservice is sent
        // System.assertEquals(casesList[0].ContactId, contactsList[0].Id);

        Test.stopTest();
        tearDown();
    }
    
     /** Test expired offer**/
    public static testMethod void testExpiredOffer() {
        setup();
        init();
        Test.startTest();

        // getting the first opportunity to update Offer__c
        Opportunity updateOpp = [
            SELECT Id, Offer__c
            FROM Opportunity
            WHERE Id =:opportunityList[0].Id];
        Recordtype recordtype = [SELECT ID, Name  FROM RecordType Where SObjectType = 'Opportunity' AND DeveloperName='Fonterra_SmartPrice' LIMIT 1];
        updateOpp.Offer__c = 'new contract 2';
    
       
        
        updateOpp.RecordTypeId =recordtype.id;
          updateOpp.Offer_Status__c = 'Needs_Tenure_Approval'; 
           updateOpp.Offer_Tenure__c   =11;
      update updateOpp;
   Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

        req1.setComments('Submitting request for approval.');

        req1.setObjectId(updateOpp.Id);

        req1.setNextApproverIds(new Id[] {UserInfo.getUserId()});

         

        //Submit the approval request for the change

        Approval.ProcessResult result = Approval.process(req1);

         

        //Verify the result

        System.assert(result.isSuccess());

         

        System.assertEquals('Pending', result.getInstanceStatus(), 'Instance Status'+result.getInstanceStatus());
        // verify webservice is sent
        // System.assertEquals(casesList[0].ContactId, contactsList[0].Id);
        //now expire
        updateOpp.Offer_Status__c = 'Expired'; 
        update updateOpp;

        Test.stopTest();
        tearDown();
    }
}