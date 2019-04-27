public without sharing class FW_ParkLocatorHelper extends FW_Transformation_REMOTING {
	
	public override object validateInput(Object dataInput){
		FW_ParkLocatorInput input = (FW_ParkLocatorInput) dataInput;     

        string validationCode;      
        string messageReference;
        
        if(input != null && input.country != null){
			messageReference = input.country;
		}
        else{
             validationCode = 'V001';               
        }
        
        if(string.isNotBlank(validationCode)){
            
            continueExecution = false;
            
            FW_ParkLocatorOutput output = new FW_ParkLocatorOutput();
            output.tranId = transDetails.guid;
            
            output.tranCode = validationCode;
            transStatus.errorCode = validationCode;
            
            output.tranStatus = 'E';
            transStatus.status = 'E';

            output.tranStatusDescription = 'Country is Blank';
            transStatus.errorDescription = output.tranStatusDescription;
            
            transDetails.messageReference = messageReference;       
            return output;
        }
        
        return dataInput;
	}
	
	public override object transformInput(Object dataInput){
		FW_ParkLocatorInput input = (FW_ParkLocatorInput) dataInput; 
		FW_ParkLocatorServiceInput serviceInput = new FW_ParkLocatorServiceInput();
		serviceInput.country = input.country;
		
		serviceInput.tranId = transDetails.guid;
		
		transDetails.messageReference = input.country;
        return serviceInput;
	}
	
	public override object transformOutput(Object dataInput, Object operationOutput){
		FW_ParkLocatorInput input = (FW_ParkLocatorInput) dataInput;
        FW_ParkLocatorOutput output = new  FW_ParkLocatorOutput();
        
        string errorCode;
        try
        {
            if(transStatus != null && transStatus.status == 'S')
            {
                FW_ParkLocatorServiceOutput serviceOutput = (FW_ParkLocatorServiceOutput) operationOutput;
                output.tranId = serviceOutput.tranId;
                output.tranStatus = serviceOutput.tranStatus;
                output.tranCode = serviceOutput.tranCode;
                output.tranStatusDescription = serviceOutput.tranStatusDescription;

                if(serviceOutput.tranStatus == 'S' || serviceOutput.tranStatus == 'P')
                {   
                    output.parks = serviceOutput.parks;
                }
                else
                {
                    errorCode = 'SERVICE_ERROR';
                    output.tranStatusDetails = transStatus.errorDescription;
                }
            }
        }
        catch(Exception ex)
        {
            errorCode = 'UNABLE_TOPROCESS_THE_REQUEST';
            output.tranStatusDetails = 'Transformation Error : ' + ex.getMessage() + ex.getstacktracestring();
        }
        if(string.isNotBlank(errorCode))
        {
            output.tranId = transDetails.guid;
            output.tranCode = errorCode;
            output.tranStatus = 'E';
        }
        if(string.isNotBlank(output.tranCode))
        {
            output.tranStatusDescription = 'Error Based on Error Code';
        }
        return output;
	}
    
}