public without sharing class FW_Service_REST extends FW_Service_Base {
    
    HttpRequest request;// = new HttpRequest();
    HttpResponse response = new HttpResponse();
    Http http = new Http();
    
    //string requestLabel;
    
    private void prepareServiceRequest(){
      request = new HttpRequest();
      if(serviceSetting.Timeout__c != null) request.setTimeout(integer.ValueOf(serviceSetting.Timeout__c));
      if(serviceSetting.Operation__c != null) request.setMethod(serviceSetting.Operation__c);
      if(serviceSetting.Compressed__c) request.setCompressed(serviceSetting.Compressed__c);
  
        if(serviceSettings.requestHeader != null && !serviceSettings.requestHeader.isEmpty()){
          Set<string> keys = serviceSettings.requestHeader.keySet();
          for(string key : keys){
            request.setHeader(key, serviceSettings.requestHeader.get(key));
          }          
        }
        
        string jsonString;
        if(requestBody != null){
            if(requestBody instanceof string){
                jsonString = (string)requestBody;}
            else {
                jsonString = JSON.serializePretty(requestBody);}   
            //jsonString = jsonString.replace('"currency_x":', '"currency":');         
        }        
        
        //if(!serviceSetting.EndPointParameters__c){
            request.setEndpoint(serviceSettings.serviceEndpoint);
            if(!serviceSetting.MockResponse__c && jsonString !=  null && (serviceSetting.Operation__c != null && serviceSetting.Operation__c != 'GET')) 
                request.setBody(jsonString);
        //}
        //else
            //request.setEndpoint(serviceSettings.serviceEndpoint + jsonString);
        
        requestBody = jsonString;       
        System.debug('Request Body : ' + requestBody);
    }
   
    private void execute(FW_Service_Continuation contSettings){
        try{
            if(contSettings.isContinuation){
                responseBody = contSettings.continuation.addHttpRequest(request);
                contSettings.continuationState.requestLabel = responseBody;
            }
            else{
                system.debug('Request : ' + request);
                
                //Initialize the Response Body with Mock Output
                responseBody = serviceMockOutput;
                if (Test.isRunningTest()) {
                    FW_ServiceMock_REST serviceMock = new FW_ServiceMock_REST();
                    serviceMock.responseBody = JSON.serialize(serviceMockOutput);
                    Test.setMock(HttpCalloutMock.class, serviceMock);
                }
                
                if(!serviceSetting.MockResponse__c){
                    response = http.send(request); 
                    responseBody = response.getBody();
                }
                
                system.debug('Response : ' + response);
                system.Debug('Response Body : ' + responseBody);
            }   
        }
        catch(Exception ex) {
            system.debug('Interface Error : '+ex.getMessage());
            throw ex;
        }
    } 
    
    public void processContinuationResponse(Object continuationOutput){
        try{
            system.debug('Continuation Output : ' + continuationOutput);
            
            //Initialize the Response Body with Mock Output
            responseBody = serviceMockOutput;
            
            if (Test.isRunningTest()) {
                FW_ServiceMock_REST serviceMock = new FW_ServiceMock_REST();
                serviceMock.responseBody = JSON.serialize(serviceMockOutput);
                Test.setContinuationResponse((string)continuationOutput, serviceMock.respond(request));
            }           
            
            if(!serviceSetting.MockResponse__c){
                response = Continuation.getResponse((string)continuationOutput);
                responseBody = response.getBody();
            }
            
            system.debug('Continuation Response : ' + response);
            system.Debug('Continuation Response Body : ' + responseBody);
        }
        catch(Exception ex){
            system.debug('Interface Error : '+ex.getMessage());
            throw ex;
        }
    }
    
    public void processServiceResponse(){
                
        string jsonResponse = (string) responseBody;
        system.debug('@@jsonResponse' + jsonResponse);
        //TODO
        //Set Response Headers
        
        if(response.getStatusCode() != 200 && response.getStatusCode() != 201 &&
            response.getStatusCode() != 204){
            serviceStatus.status = 'I';
            serviceStatus.errorCode = string.valueOf(response.getStatusCode());
            serviceStatus.errorDescription = response.getStatus();   
            
            //Continuation Response Codes
            if(response.getStatusCode() == 2000)
                serviceStatus.errorDescription = 'The timeout was reached, and the server didn’t get a chance to respond.';
            if(response.getStatusCode() == 2001)
                serviceStatus.errorDescription = 'There was a connection failure.';
            if(response.getStatusCode() == 2002)
                serviceStatus.errorDescription = 'Exceptions occurred.';
            if(response.getStatusCode() == 2003)
                serviceStatus.errorDescription = 'The response hasn’t arrived (which also means that the Apex asynchronous callout framework hasn’t resumed)';
            if(response.getStatusCode() == 2004)
                serviceStatus.errorDescription = 'The response size is too large (greater than 1 MB).';
                                 
            /*if(jsonResponse != null){
                XmlStreamReader xsr = new XmlStreamReader(jsonResponse);
                //TODO
                //Parse the XML for the error code and description
            }*/                   
            try{
                system.debug('Final JSON to deserialize :' + jsonResponse);
                responseBody = JSON.deserialize(jsonResponse, Type.forName(serviceSetting.OutputClass__c));
            }
            catch(Exception e){
                //DO NOT DO ANYTHING
            }
        }
        else if(serviceSetting.OutputClass__c != null && jsonResponse != null && String.isNotBlank(jsonResponse) && serviceStatus.status == 'S'){           
            //jsonResponse = jsonResponse.replace('"system":', '"system_x":');
            //jsonResponse = jsonResponse.replace('"@type":', '"type_x":');
            //jsonResponse = jsonResponse.replace('@xmlns:', '');
            system.debug('Final JSON to deserialize :' + jsonResponse);
            system.debug('serviceSetting.OutputClass__c :' + serviceSetting.OutputClass__c);
            system.debug('Type.forName(serviceSetting.OutputClass__c) :' + Type.forName(serviceSetting.OutputClass__c));
            responseBody = JSON.deserialize(jsonResponse, Type.forName(serviceSetting.OutputClass__c));  
            system.debug('Final JSON deserialized :' + responseBody);
        }

    }
    
}