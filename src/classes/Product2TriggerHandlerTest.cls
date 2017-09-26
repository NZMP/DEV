@isTest
public with sharing class Product2TriggerHandlerTest {

	public static Product2 product2; 	

	public static void setup() {
	}

	public static void tearDown() {
	}

	public static testMethod void insertProduct2WithStandardPriceBookEntryWithForecastPrice() {
		setup();

       	product2 = TestDataHelper.createProduct2(true, 20.00);
		//check inserted product contains a standard pricebook entry
		List<PricebookEntry> pricebookEntries = [Select Name, UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id, IsActive 
				From PricebookEntry 
				Where Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id()
				And Product2Id = :product2.Id];
		System.assertEquals(1, pricebookEntries.size());
		System.assertEquals(product2.Name, pricebookEntries[0].Name);
		System.assertEquals(product2.Forecast_Price__c, pricebookEntries[0].UnitPrice); 
		System.assertEquals(product2.IsActive, pricebookEntries[0].IsActive);

		tearDown();
	}
	
	public static testMethod void insertProduct2WithStandardPriceBookEntryWithNullForecastPrice() {
		setup();

       	product2 = TestDataHelper.createProduct2(true, null);
		//check inserted product contains a standard pricebook entry
		List<PricebookEntry> pricebookEntries = [Select Name, UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id, IsActive 
				From PricebookEntry 
				Where Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id()
				And Product2Id = :product2.Id];
		System.assertEquals(1, pricebookEntries.size());
		System.assertEquals(product2.Name, pricebookEntries[0].Name);
		System.assertEquals(1, pricebookEntries[0].UnitPrice); 
		System.assertEquals(product2.IsActive, pricebookEntries[0].IsActive);

		tearDown();
	}
	
	public static testMethod void insertProduct2WithStandardPriceBookEntryWithNegativeForecastPrice() {
		setup();

       	product2 = TestDataHelper.createProduct2(true, -20.00);
		//check inserted product contains a standard pricebook entry
		List<PricebookEntry> pricebookEntries = [Select Name, UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id, IsActive 
				From PricebookEntry 
				Where Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id()
				And Product2Id = :product2.Id];
		System.assertEquals(1, pricebookEntries.size());
		System.assertEquals(product2.Name, pricebookEntries[0].Name);
		System.assertEquals(1, pricebookEntries[0].UnitPrice); 
		System.assertEquals(product2.IsActive, pricebookEntries[0].IsActive);

		tearDown();
	}
	
	public static testMethod void updateProduct2ChangeForecastPrice() {
		setup();

		// Create a product with a forecast price and insert 
       	product2 = TestDataHelper.createProduct2(true, 20.00);
		
		// Update the Forecast Price on the product
		product2.Forecast_Price__c = 30.00;
		
		
		// Update
		update product2;
		
		// Retrieve Pricebook from database
		List<PricebookEntry> pricebookEntries = [Select Name, UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id, IsActive 
				From PricebookEntry 
				Where Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id()
				And Product2Id = :product2.Id];
		
		// Check to see if the UnitPrice on the Pricebook has been updated with the new forecast price
		System.assertEquals(product2.Forecast_Price__c, pricebookEntries[0].UnitPrice); 
		
		tearDown();
	}
	
	public static testMethod void updateProduct2ChangeForecastPriceWithNothing() {
		setup();

		// Create a product with a forecast price and insert 
       	product2 = TestDataHelper.createProduct2(true, 20.00);
		
		// Update the Forecast Price on the product
		product2.Forecast_Price__c = 0.00;
		
		
		// Update
		update product2;
		
		// Retrieve Pricebook from database
		List<PricebookEntry> pricebookEntries = [Select Name, UseStandardPrice, UnitPrice, Product2Id, Pricebook2Id, IsActive 
				From PricebookEntry 
				Where Pricebook2Id = :CrmsConstants.getStandardPriceBook2Id()
				And Product2Id = :product2.Id];
		
		// Check to see if the UnitPrice on the Pricebook has been updated with the new forecast price
		System.assertEquals(1, pricebookEntries[0].UnitPrice); 
		
		tearDown();
	}
}