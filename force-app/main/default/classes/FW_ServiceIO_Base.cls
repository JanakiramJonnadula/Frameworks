public without sharing abstract class FW_ServiceIO_Base implements FW_ServiceIO_Interface {
	
	public abstract object convertInputToRequest(object serviceInput, FW_Service_Settings serviceSettings, FW_Service_Details serviceDetails);
    
    public abstract object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest);
    
    public abstract object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest);
    
    public abstract object convertResponseToOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus);
    
    public abstract object prepareMockOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus);
    
	public abstract object processContinuationResponse(Object continuationOutput);

}