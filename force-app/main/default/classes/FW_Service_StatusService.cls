@RestResource(urlMapping='/FW/ServiceStatus/*')
global without sharing class FW_Service_StatusService {
	
	@HttpPost
	global static FW_Service_Status_Log__c doGet() {
		
		RestRequest req = RestContext.request;
		
		string requestString = req.requestBody.toString();
		FW_Service_Status_Log__c statusLog = 
			(FW_Service_Status_Log__c) JSON.deserialize(requestString, FW_Service_Status_Log__c.class);
		
		system.debug('Before DML : ' + statusLog);		
		if(statusLog.id != null)	
			upsert statusLog;
		else
			insert statusLog;
		system.debug('After DML : ' + statusLog);
		
		return statusLog;
	}
    
}