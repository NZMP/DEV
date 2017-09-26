/***************************
* @description: Opportunity Trigger Handler Class. 
* @author: Mahmood Zubair(DC)
* @history:
* 15March2016 MahmoodZ(DC): Initial version
* 22June2016 MahmoodZ(DC): Adding the Process Ship TO and Payer details changes. 
*
*******************************/
public class OpportunityTriggerHandler{

    public static boolean isExecuted = false;
    
    public static void processOppsForSAP(List<Opportunity> newOppList, Map<Id,Opportunity> oldMap){
        RecordType smartPriceRecordtype = [SELECT ID, Name  FROM RecordType Where SObjectType = 'Opportunity' AND DeveloperName='Fonterra_SmartPrice' LIMIT 1]; 
        set<id> OpportuntiestoProcessSet = new set<id>();
        set<id> OpportuntiestoProcessSet2 = new set<id>();
        integer j = 0;
        for(Integer i = 0; i < newOppList.Size(); i++){
            if(newOppList[i].Offer_Status__c == 'Customer_Accepted' && oldMap.get(newOppList[i].id).Offer_Status__c != 'Customer_Accepted' && newOppList[i].RecordTypeId == smartPriceRecordtype.Id){
                j++;
                if ( J < 80){
                    OpportuntiestoProcessSet.add(newOppList[i].id);
                } else {
                    OpportuntiestoProcessSet2.add(newOppList[i].id); 
                }
            }
        }
        
        if (OpportuntiestoProcessSet.size() > 0){
             SFtoSAPWebserviceHandler.FutureMethod(OpportuntiestoProcessSet);
             isExecuted = true;
        }
        
        if (OpportuntiestoProcessSet2.size() > 0){
             SFtoSAPWebserviceHandler.FutureMethod(OpportuntiestoProcessSet2); 
             isExecuted = true;     
        }
    }
    
    public static void opportunityContactTrigger2(List<Opportunity> newOppList, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        set<id> oldOpportunityIdSet = new set<id>();
        
        for(Integer i = 0; i < newOppList.Size(); i++){
            if(newOppList[i].Offer_Status__c == 'Customer_Accepted' && oldMap.get(newOppList[i].id).Offer_Status__c != 'Customer_Accepted'){ 
                oldOpportunityIdSet.add(newOppList[i].Id); 
            }
        }
        
        map<String,String> newOpportunityId2Customer = new map<String,String>();
        for (Id key : newMap.keySet()) {
          Opportunity newOpp = newMap.get(key);
          newOpportunityId2Customer.put(key, newOpp.Ship_To_Account_Number__c + '_' + newOpp.Sold_To_Account_Number__c);
        }
          
        System.debug('oldOpportunityIdSet.size():' + oldOpportunityIdSet.size());        
        
        if(oldOpportunityIdSet.size() > 0){
          PPSSPriceGuidance.putData2(oldOpportunityIdSet, newOpportunityId2Customer);
          isExecuted = true;   
        }
    }
      public static void rejectRecord(List<Opportunity> oppList){
           set<Id> OppIdSet = new set<Id>();
            for (Integer i = 0; i < oppList.size() ; i++){
                OppIdSet.add(oppList[i].id);
            }
           Set<Id> pInstanceWorkitems = (new Map<Id, ProcessInstanceWorkitem>([SELECT Id,ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in : OppIdSet])).keySet();
           Approval.ProcessWorkitemRequest[] allReq = New Approval.ProcessWorkitemRequest[]{}; 
            for (Id pInstanceWorkitemsId:pInstanceWorkitems){
                system.debug(pInstanceWorkitemsId);
                Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                req2.setComments('Auto rejected on offer expiry.');
                req2.setAction('Reject'); //to approve use 'Approve'


                // Use the ID from the newly created item to specify the item to be worked
                req2.setWorkitemId(pInstanceWorkitemsId);

                // Add the request for approval
                allReq.add(req2);
            }
            Approval.ProcessResult[] result2 =  Approval.process(allReq);
           }

/*    //Get ProcessInstanceWorkItemId using SOQL
    public static Id getWorkItemId(Id targetObjectId){
        Id retVal = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            retVal  =  workItem.Id;
        }

        return retVal;
        }
         public static void rejectRecord(Opportunity opp){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Auto rejected on offer expiry');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(opp.id);


        if(workItemId == null){
           // opp.addError('Error Occured in Trigger');
           //continue to expire

        }
        else{
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
   
 */   
    //MahmoodZ(DC) Method to Fire when Ship to and Payer on Opportunity Changes to Updated the corresponding offer.
          
    /*  
    public static void processShipToAndPayerChange(List<Opportunity> oppList){
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
        List<IncoTerms__c> incoTermsList = [SELECT ID, Name, IncoTerms_code__c
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
            if(shipToChangeSet.contains(oppList[i].Ship_To__c)){
                newOfferObj.Id = offerMap.get(oppList[i].id).Id;
                string incoterms =  partnerFunctionMap.get(oppList[i].Ship_To__c).Incoterms__c;  
                newOfferObj.IncoTerm__c= IncoTermsMap.get(incoterms).Id;
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
        system.debug('Ship to Change set---> ' + shipToChangeSet );
        system.debug('Payer Change set ---> ' + payerChangeSet ) ; 
        if (offerUpdateList.size() > 0){
            update offerUpdateList;
        }
         isExecuted = true; 
    
    }
     
   public the old way of doing it - superseded by opportunityContactTrigger2 
    private  static void opportunityContactTrigger(List<Opportunity> newOppList, Map<Id,Opportunity> oldMap, Map<Id,Opportunity> newMap){
        set<id> oldOpportunityIdSet = new set<id>();
        
        for(Integer i = 0; i < newOppList.Size(); i++){
            if(newOppList[i].Offer_Status__c == 'Customer_Accepted' && oldMap.get(newOppList[i].id).Offer_Status__c != 'Customer_Accepted'){ 
                oldOpportunityIdSet.add(newOppList[i].Id); 
            }
        }
           
        if(oldOpportunityIdSet.size() > 0){
         
            map<id,CameleonCPQ__Quote__c> camQuoteMap = new map<id,CameleonCPQ__Quote__c>();
            List<CameleonCPQ__Quote__c>  camQuoteList = [SELECT ID, 
                                                                contract_start_date__c, 
                                                                contract_end_date__c, 
                                                                Pricing_Reference_Date__c, 
                                                                OpportunityId__c  
                                                         FROM CameleonCPQ__Quote__c
                                                         WHERE OpportunityId__c IN :oldOpportunityIdSet
                                                               AND CameleonCPQ__Status__c = 'Customer_Accepted']; 
                                                           
            for(Integer i = 0; i < camQuoteList.size(); i++){
                camQuoteMap.put(camQuoteList[i].OpportunityId__c , camQuoteList[i]); 
            }
            
            List<OpportunityLineItem> oppLineList= [SELECT Months__c,   // comma delimited string
                                                           Services__c, // comma delimited string
                                                           Target_Price__c,
                                                           Stretch_Price__c,
                                                           Raw_Target__c,
                                                           Raw_Stretch__c,
                                                           Raw_Floor__c,
                                                           Quantity,
                                                           ProductCode,
                                                           Floor_Price__c,
                                                           OpportunityId 
                                                    FROM OpportunityLineItem
                                                    WHERE OpportunityId = :oldOpportunityIdSet];
                                                    
            Date contractStartDate  = date.newinstance(9999, 12, 31);
            Date contractEndDate    = date.newinstance(9999, 12, 31);
            Date priceReferenceDate = date.newinstance(9999, 12, 31); 
            ContractKeyGenerator keyGen = new ContractKeyGenerator();                                   
            
            for(Integer i = 0; i < oppLineList.size(); i++){
                if (camQuoteMap.containskey(oppLineList[i].OpportunityId)){
                    contractStartDate = camQuoteMap.get(oppLineList[i].OpportunityId).contract_start_date__c;
                    contractEndDate = camQuoteMap.get(oppLineList[i].OpportunityId).contract_end_date__c ;
                    priceReferenceDate = camQuoteMap.get(oppLineList[i].OpportunityId).Pricing_Reference_Date__c;
                } 
                
                System.debug('**** sending opportunity line item values ****** '+
                            newMap.get(oppLineList[i].OpportunityId).Offer__c + ' '+ oppLineList[i].Id + ' ' +oppLineList[i].ProductCode + ' ' + newMap.get(oppLineList[i].OpportunityId).Ship_To_Account_Number__c + ' ' +
                            oppLineList[i].Target_Price__c);
                            
                List<String> lineItemKeys = keyGen.generateKeys(oppLineList[i].Months__c,oppLineList[i].Services__c);
                for (String key : lineItemKeys){
                     
                     PPSSPriceGuidance.putData(1 ,
                                          key,
                                          newMap.get(oppLineList[i].OpportunityId).Ship_To_Account_Number__c+ '_'+ newMap.get(oppLineList[i].OpportunityId).Sold_To_Account_Number__c,
                                          oppLineList[i].ProductCode,
                                          oppLineList[i].Floor_Price__c,
                                          oppLineList[i].Stretch_Price__c,
                                          oppLineList[i].Target_Price__c,
                                          oppLineList[i].Raw_Floor__c,
                                          oppLineList[i].Raw_Stretch__c,
                                          oppLineList[i].Raw_Target__c,
                                          contractStartDate,
                                          contractEndDate,
                                          priceReferenceDate);
                                          
                     isExecuted = true;                     
                
                }
            }   
        }  
    }*/
    
}