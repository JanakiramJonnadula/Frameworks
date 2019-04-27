@isTest
global without sharing class FW_ServiceMock_REST implements HttpCalloutMock{
	
	public object responseBody;
	
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json'); 
        response.setBody(responseBody instanceof string ? (string) responseBody : JSON.serializePretty(responseBody));
        response.setStatusCode(200);
        return response; 
    }
    
    //https://salesforce.stackexchange.com/questions/3486/testing-httpcallout-with-httpcalloutmock-and-unittest-created-data
    
}