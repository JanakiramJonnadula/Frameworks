public without sharing abstract class FW_ServiceIO_REST extends FW_ServiceIO_Base {

    public object serviceInput;
    public FW_Service_Details serviceDetails;

    public virtual void setEndPointParameters(FW_Service_Settings serviceSettings) {}

    public virtual void setCustomHeaderValues(map<string, string> requestHeader) {}

    private virtual object convertInputToRequest() {
        return serviceInput;
    }

    public override object convertInputToRequest(object serviceInput, FW_Service_Settings serviceSettings, FW_Service_Details serviceDetails) {
        this.serviceInput = serviceInput;
        this.serviceDetails = serviceDetails;

        setEndPointParameters(serviceSettings);
        setCustomHeaderValues(serviceSettings.requestHeader);

        return convertInputToRequest();
    }

    public override object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest) {
        return null;
    }
    
    public override object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest){
    	return null;
    }
    
    public override object processContinuationResponse(Object continuationOutput){
    	return null;
    }
    
    public override virtual object convertResponseToOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = request;
        return response;
    }
    
    public override virtual object prepareMockOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = request;
        return response;
    }

}