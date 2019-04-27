public without sharing class FW_Service_APEX extends FW_Service_Base {

    private void prepareServiceRequest() {}

    private void execute(FW_Service_Continuation contSettings) {
        try {
            system.debug('APEX - execute');
            
             //Initialize the Response Body with Mock Output
             responseBody = serviceMockOutput;
            
            if(!serviceSetting.MockResponse__c)
            	responseBody = serviceIO.invokeWebserviceCallout(null);

        } catch (Exception e) {
            system.debug('***** Exception received = ' + e.getMessage());
            throw e;
        }
    }
    
    public void processContinuationResponse(Object continuationOutput){}

    public void processServiceResponse() {}

}