@isTest (seeAllData=true)
//due to inability to isolate standard pricebook see all data is required when
//creating (test data for) opportunity line items
public with sharing class OptyProdPricingCollarCalculationCtlrTest {

    public static PageReference optyProdPricingCollarPdfPage = Page.OpportunityProdPricingCollarPdf;
    public static Account account1;
    public static Account accountParent1;
    public static Opportunity opportunity1;
    public static OpportunityLineItem oli1;
    public static Product2 product1;
/*
    public static Pricebook2 createPricebook(String pricebookName, Boolean performInsert) {
        Pricebook2 pb = new Pricebook2();
        pb.Name = pricebookName;
        pb.Description = 'Test Description';
        pb.IsActive = true;
        if (performInsert){
            insert pb;
        }
        return pb;
    }

    public static Pricebook2 createPricebookStandard() {
        Pricebook2 standardPriceBook1 = [Select Id, Name, IsActive From Pricebook2 where IsStandard = true LIMIT 1];
        if (!standardPriceBook1.isActive) {
            standardPriceBook1.isActive = true;
            update standardPriceBook1;
        }
        return standardPriceBook1;
    }
  
    public static PricebookEntry createPricebookEntry(Pricebook2 pricebook, Product2 product, String currencyCode, Boolean performInsert) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebook.Id;
        pbe.Product2Id = product.Id;
        //pbe.CurrencyIsoCode = currencyCode;
        pbe.IsActive = true;
        pbe.UnitPrice = 100;
        if (performInsert){
            insert pbe;
        }
        return pbe;
    }
*/

    public static void queryOli() {
        oli1 = [Select Quantity, ServiceDate, Last_Delivery_Date__c, Pricing_Collar_Product_Class__c, Collar_First_Month__c, Collar_Last_Month__c, 
                       OpportunityId, PricebookEntry.Name, Opportunity.Name, Pricebookentry.Product2.Name, Material_Number__c, 
                       Agreement_Term_mths__c, Quantity_Unit__c, Volume_Change__c, Description, Cap_Price_Chosen__c, Floor_Price_Chosen__c, Fee__c
                From OpportunityLineItem Where Id = :oli1.id];
    }

    public static void setup() {
        Test.setCurrentPage(optyProdPricingCollarPdfPage);

        //setup initial data with valid product class and quantity
        product1 = TestDataHelper.createProduct2(true);
        product1.Commodity_Class_Description__c = 'BUTTER';
        update product1;
        
        //Pricebook2 pricebook1 = createTestPricebook('Test Pricebook', true);
        //Pricebook2 pricebook1 = createPricebookStandard();
        //PricebookEntry pricebookEntry1 = createPricebookEntry(pricebook1, product1, 'NZD', true); 
        PricebookEntry pricebookEntry1 = [Select Id, IsActive From PricebookEntry Where Product2Id = :product1.Id];
        pricebookEntry1.IsActive = true;
        update pricebookEntry1;
        
        //create test account1 record with related opportunity and strategic initiative
        account1 = TestDataHelper.createAccount('Sold To Party', 'TestAccountGroup', 'AccNo1', true);
        opportunity1 = TestDataHelper.createOpportunity(account1.Id, true);
        oli1 = new OpportunityLineItem(OpportunityId = opportunity1.id, PricebookEntryId = pricebookEntry1.id, TotalPrice = 9);
        oli1.Quantity = 1000;
        //ensure start and end dates are valid, i.e. within the next 3-9 months 
        oli1.ServiceDate = System.today() + 100;
        oli1.Last_Delivery_Date__c = System.today() + 165;
        insert oli1;
        queryOli();

    }

    public static void deletePricingCollarCalculationTables() {

        //generate test price collar calculation tables however not useful due 
        //to see all data setting so we need to "delete" existing calculation
        //tables!
        delete [Select Id From Pricing_Collar_Calculation__c Where Pricing_Collar_Product__c = 'Butter'];

    }

    public static void generatePricingCollarCalculationTables() {
        //delete existing calculation tables so we can work with our own test
        //data
        deletePricingCollarCalculationTables();
        
        //generate calculation tables with dates that match opporunity line item
        //i.e. within the next 3-9 months
        Pricing_Collar_Calculation__c pcc = new Pricing_Collar_Calculation__c();
        pcc.Pricing_Collar_Product__c = 'Butter';
        pcc.Type__c = 'Cap Price';
        pcc.Name_Value__c = 3000;
        pcc.Calculation_Value__c = 3; 
        pcc.Calculation_Date__c = System.today() + 100;
        insert pcc;
        pcc = new Pricing_Collar_Calculation__c();
        pcc.Pricing_Collar_Product__c = 'Butter';
        pcc.Type__c = 'Cap Price';
        pcc.Name_Value__c = 5000;
        pcc.Calculation_Value__c = 5; 
        pcc.Calculation_Date__c = System.today() + 135;
        insert pcc;     
        pcc = new Pricing_Collar_Calculation__c();
        pcc.Pricing_Collar_Product__c = 'Butter';
        pcc.Type__c = 'Floor Price';
        pcc.Name_Value__c = 1000;
        pcc.Calculation_Value__c = 1; 
        pcc.Calculation_Date__c = System.today() + 100;
        insert pcc;
        pcc = new Pricing_Collar_Calculation__c();
        pcc.Pricing_Collar_Product__c = 'Butter';
        pcc.Type__c = 'Floor Price';
        pcc.Name_Value__c = 3000;
        pcc.Calculation_Value__c = 3; 
        pcc.Calculation_Date__c = System.today() + 135;
        insert pcc;

    }

    public static void tearDown() {
    }

    public static testMethod void validPriceCollarCalculationWithPdf() {

        setup();
        generatePricingCollarCalculationTables();

        Apexpages.currentPage().getParameters().put('renderAs','pdf');
        OptyProdPricingCollarCalculationCtlr controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));
        controller.calculatePriceCollarFees();
        System.debug('!!priceCollarFees'+controller.priceCollarFees);
        //!!priceCollarFees((Pricing_Collar_Calculation__c:{Name=3000, Name_Value__c=3000, Calculation_Value__c=2}, Pricing_Collar_Calculation__c:{Name=3000, Name_Value__c=3000, Calculation_Value__c=0}), (Pricing_Collar_Calculation__c:{Name=5000, Name_Value__c=5000, Calculation_Value__c=4}, Pricing_Collar_Calculation__c:{Name=5000, Name_Value__c=5000, Calculation_Value__c=2}))
        //System.assertEquals(2, controller.priceCollarFees.size());
        //System.assertEquals(2, controller.priceCollarFees[0].size());
        //System.assertEquals(2, controller.priceCollarFees[1].size());
        System.debug('!!floorPriceHeaderDisplayList'+controller.floorPriceHeaderDisplayList);
        //System.assertEquals(2, controller.floorPriceHeaderDisplayList.size());

        //check pdf is generated and attached to opportunity
        controller.savePricingCollarFeesAsPdfAttachment();
        //System.debug('!!pdfAttachment='+[Select Name, ContentType From Attachment Where ParentId = :opportunity1.id]);
       // System.assertEquals(1, [Select Name, ContentType From Attachment Where ParentId = :opportunity1.id].size());

        tearDown();

    }

    public static testMethod void noPricingCollarCalculationTableData() {

        setup();
        deletePricingCollarCalculationTables();

        oli1.Quantity = 1000;
        update oli1;
        queryOli();
        Apexpages.currentPage().getParameters().put('renderAs','pdf');
        OptyProdPricingCollarCalculationCtlr controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));

        tearDown();

    }

    public static testMethod void invalidVolumeLimitExceeded() {

        setup();

        oli1.Quantity = 4001;
        update oli1;
        queryOli();
        Apexpages.currentPage().getParameters().put('renderAs','pdf');
        OptyProdPricingCollarCalculationCtlr controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));

        tearDown();

    }

    public static testMethod void invalidServiceDateNull() {

        setup();

        oli1.ServiceDate = null;
        oli1.Quantity = 1001;
        update oli1;
        queryOli();

        Apexpages.currentPage().getParameters().put('renderAs','pdf');
        OptyProdPricingCollarCalculationCtlr controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));
        controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));
        controller.calculatePriceCollarFees();

        tearDown();

    }

    public static testMethod void invalidCommodityClassNull() {

        setup();

        product1.Commodity_Class_Description__c = null;
        update product1;
        oli1.Quantity = 1001;
        update oli1;
        queryOli();

        Apexpages.currentPage().getParameters().put('renderAs','pdf');
        OptyProdPricingCollarCalculationCtlr controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));
        controller = new OptyProdPricingCollarCalculationCtlr(new ApexPages.StandardController(oli1));
        controller.calculatePriceCollarFees();

        tearDown();

    }
    
    public static testMethod void renderPage() {
        
        OptyProdPricingCollarCalculationCtlr.getUserTimeZoneOffset();
        
        setup();

        tearDown();

    }

}