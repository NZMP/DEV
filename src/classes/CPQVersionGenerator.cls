public class CPQVersionGenerator {

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
        CPQGlobals.info('CPQVersion', 'Step0:TriggerVersionGeneration'); 
        iStepCurr = 1;
        req = new HttpRequest();          
        req.setEndpoint(url + '/eximpWS/rest-services/versioning/' + sVersionLabelDyn);
        req.setMethod('PUT');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', authToken);
        
        /**/
        requestBody = '{ "date": ' + System.currentTimeMillis() + ', "description": "version 1 description" }';
        req.setBody(requestBody);
        
      } else if(iStepCurr == 1) {

        req = new HttpRequest();
        req.setEndpoint(url + '/eximpWS/rest-services/versioning/status');                     
        req.setHeader('Authorization', authToken);
        req.setMethod('GET');   
    
      }
      break;          
    }

    return req;
  }
  
  @future (callout=true)
  public static void runWait(String jobSpecContext) 
  {
    iStepCurr = 1;    
    Http http = new Http();
    HttpRequest req = continuationCallout(null);
    HttpResponse res = null;   
    try {
      CPQGlobals.info('CPQVersion', 'HttpR:RequestB:runWait'); 
      req.setCompressed(true);
      res = http.send(req);
      CPQGlobals.info('CPQVersion', 'HttpR:RequestE:runWait'); 
    } catch(System.CalloutException e) {
      CPQGlobals.error('CPQVersion', 'HttpR:RequestF:runWait:Failure:' + e + ':' + (res == null ? 'null' : res.toString())); 
    }        
    CPQJobSpec.signalFinished(jobSpecContext, res);
  }  

    
  @future (callout=true)
  public static void generateVersion(String jobSpecContext) 
  {
    sVersionLabelDyn = CPQJobSpec.getVersionLabelDyn(jobSpecContext);    
    CPQGlobals.info('CPQVersion', 'Process:Beg');      
    Http http = new Http();
    HttpRequest req = null;
    HttpResponse res = null;   
    iStepCurr = 0;  
    while((req = continuationCallout(res)) != null) {
      try {
        CPQGlobals.info('CPQVersion', 'HttpR:RequestB'); 
        req.setCompressed(true);
        res = http.send(req);
        CPQGlobals.info('CPQVersion', 'HttpR:RequestE'); 
      } catch(System.CalloutException e) {
        CPQGlobals.error('CPQVersion', 'HttpR:RequestF:Failure:' + e + ':' + (res == null ? 'null' : res.toString())); 
        break;
      }     
      break;      
    }
    CPQGlobals.info('CPQVersion', 'Process:End'); 
    continuationCalloutReset();
    
    CPQJobSpec.signalFinished(jobSpecContext);
    
    //return 0;    
  }
}