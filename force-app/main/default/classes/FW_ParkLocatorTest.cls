@isTest
public with sharing class FW_ParkLocatorTest {
    
    //Positive Test Cases
    static testMethod void runPositiveTestCase1() {
        FW_ParkLocatorInput input = new FW_ParkLocatorInput();  
        input.country = 'India';
        
        FW_Transformation transformation = new FW_Transformation('FW_ParkLocatorSOAP');
        object output = transformation.execute(input);
    }
    static testMethod void runvNegetiveTestCase1() {
        FW_ParkLocatorInput input = new FW_ParkLocatorInput();  
        
        FW_Transformation transformation = new FW_Transformation('FW_ParkLocatorSOAP');
        object output = transformation.execute(input);
    }
    
    static testMethod void runPositiveTestCase2() {
        FW_ParkLocatorInput input = new FW_ParkLocatorInput();  
        input.country = 'India';
        
        Continuation continuation = (Continuation) FW_Transformation_Controller.startRequest('FW_ParkLocatorSOAP', input);
        
        FW_Service_ContinuationState state = new FW_Service_ContinuationState();
        state.requestLabel = 'Continuation-1';
        state.requestName = 'FW_ParkLocatorSOAP';
        state.dataInput = input;
        
        FW_ParkLocatorInput serviceInput = new FW_ParkLocatorInput();
        serviceInput.country = 'Park1';
        state.serviceInput = serviceInput;
        
        FW_Service_Status_Log__c slog = new FW_Service_Status_Log__c();
        FW_Service_Status_Log__c tlog = new FW_Service_Status_Log__c();
        state.serviceStatusLog = slog;  
        state.transformationStatusLog = tlog;
        object output = FW_Transformation_Controller.processResponse(state);
        
        //Object result = Test.invokeContinuationMethod(controller, continuation);
    }    
}