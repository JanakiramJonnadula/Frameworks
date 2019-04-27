@isTest
public without sharing class FW_Service_StatusServiceTest {
    
    static testMethod void PositiveTest() { 
        FW_Service_Status_Log__c fss = new FW_Service_Status_Log__c();
        fss.Name = 'Test';
        fss.MessageReference__c = '500';       
        fss.ErrorCode__c = 'E';
        fss.ErrorDescription__c = 'Error';
        insert fss;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        string JsonMsg = '{"key": "Value"}';
        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;    
         FW_Service_Status_Log__c  response = FW_Service_StatusService.doGet();
    }
    
}