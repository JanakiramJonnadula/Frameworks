public without sharing class FW_Service_Log {

    public Object requestBody;
    public Object responseBody;

    public FW_Service_Setting__mdt serviceSetting;
    public FW_Service_Status serviceStatus;
    
    public Object transInput;
    public Object transOutput;
    
    public FW_TransformationSetting__mdt transSetting;
    public FW_Transformation_Status transStatus;
    
    public static FW_Global_Setting__mdt pii_regex;
    public static FW_Global_Setting__mdt pii_variables;
	public static FW_Global_Setting__mdt pii_logAll;

    public FW_Service_Status_Log__c logServiceStatus(FW_Service_Status_Log__c statusLog) {
        System.Debug('Log Service Status START');
        try {
            if (serviceSetting.LogStatus__c) {

                statusLog.Name = serviceSetting.QualifiedApiName + 'Service';
                                
                statusLog.Status__c = serviceStatus.status;
                statusLog.ErrorCode__c = serviceStatus.errorCode;
                statusLog.ErrorDescription__c = serviceStatus.errorDescription;
                statusLog.LogType__c = 'Service';
                
                getPIISettings();
              
                if (serviceSetting.LogRequest__c && requestBody != null && statusLog.RequestBody__c == null) {
                    string request;
                    string request1;
                    string request2;
                    if (requestBody instanceof string)
                        request = (String) requestBody;
                    else
                        //request = string.valueof(requestBody);
                        request = JSON.serializePretty(requestBody);
                    if (request.length() > 131000){
                        request1 = request.substring(0, 131000);
                        if(request.length() > 262000)
                        	request2 = request.substring(131000, 131000);
                        else
                        	request2 = request.substring(131000, request.length() - 131000);
                    }
                    else
                    	request1 = request;
                    statusLog.RequestBody__c = !serviceSetting.LogRequestPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(request1): request1;
                    statusLog.RequestBody2__c = !serviceSetting.LogRequestPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(request2): request2;
                }
                
                if (serviceSetting.LogResponse__c && responseBody != null) {
                    string response;
                    string response1;
                    string response2;
                    if (responseBody instanceof string)
                        response = (String) responseBody;
                    else
                        //response = string.valueof(responseBody);
                        response = JSON.serializePretty(responseBody);
                    if (response.length() > 131000){
                        response1 = response.substring(0, 131000);
                        if(response.length() > 262000)
                        	response2 = response.substring(131000, 131000);
                        else
                        	response2 = response.substring(131000, response.length() - 131000);
                    }
                    else
                    	response1 = response;
                    	
                    system.debug('RES1 : ' + serviceSetting.LogResponsePII__c);
                    system.debug('RES2 : ' + pii_logAll);
                    system.debug('RES3 : ' + pii_logAll.Value__c);
                    	
                    statusLog.ResponseBody__c = !serviceSetting.LogResponsePII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(response1): response1;
                    statusLog.ResponseBody2__c = !serviceSetting.LogResponsePII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(response2): response2;
                }
                
                system.debug('TEST : ' + statusLog);
                
                statusLog.InputProcessingTime__c = statusLog.InputProcessingEndTime__c.getTime() - statusLog.StartTime__c.getTime();
                statusLog.CalloutTime__c = statusLog.CalloutEndTime__c.getTime() - statusLog.CalloutStartTime__c.getTime();
                statusLog.OutputProcessingTime__c = statusLog.EndTime__c.getTime() - statusLog.OutputProcessingStartTime__c.getTime();

                System.Debug('Log Service Status BEFORE INSERT' + statusLog);
                
                boolean canLog = true;
                
                if(serviceSetting.LogFail__c && serviceStatus.status == 'S')
                	canLog = false;

				if(canLog){
	                if(statusLog.Continuation__c || serviceSetting.LogWithCallout__c){
	                	FW_Service service = new FW_Service(FW_Service_Helper.statusLogService);   
						statusLog = (FW_Service_Status_Log__c) service.callout(statusLog);
						//object output = service.callout(statusLog);
	                }
	                else
	                	insert statusLog;
				}

                System.Debug('Log Service Status END');
            }
        } catch (Exception ex) {
            system.debug('@@Error Logging :' + ex.getMessage() + ex.getstacktracestring());             
        }
        
        return statusLog;
    }
    
    public FW_Service_Status_Log__c logTransformationStatus(FW_Service_Status_Log__c statusLog) {
        System.Debug('Log Transformation Status START');
		System.Debug('transSetting.LogStatus__c : ' + transSetting.LogStatus__c);
        try {
            if (transSetting.LogStatus__c) {

                statusLog.Name = transSetting.QualifiedApiName + 'Transformation';
                                
                statusLog.Status__c = transStatus.status;
                statusLog.ErrorCode__c = transStatus.errorCode;
                statusLog.ErrorDescription__c = transStatus.errorDescription;
                statusLog.LogType__c = 'Remoting';
                
                getPIISettings();
              
                if (transSetting.LogInput__c && transInput != null && statusLog.RequestBody__c == null) {
                    string request;
                    string request1;
                    string request2;
                    if (transInput instanceof string)
                        request = (String) transInput;
                    else
                        request = JSON.serializePretty(transInput);
                    if (request.length() > 131000){
                        request1 = request.substring(0, 131000);
                        if(request.length() > 262000)
                        	request2 = request.substring(131000, 131000);
                        else
                        	request2 = request.substring(131000, request.length() - 131000);
                    }
                    else
                    	request1 = request;
                    statusLog.RequestBody__c = !transSetting.LogInputPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(request1): request1;
                    statusLog.RequestBody2__c = !transSetting.LogInputPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(request2): request2;
                }
                
                if (transSetting.LogOutput__c && transOutput != null) {
                    string response;
                    string response1;
                    string response2;
                    if (transOutput instanceof string)
                        response = (String) transOutput;
                    else
                        response = JSON.serializePretty(transOutput);
                    if (response.length() > 131000){
                        response1 = response.substring(0, 131000);
                        if(response.length() > 262000)
                        	response2 = response.substring(131000, 131000);
                        else
                        	response2 = response.substring(131000, response.length() - 131000);
                    }
                    else
                    	response1 = response;
                    statusLog.ResponseBody__c = !transSetting.LogOutputPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(response1): response1;
                    statusLog.ResponseBody2__c = !transSetting.LogOutputPII__c && pii_logAll != null && pii_logAll.Value__c != 'Y' ? removePII(response2): response2;
                }
                
                statusLog.InputProcessingTime__c = statusLog.InputProcessingEndTime__c.getTime() - statusLog.StartTime__c.getTime();
                statusLog.CalloutTime__c = statusLog.CalloutEndTime__c.getTime() - statusLog.CalloutStartTime__c.getTime();
                statusLog.OutputProcessingTime__c = statusLog.EndTime__c.getTime() - statusLog.OutputProcessingStartTime__c.getTime();

                System.Debug('Log Transformation Status BEFORE INSERT' + statusLog);
                
                boolean canLog = true;
                
                if(transSetting.LogFail__c && transStatus.status == 'S')
                	canLog = false;

				if(canLog){
	                //if(statusLog.Continuation__c || transSetting.LogWithCallout__c){
	                	FW_Service service = new FW_Service(FW_Service_Helper.statusLogService);   
						statusLog = (FW_Service_Status_Log__c) service.callout(statusLog);
						//object output = service.callout(statusLog);
	                //}
	                //else
	                	//insert statusLog;
				}

                System.Debug('Log Transformation Status END');
            }
        } catch (Exception ex) {
            system.debug('@@Error Logging :' + ex.getMessage() + ex.getstacktracestring());            
        }
        
        return statusLog;
    }
    
    public static string removePII(string input){
    	
    	if(input != null){
    		
			list<string> piiVariables = pii_variables.Value__c.split(',');
				
			for(string variable : piiVariables){
				String rg = pii_regex.Value__c.replace('Variable', variable);
				//system.debug(rg);
				string replace = '\"' + variable + '\" : \"' + '*****\"';
				input = input.replaceAll(rg, replace);				
			}
    	}
    	
    	system.debug('After Remove PII Data :' + input);
    	
    	return input;
    }
    
    public static void getPIISettings(){
    	if(pii_regex == null)
    	pii_regex = [SELECT Value__c FROM FW_Global_Setting__mdt 
                                                    WHERE QualifiedApiName = 'FW_PII_RegEx' limit 1];
        if(pii_variables == null)
	    pii_variables = [SELECT Value__c FROM FW_Global_Setting__mdt 
	                                                    WHERE QualifiedApiName = 'FW_PII_Variables' limit 1];
		if(pii_logAll == null)
		pii_logAll = [SELECT Value__c FROM FW_Global_Setting__mdt 
	                                                    WHERE QualifiedApiName = 'FW_Log_PII_All' limit 1];
    }

}