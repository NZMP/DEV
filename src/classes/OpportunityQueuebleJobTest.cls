/**************************************
*Author : MahmoodZ(DC) 
*Description: Test class for testing the OpportunityQueuebleJob
*Change Log
* 23Jun2016: MahmoodZ(DC) Initial Version
*
*
*
*
***************************************/
@isTest(seeAllData = False)
private Class  OpportunityQueuebleJobTest{

    @testSetup 
    static void setup() {
    
        // Create the test data 
        // add account
        Account customer =
            TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY,
                    'accountGroupCust', 'accountNumberCust', true) ;
        Account partner =
            TestDataHelper.createAccount(CrmsConstants.ACCOUNT_RECORD_TYPE_SOLD_TO_PARTY,
                    'accountGroupParnter', 'accountNumberPartner', true) ;    
    
        IncoTerms__c incoObj = new IncoTerms__c();
        incoObj.Name = 'Inc01';
        incoObj.IncoTerms_code__c = 'Inc01';
        incoObj.IncoTerms_Description__c = 'Inc01';
        insert incoObj;
        
        IncoTerms__c incoObj2 = new IncoTerms__c();
        incoObj2.Name = 'Inc02';
        incoObj2.IncoTerms_code__c = 'Inc02';
        incoObj2.IncoTerms_Description__c = 'Inc02';
        insert incoObj2;
        
        Payment_Term__c paymentObj = new Payment_Term__c ();
        paymentObj.Name = 'Pay01';
        paymentObj.Payment_Terms_Code__c= 'Pay01';
        paymentObj.Payment_Terms_Description__c= 'Pay01';
        insert paymentObj ;
        
        Payment_Term__c paymentObj2 = new Payment_Term__c ();
        paymentObj2.Name = 'Pay02';
        paymentObj2.Payment_Terms_Code__c= 'Pay02';
        paymentObj2.Payment_Terms_Description__c= 'Pay02';
        insert paymentObj2;
        
        Customer_Sales_Area__c customerObj= new Customer_Sales_Area__c();
        customerObj.Customer__c = customer.id;
        customerObj.Incoterms_Description__c ='Inc01';
        customerObj.Incoterms__c ='Inc01';
        customerObj.Incoterms_Part_2__c ='Inc01';
        customerObj.Payment_Terms__c ='Pay01';
        customerObj.Payment_Terms_Description__c ='Pay01';
        insert customerObj;
        
        Customer_Sales_Area__c customerObj2= new Customer_Sales_Area__c();
        customerObj2.Customer__c = customer.id;
        customerObj2.Incoterms_Description__c ='Inc02';
        customerObj2.Incoterms__c ='Inc02';
        customerObj2.Incoterms_Part_2__c ='Inc02';
        customerObj2.Payment_Terms__c ='Pay02';
        customerObj2.Payment_Terms_Description__c ='Pay02';
        insert customerObj2;
        
        Partner_Function__c partnerObj = new Partner_Function__c();
        partnerObj.Customer__c = customer.id;
        partnerObj.Partner__c = partner.Id;
        partnerObj.Customer_Sales_Area__c = customerObj.id;
        partnerObj.Partner_Function_Description__c = 'Ship-to party';
        partnerObj.Sales_Organisation__c ='001';
        insert partnerObj;
        
        Partner_Function__c partnerObj2 = new Partner_Function__c();
        partnerObj2.Customer__c = customer.id;
        partnerObj2.Partner__c = partner.Id;
        partnerObj2.Customer_Sales_Area__c = customerObj2.id;
        partnerObj2.Partner_Function_Description__c = 'Payer';
        partnerObj2.Sales_Organisation__c = '002';
        insert partnerObj2;
        
        Partner_Function__c partnerObj3 = new Partner_Function__c();
        partnerObj3.Customer__c = customer.id;
        partnerObj3.Partner__c = partner.Id;
        partnerObj3.Customer_Sales_Area__c = customerObj.id;
        partnerObj3.Partner_Function_Description__c = 'Ship-to party';
        partnerObj3.Sales_Organisation__c = '003';
        insert partnerObj3;
        
        Partner_Function__c partnerObj4 = new Partner_Function__c();
        partnerObj4.Customer__c = customer.id;
        partnerObj4.Partner__c = partner.Id;
        partnerObj4.Customer_Sales_Area__c = customerObj2.id;
        partnerObj4.Partner_Function_Description__c = 'Payer';
        partnerObj4.Sales_Organisation__c = '004';
        insert partnerObj4;     
    }
    
    //23Jun2016 MahmoodZ(DC): Creating the Opportunity to fire the code. 
    static testMethod void createOpportunity(){
        Partner_Function__c  ShipToObj = [SELECT Id, Name FROM Partner_Function__c  WHERE Sales_Organisation__c = '001'];
        Partner_Function__c  PayerObj= [SELECT Id, Name FROM Partner_Function__c  WHERE Sales_Organisation__c = '002']; 
        Partner_Function__c  ShipToObj2 = [SELECT Id, Name FROM Partner_Function__c  WHERE Sales_Organisation__c = '003'];
        Partner_Function__c  PayerObj2 = [SELECT Id, Name FROM Partner_Function__c  WHERE Sales_Organisation__c = '004'];   
        Account accObj = [SELECT ID, Name FROM Account WHERE Account_Number__c= 'accountNumberCust'];
        
        Test.StartTest();
        Opportunity oppObj = new Opportunity();
        oppObj.Name = 'Test Class Opportunity';
        oppObj.accountid = accObj.Id;
        oppObj.Ship_To__c = ShipToObj.Id;
        OppObj.Payer__c = PayerObj.Id;
        OppObj.Opportunity_Type_Overview__c = 'Increase Volume';
        OppObj.Opportunity_Sub_Type__c = 'Increase Existing Product';
        OppObj.Stage_in_Buying_Cycle__c = 'Recognition of Needs';
        OppObj.StageName = 'Value Proposition';
        oppObj.CloseDate = date.Today(); 
        Insert OppObj;
        
        CameleonCPQ__Quote__c CPQQuote = TestDataHelper.createQuote(false);
        CPQQuote.OpportunityId__c =  OppObj.Id;
        CPQQuote.CameleonCPQ__AccountId__c = accObj.id;
        CPQQuote.Contract_Start_Date__c = Date.Today();
        CPQQuote.Contract_End_Date__c = Date.Today().adddays(10);
        //CPQQuote.Payment_Terms__c = 'dasdasd';
        //CPQQuote.IncoTerms__c ='asdasd';
        CPQQuote.Offer_Currency__c ='USD';
        CPQQuote.Offer_Valid_From__c = Date.Today().adddays(2);
        CPQQuote.Offer_Valid_To__c =Date.Today().adddays(22);
        CPQQuote.Approval_Comments__c = 'Testing Comments';
        insert CPQQuote;
        
        oppObj.Ship_To__c = ShipToObj2.id;
        OppObj.Payer__c =PayerObj2.id;
        OppObj.Agreement_End_Date__c = Date.today().adddays(10);
        OppObj.Agreement_Start_Date__c = Date.today();
        oppObj.accountid = accObj.Id;
        //update oppObj;
        List<Opportunity> opportunitesChangedList = new list<Opportunity>();
        opportunitesChangedList.add(oppObj);
           OpportunityQueuebleJob oQJ = new OpportunityQueuebleJob(opportunitesChangedList);     
           system.enqueueJob(oQJ);    
        Test.StopTest();
    }
    
    
}