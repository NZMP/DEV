public without sharing class ChartGenerator {

    public static final String FINANCIAL_PERFORMANCE_CHART1_REPORT_NAME = 'Financial Performance-Purchase Vol (MT)2';
    public static final String FINANCIAL_PERFORMANCE_CHART1_REPORT_PARAMS = '?isdtp=lt&pv2={!Account.Account_Number__c}-&pv3={!Account.Account_Number__c}-';
    public static final String FINANCIAL_PERFORMANCE_CHART2_REPORT_NAME = 'Financial Performance-Price Achievement2';
    public static final String FINANCIAL_PERFORMANCE_CHART2_REPORT_PARAMS = '?isdtp=lt&pv2={!Account.Account_Number__c}-&pv3={!Account.Account_Number__c}-';
    public static final String FINANCIAL_PERFORMANCE_CHART3_REPORT_NAME = 'Financial Performance - Gross Margin 2';
    public static final String FINANCIAL_PERFORMANCE_CHART3_REPORT_PARAMS = '?isdtp=lt&pv2={!Account.Account_Number__c}-&pv3={!Account.Account_Number__c}-';

    public static final String METRICS_CHART1_REPORT_NAME = 'Metrics - Account Sales Pipeline 2';
    public static final String METRICS_CHART1_REPORT_PARAMS = '?isdtp=lt&pv1={!Account.Account_Number__c}&pv2={!Account.Account_Number__c}';

	public static URL salesforceBaseUrl = null;
	public static String setSalesforceBaseUrl(URL baseURL) {
		salesforceBaseUrl = baseURL;
		return getSalesforceInstance();
	}

	private static String salesforceInstance = null;
    public static String getSalesforceInstance() {
        if ((salesforceInstance == null) || (salesforceBaseUrl != null)) {
        	URL salesforceInstanceURL = System.URL.getSalesforceBaseUrl();
        	if (salesforceBaseUrl != null) {
        		salesforceInstanceURL = salesforceBaseUrl;
        		salesforceBaseUrl = null;
        	}
            salesforceInstance = null;
            List<String> parts = salesforceInstanceURL.getHost().replace('-api','').split('\\.');
            if (parts.size() == 3) salesforceInstance = parts[0];
            else if (parts.size() == 4) salesforceInstance = parts[0] + '.' + parts[1];
            else if (parts.size() == 5) {
            	List<String> hostSplit = parts[0].split('--');
            	if (hostSplit.size() == 1) {
					salesforceInstance = parts[1];
            	} else if (hostSplit.size() == 2) {
            		if (hostSplit[1] == 'c') {
            			salesforceInstance = hostSplit[0] + '.my';
            		} else {
            			salesforceInstance = hostSplit[0] + '--' + hostSplit[1] + '.' + parts[1] + '.my';
            		}
            	} else if (hostSplit.size() == 3) {
            		salesforceInstance = hostSplit[0] + '--' + hostSplit[1] + '.' + parts[1] + '.my';
            	}
            }
            REPORT_URL_BASE = 'https://' + salesforceInstance + '.salesforce.com/';
			ATTACHMENT_VIEW_URL_BASE = REPORT_URL_BASE + 'servlet/servlet.FileDownload?file=';
			REPORT_SESSION_REQUEST_URL_BASE = REPORT_URL_BASE + 'services/Soap/u/25.0';
        }
        return 'https://' + salesforceInstance + '.salesforce.com/';
    }
 
    public static String REPORT_URL_BASE = null;
    public static final String REPORT_URL_PARAM_REGEX = '\\{!.*?\\}';
    public static Pattern reportUrlRegexPattern = Pattern.compile(REPORT_URL_PARAM_REGEX);
    public static final String REPORT_IMG_SRC_REGEX = '.*src="?(.*Chart.*?)".*';
    public static final Integer REPORT_IMG_SRC_REGEX_MATCH_GROUP = 1;
    public static Pattern reportChartImgSrcRegexPattern = Pattern.compile(REPORT_IMG_SRC_REGEX);    
    public static String ATTACHMENT_VIEW_URL_BASE = null;
    public static final String ATTACHMENT_CONTENT_TYPE_TEXTPLAIN = 'text/plain';
    public static final String ATTACHMENT_CHART_NA = 'Chart not available';
    
    public static HttpResponse getChartForReport(String reportName, String reportParameters, Map<String, SObject> sObjectNameToSObjectMap, Attachment chartAttachment) {
    	HttpResponse chartResponse = null;
        String reportChartImageUrl = CrmsConstants.URL_S_GIF;
        String reportId = null;
        If (Test.isRunningTest()) {
        	reportId = CrmsConstants.getReportId(reportName);
        	reportId = reportName;
        } else {
        	reportId = CrmsConstants.getReportId(reportName);
        }
        if (reportId != null) {
        	try {
	            String reportUrl = REPORT_URL_BASE + reportId + reportParameters;
	            Matcher reportParamMatcher = reportUrlRegexPattern.matcher(reportUrl);
	            List<String> paramSplit = null; 
	            while (reportParamMatcher.find()) {
	                paramSplit = (reportParamMatcher.group(0).substring(2, reportParamMatcher.group(0).length() - 1)).split('\\.'); 
	                reportUrl = reportUrl.replace(reportParamMatcher.group(0), (String)(sObjectNameToSObjectMap.get(paramSplit[0]).get(paramSplit[1]))); 
	            }
	            system.debug('reportUrl='+reportUrl);
	            HttpResponse reportResponse = getHttpResponse(reportUrl, CrmsConstants.HTTP_METHOD_GET, new Map<String, String>{'Cookie' => 'sid='+getSessionId()}, null);
	            if (reportResponse != null) {
		            List<List<String>> reportChartImgSrc = getPatternMatches(reportChartImgSrcRegexPattern, new List<Integer>{ REPORT_IMG_SRC_REGEX_MATCH_GROUP }, reportResponse.getBody(), true);
		            if (reportChartImgSrc.size() > 0) {
		                reportChartImageUrl = reportChartImgSrc[0][0];
				        reportChartImageUrl = reportChartImageUrl.replace(CrmsConstants.AMPERSAND_STRING_XML, CrmsConstants.AMPERSAND_STRING);
						system.debug('reportChartImageUrl='+reportChartImageUrl);
				        if (reportChartImageUrl.contains(CrmsConstants.DOUBLEQUOTE_STRING)) {
				        	reportChartImageUrl = reportChartImageUrl.split(CrmsConstants.DOUBLEQUOTE_STRING)[0];
				        	system.debug('reportChartImageUrl2=' + reportChartImageUrl);
				        }
				        chartResponse = getHttpResponse(ChartGenerator.REPORT_URL_BASE + reportChartImageUrl.substring(1), CrmsConstants.HTTP_METHOD_GET, new Map<String, String>{'Cookie' => 'sid='+getSessionId()}, null);
				        if (chartResponse != null) {
							chartAttachment.Name = reportName;
							chartAttachment.ContentType = chartResponse.getHeader('Content-Type');
							chartAttachment.Body = chartResponse.getBodyAsBlob();
				        }
		            }
	            }
	        } catch (Exception e) {
	            system.debug(e);
	        }
        }
        return chartResponse;
    }

    public static final String REPORT_INTEGRATION_USER_USERNAME = System.Label.REPORT_INTEGRATION_USER_USERNAME;
    public static User integrationUser = [Select Integration_Security_Credentials__c from User Where Username = :REPORT_INTEGRATION_USER_USERNAME];
    public static String REPORT_SESSION_REQUEST_URL_BASE = null;
    public static final String REPORT_SESSION_REQUEST_PARAM_USERNAME = '{!IntegrationUser.Username}';
    public static final String REPORT_SESSION_REQUEST_PARAM_PASSWORDANDTOKEN = '{!IntegrationUser.PasswordAndToken}';
    public static final String REPORT_SESSION_REQUEST_SESSION_ID = '{!IntegrationUser.SessionId}';
    public static final String REPORT_SESSION_LOGIN_REQUEST_BODY = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com"><soapenv:Header></soapenv:Header><soapenv:Body><urn:login><urn:username>' + REPORT_SESSION_REQUEST_PARAM_USERNAME + '</urn:username><urn:password>' + REPORT_SESSION_REQUEST_PARAM_PASSWORDANDTOKEN + '</urn:password></urn:login></soapenv:Body></soapenv:Envelope>';
	//public static final String REPORT_SESSION_LOGOUT_REQUEST_BODY = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com"><soapenv:Header><urn:SessionHeader><urn:sessionId>' + REPORT_SESSION_REQUEST_SESSION_ID + '</urn:sessionId></urn:SessionHeader></soapenv:Header><soapenv:Body><urn:logout/></soapenv:Body></soapenv:Envelope>';
    public static final String REPORT_SESSION_ID_REGEX = '<sessionId>(.*?)</sessionId>';
    public static final Integer REPORT_SESSION_ID_REGEX_MATCH_GROUP = 1;
    public static Pattern reportSessionIdRegexPattern = Pattern.compile(REPORT_SESSION_ID_REGEX);
    //public static final String REPORT_SESSION_SERVER_URL_REGEX = '<serverUrl>(.*?)</serverUrl>';
    //public static final Integer REPORT_SESSION_SERVER_URL_REGEX_MATCH_GROUP = 1;
    //public static Pattern reportSessionServerUrlRegexPattern = Pattern.compile(REPORT_SESSION_SERVER_URL_REGEX);
    
    public static String sessionId = null;
    public static String sessionServerUrl = null;

    public static String getSessionId() {
        if (sessionId == null) {
            sessionId = CrmsConstants.EMPTY_STRING;
            if ((integrationUser != null) && (integrationUser.Integration_Security_Credentials__c != null) && (integrationUser.Integration_Security_Credentials__c.contains('|'))) {
                String securityCredentials = integrationUser.Integration_Security_Credentials__c;
                HttpResponse sessionResponse = getHttpResponse(
                    REPORT_SESSION_REQUEST_URL_BASE, CrmsConstants.HTTP_METHOD_POST, 
                    new Map<String, String>{'Content-Type' => 'text/xml', 'SOAPAction' => 'dummy'}, 
                    REPORT_SESSION_LOGIN_REQUEST_BODY.replace(REPORT_SESSION_REQUEST_PARAM_USERNAME, securityCredentials.split('\\|')[0]).replace(REPORT_SESSION_REQUEST_PARAM_PASSWORDANDTOKEN, securityCredentials.split('\\|')[1].replaceAll('<','&lt;').replaceAll('>','&gt;'))
                );
                if (sessionResponse != null) {            
	                List<List<String>> sessionIds = getPatternMatches(reportSessionIdRegexPattern, new List<Integer>{ REPORT_SESSION_ID_REGEX_MATCH_GROUP }, sessionResponse.getBody(), true);
	                if (sessionIds.size() > 0) {
	                    sessionId = sessionIds[0][0];
	                    //system.debug('sessionId=' + sessionId);
	                }
/*	                
	                List<List<String>> sessionServerUrls = getPatternMatches(reportSessionServerUrlRegexPattern, new List<Integer>{ REPORT_SESSION_SERVER_URL_REGEX_MATCH_GROUP }, sessionResponse.getBody(), true);
	                if (sessionServerUrls.size() > 0) {
	                    sessionServerUrl = sessionServerUrls[0][0];
	                    system.debug('sessionServerUrl=' + sessionServerUrl);
	                }
*/
                }
            }
        }
        return sessionId;
    }

    public static String getSessionFrameSrc() {
    	return REPORT_URL_BASE + 'secur/frontdoor.jsp?sid=' + getSessionId() + '&retURL=' + CrmsConstants.URL_S_GIF;
    }
/*
    public static void invalidateSessionId() {
        if (sessionId != null) {
            HttpResponse sessionResponse = getHttpResponse(
                sessionServerUrl, CrmsConstants.HTTP_METHOD_POST, 
                new Map<String, String>{'Content-Type' => 'text/xml', 'SOAPAction' => 'dummy'}, 
                REPORT_SESSION_LOGOUT_REQUEST_BODY.replace(REPORT_SESSION_REQUEST_SESSION_ID, sessionId)
            );
        }
    }
*/  
    public static List<List<String>> getPatternMatches(Pattern pattern, List<Integer> matchGroups, String match, Boolean stripCRLFs) {
        List<List<String>> patternMatches = new List<List<String>>();
        List<String> patternMatchGroups = new List<String>();
        if (stripCRLFs) {
            match = match.replace(CrmsConstants.LINE_FEED, CrmsConstants.EMPTY_STRING).replace(CrmsConstants.CARRIAGE_RETURN, CrmsConstants.EMPTY_STRING);
        }
        //system.debug('match=' + match);
        Matcher matcher = pattern.matcher(match);
        //system.debug('matcher=' + matcher);
        while (matcher.find()) {
            patternMatchGroups = new List<String>();
            for (Integer i = 0; i < matchGroups.size(); i++) {
                patternMatchGroups.add(matcher.group(matchGroups[i]));  
            }
            patternMatches.add(patternMatchGroups);
        }
        //system.debug('patternMatches=' + patternMatches);
        return patternMatches;
    }

	public static String testGetHttpResponseBody = null;

    public static HttpResponse getHttpResponse(String url, String method, Map<String, String> headers, String body) {
        HttpResponse response = null;
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod(method);
            if (headers != null) {
                for (String key : headers.keySet()) {
                    request.setHeader(key, headers.get(key));
                    //system.debug(key+'='+headers.get(key));               
                }
            }
            if ((method == CrmsConstants.HTTP_METHOD_POST) && (body != null)) {
                request.setBody(body);
            }
            Http http = new Http();
            If (Test.isRunningTest()) {
            	response = new HttpResponse();
            	response.setBody(testGetHttpResponseBody);
            } else {
                response = http.send(request);               
            }
            system.debug('response.getBody().length()='+response.getBody().length());
            //system.debug('response.getBody()='+response.getBody());
            //system.debug('request.body='+body);
        } catch (Exception e) {
            system.debug(e);
        }
        return response;
    }
 
	static {
		getSalesforceInstance();	
	}   

}