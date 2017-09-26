trigger CPQQuoteDefaultValues on CameleonCPQ__Quote__c (before insert, before update) {

    /* Setting the Opportunity ID after a clone has refreshed
    for (Integer i = 0; i < Trigger.New.size(); i++) {
      if (Trigger.Old != null) {
      CameleonCPQ__Quote__c quoteOld = Trigger.Old.get(i);
      CameleonCPQ__Quote__c quoteNew = Trigger.New.get(i);
        // Update OpportunityId__c
        if (quoteOld.CameleonCPQ__TotalPrice1__c==null && quoteNew.CameleonCPQ__TotalPrice1__c!=null) {
            try
            {
                quoteNew.OpportunityId__c = quoteNew.Hidden_Opportunity_Id__c;
              
            }
            catch(Exception e)
            {
                System.debug(LoggingLevel.ERROR,'Unable to set Opportunity ID');
            }
         }
      }
    }*/
     
    

    for (CameleonCPQ__Quote__c quote : Trigger.New) {
 
     //Checks for inserts & updates    
          // Default the sold-to Account from the opportunity
            if(quote.OpportunityId__c!=null && quote.CameleonCPQ__AccountId__c ==null )    {
                Opportunity opp = [SELECT OwnerId, AccountId FROM Opportunity where Id = :quote.OpportunityId__c];
                quote.CameleonCPQ__AccountId__c = opp.AccountId;
            }
            
             // Set NZ Exchange rate
            if (quote.NZ_Currency_Conversion_rate__c==null ) 
                {
                    try
                    {
                        ExchangeRate__c currExch = [SELECT id, Alt_Rate__c FROM ExchangeRate__c WHERE FromCurrency__c=: 'NZD' ORDER BY Validity_Start_Date__c DESC LIMIT 1];
                        quote.NZ_Currency_Conversion_rate__c = currExch.Alt_Rate__c;
                        quote.NZ_Exchange_Rate__c = currExch.id;
                      
                    }
                    catch(Exception e)
                    {
                        System.debug('Exchange rate not available');
                    }         
                }
            
        
        // Update IncoTerm
            if (quote.IncoTerm__c==null) {
                try
                {
                    IncoTerms__c IncoTerm = [SELECT id FROM IncoTerms__c WHERE IncoTerms_Code__c= :quote.Ship_To_Incoterms__c LIMIT 1];          
                    quote.IncoTerm__c = IncoTerm.id;
                  
                }
                catch(Exception e)
                {
                    System.debug('Unable to find IncoTerm');
                }
             }  
              
         // Update PaymentTerm
            if (quote.Payment_Term__c==null) {
                try
                {
                   Payment_Term__c PaymentTerm = [SELECT id FROM Payment_Term__c WHERE Payment_Terms_Code__c = :quote.Payer_Payment_Terms__c LIMIT 1];
                  quote.Payment_Term__c = PaymentTerm.id;
                  
                }
                catch(Exception e)
                {
                    System.debug('Unable to find PaymentTerm');
                }
            }
                    //Update Sales Org Address
            
            if (quote.OpportunityId__c !=null && quote.Sales_Org__c == null) {
                try
                {
                    Opportunity opp = [SELECT Sales_Organisation__c FROM Opportunity WHERE Id = :quote.OpportunityId__c]; 
                    Sales_Org__c salesId = [SELECT Id FROM Sales_Org__c WHERE Name = :opp.Sales_Organisation__c];
                    quote.Sales_Org__c = salesId.Id;
                  
                }
                catch(Exception e)
                {
                    System.debug('Unable to set Sales Org Address');
                }
              }

        if (quote.Offer_Valid_From__c==null )
        { 
            quote.Offer_Valid_From__c = date.today();
        }
           
        //If this is an insert, set default values
        if(Trigger.isInsert)
        {            
            
            
            // Default contract end date to end of month.
            if (quote.Contract_End_Date__c<>null)
            {
                Integer numberOfDays = Date.daysInMonth(quote.Contract_End_Date__c.year(), quote.Contract_End_Date__c.month());
                quote.Contract_End_Date__c= Date.newInstance(quote.Contract_End_Date__c.year(), quote.Contract_End_Date__c.month(), numberOfDays);
            }   
             // Default contract start date to start of month
             if (quote.Contract_Start_Date__c<>null) 
             {      
                quote.Contract_Start_Date__c= Date.newInstance(quote.Contract_Start_Date__c.year(), quote.Contract_Start_Date__c.month(), 1);   
            }
            
            // Update Exchange rate
            if (quote.Quote_Currency__c!=null && quote.Offer_Currency__c!=null) {
                try
                {
                    ExchangeRate__c currExch = [SELECT id, Alt_Rate__c FROM ExchangeRate__c WHERE To_Currency__c= :quote.Quote_Currency__c AND FromCurrency__c= :quote.Offer_Currency__c ORDER BY Validity_Start_Date__c DESC LIMIT 1];
                    quote.Currency_Conversion_rate__c = currExch.Alt_Rate__c;
                    quote.Exchange_Rate__c = currExch.id;
                  
                }
                catch(Exception e)
                {
                    System.debug('Exchange rate not available');
                }
            }
            // Sanctioned Currencies
            if (quote.ShippingCountryCode__c!=null && quote.Offer_Currency__c!=null   ) {
                try
                {           
                    Sanction_Currency__c[] currSanction = [SELECT Departure_Country__c, Account_Number__c FROM Sanction_Currency__c WHERE Destination_Country__c = :quote.ShippingCountryCode__c AND Currency__c = :quote.Offer_Currency__c];          
                    STRING countries = '';
                    List<String> exceptions = new List<String>();
                    for(Integer i=0;i<currSanction.size();i++) {
                        if(currSanction[i].Account_Number__c == quote.ShiptoNumber__c) {                                    
                            exceptions.add(currSanction[i].Departure_Country__c);
                        }
                    }
                    BOOLEAN includeCurrency = false;
                    for(Integer i=0;i<currSanction.size();i++) {
                        try
                        {
                            for(Integer j=0;j<exceptions.size();j++) {
                                if(currSanction[i].Departure_Country__c == exceptions[j]){
                                    includeCurrency = true; 
                                    break;
                                }
                             }
                         } 
                         catch(Exception e)
                         {
                             System.debug('No exceptions');
                         }
                         if(includeCurrency == false){
                                countries = countries + ';' + currSanction[i].Departure_Country__c;
                         }
                    }                
                    quote.Sanctioned_Currencies__c = countries;
                }
                catch(Exception e)
                {
                    quote.Sanctioned_Currencies__c = 'Failed';
                    System.debug('No sanctioned currencies');
                }
            }
        }
       
        //if this is an update, check for any changes & update details
        if(Trigger.isUpdate)
        {
             //Get previous details to check if fields have changed
            CameleonCPQ__Quote__c oldQuote= Trigger.oldMap.get(quote.id);   
            
            // changed contract end date to end of month.
            if (quote.Contract_End_Date__c<>null && oldQuote.Contract_End_Date__c <> quote.Contract_End_Date__c)
            {
                Integer numberOfDays = Date.daysInMonth(quote.Contract_End_Date__c.year(), quote.Contract_End_Date__c.month());
                quote.Contract_End_Date__c= Date.newInstance(quote.Contract_End_Date__c.year(), quote.Contract_End_Date__c.month(), numberOfDays);
            }   
             // changed contract start date to start of month
             if (quote.Contract_Start_Date__c<>null &&  oldQuote.Contract_Start_Date__c<> quote.Contract_Start_Date__c) 
             {      
                quote.Contract_Start_Date__c= Date.newInstance(quote.Contract_Start_Date__c.year(), quote.Contract_Start_Date__c.month(), 1);   
            }
            
            // Update Exchange rate
            if (quote.Quote_Currency__c!=null && quote.Offer_Currency__c!=null && oldQuote.Offer_Currency__c<> quote.Offer_Currency__c) {
                try
                {
                    ExchangeRate__c currExch = [SELECT id, Alt_Rate__c FROM ExchangeRate__c WHERE To_Currency__c= :quote.Quote_Currency__c AND FromCurrency__c= :quote.Offer_Currency__c ORDER BY Validity_Start_Date__c DESC LIMIT 1];
                    quote.Currency_Conversion_rate__c = currExch.Alt_Rate__c;
                    quote.Exchange_Rate__c = currExch.id;
                  
                }
                catch(Exception e)
                {
                    System.debug('Exchange rate not available');
                }
            }
           
         
            
            
            
            // Update Sanctioned Currencies
            if (quote.ShippingCountryCode__c!=null && quote.Offer_Currency__c!=null && (oldQuote.Offer_Currency__c<> quote.Offer_Currency__c || oldQuote.ShippingCountryCode__c<> quote.ShippingCountryCode__c)  ) {
                try
                {           
                    Sanction_Currency__c[] currSanction = [SELECT Departure_Country__c, Account_Number__c FROM Sanction_Currency__c WHERE Destination_Country__c = :quote.ShippingCountryCode__c AND Currency__c = :quote.Offer_Currency__c];          
                    STRING countries = '';
                    List<String> exceptions = new List<String>();
                    for(Integer i=0;i<currSanction.size();i++) {
                        if(currSanction[i].Account_Number__c == quote.ShiptoNumber__c) {                                    
                            exceptions.add(currSanction[i].Departure_Country__c);
                        }
                    }
                    BOOLEAN includeCurrency = false;
                    for(Integer i=0;i<currSanction.size();i++) {
                        try
                        {
                            for(Integer j=0;j<exceptions.size();j++) {
                                if(currSanction[i].Departure_Country__c == exceptions[j]){
                                    includeCurrency = true; 
                                    break;
                                }
                             }
                         } 
                         catch(Exception e)
                         {
                             System.debug('No exceptions');
                         }
                         if(includeCurrency == false){
                                countries = countries + ';' + currSanction[i].Departure_Country__c;
                         }
                    }                
                    quote.Sanctioned_Currencies__c = countries;
                }
                catch(Exception e)
                {
                    quote.Sanctioned_Currencies__c = 'Failed';
                    System.debug('No sanctioned currencies');
                }
            }
            
        }       
        
    }     
        
}