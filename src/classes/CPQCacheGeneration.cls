public class CPQCacheGeneration {
      
  private static Long iStepCurr;
  private static String sVersionLabelDyn;
    
  private static void continuationCalloutReset() 
  {
    iStepCurr = 0;
  }     
  
  static {
    continuationCalloutReset();
  }

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
        CPQGlobals.info('CPQCache', 'Step0:TriggerCacheGeneration'); 
        iStepCurr = 1;
        req = new HttpRequest();          
        req.setEndpoint(url + '/eximpWS/rest-services/serialization/versions/' + sVersionLabelDyn);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authToken);
        
      }
      break;          
    }

    return req;
  }

    
  @future (callout=true)
  public static void generateCache(String jobSpecContext) 
  {
    sVersionLabelDyn = CPQJobSpec.getVersionLabelDyn(jobSpecContext); 
    CPQGlobals.info('CPQCache', 'Process:Beg');      
    Http http = new Http();
    HttpRequest req = null;
    HttpResponse res = null;   
    iStepCurr = 0;  
    while((req = continuationCallout(res)) != null) {
      try {
        CPQGlobals.info('CPQCache', 'HttpR:RequestB'); 
        req.setCompressed(true);
        res = http.send(req);
        CPQGlobals.info('CPQCache', 'HttpR:RequestE'); 
      } catch(System.CalloutException e) {
        CPQGlobals.error('CPQCache', 'HttpR:RequestF:Failure:' + e + ':' + (res == null ? 'null' : res.toString())); 
        break;
      }        
    }
    CPQGlobals.info('CPQCache', 'Process:End'); 
    continuationCalloutReset();
    
    CPQJobSpec.signalFinished(jobSpecContext);
    //return 0;    
  }
}