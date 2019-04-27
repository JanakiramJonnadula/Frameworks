public without sharing abstract class FW_Service_BASE implements FW_Service_Interface {

    public FW_Service_Setting__mdt serviceSetting;
    public FW_Service_Settings serviceSettings;
    public FW_Service_Details serviceDetails;
    public FW_ServiceIO serviceIO;
    
    public FW_Service_Status serviceStatus = new FW_Service_Status();

    public Object requestBody;
    public Map <string, string> responseHeader;
    public Object responseBody;
    
    public Object serviceInput;
    public Object serviceMockOutput;

    private void getServiceEndPoint() {
                    
        if(string.isNotBlank(serviceSetting.NamedCredential__c)){
            if(string.isNotBlank(serviceSetting.CustomCredential__c)){
                if(serviceSetting.CustomCredential__c == FW_Service_Helper.FW_OAuth_Session 
                    && String.isBlank(UserInfo.getSessionId())){
                    serviceSettings.serviceEndpoint = 'callout:' + serviceSetting.NamedCredential__c + serviceSetting.EndPoint__c;
                }
                else{
                    //NamedCredential nc = [SELECT Endpoint FROM NamedCredential WHERE DeveloperName = : serviceSetting.NamedCredential__c];
                    //serviceSettings.serviceEndpoint = nc.Endpoint + serviceSetting.EndPoint__c;
                    //URL.getSalesforceBaseUrl().getHost();
                    serviceSettings.serviceEndpoint = System.Url.getOrgDomainUrl().toExternalForm() + serviceSetting.EndPoint__c;                    
                }
            }
            else{
                serviceSettings.serviceEndpoint = 'callout:' + serviceSetting.NamedCredential__c + serviceSetting.EndPoint__c;
            } 
        }
        else{
            serviceSettings.serviceEndpoint = serviceSetting.EndPoint__c;
        }
        //TODO - Continuation with Mock Data check : Endpoint is Mandatory
    }

    private void getRequestHeader() {
        serviceSettings.requestHeader = FW_Service_Helper.getServiceHeaders(serviceSetting.HeaderName__c, serviceSetting.CustomCredential__c);
    }
    
    private void getContinuationSettings(FW_Service_Continuation contSettings){
        if(contSettings.continuation != null && 
            String.isNotBlank(contSettings.continuation.continuationMethod) &&
            contSettings.continuation.timeout != null &&
            !System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled() && !Trigger.isExecuting){
            contSettings.isContinuation = true;
        }
    }
   
    private void getRequestBody() {
        if (serviceIO != null) {
            requestBody = serviceIO.convertInputToRequest(serviceInput, serviceSettings, serviceDetails);
            System.debug('Service Input : ' + serviceInput);
            System.debug('Service Endpoint : ' + serviceSettings.serviceEndpoint);
            System.debug('Service Request Header : ' + serviceSettings.requestHeader);
        }
    }

    private object prepareOutput() {
        object serviceOutput;
        //if (serviceIO != null && serviceSetting.OutputClass__c != null) {
            serviceOutput = serviceIO.convertResponseToOutput(serviceInput, responseBody, responseHeader, serviceStatus);
            System.Debug('serviceOutput : ' + string.valueof(serviceOutput));
        //}
        return serviceOutput;
    }
    
    private object prepareMockOutput() {
        if (serviceIO != null && serviceSetting.OutputClass__c != null) {
            serviceMockOutput = serviceIO.prepareMockOutput(serviceInput, responseBody, responseHeader, serviceStatus);
            System.Debug('Mocked Output : ' + string.valueof(serviceMockOutput));
        }
        return serviceMockOutput;
    }
    
    private abstract void prepareServiceRequest();

    private abstract void execute(FW_Service_Continuation contSettings);

    private abstract void processServiceResponse();

    private abstract void processContinuationResponse(Object continuationOutput);

    public Object performServiceCallout(FW_Service_Setting__mdt serviceSetting, Object serviceInput, 
                                            FW_Service_Continuation contSettings, FW_Service_Details serviceDetails) {
        System.Debug('Start performServiceCallout');
        System.Debug('serviceInput : ' + serviceInput);
        
        FW_Service_Status_Log__c statusLog = new FW_Service_Status_Log__c();
        FW_Service_Log serviceLog = new FW_Service_Log();
                
        statusLog.StartTime__c = system.now();
        try {
            this.serviceSetting = serviceSetting;
            this.serviceSettings = new FW_Service_Settings(); 
            
            this.serviceDetails = serviceDetails;           
            if(this.serviceDetails == null) this.serviceDetails = new FW_Service_Details();
            if(String.isBlank(this.serviceDetails.guid)) this.serviceDetails.guid = FW_GUID_Generator.generateGUID(); 
            this.serviceStatus.status = 'S';
            this.serviceStatus.referenceId = this.serviceDetails.guid;
            this.serviceStatus.referenceName = this.serviceDetails.messageReference;
            
            this.serviceIO = new FW_ServiceIO(serviceSetting.ProcessingClass__c);   
            this.serviceInput =  serviceInput;
            
            getServiceEndPoint();
            getRequestHeader();
            getContinuationSettings(contSettings);
            getRequestBody();

            prepareServiceRequest();
        } catch (Exception ex) {
            serviceStatus.status = 'E';
            serviceStatus.errorCode = 'Input';
            serviceStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Base Service :' + serviceStatus.errorDescription);
        }
        statusLog.InputProcessingEndTime__c = system.now();
        
        statusLog.CalloutStartTime__c = system.now();
        try {
            if (serviceStatus.status == 'S'){
                if(serviceSetting.MockResponse__c || Test.isRunningTest())
                    serviceMockOutput = prepareMockOutput();
                    
                execute(contSettings);
            }
                
            serviceLog.responseBody = responseBody;
        } catch (Exception ex) {
            serviceStatus.status = 'I';
            serviceStatus.errorCode = 'Interface';
            serviceStatus.errorDescription = ex.getMessage();
        }
        statusLog.CalloutEndTime__c = system.now();

        statusLog.OutputProcessingStartTime__c = system.now();
        object serviceOutput;
        try {
            if(!contSettings.isContinuation) {              
                if(serviceStatus.status != 'I' && !serviceSetting.MockResponse__c && !Test.isRunningTest() || Test.isRunningTest())
                //if(serviceStatus.status != 'I' && !serviceSetting.MockResponse__c && !Test.isRunningTest())// || Test.isRunningTest())
                    processServiceResponse();
                    
                serviceOutput = prepareOutput();
            }
            else
                serviceOutput = responseBody;
            if(serviceSetting.MockResponse__c) 
                serviceLog.responseBody = serviceOutput;
        } catch (Exception ex) {
            serviceStatus.status = !Test.isRunningTest() ? 'E' : 'S';
            serviceStatus.errorCode = 'Output';
            serviceStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Base Service :' + serviceStatus.errorDescription);
            //system.assert (false,ex.getmessage() + '-' + ex.getstacktracestring());
        }
        statusLog.EndTime__c = system.now();
        
        statusLog.UID__c = this.serviceDetails.guid;
        statusLog.MessageReference__c = this.serviceDetails.messageReference;
        statusLog.Continuation__c = contSettings.isContinuation;
        
        serviceLog.requestBody = this.requestBody;        
        serviceLog.serviceSetting = serviceSetting;
        serviceLog.serviceStatus = serviceStatus;  
        if(contSettings.isContinuation) contSettings.continuationState.serviceInput = serviceInput;     
        statusLog = serviceLog.logServiceStatus(statusLog);
        if(contSettings.isContinuation) contSettings.continuationState.serviceStatusLog = statusLog;
        
        System.Debug('End performServiceCallout');  
        
        return serviceOutput;
    }

    public Object processContinuationResponse(FW_Service_Setting__mdt serviceSetting, Object continuationOutput, 
                                                    FW_Service_Continuation contSettings, FW_Service_Details serviceDetails) {

        FW_Service_Status_Log__c statusLog = new FW_Service_Status_Log__c();
        FW_Service_Log serviceLog = new FW_Service_Log();
        
        try {
            this.serviceSetting = serviceSetting;
            this.serviceIO = new FW_ServiceIO(serviceSetting.ProcessingClass__c);
            this.serviceStatus.status = 'S';             
            statusLog = contSettings.continuationState.serviceStatusLog;
            this.serviceStatus.referenceId = statusLog.UID__c;
            this.serviceStatus.referenceName = statusLog.MessageReference__c;
            this.serviceInput = contSettings.continuationState.serviceInput;
        } catch (Exception ex) {
            serviceStatus.status = 'E';
            serviceStatus.errorCode = 'Input';
            serviceStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Base Service :' + ex.getMessage() + ex.getstacktracestring());
        }

        try {
            if(serviceSetting.MockResponse__c || Test.isRunningTest())
                serviceMockOutput = prepareMockOutput();
            processContinuationResponse(continuationOutput);            
            serviceLog.responseBody = responseBody;
        } catch (Exception ex) {
            serviceStatus.status = 'I';
            serviceStatus.errorCode = 'Interface';
            serviceStatus.errorDescription = ex.getMessage();
        }
        statusLog.CalloutEndTime__c = system.now();
       
        statusLog.OutputProcessingStartTime__c = system.now();
        object serviceOutput;
        try {
            if(serviceStatus.status != 'I' && !serviceSetting.MockResponse__c && !Test.isRunningTest())
                processServiceResponse();
            serviceOutput = prepareOutput();
            if(serviceSetting.MockResponse__c) serviceLog.responseBody = serviceOutput;
        } catch (Exception ex) {
            serviceStatus.status = 'E';
            serviceStatus.errorCode = 'Output';
            serviceStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Base Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        statusLog.EndTime__c = system.now();
                                
        serviceLog.serviceSetting = serviceSetting;
        serviceLog.serviceStatus = serviceStatus;           
        statusLog = serviceLog.logServiceStatus(statusLog);

        system.Debug('End processContinuationResponse');
        
        return serviceOutput;
    }

}