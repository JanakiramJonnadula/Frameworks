public without sharing class FW_ParkLocatorServiceCallout extends FW_ServiceIO_SOAP {
	
	string country;

    public void convertInputToRequest() {
    	//Convert Service Input to Web Service Input
        FW_ParkLocatorServiceInput input = (FW_ParkLocatorServiceInput) serviceInput;
        country = input.country;
        
        //Set Message Reference to log
        serviceDetails.messageReference = country;
        
        //Set tranId if the Web Service has s transaction id field
        //input.tranId = serviceDetails.guid;
    }

    public override object invokeWebserviceCallout(FW_Service_SOAPRequest soapRequest) {

        FW_ParkLocatorService.ParksImplPort stub = new FW_ParkLocatorService.ParksImplPort();
        stub.endpoint_x = soapRequest.endpoint_x;
        stub.inputHttpHeaders_x = soapRequest.inputHttpHeaders_x;
        stub.timeout_x = soapRequest.timeout_x;

        list<string> parks = stub.byCountry(country);        

        return parks;
    }
    
    public override object invokeWebserviceAsyncCallout(Continuation continuation, FW_Service_SOAPRequest soapRequest) {
    	
    	AsyncFW_ParkLocatorService.AsyncParksImplPort stub = new AsyncFW_ParkLocatorService.AsyncParksImplPort();
        stub.endpoint_x = soapRequest.endpoint_x;
        stub.inputHttpHeaders_x = soapRequest.inputHttpHeaders_x;
        stub.timeout_x = soapRequest.timeout_x;

        AsyncFW_ParkLocatorService.byCountryResponseFuture response = stub.beginByCountry(continuation, country);

        return response;
    }
    
    public override object processContinuationResponse(Object continuationOutput){
    	
    	AsyncFW_ParkLocatorService.byCountryResponseFuture response = (AsyncFW_ParkLocatorService.byCountryResponseFuture) continuationOutput;
    	return response.getValue();
    	
    }
    
    public override object convertResponseToOutput(object serviceInput, object response, map < string, string > responseHeader, FW_Service_Status serviceStatus) {

		FW_ParkLocatorServiceOutput output = new FW_ParkLocatorServiceOutput();
		output.tranId = serviceStatus.referenceId;
		output.tranStatus = serviceStatus.status;
    	
    	try{    		
    		if(serviceStatus != null && serviceStatus.status == 'S' &&
    			response != null && response instanceof list<string>){
    			list<string> parks = (list<string>) response;
	            output.parks = parks;
    		}
    		else{    			
				output.tranCode = 'Interface';
				output.tranStatusDescription = serviceStatus.errorDescription;
    		} 
    		//return response;   		
    	}
    	catch(Exception ex){
			output.tranStatus = 'E';
			output.tranCode = 'Output';
			output.tranStatusDescription = 'Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
    	}
        
        return output;
    }
    
    public override object prepareMockOutput(object serviceInput, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
		FW_ParkLocatorService.byCountryResponse response_x = new FW_ParkLocatorService.byCountryResponse();
        list<string> parks = new list<string>();
        parks.add('Park1');
        response_x.return_x = parks;
        
        return response_x;
    }
    
}