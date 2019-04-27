public without sharing abstract class FW_Transformation_REMOTING extends FW_Transformation_BASE {
    
    public override virtual object validateInput(Object dataInput){
        return dataInput; 
    }
    
    public override virtual object transformInput(Object dataInput){
        return dataInput; 
    }
    
    public override virtual object transformOutput(Object operationOutput){
        return operationOutput;
    }
    
    public override virtual object transformOutput(Object dataInput, Object operationOutput){
        return operationOutput;
    }
    
    public override virtual void postTransformProcess(){
        
    }
     
     //--------------------------
   
     private object execute(Object operationInput, FW_Transformation_Settings otherSettings){
        
        Object operationOutput;
        
        try{  
            if(String.isNotBlank(transformationSetting.ServiceName__c)){        

                service = new FW_Service(transformationSetting.ServiceName__c);
                service.serviceDetails = transDetails;
                
                if(otherSettings.isContinuation){
                    service.continuation = otherSettings.continuation;
                    service.continuationState = otherSettings.continuationState;
                }
                
                if (Test.isRunningTest())
                    Test.startTest();
                    
                operationOutput = service.callout(operationInput);
                
                if (Test.isRunningTest())
                    Test.stopTest();
            }
            else
                operationOutput = operationInput;
        }
        catch(Exception ex) {
            system.debug('Interface Error : '+ex.getMessage());
            throw ex;
        }
        return operationOutput;
     }
     
     private object executeOutput(Object continuationOutput, FW_Transformation_Settings otherSettings){
        
        Object serviceOutput;
        
        try{  
            if(String.isNotBlank(transformationSetting.ServiceName__c)){        
                service = new FW_Service(transformationSetting.ServiceName__c);

                service.continuation = otherSettings.continuation;
                service.continuationState = otherSettings.continuationState;
                    
                serviceOutput = service.processResponse(continuationOutput);
            }
            else
                serviceOutput = continuationOutput;
        }
        catch(Exception ex) {
            system.debug('Interface Error : '+ex.getMessage());
            throw ex;
        }
        return serviceOutput;
     }
    
}