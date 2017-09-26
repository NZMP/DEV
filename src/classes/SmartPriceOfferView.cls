public class SmartPriceOfferView {

    private final ApexPages.StandardController controller;
           
    public SmartPriceOfferView(ApexPages.StandardController controller) 
    {
        this.controller = controller;
    }
   
    public PageReference getRedir() 
    {
        CameleonCPQ__Quote__c qt = [Select id, TotalPrice2USD__c, Contract_Start_Date__c, Contract_End_Date__c From CameleonCPQ__Quote__c Where Id = :ApexPages.currentPage().getParameters().get('id')];

        PageReference newPage;
        //check if this is refreshing a clone
         if (qt.TotalPrice2USD__c == NULL && qt.Contract_Start_Date__c== NULL && qt.Contract_End_Date__c== NULL) {
            newPage = Page.RefreshSmartPriceOffer;
            newPage.getParameters().put('id', qt.id);
            newPage.setRedirect(true);
            
        } else {
                
                if (qt.TotalPrice2USD__c <> NULL && qt.Contract_Start_Date__c== NULL && qt.Contract_End_Date__c== NULL)
                {
                     newPage= new PageReference('/'+qt.id+'/e?retURL='+qt.id);
                    newPage.setRedirect(true);             
           
                }
                else{
                    newPage = Page.CameleonCPQ__CPQQuotePanel;
                    newPage.getParameters().put('id', qt.id);
                    newPage.setRedirect(true);
                }
   
        }
        return  newPage;

        
    }
    
  
       
        

}