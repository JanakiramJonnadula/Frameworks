@RestResource(urlMapping='/FW/Service/*')
global with sharing virtual class FW_Transformation_Controller {
    
    FW_Service_ContinuationState conState;
    public object result { get; set; }
    
    public FW_Transformation_Controller() {
        String hostname = URL.getSalesforceBaseUrl().getHost();
        String mydomain;
        if(hostname.indexOf('--c') != -1) mydomain = hostname.substring(0, hostname.indexOf('--c'));
        String lcBaseURL = 'https://' + mydomain + '.lightning.force.com';
        Map<String, String> headers = Apexpages.currentPage().getHeaders(); 
        headers.put('X-Frame-Options', 'ALLOW-FROM ' + lcBaseURL);
        headers.put('Content-Security-Policy', 'frame-ancestors ' + lcBaseURL);
        //Map<String, String> headers = Apexpages.currentPage().getHeaders();
        //headers.put('X-Frame-Options', 'ALLOW-FROM ' + 'https://janakiram-client-dev-ed.lightning.force.com');
        //headers.put('Content-Security-Policy', 'frame-ancestors ' + 'https://janakiram-client-dev-ed.lightning.force.com');        
    }

    @AuraEnabled(cacheable=true)
    public static String getVFBaseURL() {
        User user = [SELECT fullPhotoUrl FROM User WHERE userType = 'Standard' LIMIT 1]; 
        // The above query returns a URL like https://my-domain-dev-ed--c.na50.content.force.com/profilephoto/001/A
        // Let's use the two first fragments of that URL to create the VF base URL 
        List<String> fragments = user.fullPhotoUrl.split('\\.');
        return (fragments[0] + '.' + fragments[1] + '.visual.force.com').toLowerCase();
    }
    
    //Remote call handler for the Lightning App/Components    
    @AuraEnabled
    public static object startLightningRequest(String requestName, object containerInput) {    
        
        FW_Transformation transformation = new FW_Transformation(requestName);       
        return transformation.execute(containerInput);
    }
    
    //Remote call handler for the Visualforce Pages
    @RemoteAction    
    global static object startRequest(String requestName, object containerInput) {    
        
        FW_Transformation transformation = new FW_Transformation(requestName);
        
        Continuation continuation = new Continuation(transformation.continuationTimeout);
        continuation.continuationMethod = transformation.continuationMethod;
        transformation.continuation = continuation;
        
        FW_Service_ContinuationState continuationState = new FW_Service_ContinuationState();
        continuationState.requestName = requestName;
        transformation.continuationState = continuationState;
        
        object containerOutput = transformation.execute(containerInput);
        
        continuationState.requestLabel = containerOutput;        
        continuation.state = continuationState;
        
        return transformation.isContinuation ? continuation : containerOutput;
    }
    
    //Remote call handler for the Visualforce Pages - Not Governor Limts applies on Queries
    @RemoteAction @ReadOnly   
    global static object startReadOnlyRequest(String requestName, object containerInput) {
                
        FW_Transformation transformation = new FW_Transformation(requestName);
        object containerOutput = transformation.execute(containerInput);
        
        return containerOutput;
    }
    
    /*
    //Remote call handler for the Visualforce Pages
    @RemoteAction    
    global static object startParallelRequest(String requestName, object containerInput) {    
        
        FW_Transformation transformation = new FW_Transformation(requestName);
        
        Continuation continuation = new Continuation(transformation.continuationTimeout);
        continuation.continuationMethod = transformation.continuationMethod;
        transformation.continuation = continuation;
        
        FW_Service_ContinuationState continuationState = new FW_Service_ContinuationState();
        continuationState.requestName = requestName;
        transformation.continuationState = continuationState;
        
        object containerOutput = transformation.execute(containerInput);
        
        continuationState.requestLabel = containerOutput;        
        continuation.state = continuationState;
        
        return transformation.isContinuation ? continuation : containerOutput;
    }
    */
    
    //Remote call handler for the Visualforce Pages - Continuation Callback
    global static object processResponse(object state) {
    
        FW_Service_ContinuationState continuationState = (FW_Service_ContinuationState) state;  
        
        FW_Transformation transformation = new FW_Transformation(continuationState.requestName); 
        transformation.continuationState = continuationState;
        object containerOutput = transformation.transformContinuationOutput(continuationState.requestLabel);
        
        return containerOutput;
    }
    
    //Action handler for the Visualforce Pages
    public object startRequest(String requestName) {
         
        FW_Transformation transformation = new FW_Transformation(requestName);
        
        Continuation continuation = new Continuation(transformation.continuationTimeout);
        continuation.continuationMethod = transformation.continuationMethod;
        transformation.continuation = continuation;
        
        conState = new FW_Service_ContinuationState();
        conState.requestName = requestName;
        transformation.continuationState = conState;
        
        object containerOutput = transformation.execute('UP');
        conState.requestLabel = containerOutput;
        
        continuation.state = conState;
        
        return transformation.isContinuation ? continuation : containerOutput;
    }
    
    //Action handler for the Visualforce Pages - Continuation Callback
    public void processResponse() {
        
        FW_Transformation transformation = new FW_Transformation(conState.requestName); 
        transformation.continuationState = conState;
        object containerOutput = transformation.transformContinuationOutput(conState.requestLabel);
                
        this.result = containerOutput;   
    }
    
    //Async Handler for the Apex execution
    public static object startAsyncRequest(String requestName, object containerInput) {
        AsyncExecution asyncExecution = new AsyncExecution();
        asyncExecution.requestName = requestName;
        asyncExecution.containerInput = containerInput;
        ID jobID = System.enqueueJob(asyncExecution);
        return jobID;
    }
    
    //Async implementation for the Apex execution
    private class AsyncExecution implements Queueable {
        public String requestName; 
        public object containerInput;
        public void execute(QueueableContext context) {
            FW_Transformation transformation = new FW_Transformation(requestName);       
            transformation.execute(containerInput);        
        }
    }
    
    //Restart the request Status Log button   
    webservice static string restartRequest(string serviceStatusLogID) {
        
        if(serviceStatusLogID != null){
            FW_Service_Status_Log__c log = [SELECT Id, Name, RequestBody__c, LogType__c FROM FW_Service_Status_Log__c
                                            WHERE Id =: serviceStatusLogID];
            
           if(log != null){
                if(log.LogType__c == 'Remoting'){
                    FW_TransformationSetting__mdt transformationSetting = [Select OutputClass__c, InputClass__c
                                                                    From FW_TransformationSetting__mdt
                                                                    WHERE QualifiedApiName =: log.Name.replace('Transformation', '')
                                                                    limit 1];                   
                    FW_Transformation transformation = new FW_Transformation(log.Name.replace('Transformation', '')); 
                       
                    return string.valueof(transformation.execute(JSON.deserialize(log.RequestBody__c, Type.forName(transformationSetting.InputClass__c))));
                }
                else if(log.LogType__c == 'Service'){
                    FW_Service_Setting__mdt serviceSetting = [Select OutputClass__c, InputClass__c
                                                        From FW_Service_Setting__mdt
                                                        WHERE QualifiedApiName =: log.Name.replace('Service', '')
                                                        limit 1];
                    FW_Service service = new FW_Service(log.Name.replace('Service', ''));
                    
                    return string.valueof(service.callout(JSON.deserialize(log.RequestBody__c, Type.forName(serviceSetting.InputClass__c))));
                }
                else return 'Error';
            }  
            else return 'No Status Log Record Found.';          
            
        }
        else return 'Status Log Record ID is Blank';
    }
    
    @HttpPost
    global static string startRequest() {
        
        RestRequest req = RestContext.request;      
        string requestString = req.requestBody.toString();
        
        String requestName = req.params.get('requestName');
        
        system.debug('1 : ' + requestName);
        system.debug('2 : ' + requestString);
        
        FW_TransformationSetting__mdt transformationSetting = [Select OutputClass__c, InputClass__c
                                                                    From FW_TransformationSetting__mdt
                                                                    WHERE QualifiedApiName = : requestName
                                                                    limit 1];
        
        FW_Transformation transformation = new FW_Transformation(requestName);
        
        return JSON.serialize(transformation.execute(requestString));
        //return string.valueOf(transformation.execute(requestString));
        //return string.valueOf(transformation.execute(JSON.deserialize(requestString, Type.forName(transformationSetting.InputClass__c))));
    }
    
    /*
    // Called via JavaScript Remoting
    @RemoteAction
    global static Object invoke(String methodName, String[] params) {

        if (methodName == 'getProducts') {
            // Make an HTTPRequest as we normally would
            // Remember to configure a Remote Site Setting for the service!
            String url = 'https://long-running.herokuapp.com/products?latency=' + params[0];
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);

            // Create a Continuation for the HTTPRequest        
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(req);
            con.continuationMethod = 'callback';        

            // Return it to the system for processing
            return con;
        } else if (methodName == 'getProduct') {
            // Make an HTTPRequest as we normally would
            // Remember to configure a Remote Site Setting for the service!
            String url = 'https://long-running.herokuapp.com/products/' + params[0] + '?latency=' + params[1];
            HttpRequest req = new HttpRequest();
            req.setMethod('GET');
            req.setEndpoint(url);

            // Create a Continuation for the HTTPRequest        
            Continuation con = new Continuation(60);
            con.state = con.addHttpRequest(req);
            con.continuationMethod = 'callback';        

            // Return it to the system for processing
            return con;
        } else {
            return null;
        }
    }

    global static Object callback(Object state) {
        HttpResponse response = Continuation.getResponse((String)state);
        Integer statusCode = response.getStatusCode();
        if (statusCode >= 2000) {
            return 'Continuation error: ' + statusCode;
        }
        return response.getBody();
    }
    */
    
}