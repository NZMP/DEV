/***************************
* @description: Test class for SFtoSAPWebserviceHandler
* @author: Mahmood Zubair(DC)
* @history:
* 09March2016 MahmoodZ(DC): Initial version
*
*
*******************************/

Global class SFtoSAPWebserviceHandler {
    
    
    webservice static void opportunityBtnPress(string opportunityid){
        set<id> opportunityidset = new set<id>();
        opportunityidset.add(opportunityid);
        OpportunitiestoProcess(opportunityidset);
    }
    
    @future(callout=true)
    public static void FutureMethod(set<id> opportunityIdSet){
        OpportunitiestoProcess(opportunityIdSet);
    }
    
    private static void OpportunitiestoProcess(set<id> opportunityIdSet){
        List<CameleonCPQ__Quote__c> cameleonCPQ_QuoteList = new List<CameleonCPQ__Quote__c>();
        List<OpportunityLineItem> opportunityLineItemList = New List<OpportunityLineItem>();
        map<Id,fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage> calloutResponseMap = new   map<Id,fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage>();
        List<Opportunity> callOutExceptionOpportunityList = new  List<Opportunity>();
        if (opportunityIdSet.size() > 0){
            cameleonCPQ_QuoteList = [SELECT Id, Name, OpportunityId__r.Sales_Organisation__c, OpportunityId__r.Distribution_Channel__c, OpportunityId__r.Offer_Tenure__c,
                                      OpportunityId__r.Division__c, SoldToNumber__c, ShiptoNumber__c, Contract_Start_Date__c, Contract_End_date__c, Payment_Terms__c,
                                      Incoterms__c, Ship_To_IncoTerms__c, OpportunityId__r.Opportunity_No__c, Offer_Currency__c, Offer_Valid_From__c, Offer_Valid_To__c, 
                                      Pricing_Reference_Date__c, Approval_Comments__c, OpportunityId__c, OpportunityId__r.Name, Shipping_Condition_Code__c
                               FROM CameleonCPQ__Quote__c 
                               WHERE OpportunityId__c IN : opportunityIdSet];
                               
            Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>([SELECT Id, Name, Payer__r.Partner_Account_No__c, Ship_to__r.Incoterms_Part_2__c 
                                                  FROM Opportunity WHERE Id IN :opportunityIdSet]);
                             
            OpportunityLineItemList = [SELECT Id, Name, Material_Number__c, Services__c, Selling_UoM__c, Delivery_Plant__c, Application__c, Application_SubType__c,
                                              Volumes_UoM__c,Volumes__c, Months__c, Service_Type__c, Sales_Type__c , SpecialContractType__c, Value_Conditions__c, OpportunityId  
                                      FROM OpportunityLineItem 
                                      Where OpportunityId IN :  opportunityIdSet];                         
            if (cameleonCPQ_QuoteList.size() > 0 ){
        
                for (integer i = 0; i < cameleonCPQ_QuoteList.size(); i++ ){
                
                    //CameleonCPQ__Quote__c cameleonCPQQuote = cameleonCPQ_QuoteList[i];
                    
                    fonterraComGlobalCommon.BusinessDocumentMessageHeader QuoteHeader = createquoteHeader();
                   
                    
                    fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate QuoteBody =createQuote(cameleonCPQ_QuoteList[i], opportunityMap );
                  
                    List<fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems> quoteItemsList = new List<fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems>();
                    
                    Integer itemLevel = 10;
                    Integer highLevel = 10; 
                    
                    for (integer j = 0; j < OpportunityLineItemList.size(); j++ ){
                        if(OpportunityLineItemList[j].OpportunityId == cameleonCPQ_QuoteList[i].OpportunityId__c){
                            List<string> itemsVolumeSet = new List<string>();
                            List<string> itemsMonthSet = new List<string>();
                            List<string> itemsServicesSet = new List<string>();
                            List<string> itemsTypeSet = new List<string>();
                            if(OpportunityLineItemList[j].Volumes__c != null){
                                for(string s : OpportunityLineItemList[j].Volumes__c.split(',')){
                                    itemsVolumeSet.add(s);
                                }
                            }
                            if(OpportunityLineItemList[j].Months__c != null){
                                for(string s : OpportunityLineItemList[j].Months__c.split(',')){
                                    itemsMonthSet.add(s);
                                }
                            }
                            if(OpportunityLineItemList[j].Services__c != null) { 
                                for(string s : OpportunityLineItemList[j].Services__c.split(',')){
                                    itemsServicesSet.add(s);
                                }
                            }
                            if(OpportunityLineItemList[j].Service_Type__c != null){
                                for(string s : OpportunityLineItemList[j].Service_Type__c.split(',')){
                                    itemsTypeSet.add(s);
                                }
                            }
                          
                            for (integer k = 0; k < itemsVolumeSet.size() ; k++){
                                if (highlevel != itemlevel){
                                    highLevel = itemLevel + 10;
                                    itemLevel = itemLevel + 10;
                                }
                                string volume = (itemsVolumeSet.get(k) != null) ? itemsVolumeSet.get(k) : null;
                                string month = (itemsMonthSet.get(k) != null) ? itemsMonthSet.get(k) : null;
                                fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems parentItems  = createQuoteItem(OpportunityLineItemList[j],
                                                                                                      cameleonCPQ_QuoteList[i], 
                                                                                                      volume ,
                                                                                                      month , 
                                                                                                      '',
                                                                                                      '',
                                                                                                      true,
                                                                                                      itemLevel,
                                                                                                      highLevel);

                                system.debug('Parent Items' + parentItems);
                                quoteItemsList.add(parentItems);   
                                 if (itemsServicesSet.size()==0) 
                                {    
                                    highLevel = itemLevel + 10;
                                    itemLevel = ItemLevel + 10;
                                   }                                                
                                for (integer l = 0 ; l < itemsServicesSet.size(); l++){
                                    itemLevel = ItemLevel + 10;
                                    string service = itemsServicesSet.get(l); 
                                    string stype = null;
                                    if (itemsTypeSet.size() > 0 && itemsTypeSet.size() > l) {
                                       stype= itemsTypeSet.get(l);
                                    }
                                    fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems childItems  = createQuoteItem(OpportunityLineItemList[j], 
                                                      cameleonCPQ_QuoteList[i], 
                                                      volume ,
                                                      month , 
                                                      service ,
                                                      stype ,
                                                      false,
                                                      itemLevel,
                                                      highLevel);
                                                      
                                    quoteItemsList.add(childItems);
                                    system.debug('ChildItems' + childItems);
                            
                                }   
                            }
                        }
                    }
                             
                    // quoteItemsList;
                    QuoteBody.CustomerQuoteCreateItems = quoteItemsList;
                    system.debug('fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate' +QuoteBody);
                    system.debug('fonterraComGlobalCommon.BusinessDocumentMessageHeader' + QuoteHeader);
            
                    fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage response = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage();
                    try{
                        response = performcallout(QuoteHeader ,QuoteBody);
                        calloutResponseMap.put(cameleonCPQ_QuoteList[i].OpportunityId__c,response);
                        
                        system.debug('webservice response message header' + response.MessageHeader);
                        system.debug('Customer Quote' + response.customerquote);
                        system.debug('response log' + response.log);
                        fonterraComGlobalCommon.log responselogdetails = response.log;
                        list<fonterraComGlobalCommon.LogItem> logitemList = responselogdetails.Item;
                    
                        system.debug('Log BusinessDocumentProcessingResultCode'+ responselogdetails.BusinessDocumentProcessingResultCode  ); 
                        system.debug('Log MaximumLogItemSeverityCode' + responselogdetails.MaximumLogItemSeverityCode );
                        for(integer z = 0; z < logitemList.size() ; z++){
                            system.debug( string.valueof(z)+ ' logitem TypeID =' +logitemList[z].TypeID);
                            system.debug( string.valueof(z)+ ' logitem CategoryCode='+ logitemList[z].CategoryCode);
                            system.debug( string.valueof(z)+ ' logitem SeverityCode='+ logitemList[z].SeverityCode);
                            system.debug( string.valueof(z)+ ' logitem Note='+ logitemList[z].Note);
                            system.debug( string.valueof(z)+ ' logitem WebURI='+ logitemList[z].WebURI);
                        }
                    }catch (CalloutException excpObj) {
                        string  errordetails = 'Date Created ' + String.Valueof(Datetime.Now()) + '\n' ;  
                        errordetails += 'Error Cause = ' + excpObj.getCause() + '\n';
                        errordetails  += 'Error Message = ' +  excpObj.getmessage();
                        callOutExceptionOpportunityList.Add( New Opportunity(id =cameleonCPQ_QuoteList[i].OpportunityId__c,
                                                                             SAP_Status__c = 'Error',
                                                                             SAP_Message__c = errordetails));
                    }
 
                   
                }
                updaterelatedOpportunitites(calloutResponseMap);
                if (callOutExceptionOpportunityList.size() > 0){
                    update callOutExceptionOpportunityList;
                }
            }        
        }   
    }
    
    private static fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems createQuoteItem(OpportunityLineItem oppLineItem, CameleonCPQ__Quote__c camCPQQuote, 
                                                                                       string volume, string RequestedDate, string service, string stype,
                                                                                       boolean parentitem, integer itemlevel,integer highlevel){
                                                                                                                                                                                 
        fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems Items = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateItems();
        //fonterraComGlobalCommon.CustomerQuoteID ItemLevelID = new  fonterraComGlobalCommon.CustomerQuoteID() ;
        //fonterraComGlobalCommon.CustomerQuoteID HighLevelItemID  = new  fonterraComGlobalCommon.CustomerQuoteID();
        
        if (parentitem == true){
           
            items.ItemLevel = String.Valueof(highlevel); 
            items.HighLevelItem = ''; 
            items.Product = (oppLineItem.material_Number__c != null) ? oppLineItem.material_Number__c : '' ;
            items.DeliveryControl = '';
        } else {
           
            items.ItemLevel = String.Valueof(itemlevel); 
            items.HighLevelItem =String.Valueof(highlevel); 
            items.Product = (service != null) ? service :'';
            Items.DeliveryControl = (stype != null) ? stype : '';
        }
       
        Items.SpecialContractType = ( oppLineItem.SpecialContractType__c != null) ? oppLineItem.SpecialContractType__c: '';    
       
        
        Items.SalesUnit = ( oppLineItem.Selling_UoM__c != null) ? oppLineItem.Selling_UoM__c : '';
        Items.GBApplicationCode = ( oppLineItem.Application__c != null) ? oppLineItem.Application__c : '';
        Items.CustomerApplication = ( oppLineItem.Application_SubType__c != null) ? oppLineItem.Application_SubType__c : '';
        Items.SalesType = ( oppLineItem.Sales_Type__c != null) ? oppLineItem.Sales_Type__c : null;
       // fonterraComGlobalCommon.PlantID DeliveryPlant = new fonterraComGlobalCommon.PlantID();
       // DeliveryPlant.schemeAgencyID = ( opplineItem.Delivery_Plant__c != null) ? opplineItem.Delivery_Plant__c : null ;
        Items.DeliveryPlant = ( opplineItem.Delivery_Plant__c != null) ? opplineItem.Delivery_Plant__c : '';
        
        if (parentitem == true && opplineItem.Value_Conditions__c != null ){
            list<fonterraComGiSfMakeandmanageoffer.PriceComponent_element> PriceComponentLst = new list<fonterraComGiSfMakeandmanageoffer.PriceComponent_element>();
            map<string,string> ValueConitionsMap = new map<string,string>();
            integer v = 0;
            
            for(string s : opplineItem.Value_Conditions__c.split(',')){
                v++;
                if (v == 1)
                ValueConitionsMap.put('ZNEG',s);
                else if ( v == 2)
                ValueConitionsMap.put('ZDST',s);
                else if ( v == 3)
                ValueConitionsMap.put('ZP00',s);
                else if ( v == 4)
                ValueConitionsMap.put('ZMAS',s);
                else if ( v == 5)
                ValueConitionsMap.put('ZOMN',s);
            }
            
            for (string s : ValueConitionsMap.keySet()){
                fonterraComGiSfMakeandmanageoffer.PriceComponent_element priceCom = new fonterraComGiSfMakeandmanageoffer.PriceComponent_element();
                //fonterraComGlobalCommon.PriceSpecificationElementTypeCode PricingCondition = new fonterraComGlobalCommon.PriceSpecificationElementTypeCode();
                //PricingCondition.listID = s;
                priceCom.PricingConditionType = s;
                priceCom.PricingConditionValue = ValueConitionsMap.get(s);
                priceCom.ConditionCurrency = (camCPQQuote.Offer_Currency__c != null) ? camCPQQuote.Offer_Currency__c : '';
                if (oppLineItem.Selling_UoM__c != null){ 
                    if (oppLineItem.Selling_UoM__c == 'TNE'){
                        priceCom.ConditionUOM = 'KGM';
                    } else{
                        priceCom.ConditionUOM = oppLineItem.Selling_UoM__c ;
                    }               
                } else{
                     priceCom.ConditionUOM = '';  
                }
                
                
                priceCom.BaseConditionValue = (priceCom.ConditionUOM == 'KGM')? '1000' : '1';
                PriceComponentLst.add(priceCom);
            }
            if (PriceComponentLst.size() > 0){
                Items.PriceComponent = PriceComponentLst; 
            }
        }
        
        list<fonterraComGlobalCommon.ScheduleLine> ScheduleLineLst = new List<fonterraComGlobalCommon.ScheduleLine>();
        fonterraComGlobalCommon.ScheduleLine schedule = new fonterraComGlobalCommon.ScheduleLine();
        schedule.LineNumber = '';
        schedule.Date_x = formatDate(RequestedDate);  
        //fonterraComGlobalCommon.Quantity Quantity = new fonterraComGlobalCommon.Quantity();
        //Quantity.unitCode = 'TNE';
        //Quantity.Content = volume ;
        schedule.RequestedQuantity= volume;
        schedule.DeliveryBlockingReasonCode ='DeliveryBlockingReasonCode';
        ScheduleLineLst.add(schedule);
        items.ScheduleLine = ScheduleLineLst;
        
        return items;
      //  null;
    }
    
    private static fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate createQuote(CameleonCPQ__Quote__c cameleonCPQQuote, map<Id,Opportunity> oppMap){
        fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate customerQuote = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate();
        customerQuote.ShippingConditions = (cameleonCPQQuote.Shipping_Condition_Code__c != null) ? cameleonCPQQuote.Shipping_Condition_Code__c : '';
        customerQuote.QuotationType = 'ZGQC';
        customerQuote.SalesOrganisation = (cameleonCPQQuote.OpportunityId__r.Sales_Organisation__c != null) ? cameleonCPQQuote.OpportunityId__r.Sales_Organisation__c : '';
        customerQuote.DistributionChannel =(cameleonCPQQuote.OpportunityId__r.Distribution_Channel__c != null) ? cameleonCPQQuote.OpportunityId__r.Distribution_Channel__c : '';
        customerQuote.SoldToParty = (cameleonCPQQuote.SoldToNumber__c != null) ? cameleonCPQQuote.SoldToNumber__c : '';
        customerQuote.ShipToParty = (cameleonCPQQuote.ShiptoNumber__c != null) ? cameleonCPQQuote.ShiptoNumber__c : '';
        customerQuote.RequestedDeliveryDate = (cameleonCPQQuote.Contract_Start_Date__c != null) ? formatDate(cameleonCPQQuote.Contract_Start_Date__c) : '';
        customerQuote.ContractStartDate = (cameleonCPQQuote.Contract_Start_Date__c != null) ? formatDate(cameleonCPQQuote.Contract_Start_Date__c) : '';
        customerQuote.ContractEndDate =(cameleonCPQQuote.Contract_End_Date__c != null) ? formatDate(cameleonCPQQuote.Contract_End_Date__c) : '';
        customerQuote.OpportunityID =(cameleonCPQQuote.OpportunityId__r.Opportunity_No__c != null) ? cameleonCPQQuote.OpportunityId__r.Opportunity_No__c : '';
        customerQuote.Currency_x =(cameleonCPQQuote.Offer_Currency__c != null) ? cameleonCPQQuote.Offer_Currency__c : 'USD';
        customerQuote.ValidityStartDate =(cameleonCPQQuote.Offer_Valid_From__c != null) ? formatDate(cameleonCPQQuote.Offer_Valid_From__c) : '';
        customerQuote.ValidityEndDate =(cameleonCPQQuote.Offer_Valid_To__c != null) ? formatDate(cameleonCPQQuote.Offer_Valid_To__c) : '';
        customerQuote.PricingDate =(cameleonCPQQuote.Pricing_Reference_Date__c != null) ? formatDate(cameleonCPQQuote.Pricing_Reference_Date__c) : '';
      
        customerQuote.IncoTerms1 = (cameleonCPQQuote.IncoTerms__c != null) ? cameleonCPQQuote.IncoTerms__c : '';
        if (oppMap.containskey(cameleonCPQQuote.OpportunityId__c) && oppMap.get(cameleonCPQQuote.opportunityId__c).Ship_to__r != null ){
            customerQuote.IncoTerms2 = (oppMap.get(cameleonCPQQuote.OpportunityId__c).Ship_to__r.Incoterms_Part_2__c != null) ? oppMap.get(cameleonCPQQuote.OpportunityId__c).Ship_to__r.Incoterms_Part_2__c  : '';
        }
        //customerQuote.IncoTerms2 = (cameleonCPQQuote.Ship_To_IncoTerms__c != null) ? cameleonCPQQuote.Ship_To_IncoTerms__c  : '';
        customerQuote.paymentTerms = (cameleonCPQQuote.Payment_Terms__c!= null) ? cameleonCPQQuote.Payment_Terms__c: '';
        customerQuote.Division = (cameleonCPQQuote.OpportunityId__r.Division__c != null) ? cameleonCPQQuote.OpportunityId__r.Division__c : '';
        
        List<fonterraComGiSfMakeandmanageoffer.Party_element>  PartyList = new List<fonterraComGiSfMakeandmanageoffer.Party_element>();
        fonterraComGiSfMakeandmanageoffer.Party_element partyElement = new  fonterraComGiSfMakeandmanageoffer.Party_element();
        partyElement.RoleCode = '';
        if (oppMap.containskey(cameleonCPQQuote.opportunityId__c) && oppMap.get(cameleonCPQQuote.opportunityId__c).Payer__r != null ){
            partyElement.Payer = (oppMap.get(cameleonCPQQuote.opportunityId__c).Payer__r.Partner_Account_No__c != null) ? oppMap.get(cameleonCPQQuote.opportunityId__c).Payer__r.Partner_Account_No__c  : '';
        }
        //partyElement.Payer = '101256';
        PartyList.add(partyElement);
        
        customerQuote.Party = PartyList;
        customerQuote.SenderSystem =label.PRICING_SAP_SYSTEM;
        //Mahmood Zubair 09/03/2016 Calling the  
        if (cameleonCPQQuote.Approval_Comments__c != null){
            
            List<fonterraComGiSfMakeandmanageoffer.TextCollection_element> TextCollectionList = new    List<fonterraComGiSfMakeandmanageoffer.TextCollection_element>();
            fonterraComGiSfMakeandmanageoffer.TextCollection_element TxtCollectionElement = new fonterraComGiSfMakeandmanageoffer.TextCollection_element();
            TxtCollectionElement.TypeCode = 'ZG01';
            TxtCollectionElement.ContentText = cameleonCPQQuote.Approval_Comments__c;
  
            TextCollectionList.add(TxtCollectionElement);
        
            customerQuote.TextCollection = TextCollectionList;
        }
        return customerQuote;
    }       
    
    private static  fonterraComGlobalCommon.BusinessDocumentMessageHeader  createQuoteHeader(){
         fonterraComGlobalCommon.BusinessDocumentMessageHeader QuoteHeader = new  fonterraComGlobalCommon.BusinessDocumentMessageHeader();       
         QuoteHeader.SenderBusinessSystemID = label.PRICING_SAP_SYSTEM; 
         QuoteHeader.ID = '';
         QuoteHeader.UUID = '';
         QuoteHeader.ReferenceID = '';
         QuoteHeader.ReferenceUUID = '';
         QuoteHeader.CreationDateTime = '';
         QuoteHeader.TestDataIndicator = '';
         QuoteHeader.RecipientBusinessSystemID = '';
         
    
         return QuoteHeader;
       
    }
    
    
    private static fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage performCallOut(fonterraComGlobalCommon.BusinessDocumentMessageHeader QuoteHeader  , fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreate QuoteBody ){
        
        fonterraComGiSfMakeandmanageoffer.HTTPS_Port callout = new fonterraComGiSfMakeandmanageoffer.HTTPS_Port();
        //callout.clientCert_x= label.PRICING_USER;
        //callout.clientCertPasswd_x =label.PRICING_PASS;
        callout.inputHttpHeaders_x = new map<string,string>();
        
        callout.inputHttpHeaders_x.put('Authorization', label.PRICING_SAP_AUTHORIZATION);    //SV9DUFFfWF9YRDI6RG9sUGhpbjAwMQ==');
        callout.inputHttpHeaders_x.put('Content-Type', 'text/xml;charset=UTF-8');
        callout.inputHttpHeaders_x.put('Connection','Keep-Alive');
        callout.inputHttpHeaders_x.put('UserName',label.PRICING_SAP_USER);
        callout.inputHttpHeaders_x.put('Password',label.PRICING_SAP_PASSWORD);
        callout.inputHttpHeaders_x.put('SOAPAction','"http://sap.com/xi/WebService/soap1.1"');
        callout.inputHttpHeaders_x.put('Accept-Encoding','gzip,deflate');
        callout.endpoint_x = label.PRICING_SAP_ENDPOINT;// 'http://requestb.in/r0qn9sr0'
        //callout.endpoint_x =  'http://requestb.in/1c3a9li1';
        callout.timeout_x =100000;
        
        
        fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage response = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage();
        if (!Test.IsRunningTest()){
            response = callout.CustomerQuoteCreateRequestConfirmation(QuoteHeader ,QuoteBody );
        }else {
            response =createDummyResponse();
        }
        
        return response;                    
    
    }
    
    private static void updaterelatedOpportunitites(map<Id,fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage> calloutResponseMap){
        List<Opportunity> opportunitesToUpdateList = new List<Opportunity>();
             
        for (Id opportunityid : calloutResponseMap.keyset()){
             fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage response = calloutResponseMap.get(opportunityid);
             Opportunity oppUpdateObj = new Opportunity(); 
             oppUpdateObj.id = opportunityid; 
             string warningMessage = '';
             fonterraComGlobalCommon.log responselogdetails = response.log;
             list<fonterraComGlobalCommon.LogItem> logitemList = responselogdetails.Item;
             warningMessage = 'Date Created ' + String.Valueof(Datetime.Now()) + '\n' ;       
             warningMessage += 'BusinessDocumentProcessingResultCode = '+ responselogdetails.BusinessDocumentProcessingResultCode +'\n'; 
             warningMessage += 'MaximumLogItemSeverityCode =' + responselogdetails.MaximumLogItemSeverityCode +'\n';
             for(integer z = 0; z < logitemList.size() ; z++){
                 warningMessage += string.valueof(z)+ ' logitem TypeID =' +logitemList[z].TypeID + '\n';
                 warningMessage += string.valueof(z)+ ' logitem CategoryCode='+ logitemList[z].CategoryCode + '\n' ;
                 warningMessage += string.valueof(z)+ ' logitem SeverityCode='+ logitemList[z].SeverityCode + '\n';
                 warningMessage += string.valueof(z)+ ' logitem Note='+ logitemList[z].Note + '\n' ;
                 warningMessage += string.valueof(z)+ ' logitem WebURI='+ logitemList[z].WebURI + '\n\n';
             }
             if(response.customerquote != null){
                 oppUpdateObj.Offer__c = string.valueof(response.customerquote);
                 oppUpdateObj.SAP_Status__c = 'Sent';            
                 oppUpdateObj.SAP_Message__c = warningMessage ;
                  
             } else if(response.log != null &&  responselogdetails.MaximumLogItemSeverityCode=='3'){
                 oppUpdateObj.SAP_Status__c = 'Error'; 
                
                 oppUpdateObj.SAP_Message__c = warningMessage ; 
                            
             }else if(response.log != null &&  responselogdetails.MaximumLogItemSeverityCode=='2'){
                 oppUpdateObj.SAP_Status__c = 'Warning'; 
                
                 oppUpdateObj.SAP_Message__c = warningMessage ; 
                            
             }
             if (oppUpdateObj.SAP_Status__c != null)
                 opportunitesToUpdateList.add(oppUpdateObj);
             
        }
        
        if(opportunitesToUpdateList.size() > 0){
            update opportunitesToUpdateList;
        }
    
    } 
    
    private static String formatDate(Date dt){
        integer day = dt.day();
        integer month = dt.month();
        integer year = dt.year();
        string strdate = string.valueof(day)+'.'+string.valueof(month)+'.'+string.valueof(year);
        return strdate;
    } 
    
    private static String formatDate(string dt){
        string day = dt.substring(6,8);
        string month = dt.substring(4,6);
        string year = dt.substring(0,4);
        string strdate = day+'.'+month+'.'+year;

        return strdate;
    } 
    
    private static fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage createDummyResponse(){
           fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage respElement = new fonterraComGiSfMakeandmanageoffer.CustomerQuoteCreateConfirmationMessage();
           respElement.customerquote = '2323232';
           respElement.MessageHeader = null;
           fonterraComGlobalCommon.log responselogdetails = new fonterraComGlobalCommon.log();
           responselogdetails.BusinessDocumentProcessingResultCode= '5';
           responselogdetails.MaximumLogItemSeverityCode = '3';
           list<fonterraComGlobalCommon.LogItem> logitemList = new list<fonterraComGlobalCommon.LogItem>();
           fonterraComGlobalCommon.LogItem logitem1 = new fonterraComGlobalCommon.LogItem();
           logitem1.TypeID = 'TypeID';
           logitem1.CategoryCode = 'CategoryCode';
           logitem1.SeverityCode = 'SeverityCode';
           logitem1.Note = 'Note';
           logitem1.WebURI = 'WebURI'; 
           logitemList.add(logitem1);
           responselogdetails.item= logitemList;
           respElement.log = responselogdetails;
           return respElement;
    
    }
        
}