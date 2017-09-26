global class CPQGlobals {
  
  public static final String sWorkspace = 'wksFonterra';
  public static final String sWorkspace2 = 'wksFonterra';
  public static final String versionLabelWorking = 'Working version'; //'wksJeromeActiveVersion' 'wksFonterraActiveVersion'
  //public static final String versionLabelDynamic = 'Version'; //'wksJeromeActiveVersion' 'wksFonterraActiveVersion'
  public static final String sBPS = 'bpsProduct';
  public static final String sDateFormat = 'yyyyMMddhhmmss';     
  
  /*public static final String url = 'https://ts005101.mycameleon.com/';
  public static final String user = '00DN0000000UU9F';
  public static final String password = '<3u6czw#EE)f';
  public static final String authToken = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(user + ':'+ password));  */
  
  CameleonCPQ__CAMCPQSettings__c cpq = CameleonCPQ__CAMCPQSettings__c.getOrgDefaults();
  
  public string url = cpq.CameleonCPQ__CPQServer_EndpointURL__c;
  public  String user = UserInfo.getOrganizationId();
  public  String password = cpq.CameleonCPQ__CPQSession_AuthPwd__c;
  public String authToken = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(user + ':'+ password)); 
  
  public static void info(String sClass, String s) { System.debug(sClass + ':INF:' + System.Now().format(sDateFormat) + ':' + s); }
  public static void warn(String sClass, String s) { System.debug(sClass + ':WRN:' + System.Now().format(sDateFormat) + ':' + s); }
  public static void error(String sClass, String s) { System.debug(sClass + ':ERR:' + System.Now().format(sDateFormat) + ':' + s); }  
  
}