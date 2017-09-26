public class CPQCatalogIntegration {
  
  private static String slotNo;
  private static Long iStepCurr;
  private static String uploadFileName;
  private static Product2[] pp;
  private static Long ppBeg;
  private static Long ppEnd; 
  private static Double WaitBegMilliseconds; 
  private static Boolean bWaitFirstOtherwiseLast; 
  private static Long chunk;  
     
  
  private static void continuationCalloutReset() 
  {
    slotNo = null;
    iStepCurr = 0;
    uploadFileName = null;
    pp = null;
    ppBeg = null;
    ppEnd = null;     
    WaitBegMilliseconds = 0;   
    bWaitFirstOtherwiseLast = true;     
    chunk = 50;
  }     
  
  static {
    continuationCalloutReset();
  }
  
  private static final String sHeader_FMT = '<?xml version=\'\'1.0\'\' encoding=\'\'UTF-8\'\'?>\n' +
  '<!--CAMELEON SOFTWARE - EMODELING EXPORT - Generation Date : 24/02/2016 21:23:06-->\n' +
  '<export xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n' +
  '  <importExportMetadata workspaceName="' + CPQGlobals.sWorkspace + '">\n' +
  '    <exportDate>{0}</exportDate>\n' +
  '    <exportType>DELTA</exportType>\n' +
  '    <version versionDate="8099-12-31T23:59:59-06:00" isWorking="true">\n' +
  '      <fixNumber>0</fixNumber>\n' +
  '      <versionDescr>' + CPQGlobals.versionLabelWorking + '</versionDescr>\n' +
  '      <versionLabel>' + CPQGlobals.versionLabelWorking + '</versionLabel>\n' +
  '    </version>\n' +
  '  </importExportMetadata>\n';

  private static final String standardSalesItem_Beg_FMT = 
  '  <standardSalesItem eligibility="true" name="{0}" workspace="' + CPQGlobals.sWorkspace + '">\n' +
  '    <descriptions>\n' +
  '      <description variant="" language="en" country="US">{1}</description>\n' +
  '    </descriptions>\n' +
  '    <businessPropertySets>\n' +
  '      <businessPropertySet workspace="' + CPQGlobals.sWorkspace + '" name="' + CPQGlobals.sBPS + '">\n' +
  '        <businessProperties>\n';

  private static final String standardSalesItem_End_FMT = 
  '        </businessProperties>\n' +
  '      </businessPropertySet>\n' +
  '    </businessPropertySets>\n' +
  '    <links>\n' +
  '      <link seqOrder="0" quantity="1">\n' +
  '        <child workspace="' + CPQGlobals.sWorkspace2 + '" objectType="CP" name="cpConfiguration" />\n' +
  '        <parameterIdent parameterType="LinkType" class="ProductLink" workspace="' + CPQGlobals.sWorkspace + '" name="configurationLink" />\n' +
  '      </link>\n' +
  '    </links>\n' +
  '    <sparepartsviews />\n' +
  '    <manufacturingLinks />\n' +
  '    <routingLinks />\n' +
  '  </standardSalesItem>\n';

  private static final String businessPropertySet_FMT = 
  '          <businessProperty name="{0}">\n' +
  '            <seqOrder>{2}</seqOrder>\n' +
  '            <values>\n' +
  '              <value>{1}</value>\n' +
  '            </values>\n' +
  '          </businessProperty>\n';
  
  private static final String naLinks_Pp_FMT = 
  '    <naLinks>\n' +
  '       <naLink filterMethodScope="currentCollection" seqOrder="0"  mergeType="UPDATE">\n' +
  '         <child workspace="' + CPQGlobals.sWorkspace + '" objectType="CP" name="gspFonterra" />\n' +
  '       </naLink>\n' +
  '    </naLinks>\n';
  
  private static final String naLinks_NA_FMT = '    <naLinks />\n';


    private static final String productCollection_FMT =   
  '  <productCollection isRoot="{0}" name="{1}" workspace="' + CPQGlobals.sWorkspace + '" mergeType="IGNORE">\n' +
  '    <descriptions>\n' +
  '      <description variant="" language="en" country="US"  mergeType="UPDATE">{2}</description>\n' +
  '    </descriptions>\n' +
  '    <businessPropertySets />\n' +
  '    <links>\n{3}' +
  '    </links>\n' +
  '    <collectionLinks>\n{4}' +
  '    </collectionLinks>\n' +
  '    <labelLinks />\n' +
  '    <labels />\n' +
  '{5}' +
  '    <searchBpss />\n' +
  '    <teaserLinks />\n' +
  '  </productCollection>\n';

    private static final String collectionLink_FMT =   
  '      <collectionLink seqOrder="{0}"    mergeType="UPDATE" >\n' +
  '        <child workspace="' + CPQGlobals.sWorkspace + '" objectType="CL" name="{1}" />\n' +
  '      </collectionLink>\n';

    private static final String link_FMT =   
  '      <link xsi:type="productCollectionItem" seqOrder="{0}"   mergeType="UPDATE" >\n' +
  '        <child workspace="' + CPQGlobals.sWorkspace + '" objectType="SI" name="{1}" />\n' +
  '        <labels />\n' +
  '      </link>\n';      

  private static String buildStandardSalesItemTags(Product2[] p, Long iBeg, Long iEnd) 
  {
    List<String> result = new List<String>();
    String [] ss = new String[3];
    Integer k;
    for (Integer i = iBeg.intValue(); i <= iEnd; i++) {
      if(p[i] == null) continue;
      k = 0;
      ss[k] = p[i].ProductCode; k++;
      ss[k] = p[i].Name == null ? '' : p[i].Name.escapeXml(); k++;
      result.add(System.String.format(standardSalesItem_Beg_FMT, ss));
      Long jj = 0;
      k = 0; ss[k] = 'bpSAPRef'; k++; ss[k] = p[i].SAP_Reference_Key__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpComClass'; k++; ss[k] = (p[i].Commodity_Class_Description__c == null ? '' : p[i].Commodity_Class_Description__c.escapeXml()); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpComGroup'; k++; ss[k] = (p[i].Commodity_Group_Description__c == null ? '' : p[i].Commodity_Group_Description__c.escapeXml()); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpProdClass'; k++; ss[k] = (p[i].Product_Class_Description__c == null ? '' : p[i].Product_Class_Description__c.escapeXml()); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpMatGroup'; k++; ss[k] = (p[i].Material_Group_Description__c == null ? '' : p[i].Material_Group_Description__c.escapeXml()); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpActive'; k++; ss[k] = (p[i].IsActive ? 'true' : 'false'); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpComClassID'; k++; ss[k] = p[i].Commodity_Class__c == null ? '' : p[i].Commodity_Class__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpComGroupID'; k++; ss[k] = p[i].Commodity_Group__c == null ? '' : p[i].Commodity_Group__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpMatGroupID'; k++; ss[k] = p[i].Material_Group__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpMatID'; k++; ss[k] = p[i].Material_Number__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpProdClassID'; k++; ss[k] = p[i].Product_Class__c == null ? '' : p[i].Product_Class__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpBaseUnit'; k++; ss[k] = p[i].Base_Unit__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      //k = 0; ss[k] = 'bpLastSyncDate'; k++; ss[k] = datetime.newInstance(p[i].Data_Last_Loaded_Date__c.year(), p[i].Data_Last_Loaded_Date__c.month(),p[i].Data_Last_Loaded_Date__c.day()).format(sDateFormat); k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));
      k = 0; ss[k] = 'bpUOMs'; k++; ss[k] = p[i].Alternate_UoMs__c == null ? '' : p[i].Alternate_UoMs__c; k++; ss[k] = '' + (jj++); k++; result.add(System.String.format(businessPropertySet_FMT, ss));      
      k = 0;
      result.add(System.String.format(standardSalesItem_End_FMT, null));
    }
    return string.join(result,'');
  }


  private static void ProductHierarchy_add(Map<String, Object> m, String [] ss, Integer iPos)
  {
    if(iPos >= ss.size() - 1) {
      m.put(ss[iPos], null);
    } else {
      Map<String,Object> c = (Map<String,Object>) m.get(ss[iPos]);
      if(c == null) {
        m.put(ss[iPos], c = new Map<String,Object>());
      }
      ProductHierarchy_add(c, ss, iPos + 1);
    }
  } 

  private static void ProductHierarchy_dump(Map<String, Object> m, String prefix, List<String> result)
  {
    for (String s : m.keySet()){
      if(m.get(s) == null) {
        result.add(prefix + ',' + s);
      } else {
        ProductHierarchy_dump((Map<String,Object>) m.get(s), prefix + ',' + s, result);
      }
    }
  } 

  private static String buildProductCollectionTags(Product2[] p, Long iBeg, Long iEnd)
  {
    Map<String,Object> mCg = new Map<String,Object>();
    Map<String,String> mCg2Desc = new Map<String,String>();
    Map<String,String> mCc2Desc = new Map<String,String>();
    Map<String,String> mPc2Desc = new Map<String,String>();

    //System.debug('' + p.size());

    String [] ssb = new String[3];
    Integer k;
    for (Integer i = iBeg.intValue(); i <= iEnd; i++) {
      if(p[i] == null) continue;
      boolean bIsServiceMaterial = false;
      if(p[i].Service_Material__c.equals('No')) {
        bIsServiceMaterial = false;
      } else if(p[i].Service_Material__c.equals('Yes')) {
        bIsServiceMaterial = true;
      } else {
        CPQGlobals.error('CPQCatalog', 'Bad Service_Material__c value:' + p[i].Service_Material__c);
      }
      String Commodity_Group = p[i].Commodity_Group__c;
      String Commodity_Class = p[i].Commodity_Class__c;
      if(bIsServiceMaterial) {
        Commodity_Group = 'Services';
        Commodity_Class = 'Services';
      }
      if(Commodity_Group == null || Commodity_Class == null || p[i].ProductCode == null) {
        CPQGlobals.warn('CPQCatalog', 'Record ignored:Commodity_Group == null || Commodity_Class == null || p[i].ProductCode == null');
      } else {
        k = 0;
        ssb[k] = Commodity_Group; k++;
        ssb[k] = Commodity_Class; k++;
        ssb[k] = p[i].ProductCode; k++;
        ProductHierarchy_add(mCg, ssb, 0);
        if(mCg2Desc.get(Commodity_Group) == null)  mCg2Desc.put(Commodity_Group, p[i].Commodity_Group_Description__c == null ? (bIsServiceMaterial ? 'Service' : 'Missing') : p[i].Commodity_Group_Description__c.escapeXml());
        if(mCc2Desc.get(Commodity_Class) == null)  mCc2Desc.put(Commodity_Class, p[i].Commodity_Class_Description__c == null ? (bIsServiceMaterial ? 'Service' : 'Missing') : p[i].Commodity_Class_Description__c.escapeXml());
        if(mPc2Desc.get(p[i].ProductCode) == null) mPc2Desc.put(p[i].ProductCode, p[i].Name == null ? '' : p[i].Name.escapeXml());
      }      
    }

    List<String> result = new List<String>();
      
    List<String> cgList = new List<String>();
    for (String sCg : mCg.keySet()){
      //System.debug(sCg);      
      Map<String,Object> mCc = (Map<String,Object>) mCg.get(sCg);
      cgList.add(System.String.format(collectionLink_FMT, new String[] {'' + cgList.size(), 'cl' + sCg})); 
      List<String> ccList = new List<String>();
      for (String sCc : mCc.keySet()){
        //System.debug(' ' + sCc);
        Map<String,Object> mPc = (Map<String,Object>) mCc.get(sCc);
        ccList.add(System.String.format(collectionLink_FMT, new String[] {'' + ccList.size(), sCc})); 
        List<String> pcList = new List<String>();
        for (String sPc : mPc.keySet()){
          //System.debug('  ' + sPc);  
          pcList.add(System.String.format(link_FMT, new String[] {'' + pcList.size(), sPc})); 
        }
        result.add(System.String.format(productCollection_FMT, new String[] {'false', sCc, (String) mCc2Desc.get(sCc), string.join(pcList,''), '', naLinks_Pp_FMT}));  //
      }
      result.add(System.String.format(productCollection_FMT, new String[] {'false', 'cl' + sCg, (String) mCg2Desc.get(sCg), '', string.join(ccList,''), naLinks_NA_FMT}));  
    }
    result.add(System.String.format(productCollection_FMT, new String[] {'true', 'catSFDC', 'Fonterra Catalog', '', string.join(cgList,''), naLinks_NA_FMT}));  

    //ProductHierarchy_dump(mCg, '', result);
    
    return string.join(result,'');
  }
  
  private static String buildProductXML(Product2[] p, Long iBeg, Long iEnd)
  {
    String header = System.String.format(sHeader_FMT, new String[] {System.now().format('yyyy-MM-dd') + 'T' + System.now().format('hh:mm:ss') + '.000-06:00'});

    String body_StandardSalesItem = buildStandardSalesItemTags(p, iBeg, iEnd);

    String body_ProductCollection = buildProductCollectionTags(p, iBeg, iEnd);    
   
    return header + body_StandardSalesItem + body_ProductCollection + '</export>\n';   
  }   
    
  /**
   * Step 1. Create a slot
   * Step 2. Load the file to the slot
   * Step 3. Launch the import task
   * Step 4. Check for status until import is done
  */        
  
  private static HttpRequest continuationCallout(HttpResponse res) 
  {     
    HttpRequest req = null;
    String requestBody = null;
     CameleonCPQ__CAMCPQSettings__c cpq = CameleonCPQ__CAMCPQSettings__c.getOrgDefaults();
  
      string url = cpq.CameleonCPQ__CPQServer_EndpointURL__c;
      String user = String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
      String password = cpq.CameleonCPQ__CPQSession_AuthPwd__c;
      String authToken = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(user + ':'+ password)); 
      
    while(true) {
      if(iStepCurr == 0) {
        CPQGlobals.info('CPQCatalog', 'Step0:Initialize'); 
        iStepCurr = 1;
        req = new HttpRequest();  
        
        req.setEndpoint(url + '/eximpWS/rest-services/imports');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authToken);
        
      } else if(iStepCurr == 1) {
        CPQGlobals.info('CPQCatalog', 'Step1:Complete:'+ res.getStatus() + ':' + res.getBody()); 
        iStepCurr = 2;
        req = new HttpRequest();
        JSONParser parser = JSON.createParser(res.getBody());
        slotNo = null;
        while(parser.nextToken() != null) {
          if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'id')) {
            parser.nextToken();
            slotNo = parser.getText();
            break;
          }
        }             
        
        requestBody = buildProductXML(pp, ppBeg, ppEnd);
        
        //System.debug(requestBody);
        
        uploadFileName = 'product_catalogue_' + system.now().format(CPQGlobals.sDateFormat) + '.xml';
        CPQGlobals.info('CPQCatalog', 'Step2:Filename:'+ uploadFileName + ':' + ppBeg + ':' + ppEnd + ':' + requestBody.length() + ' bytes'); 
        
        req = new HttpRequest();
        req.setEndpoint(url + '/eximpWS/rest-services/import/' + slotNo + '/file');
        req.setMethod('PUT');        
        req.setHeader('Authorization', authToken);
        req.setHeader('Content-Type','application/octet-stream');
        req.setHeader('Content-Disposition','filename="' + uploadFileName + '"');               
        req.setBody(requestBody);             
        
      } else if(iStepCurr == 2) {
        CPQGlobals.info('CPQCatalog', 'Step2:Complete:'+ res.getStatus()); 
        iStepCurr = 3;
        req = new HttpRequest();
        
        req.setEndpoint(url + '/eximpWS/rest-services/eximp/imports/' + slotNo);
        req.setMethod('PUT');          
        req.setHeader('Authorization', authToken);
        req.setHeader('Content-Type','application/json');
        requestBody = 
         '{' +
         '"versionInfo": {' +
         ' "name": "' + CPQGlobals.versionLabelWorking + '",' +
         ' "working": true' +
         '},' +
         '"importOption": {' +
         ' "activateConflictFileGeneration": false,' +
         ' "createWorkspace": false,' +
         ' "importType": "IMPORT_OVERRIDE_CHANGES"' +
         '}' +
        '}';
             
        req.setBody(requestBody);
    
      } else if(iStepCurr == 3) {
        if(res != null) {
          CPQGlobals.info('CPQCatalog', 'Step3:Complete:'+ res.getStatus());  
          if(bWaitFirstOtherwiseLast) {
            break;
          }                     
        } else {
          if(bWaitFirstOtherwiseLast) {
            CPQGlobals.info('CPQCatalog', 'Step3:WaitBegn');  
          } else {
            CPQGlobals.error('CPQCatalog', 'iStepCurr == 3 && res == null && !bWaitFirstOtherwiseLast');                  
            break;
          }
        }
        iStepCurr = 4;
        
        WaitBegMilliseconds = System.Now().millisecond();
        
        req = new HttpRequest();
        req.setEndpoint(url + '/eximpWS/rest-services/eximp/status');                     
        req.setHeader('Authorization', authToken);
        req.setMethod('GET');   
    
      } else if(iStepCurr == 4) {
        if(!res.getStatus().equals('OK')) {
          CPQGlobals.info('CPQCatalog', 'Step4:Failure :'+ res.getStatus() + ':' + res.getBody()); 
        } else if(res.getBody().indexOf('READY') >= 0) {
          CPQGlobals.info('CPQCatalog', 'Step4:Complete:'+ res.getStatus() + ':' + res.getBody()); 
          ppBeg = ppEnd + 1;
          ppEnd = Math.min(pp.size() - 1, ppBeg + chunk - 1);
          if(ppBeg < pp.size()) {
            iStepCurr = 0;
            continue;
          }
        } else {
          CPQGlobals.info('CPQCatalog', 'Step4:Continue:'+ res.getStatus() + ':' + res.getBody()); 
          req = new HttpRequest();
        
          req.setEndpoint(url + '/eximpWS/rest-services/eximp/status');                     
          req.setHeader('Authorization', authToken);
          req.setMethod('GET');                   
        }         
      }   
      break;          
    }

    return req;
  }
  
  @future (callout=true)
  public static void runWait(String jobSpecContext) 
  {
    bWaitFirstOtherwiseLast = true;
    iStepCurr = 3;    
    Http http = new Http();
    HttpRequest req = continuationCallout(null);
    HttpResponse res = null;   
    try {
      CPQGlobals.info('CPQCatalog', 'HttpR:RequestB:runWait'); 
      req.setCompressed(true);
      res = http.send(req);
      CPQGlobals.info('CPQCatalog', 'HttpR:RequestE:runWait'); 
    } catch(System.CalloutException e) {
      CPQGlobals.error('CPQCatalog', 'HttpR:RequestF:runWait:Failure:' + e + ':' + (res == null ? 'null' : res.toString()));

    }        
    CPQJobSpec.signalFinished(jobSpecContext, res);
  }

    
  @future (callout=true)
  public static void restUploadCatalog(String jobSpecContext) 
  {
    String sProductCode_Beg = CPQJobSpec.getProductCodeBeg(jobSpecContext);
    String sProductCode_End = CPQJobSpec.getProductCodeEnd(jobSpecContext);
    CPQGlobals.info('CPQCatalog', 'Process:Beg');      
    if(sProductCode_Beg.length() != sProductCode_End.length()) {
      // The code will work but it may not give expected results (since the alphabetic limits of different lengths might give too many results)
      CPQGlobals.warn('CPQCatalog', 'Unexpected arguments:sProductCode_Beg.length() != sProductCode_End.length():' + sProductCode_Beg + ':' + sProductCode_End);   
    }    
    String sMask = '____________________'.substring(0, sProductCode_Beg.length());
    CPQGlobals.info('CPQCatalog', 'Query:Beg:' + sProductCode_Beg + ':' + sProductCode_End); 
    pp = [SELECT 
      ProductCode
      ,Name
      ,SAP_Reference_Key__c
      ,Commodity_Class_Description__c
      ,Commodity_Group_Description__c
      ,Product_Class_Description__c
      ,Material_Group_Description__c
      ,IsActive
      ,Commodity_Class__c
      ,Commodity_Group__c
      ,Material_Group__c
      ,Material_Number__c
      ,Product_Class__c
      ,Base_Unit__c
      ,Data_Last_Loaded_Date__c 
      ,Alternate_UoMs__c
      ,PO_Group_Description__c
      ,Material_Type__c
      ,Supplier_Group_Description__c
      ,Service_Material__c
      FROM Product2
      WHERE (ProductCode LIKE :sMask And ProductCode >= :sProductCode_Beg And ProductCode <= :sProductCode_End)
      And (IsActive = True or CreatedDate >= 2016-03-18T00:00:00Z)
      And (Material_Group__c not in ('0051', '0061'))
      And ((Commodity_Group__c not in ('0009', '0016')) And Commodity_Group_Description__c != 'Ethanol')
      And (PO_Group_Description__c not in ('Consumer', 'Foodservice'))
      And (Not (Name like '%gdt%'))
      And ((Supplier_Group_Description__c in ('Bakels Edible Oils (NZ) Ltd','Dairy Blenders','Fonterra')) or (Material_Type__c in ('ZDS1', 'ZDS2')))
      //LIMIT 10
      ORDER BY ProductCode      
      ];
    chunk = pp.size();          
    CPQGlobals.info('CPQCatalog', 'Query:End:' + pp.size()); 
    if(pp.size() > 0) {
      Http http = new Http();
      HttpRequest req = null;
      HttpResponse res = null;   
      ppBeg = 0;          
      bWaitFirstOtherwiseLast = true;
      if(bWaitFirstOtherwiseLast) {
        iStepCurr = 3;
        ppEnd = -1;                      
      } else {
        iStepCurr = 0;
        ppEnd = Math.min(pp.size() - 1, ppBeg + chunk - 1);          
      }
      Integer iCallOuts = 0;
      while((req = continuationCallout(res)) != null) {
        try {
          CPQGlobals.info('CPQCatalog', 'HttpR:RequestB'); 
          req.setCompressed(true);
          res = http.send(req);
          CPQGlobals.info('CPQCatalog', 'HttpR:RequestE'); 
        } catch(System.CalloutException e) {
          CPQGlobals.error('CPQCatalog', 'HttpR:RequestF:Failure:' + e + ':' + (res == null ? 'null' : res.toString())); 
          break;
        }        
        iCallOuts++;
        /*
        if(iStepCurr == 4) {
          CPQGlobals.info('CPQCatalog', 'Sleep:Beg'); 
          Double start = System.Now().millisecond();
          while(System.Now().millisecond() < start + (iCallOuts > 75 ? 200 : (iCallOuts > 50 ? 100 : 10))) { 
              
          }
          CPQGlobals.info('CPQCatalog', 'Sleep:End'); 
        }*/
      }
    }
    CPQGlobals.info('CPQCatalog', 'Process:End'); 
    continuationCalloutReset();
    
    CPQJobSpec.signalFinished(jobSpecContext);


    //return chunk;    
  }
}