@isTest
global without sharing class FW_ServiceMock_SOAP implements WebServiceMock{
	
	public object responseBody;
	public boolean isContinuation;
	
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
        // start - specify the response you want to send
        /*ParkService.byCountryResponse response_x = 
            new ParkService.byCountryResponse();
        list<string> l = new list<string>();
        l.add('Test');
        response_x.return_x = l;*/
        // end
        response.put('response_x', responseBody); 
        //response.put('response_x', response_x);
        //Test.setMock(HttpCalloutMock.class, responseBody);
   }
    
}