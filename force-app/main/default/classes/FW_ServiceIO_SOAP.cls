public without sharing abstract class FW_ServiceIO_SOAP extends FW_ServiceIO_Base {

    public object serviceInput;
    public FW_Service_Details serviceDetails;

    private virtual void setCustomHeaderValues(map<string, string> requestHeader) {
        System.Debug('SoapIO - setCustomHeaderValues');
    }

    private abstract void convertInputToRequest();

    public override object convertInputToRequest(object serviceInput, FW_Service_Settings serviceSettings, FW_Service_Details serviceDetails) {
        System.Debug('SoapIO - convertInputToRequest');
        System.Debug('Additional Details : ' + serviceDetails);
        
        this.serviceInput = serviceInput;
        this.serviceDetails = serviceDetails;
        
        setCustomHeaderValues(serviceSettings.requestHeader);
        convertInputToRequest();

        return serviceInput;
    }

    public override abstract object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest);
    
    public override abstract object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest);
    
    public override abstract object processContinuationResponse(Object continuationOutput);

    public override virtual object convertResponseToOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = serviceInput;
        return response;
    }

    public override virtual object prepareMockOutput(object request, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        this.serviceInput = serviceInput;
        return response;
    }

}