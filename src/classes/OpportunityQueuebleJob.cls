/**************************
*Author: MZubair (DC) 22/06/2016
*Description: Queueable class to process the offer
*Change Log:
* 22Jun2016 MZubair : Initial version. 
*
*
*
*
***************************/
public class OpportunityQueuebleJob implements Queueable{
    
    private List<Opportunity> oppList {get;Set;}
    
   
    public OpportunityQueuebleJob(List<Opportunity> oppParameterList){
        oppList = oppParameterList;
    }
    
    public void execute(QueueableContext context) {
        set<Id> shipToChangeSet = new set<Id>();
        set<Id> payerChangeSet = new set<Id>();
        set<Id> OppIdSet = new set<Id>();
        for (Integer i = 0; i < oppList.size() ; i++){
            OppIdSet.add(oppList[i].id);
            if (oppList[i].Ship_To__c != null ){
                shipToChangeSet.add(oppList[i].Ship_To__c);    
            } 
            if (oppList[i].Payer__c != null){
                payerChangeSet.add(oppList[i].Payer__c );    
            } 
        }
        
        Map<Id,Partner_Function__c> partnerFunctionMap = new Map<Id,Partner_Function__c>([SELECT ID, Incoterms_Description__c, Incoterms__c, Incoterms_Part_2__c, Payment_Terms__c
                                                                                           FROM Partner_Function__c
                                                                                           WHERE Id =:shipToChangeSet OR Id=:payerChangeSet]);
        set<String> incoTermsSet = new set<String>();
        map<string,IncoTerms__c> IncoTermsMap= new map<string, IncoTerms__c>();
        for (Partner_Function__c pf : partnerFunctionMap.values()){
             if (pf.Incoterms__c!= null){
                 incoTermsSet.add(pf.Incoterms__c);
             }
        }    
        List<IncoTerms__c> incoTermsList = [SELECT ID, Name, IncoTerms_code__c,IncoTerms_Description__c
                                            FROM IncoTerms__c 
                                            WHERE IncoTerms_code__c IN :incoTermsSet];
        
        for (integer i = 0 ; i < incoTermsList.size();i++){
            IncoTermsMap.put(incoTermsList[i].IncoTerms_code__c, incoTermsList[i]);
        }
        
        set<String> paymentTermsSet = new set<String>();
        map<string,Payment_Term__c> paymentTermsMap= new map<string, Payment_Term__c>();
        for (Partner_Function__c pf : partnerFunctionMap.values()){
             if (pf.Payment_Terms__c!= null){
                 paymentTermsSet.add(pf.Payment_Terms__c);
             }
        }    
        List<Payment_Term__c> paymentTermsList = [SELECT ID, Name, Payment_Terms_Code__c
                                            FROM Payment_Term__c
                                            WHERE Payment_Terms_Code__c IN :paymentTermsSet ];
        
        for (integer i = 0; i < paymentTermsList.size() ; i++){
            paymentTermsMap.put(paymentTermsList[i].Payment_Terms_Code__c,paymentTermsList[i]);
        }  
        
        Map<Id,CameleonCPQ__Quote__c> offerMap = new Map<Id,CameleonCPQ__Quote__c>();
        List<CameleonCPQ__Quote__c>  offerList = [SELECT ID, Incoterms2__c, Incoterms__c, Incoterms_List__c, Payment_Term__c, OpportunityID__C 
                                                 FROM   CameleonCPQ__Quote__c
                                                 WHERE OpportunityID__C IN :OppIdSet]; 
        System.debug('@@##$$ Offer List ' + offerList ) ;                                         
        for ( integer i = 0; i < offerList.size(); i++){
            offerMap.put(offerList[i].OpportunityID__C,offerList[i]);
        }
        
        List<CameleonCPQ__Quote__c> offerUpdateList = new List<CameleonCPQ__Quote__c>();
                                                             
        for (Integer i = 0; i < oppList.size() ; i++){
            CameleonCPQ__Quote__c newOfferObj = new CameleonCPQ__Quote__c();
            system.debug('Part 4');
            if(offerMap.get(oppList[i].id) != null){
                if(shipToChangeSet.contains(oppList[i].Ship_To__c)){
                    newOfferObj.Id = offerMap.get(oppList[i].id).Id;
                    string incoterms =  partnerFunctionMap.get(oppList[i].Ship_To__c).Incoterms__c;  
                    newOfferObj.IncoTerm__c= IncoTermsMap.get(incoterms).Id;
                    newOfferObj.Incoterms2__c= partnerFunctionMap.get(oppList[i].Ship_To__c).Incoterms_Part_2__c;
                } else if (oppList[i].Ship_To__c == null){
                   newOfferObj.Id = offerMap.get(oppList[i].id).Id;
                   newOfferObj.IncoTerm__c = null;
                }
            
                if(payerChangeSet.contains(oppList[i].Payer__c)){
                    newOfferObj.Id = offerMap.get(oppList[i].Id).Id;
                    string paymenterms=  partnerFunctionMap.get(oppList[i].Payer__c).Payment_Terms__c;  
                    newOfferObj.Payment_Term__c= paymentTermsMap.get(paymenterms).Id;
                } else if (oppList[i].Payer__c == null){
                    newOfferObj.Id = offerMap.get(oppList[i].id).Id;
                    newOfferObj.Payment_Term__c = null;
                    system.debug('part 4.2 Payment_Term__c = null');
                }
                if(newOfferObj.id != null){
                    offerUpdateList.add(newOfferObj);
                    system.debug('Part 4.1 offer update list' +offerUpdateList );
                }
            }
        }
        system.debug('Ship to Change set---> ' + shipToChangeSet );
        system.debug('Payer Change set ---> ' + payerChangeSet ) ; 
        if (offerUpdateList.size() > 0 && !Test.IsRunningTest()){
            update offerUpdateList;
        }
        
    }

}