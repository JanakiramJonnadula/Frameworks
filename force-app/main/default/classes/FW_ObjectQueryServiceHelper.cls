public without sharing class FW_ObjectQueryServiceHelper  extends FW_ServiceIO_APEX {
    
    public override object convertInputToRequest() {
        FW_ObjectQueryServiceInput input = (FW_ObjectQueryServiceInput) serviceInput;     
        return input;   
    }

    public override object execute() {
        FW_ObjectQueryServiceInput input = (FW_ObjectQueryServiceInput) serviceInput;
        FW_ObjectQueryServiceOutput output = new FW_ObjectQueryServiceOutput();   
         output.tranId = input.tranId;
        try{           
            output.tranStatus = 'S';
        }      
        catch(Exception ex){
            output.tranStatus = 'E';
            //output.tranCode =  'UNABLE_TOPROCESS_THE_REQUEST';
            //output.tranStatusDescription = ex.getLineNumber() + ' : ' + ex.getMessage();
            
        }
        
        return output;      
    }
      
    public override object convertResponseToOutput(object serviceInput, object response, 
                                                        Map<string, string> responseHeader, 
                                                        FW_Service_Status serviceStatus) {
                                                            
        return response;
    }

}