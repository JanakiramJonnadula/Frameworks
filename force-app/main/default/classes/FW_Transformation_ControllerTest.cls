@isTest
public without sharing class FW_Transformation_ControllerTest {

	static testMethod void runPositiveTestCase1() {
		FW_Transformation_Controller ftc = new FW_Transformation_Controller();
		FW_Transformation_Controller.getVFBaseURL();
	}

	static testMethod void runPositiveTestCase2() {
		FW_ProductSearchInput input = new FW_ProductSearchInput();  
        input.latency = '6000';
        
		FW_Transformation_Controller.startLightningRequest('FW_ProductSearchREST', input);
	}
	
	static testMethod void runPositiveTestCase3() {
		FW_ParkLocatorInput input = new FW_ParkLocatorInput();  
        input.country = 'India';

		FW_Transformation_Controller.startRequest('FW_ParkLocatorSOAP', input);
		
		FW_Service_ContinuationState state = new FW_Service_ContinuationState();
		state.requestLabel = 'Continuation-1';
		state.requestName = 'FW_ParkLocatorSOAP';
		state.dataInput = input;
		FW_ParkLocatorServiceInput serviceInput = new FW_ParkLocatorServiceInput();
		
		state.serviceInput = serviceInput;
		
		FW_Service_Status_Log__c slog = new FW_Service_Status_Log__c();
		FW_Service_Status_Log__c tlog = new FW_Service_Status_Log__c();
		state.serviceStatusLog = slog;	
		state.transformationStatusLog = tlog;
		object output = FW_Transformation_Controller.processResponse(state);
		
		//Object result = Test.invokeContinuationMethod(controller, continuation);*/
	}

	static testMethod void runPositiveTestCase4() {
		FW_ProductSearchInput input = new FW_ProductSearchInput();  
        input.latency = '6000';
        
		FW_Transformation_Controller.startReadOnlyRequest('FW_ProductSearchREST', input);
	}

	static testMethod void runPositiveTestCase5() {
		FW_ObjectQueryInput input = new FW_ObjectQueryInput();  
        input.objectName = 'Account';

		String myJSON = JSON.serialize(input);
		
        RestRequest request = new RestRequest();
        request.requestUri = System.Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/FW/Service';
        request.httpMethod = 'POST';
		request.requestBody = Blob.valueof(myJSON);

		request.params.put('requestName', 'FW_ProductSearchREST');		
        RestContext.request = request;        
		
		FW_Transformation_Controller.startRequest();
	}

	static testMethod void runPositiveTestCase6() {        
		FW_Transformation_Controller.restartRequest(null);
	}
    
}