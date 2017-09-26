@isTest global class FuturesCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('http://api.salesforce.com/foo/bar', req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"query":{"count":10,"created":"2016-09-05T04:41:29Z","lang":"en-GB","meta":{"meta":[null,null,null,null,null]},"results":{"results":[{"td":"5.25"},{"td":"5.60"},{"td":"3630"},{"td":"3650"},{"td":"2260"},{"td":"2325"},{"td":"2870"},{"td":"2970"},{"td":"4460"},{"td":"4600"}]}}}');
        res.setStatusCode(200);
        return res;
    }
}