public without sharing class FW_Service_Helper {
    
    public final static string serviceStrategies = 'FW_Service_Strategies';    
    public final static string statusLogService = 'FW_Service_StatusLog';
    public final static string FW_OAuth_Session = 'FW_OAuth_Session';
    //public final static string FW_OAuth_Bearer = 'FW_OAuth_Bearer';
    
    public static map<String, String> getServiceHeaders(string headerType, string customCredentials){
        
        system.debug('ServiceHelper - getServiceHeaders');
        
        map<string, string> headers = new map<string, string>();

        if(string.isNotBlank(headerType)){
            
          FW_Service_Header__mdt serviceHeaders = [Select 
                                                    QualifiedApiName, MasterLabel, Label, Id, DeveloperName, ContentType__c, ContentLength__c, ContentEncoding__c, 
                                                    AcceptEncoding__c, Accept__c
                                                        From FW_Service_Header__mdt
                                                            WHERE QualifiedApiName = : headerType
                                                            limit 1];
          if(serviceHeaders.ContentType__c != null) headers.put('Content-Type',serviceHeaders.ContentType__c);
          
          if(serviceHeaders.ContentEncoding__c != null) headers.put('Content-Encoding',serviceHeaders.ContentEncoding__c);
          
          if(serviceHeaders.AcceptEncoding__c != null) headers.put('Accept-Encoding',serviceHeaders.AcceptEncoding__c);
          
          if(serviceHeaders.ContentLength__c != null) headers.put('Content-Length',serviceHeaders.ContentLength__c);
          
          if(serviceHeaders.Accept__c != null) headers.put('Accept',serviceHeaders.Accept__c);
          
          if(String.isNotBlank(customCredentials)){
	          if(customCredentials.equalsIgnoreCase(FW_OAuth_Session)){
	          	headers.put('Authorization', 'OAuth' + ' ' + UserInfo.getSessionId());
	          }
	          //else if(customCredentials.equalsIgnoreCase(FW_OAuth_Bearer)){
	          	//headers.put('Authorization', 'Bearer' + ' ' + 'XYZ';
	          //}
	          /*else if(customCredentials.equalsIgnoreCase('TEST')){
	          	Blob headerValue = Blob.valueOf(serviceHeaders.Username__c + ':' + serviceHeaders.Password__c);
	            string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	            headers.put('Authorization',authorizationHeader);
	          }*/
	          //Future Implementation - OAuth Framework
	          /*else if(serviceHeaders.Username__c != null && serviceHeaders.Password__c != null){
	              Blob headerValue = Blob.valueOf(serviceHeaders.Username__c + ':' + serviceHeaders.Password__c);
	              string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
	              headers.put('Authorization',authorizationHeader); 
	          }*/
          }
          
        }
        return headers;
    }
    
}