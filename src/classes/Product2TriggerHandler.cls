public with sharing class Product2TriggerHandler {

	private boolean m_isExecuting = false;
	private integer BatchSize = 0;

	public Product2TriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterInsert(Product2[] newProduct2s) {
		List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
		PricebookEntry pricebookEntry;
		
		decimal forecastPrice;
		
		for (Product2 p : newProduct2s)
		{
			if(p.Forecast_Price__c != null && p.Forecast_Price__c > 0){
				forecastPrice = p.Forecast_Price__c;
			}else{
				forecastPrice = 1;
			}
			pricebookEntry = new PricebookEntry(
				UseStandardPrice = false,
				UnitPrice  = forecastPrice,
				Product2Id = p.Id,
				Pricebook2Id  = CrmsConstants.getStandardPriceBook2Id(),
				IsActive = p.IsActive 
			);
			pricebookEntries.add(pricebookEntry);
		}
		if (pricebookEntries.size() > 0) {
			system.debug(pricebookEntries);
			insert pricebookEntries;
		}
	}
/*
	public void OnAfterUpdate(Product2[] oldProduct2s, Product2[] updatedProduct2s, Map<ID, Product2> product2Map){
	}
		
	public void OnBeforeInsert(Product2[] newProduct2s){
	}	
	
	@future public static void OnAfterInsertAsync(Set<ID> newProduct2IDs){
	}
	
	public void OnBeforeUpdate(Product2[] oldProduct2s, Product2[] updatedProduct2s, Map<ID, Product2> product2Map){
	}
	*/
	//@updatedProduct2s list of updated products
	//@oldProduct2Map map of old product values
	public void OnAfterUpdate(Product2[] updatedProduct2s, Map<Id, Product2>updatedProducts2Map, Map<ID, Product2> oldProduct2Map){
		Set<Id> updatedProducts = new Set<Id> ();
		for(Product2 newProd :  updatedProduct2s){
			Product2 oldProd = oldProduct2Map.get(newProd.id);
			if(oldProd.Forecast_Price__c!= newProd.Forecast_Price__c){
				updatedProducts.add(newProd.Id);
			}
		}
		List<PricebookEntry> priceBooksToUpdate = [SELECT id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id =: updatedProducts];
		
		system.debug('####### updatedProducts: ' + updatedProducts);
		
		decimal fCastPrice;
		
		for(PricebookEntry pbE : priceBooksToUpdate ){
			fCastPrice = updatedProducts2Map.get(pbE.Product2Id).Forecast_Price__c;
			if(fCastPrice > 0){
				pbE.UnitPrice = fCastPrice;	
			} else{
				pbE.UnitPrice = 1;
			}
		}
		
		if(priceBooksToUpdate.size() > 0){
			update priceBooksToUpdate;
		}
	}

	/*@future public static void OnAfterUpdateAsync(Set<ID> updatedProduct2IDs){
	}
	
	public void OnBeforeDelete(Product2[] product2sToDelete, Map<ID, Product2> product2Map){
	}
	
	public void OnAfterDelete(Product2[] deletedProduct2s, Map<ID, Product2> product2Map){
	}
	
	@future public static void OnAfterDeleteAsync(Set<ID> deletedProduct2IDs){
	}
	
	public void OnUndelete(Product2[] restoredProduct2s){
	}
	
	public boolean IsTriggerContext{
		get {return m_isExecuting;}
	}
	
	public boolean IsVisualforcePageContext{
		get {return !IsTriggerContext;}
	}
	
	public boolean IsWebServiceContext{
		get {return !IsTriggerContext;}
	}
	
	public boolean IsExecuteAnonymousContext{
		get {return !IsTriggerContext;}
	}
*/
}