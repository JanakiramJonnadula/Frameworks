public without sharing class FW_Service_SOAP extends FW_Service_Base {

    FW_Service_SOAPRequest soapRequest;

    private void prepareServiceRequest() {
        system.debug('SOAPService - prepareServiceRequest');
        soapRequest = new FW_Service_SOAPRequest();
        if (serviceSetting.Timeout__c != null) soapRequest.timeout_x = integer.ValueOf(serviceSetting.Timeout__c);
        soapRequest.endpoint_x = serviceSettings.serviceEndpoint;

        if (serviceSettings.requestHeader != null && !serviceSettings.requestHeader.isEmpty()) 
            soapRequest.inputHttpHeaders_x = serviceSettings.requestHeader;
    }

    private void execute(FW_Service_Continuation contSettings) {
        try {
            system.debug('SOAPService - execute');
            
            if(contSettings.continuation != null)
                responseBody = serviceIO.invokeWebserviceAsyncCallout(contSettings.continuation, soapRequest);
            else{
            	
            	//Initialize the Response Body with Mock Output
                responseBody = serviceMockOutput;
            	
            	if (Test.isRunningTest()) {
                    FW_ServiceMock_SOAP serviceMock = new FW_ServiceMock_SOAP();
                    serviceMock.responseBody = serviceMockOutput;
                    //HttpCalloutMock mock = serviceMock;
                    //mock.respond(request);
                    Test.setMock(WebServiceMock.class, serviceMock);
                }
                
                if(!serviceSetting.MockResponse__c)
                	responseBody = serviceIO.invokeWebserviceCallout(soapRequest);
            }

        } catch (Exception e) {
            system.debug('***** Exception received = ' + e.getMessage());
            throw e;
        }
    }
    
    public void processContinuationResponse(Object continuationOutput){
        try{
			system.debug('Continuation Output : ' + continuationOutput);
        	
        	//Initialize the Response Body with Mock Output
            responseBody = serviceMockOutput;
        	
        	if (Test.isRunningTest()) {
                FW_ServiceMock_SOAP serviceMock = new FW_ServiceMock_SOAP();
                serviceMock.responseBody = serviceMockOutput;
                serviceMock.doInvoke(null,null,new Map<String, Object>(),null,null,null,null,null,null);
                //Test.setContinuationResponse((string)continuationOutput, 
                	//serviceMock.doInvoke(null,null,new Map<String, Object>(),null,null,null,null,null,null));
            }
            
            if(!serviceSetting.MockResponse__c)// && !Test.isRunningTest())
            	responseBody = serviceIO.processContinuationResponse(continuationOutput);
        }
        catch(Exception ex){
            system.debug('Interface Error : '+ex.getMessage());
            throw ex;
        }
    }

    public void processServiceResponse() {
        system.debug('SOAPService - processServiceResponse');
                
        //TODO
        //Set Response Headers
    }

}