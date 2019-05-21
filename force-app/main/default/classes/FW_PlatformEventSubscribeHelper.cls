public without sharing class FW_PlatformEventSubscribeHelper extends FW_Transformation_REMOTING{

    public override object transformInput(Object dataInput){
        FW_PlatformEventSubscribeInput input = (FW_PlatformEventSubscribeInput) dataInput;
        transDetails.messageReference = 'Subscribe Events';   

        return dataInput;
     }
      
     public override object transformOutput(Object dataInput, Object operationOutput){
        
        FW_PlatformEventSubscribeInput input = (FW_PlatformEventSubscribeInput)dataInput;
        FW_PlatformEventSubscribeOutput output = new FW_PlatformEventSubscribeOutput();   
               
        
        try
        {            
            if(transStatus != null && transStatus.status == 'S'){   
                //output.tranid = serviceOutput.tranid;
                output.tranStatus = 'S';
                // output.tranStatusDescription = serviceOutput.tranStatusDescription;
                output.tranCode = 'S';
                //transStatus.status = 'S';
                //transStatus.errorDescription = serviceOutput.tranStatusDescription;
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