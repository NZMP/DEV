@isTest
public class ChartGeneratorTest {

	public static final String REPORT_CHART_HTTP_RESPONSE_BODY = 'testReportWithChartLink<img src="/Chart/testChart"/> and testChartAttachmentBlob';

    public static testMethod void getSalesforceInstance() {
    	ChartGenerator.getSalesforceInstance();

    	System.URL testBaseUrl = new System.URL('https://ap1.salesforce.com');
    	String baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://ap1.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://c.ap1.visual.force.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://ap1.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://ap1-api.salesforce.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://ap1.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://fonterra.my.salesforce.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://fonterra.my.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://fonterra--c.ap1.visual.force.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://fonterra.my.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://fonterra--qa.cs5.my.salesforce.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://fonterra--qa.cs5.my.salesforce.com/', baseUrl);

    	testBaseUrl = new System.URL('https://fonterra--qa--c.cs5.visual.force.com');
    	baseUrl = ChartGenerator.setSalesforceBaseUrl(testBaseUrl);
    	System.assertEquals('https://fonterra--qa.cs5.my.salesforce.com/', baseUrl);

    }
        
    public static testMethod void getChartForReport() {
    	SObject testSObjectName = new Account();
    	testSObjectName.put('Name', 'testSObjectFieldValue');
    	Map<String, SObject> testSObjectNameToSObjectMap = new Map<String, SObject>();
    	testSObjectNameToSObjectMap.put('testSObjectName', testSObjectName);
    	Attachment testAttachment = new Attachment();
    	ChartGenerator.testGetHttpResponseBody = REPORT_CHART_HTTP_RESPONSE_BODY;
		HttpResponse testResponse = ChartGenerator.getChartForReport('testReportName', 'testReportParams{!testSObjectName.Name}', testSObjectNameToSObjectMap, testAttachment);
		System.assertEquals('testReportName', testAttachment.Name);
		System.assertEquals(null, testAttachment.ContentType);
		System.assertEquals(REPORT_CHART_HTTP_RESPONSE_BODY, testAttachment.Body.toString());
    }

	public static final String REPORT_SESSION_ID_REGEX = '<sessionId>(.*?)</sessionId>';
    public static final String REPORT_SESSION_ID_HTTP_RESPONSE_BODY = '<xml><test>\n\r<sessionId>testSessionId</sessionId>\n\r<serverUrl>testServerUrl</serverUrl>\n\r</test></xml>';
    
    public static testMethod void getSessionId() {
    	ChartGenerator.testGetHttpResponseBody = REPORT_SESSION_ID_HTTP_RESPONSE_BODY;
		String sessionId = ChartGenerator.getSessionId();
		System.assertEquals('testSessionId', sessionId);
		ChartGenerator.getSessionFrameSrc();
		//ChartGenerator.invalidateSessionId();
    }

    public static testMethod void getPatternMatches() {
		List<List<String>> patternMatches = ChartGenerator.getPatternMatches(Pattern.compile('<sessionId>(.*?)</sessionId>'), new List<Integer>{ 1 }, REPORT_SESSION_ID_HTTP_RESPONSE_BODY, true);
		System.assertEquals('testSessionId', patternMatches[0][0]);
    }

    public static testMethod void getHttpResponse() {
        //test http get
        ChartGenerator.testGetHttpResponseBody = 'testResponse';
        HttpResponse testResponse = ChartGenerator.getHttpResponse('testUrl', CrmsConstants.HTTP_METHOD_GET, null, null);
        System.assertEquals('testResponse', testResponse.getBody());
        //test http get with headers
        testResponse = ChartGenerator.getHttpResponse('testUrl', CrmsConstants.HTTP_METHOD_GET, new Map<String, String>{'testHeader' => 'testHeaderValue'}, null);
        System.assertEquals('testResponse', testResponse.getBody());
        //test http post
        testResponse = ChartGenerator.getHttpResponse('testUrl', CrmsConstants.HTTP_METHOD_POST, null, 'testBody');
        System.assertEquals('testResponse', testResponse.getBody());
    }

}