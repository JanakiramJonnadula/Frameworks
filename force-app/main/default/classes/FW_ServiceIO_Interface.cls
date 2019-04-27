public interface FW_ServiceIO_Interface {
    
    object convertInputToRequest(object serviceInput, FW_Service_Settings serviceSettings, FW_Service_Details serviceDetails);
       
    object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest);
    
    object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest);
    
    object convertResponseToOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus);
    
    object prepareMockOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus);
    
    object processContinuationResponse(Object continuationOutput);
    
}