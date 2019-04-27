public without sharing class FW_ObjectQueryHelper extends FW_Transformation_REMOTING{

    public override object transformInput(Object dataInput){
        FW_ObjectQueryInput input = (FW_ObjectQueryInput) dataInput;
        transDetails.messageReference = input.objectName;   

        FW_ObjectQueryServiceInput serviceInput = new FW_ObjectQueryServiceInput();      
        serviceInput.objectName = input.objectName;
        serviceInput.fields = input.fields;

        return serviceInput;
     }
      
     public override object transformOutput(Object dataInput, Object operationOutput){
        
        FW_ObjectQueryInput input = (FW_ObjectQueryInput)dataInput;
        FW_ObjectQueryOutput output = new FW_ObjectQueryOutput();
        
        FW_ObjectQueryServiceOutput serviceOutput = (FW_ObjectQueryServiceOutput)operationOutput;     
        
        output.tranid = serviceOutput.tranid;
        output.tranStatus = serviceOutput.tranStatus;
        output.tranStatusDescription = serviceOutput.tranStatusDescription;
        output.tranCode = serviceOutput.tranCode;
        transStatus.status = serviceOutput.tranStatus;
        transStatus.errorDescription = serviceOutput.tranStatusDescription;
        
        try
        {            
            if(transStatus != null && transStatus.status == 'S'){                
                output.result = serviceOutput.result;
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