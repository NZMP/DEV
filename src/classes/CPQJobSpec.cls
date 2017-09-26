global class CPQJobSpec {
  
  static final Integer ejsNotStarted      = 0;
  static final Integer ejsLoading         = 1;
  static final Integer ejsLoadWaiting     = 2;
  static final Integer ejsVersioning      = 3;
  static final Integer ejsVersionWaiting  = 4;
  static final Integer ejsCaching         = 5;
  static final Integer ejsComplete        = 6;

  String sProductCode_Beg = null;
  String sProductCode_End = null;
  String sVersionLabelDyn = null;
  Integer current = ejsNotStarted;  

  static Map<String,String[]> mapNextLoad = new Map<String,String[]>();
  
  static final String sBeg_ProductCode_Beg;
  static final String sBeg_ProductCode_End;
  
  static {
    sBeg_ProductCode_Beg = '100000';
    sBeg_ProductCode_End = '111000';
    mapNextLoad.put('100000', new String[]{'111001', '115000'});
    mapNextLoad.put('111001', new String[]{'115001', '120000'});
    mapNextLoad.put('115001', new String[]{'120001', '999999'});
    mapNextLoad.put('120001', new String[]{'S0000', 'S9999'});
        /**/
  }
    
  private static CPQJobSpec thiss(String jsonObject) {
    return (CPQJobSpec) JSON.deserialize(jsonObject, CPQJobSpec.class);
  }
  
  public static String getProductCodeBeg(String jsonObject)
  {
    CPQJobSpec thi_s = thiss(jsonObject);
    return thi_s.sProductCode_Beg;
  }
  
  public static String getProductCodeEnd(String jsonObject)
  {
    CPQJobSpec thi_s = thiss(jsonObject);
    return thi_s.sProductCode_End;
  }
  
  public static String getVersionLabelDyn(String jsonObject)
  {
    CPQJobSpec thi_s = thiss(jsonObject);
    return thi_s.sVersionLabelDyn;
  }
  
  public static void run(String jsonObject)
  {
    // Called from CPQCatalogScheduler
    if(jsonObject == null) {
      // First call
      CPQJobSpec thi_s = new CPQJobSpec();
      thi_s.sVersionLabelDyn = 'Version' + System.currentTimeMillis();
      thi_s.current = ejsLoading;
      thi_s.sProductCode_Beg = sBeg_ProductCode_Beg;
      thi_s.sProductCode_End = sBeg_ProductCode_End;
      CPQCatalogIntegration.restUploadCatalog(JSON.serialize(thi_s));
    } else {
      // Subsequent call
      CPQJobSpec thi_s = thiss(jsonObject);
      if(thi_s.current <= ejsNotStarted) {
        
      } else if(thi_s.current == ejsLoading) {
        CPQCatalogIntegration.restUploadCatalog(JSON.serialize(thi_s));
      } else if(thi_s.current == ejsLoadWaiting) {
        CPQCatalogIntegration.runWait(JSON.serialize(thi_s));
      } else if(thi_s.current == ejsVersioning) {
        CPQVersionGenerator.generateVersion(JSON.serialize(thi_s));
      } else if(thi_s.current == ejsVersionWaiting) {
        CPQVersionGenerator.runWait(JSON.serialize(thi_s));
      } else if(thi_s.current == ejsCaching) {
        CPQCacheGeneration.generateCache(JSON.serialize(thi_s));
      } else { // current >= ejsComplete
        
      }   
    }
  }
  
  public static void signalFinished(String jsonObject, HttpResponse resWait) 
  {
    // Called from runWait in CPQCatalogIntegration or CPQVersionGenerator
    CPQJobSpec thi_s = thiss(jsonObject);
    thi_s.next(resWait);
  }
  
  public static void signalFinished(String jsonObject) 
  {
    // Called from work routine in CPQCatalogIntegration, CPQVersionGenerator or CPQCacheGeneration
    CPQJobSpec thi_s = thiss(jsonObject);
    thi_s.next(null);
  }  
  
  private static String getChronString(Integer waitSeconds)
  {
    DateTime now  = DateTime.now();    
    DateTime nextRunTime = now.addSeconds(waitSeconds);
    return '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year(); 
  }
  
  private void schedule()
  {
    String sScheduleTitle = 'CPQ Catalog Scheduler ' + DateTime.now().format() + ' ';    
    if(this.current <= ejsNotStarted) {
      return;
    } else if(this.current == ejsLoading) {
      sScheduleTitle += '[' + this.sProductCode_Beg + ';' + this.sProductCode_End + '] Beg';
    } else if(this.current == ejsLoadWaiting) {
      sScheduleTitle += '[' + this.sProductCode_Beg + ';' + this.sProductCode_End + '] Cnt';
    } else if(this.current == ejsVersioning) {
      sScheduleTitle += 'Version '  + this.sVersionLabelDyn + ' Beg';
    } else if(this.current == ejsVersionWaiting) {
      sScheduleTitle += 'Version '  + this.sVersionLabelDyn + ' Cnt';
    } else if(this.current == ejsCaching) {
      sScheduleTitle += 'Cache Beg';
    } else { // current >= ejsComplete
      return;
    }   
    System.schedule(sScheduleTitle  + ' ' + System.currentTimeMillis(), getChronString(10), new CPQCatalogScheduler(JSON.serialize(this)));

  }  
      
  
  private void next(HttpResponse resWait) 
  {
    if(this.current <= ejsNotStarted) {
      return;
    } else if(this.current == ejsLoading) {
      this.current = ejsLoadWaiting;
    } else if(this.current == ejsLoadWaiting) {
      if(resWait == null) {
        CPQGlobals.error('CPQCatalog', 'Step4:Failure1:'+ resWait.getStatus() + ':' + resWait.getBody());
        this.current = ejsComplete;
      } else if(!resWait.getStatus().equals('OK')) {
        CPQGlobals.error('CPQCatalog', 'Step4:Failure2:'+ resWait.getStatus() + ':' + resWait.getBody());
        this.current = ejsComplete;
      } else if(resWait.getBody().indexOf('READY') < 0) {
        CPQGlobals.error('CPQCatalog', 'Step4:Continue:'+ resWait.getStatus() + ':' + resWait.getBody());
      } else {
        CPQGlobals.error('CPQCatalog', 'Step4:Complete:'+ resWait.getStatus() + ':' + resWait.getBody());
        if(mapNextLoad.get(this.sProductCode_Beg) == null) {
          this.current = ejsVersioning;
        } else {
          this.current = ejsLoading;
          String [] params = mapNextLoad.get(this.sProductCode_Beg);
          this.sProductCode_Beg = params[0];
          this.sProductCode_End = params[1];             
        }   
      }
    } else if(this.current == ejsVersioning) {
      this.current = ejsVersionWaiting;
    } else if(this.current == ejsVersionWaiting) {
      if(resWait == null) {
        CPQGlobals.error('CPQVersion', 'Step4:Failure1:'+ resWait.getStatus() + ':' + resWait.getBody());
        this.current = ejsComplete;
      } else if(!resWait.getStatus().equals('OK')) {
        CPQGlobals.error('CPQVersion', 'Step4:Failure2:'+ resWait.getStatus() + ':' + resWait.getBody());
        this.current = ejsComplete;
      } else if(resWait.getBody().indexOf('READY') < 0) {
        CPQGlobals.error('CPQVersion', 'Step4:Continue:'+ resWait.getStatus() + ':' + resWait.getBody());
      } else {
        CPQGlobals.error('CPQVersion', 'Step4:Complete:'+ resWait.getStatus() + ':' + resWait.getBody());
        this.current = ejsCaching;
      }      
    } else if(this.current == ejsCaching) {
      this.current = ejsComplete;
    } else { // current >= ejsComplete
      return;  
    } 

    this.schedule();    
   
  }
  

 
}