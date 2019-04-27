public interface FW_Service_Interface {
    
    object performServiceCallout(FW_Service_Setting__mdt serviceSettings, object serviceInput, 
    								FW_Service_Continuation contSettings, FW_Service_Details serviceDetails);
    
    object processContinuationResponse(FW_Service_Setting__mdt serviceSettings, object serviceInput, 
    								FW_Service_Continuation contSettings, FW_Service_Details serviceDetails);
    
}