public without sharing class FW_PlatformEventPublishHelper extends FW_Transformation_REMOTING{

    public override object transformInput(Object dataInput){
        FW_PlatformEventPublishInput input = (FW_PlatformEventPublishInput) dataInput;
        transDetails.messageReference = 'Publish Events';   

        FW_PlatformEventPublishServiceInput serviceInput = new FW_PlatformEventPublishServiceInput();      
        serviceInput.events = input.events;

        return serviceInput;
     }
      
     public override object transformOutput(Object dataInput, Object operationOutput){
        
        FW_PlatformEventPublishInput input = (FW_PlatformEventPublishInput)dataInput;
        FW_PlatformEventPublishOutput output = new FW_PlatformEventPublishOutput();
        
        FW_PlatformEventPublishServiceOutput serviceOutput = (FW_PlatformEventPublishServiceOutput)operationOutput;     
        
        output.tranid = serviceOutput.tranid;
        output.tranStatus = serviceOutput.tranStatus;
        output.tranStatusDescription = serviceOutput.tranStatusDescription;
        output.tranCode = serviceOutput.tranCode;
        transStatus.status = serviceOutput.tranStatus;
        transStatus.errorDescription = serviceOutput.tranStatusDescription;
        
        try
        {            
            if(transStatus != null && transStatus.status == 'S'){   
                output.id = serviceOutput.id;             
                output.success = serviceOutput.success;
            }
            else{
                output.tranCode = 'UNABLE_TOPROCESS_THE_REQUEST' ;
                output.tranStatusDetails = transStatus.errorDescription;
            } 
        }
        catch(Exception ex)
        {   
            output.tranCode = 'UNABLE_TOPROCESS_THE_REQUEST';
            output.tranStatusDescription= 'Transformation Error : ' + ex.getMessage() + ex.getstacktracestring();
        }       
        
        return output;     
     }    
}
