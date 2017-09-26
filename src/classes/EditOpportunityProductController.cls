public class EditOpportunityProductController {

    public OpportunityLineItem originalRecord {set;get;}
    public OpportunityLineItem cloneRecord{set;get;}
    
    public String productName {set; 
        get{
            if(productName==null){
                productName ='';
            }
            return productName;
        }
    }
    public String selectedProductId {set; get;}
    public List<SelectOption> productList {set;get;}
    
    public String showingCount{set; get;}
    
    public String errorMessage {set; get;}
    
    public EditOpportunityProductController(ApexPages.StandardController acon){
        errorMessage='';
        String originalRecordId = acon.getId();
        originalRecord = [select 
                            id, 
                            PricebookEntry.pricebook2id,
                            PricebookEntry.unitPrice,
                            Quantity,
                            ServiceDate,
                           
                            Description,
                            opportunityId,
                            Estimated_PA_MT__c,
                            Fees__c,
                          
                            FY1_PA__c,
                            FY1_Revenue__c,
                            FY1_Volume__c,
                            FY2_PA__c,
                            FY2_Revenue__c,
                            FY2_Volume__c,
                            FY3_PA__c,
                            FY3_Revenue__c,
                            FY3_Volume__c,
                            FY4_PA__c,
                            FY4_Revenue__c,
                            FY4_Volume__c,
                            FY5_PA__c,
                            FY5_Revenue__c,
                            FY5_Volume__c,
                            Product_Deal_Structure__c,
                            Volume_Change__c,
                            Quantity_Unit__c
                          from OpportunityLineItem 
                          where id=:originalRecordId];
        cloneRecord=cloningRecord();
        findProduct();
    }

    public PageReference findProduct(){
        List<PriceBookEntry> pbEntries=null;
        if(productName==null || productName==''){
            pbEntries = [select id,name,product2id,product2.name,UnitPrice,product2.Material_Number__c ,product2.Material_Type_Description__c from PriceBookEntry where pricebook2id=: originalRecord.PricebookEntry.pricebook2id and isActive=true order by Name limit 100];
        }else{   
            String pname = '%'+productName+'%';
            pbEntries = [select id,name,product2id,product2.name,UnitPrice,product2.Material_Number__c,product2.Material_Type_Description__c  from PriceBookEntry where pricebook2id=: originalRecord.PricebookEntry.pricebook2id and (Name like :pname or product2.Material_Number__c like :pname or product2.Material_Type_Description__c like :pname )and isActive=true order by Name limit 100];
        }
        productList = new List<SelectOption>();
        for(PriceBookEntry pbe : pbEntries){
            SelectOption option = new SelectOption(pbe.id, pbe.name+' | '+pbe.product2.Material_Number__c+' | '+pbe.product2.Material_Type_Description__c);
            productList.add(option);
        }
        
        showingCount = 'Showing '+pbEntries.size()+' from ';
        if(pbEntries.size()<100){
            showingCount += pbEntries.size();
        }else{
            Integer count = 0;
            if(productName==null || productName==''){
                count = [select count() from PriceBookEntry where pricebook2id=: originalRecord.PricebookEntry.pricebook2id and isActive=true limit 1000];
            }else{   
                String pname = '%'+productName+'%';
                count = [select count() from PriceBookEntry where pricebook2id=: originalRecord.PricebookEntry.pricebook2id and Name like :pname and isActive=true limit 1000];
            }
            if(count<1000){
                 showingCount += count;
            }else{
                 showingCount += '1000+';
            }
        }
        showingCount += ' products';
        
        return null;
    }
    
    public PageReference cancel(){
       return new PageReference('/'+originalRecord.Id);
    }
    
    private OpportunityLineItem cloningRecord(){
        OpportunityLineItem newRecord = new OpportunityLineItem();
        
        newRecord.PricebookEntryId =          selectedProductId;
        newRecord.Quantity =                  originalRecord.Quantity;
        newRecord.ServiceDate =               originalRecord.ServiceDate;
        
        newRecord.Description =               originalRecord.Description;
        newRecord.opportunityid=              originalRecord.opportunityId;
        newRecord.Estimated_PA_MT__c =        originalRecord.Estimated_PA_MT__c;
        newRecord.Fees__c =                   originalRecord.Fees__c;
       
        newRecord.FY1_PA__c =                 originalRecord.FY1_PA__c;
        newRecord.FY1_Revenue__c =            originalRecord.FY1_Revenue__c;
        newRecord.FY1_Volume__c =             originalRecord.FY1_Volume__c;
        newRecord.FY2_PA__c =                 originalRecord.FY2_PA__c;
        newRecord.FY2_Revenue__c =            originalRecord.FY2_Revenue__c;
        newRecord.FY2_Volume__c =             originalRecord.FY2_Volume__c;
        newRecord.FY3_PA__c =                 originalRecord.FY3_PA__c;
        newRecord.FY3_Revenue__c =            originalRecord.FY3_Revenue__c;
        newRecord.FY3_Volume__c =             originalRecord.FY3_Volume__c;
        newRecord.FY4_PA__c =                 originalRecord.FY4_PA__c;
        newRecord.FY4_Revenue__c =            originalRecord.FY4_Revenue__c;
        newRecord.FY4_Volume__c =             originalRecord.FY4_Volume__c;
        newRecord.FY5_PA__c =                 originalRecord.FY5_PA__c;
        newRecord.FY5_Revenue__c =            originalRecord.FY5_Revenue__c;
        newRecord.FY5_Volume__c =             originalRecord.FY5_Volume__c;
        newRecord.Product_Deal_Structure__c = originalRecord.Product_Deal_Structure__c;
        newRecord.Volume_Change__c =          originalRecord.Volume_Change__c;
        newRecord.Quantity_Unit__c =          originalRecord.Quantity_Unit__c;
        return newRecord;
    }
    
    public PageReference save(){
        PriceBookEntry pbentry = [select id,UnitPrice from PriceBookEntry where id=:cloneRecord.PricebookEntryid];
        cloneRecord.TotalPrice = cloneRecord.Quantity*pbentry.unitPrice;
        
        Savepoint sp = Database.setSavepoint();
        try{
            delete originalRecord;
            insert cloneRecord;
        }catch (Exception e){
            // Rollback to the previous null value
            Database.rollback(sp);
            return new PageReference('/'+originalRecord.Id);
        }
        return new PageReference('/'+cloneRecord.Id);
    }
    
    private boolean validate(){
        if(cloneRecord.Quantity==null){
            cloneRecord.quantity.addError('Quantity must be provided.');
            return false;
        }
        if(cloneRecord.Quantity<=0){
            cloneRecord.quantity.addError('Quantity must be greater than zero.');
            return false;
        }
        return true;
    }
}