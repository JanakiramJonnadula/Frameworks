public without sharing class FW_PlatformEventPublishServiceHelper   extends FW_ServiceIO_APEX {

    public override object convertInputToRequest() {
        FW_PlatformEventPublishServiceInput input = (FW_PlatformEventPublishServiceInput) serviceInput;     
        return input;   
    }

    public override object execute() {
        FW_PlatformEventPublishServiceInput input = (FW_PlatformEventPublishServiceInput) serviceInput;
        FW_PlatformEventPublishServiceOutput output = new FW_PlatformEventPublishServiceOutput();   
         output.tranId = input.tranId;
        try{
            
            List<Database.SaveResult> results = EventBus.publish(input.events);
            
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    output.tranStatus = 'S';
                    output.success = true;
                    System.debug('Successfully published event.');
                } else {
                    output.tranStatus = 'E';
                    output.success = false;
                    list<String> errors = new list<String>();
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                        errors.add('Error returned: ' + 
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                    output.errors = errors;
                }       
            }
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
