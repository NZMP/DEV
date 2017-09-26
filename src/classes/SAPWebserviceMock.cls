/***************************
* @description: Test class for SFtoSAPWebserviceHandler
* @author: Mahmood Zubair(DC)
* @history:
* 14March2016 MahmoodK(DC): Initial version
*
*
*******************************/


@isTest
global class SAPWebserviceMock implements WebServiceMock {
   global void doInvoke(
           Object stub,
           Object request,
           Map<String, Object> response,
           String endpoint,
           String soapAction,
           String requestName,
           String responseNS,
           String responseName,
           String responseType) {
       
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
                   
       response.put('response_x', respElement); 
   }
}