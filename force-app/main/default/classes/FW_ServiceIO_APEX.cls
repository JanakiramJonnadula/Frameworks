public without sharing abstract class FW_ServiceIO_APEX extends FW_ServiceIO_Base {

    public object serviceInput;
     public FW_Service_Details serviceDetails = new FW_Service_Details();

    public virtual object convertInputToRequest() {
        return serviceInput;
    }

    public override object convertInputToRequest(object serviceInput, FW_Service_Settings serviceSettings, FW_Service_Details serviceDetails) {
        System.Debug('SoapIO - convertInputToRequest');
        System.Debug('Additional Details : ' + serviceDetails);
        
        this.serviceInput = serviceInput;

        return convertInputToRequest();
    }
    
    public virtual object execute() {
        return null;
    }

    public override object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest) {
        return execute();
    }
    
    public override object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest){
    	return null;
    }
    
    public override object processContinuationResponse(Object continuationOutput){
    	return null;
    }

    public override virtual object convertResponseToOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = serviceInput;
        return response;
    }

    public override virtual object prepareMockOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = serviceInput;
        return response;
    }

}