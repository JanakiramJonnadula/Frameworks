public without sharing abstract class FW_Transformation_BASE implements FW_Transformation_Interface {
    
    public FW_TransformationSetting__mdt transformationSetting;
    public FW_Service service;
    
    public FW_Transformation_Status transStatus = new FW_Transformation_Status();   
    public FW_Service_Details transDetails = new FW_Service_Details();
    
    public boolean continueExecution = true;
    
    public abstract object validateInput(Object dataInput);
  
    public abstract object transformInput(Object dataInput);
   
    private abstract object execute(Object operationInput, FW_Transformation_Settings otherSettings);
    
    private abstract object executeOutput(Object continuationOutput, FW_Transformation_Settings otherSettings);
    
    public abstract object transformOutput(Object operationOutput);
    public abstract object transformOutput(Object dataInput, Object operationOutput);
    
    public abstract void postTransformProcess();
    
    private void getContinuationSettings(FW_Transformation_Settings otherSettings){
        if(transformationSetting.ServiceContinuation__c && String.isNotBlank(transformationSetting.ServiceContinuationMethod__c) &&
            String.isNotBlank(transformationSetting.ServiceName__c) && transformationSetting.ServiceContinuationTimeout__c != null &&
            otherSettings.continuation != null &&
            !System.isBatch() && !System.isFuture() && !System.isQueueable() && !System.isScheduled() && !Trigger.isExecuting){
            otherSettings.isContinuation = true;
        }
    }
   
    public object transformAndExecute(FW_TransformationSetting__mdt transformationSetting, Object dataInput, FW_Transformation_Settings otherSettings){
         
        this.transformationSetting = transformationSetting;
        this.transDetails.guid = FW_GUID_Generator.generateGUID();
        this.transStatus.status = 'S';
        this.transStatus.referenceId = this.transDetails.guid;      
        
        Object operationInput;
        Object operationOutput;
        Object dataOutput;
        
        FW_Service_Status_Log__c transStatusLog = new FW_Service_Status_Log__c();
        FW_Service_Log transServiceLog = new FW_Service_Log();
        transServiceLog.transInput = dataInput;
        
        transStatusLog.StartTime__c = system.now();
        try{            
            getContinuationSettings(otherSettings);
            if(dataInput != null && dataInput instanceof string && string.isNotBlank(transformationSetting.InputClass__c))
                dataInput = JSON.deserialize((string)dataInput, Type.forName(transformationSetting.InputClass__c));         
            dataInput = validateInput(dataInput) ;  
            if(continueExecution) operationInput = transformInput(dataInput);
            this.transStatus.referenceName = this.transDetails.messageReference;
        }
        catch(Exception ex){
            transStatus.status = 'E';
            transStatus.errorCode = 'Input';
            transStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Transformation Base Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        transStatusLog.InputProcessingEndTime__c = system.now();
        
        transStatusLog.CalloutStartTime__c = system.now();
        try{  
            
            if(transStatus.status == 'S' && continueExecution) operationOutput = execute(operationInput, otherSettings);
        }
        catch(Exception ex){
            transStatus.status = 'E';
            transStatus.errorCode = 'Service';
            transStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Transformation Base Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        transStatusLog.CalloutEndTime__c = system.now();
        
        transStatusLog.OutputProcessingStartTime__c = system.now();
        try{     
            if(!otherSettings.isContinuation){
                //dataOutput = continueExecution ? transformOutput(operationOutput) : dataInput;
                dataOutput = continueExecution ? transformOutput(dataInput, operationOutput) : dataInput;
            }
            else
                dataOutput = operationOutput;
        }
        catch(Exception ex){
            transStatus.status = 'E';
            transStatus.errorCode = 'Output';
            transStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Transformation Base Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        transStatusLog.EndTime__c = system.now();
        
        transStatusLog.UID__c = this.transDetails.guid;
        transStatusLog.MessageReference__c = this.transDetails.messageReference;
        transStatusLog.Continuation__c = otherSettings.isContinuation;
                
        transServiceLog.transOutput = dataOutput;
        transServiceLog.transSetting = transformationSetting;
        transServiceLog.transStatus = transStatus; 
        if(otherSettings.isContinuation){
            otherSettings.continuationState.dataInput = dataInput;
        }       
        transStatusLog = transServiceLog.logTransformationStatus(transStatusLog);
        if(otherSettings.isContinuation){ 
            otherSettings.continuationState.transformationStatusLog = transStatusLog;
        }
        
        try{
            postTransformProcess();
        }
        catch(Exception ex){
            //DO NOTHING
        }
        
        system.debug('Data output : ' + dataOutput);
        return dataOutput;

    }
    
    public object transformContinuationOutput(FW_TransformationSetting__mdt transformationSetting, object continuationOutput, FW_Transformation_Settings otherSettings){
        
        this.transformationSetting = transformationSetting;
        this.transStatus.status = 'S';      
        
        Object dataInput;
        Object operationOutput;
        Object dataOutput;
        
        FW_Service_Status_Log__c transStatusLog = new FW_Service_Status_Log__c();       

        try{     
            transStatusLog = otherSettings.continuationState.transformationStatusLog;
            dataInput = otherSettings.continuationState.dataInput;
            this.transStatus.referenceId = transStatusLog.UID__c;
            this.transStatus.referenceName = transStatusLog.MessageReference__c;
            operationOutput = executeOutput(continuationOutput, otherSettings);
        }
        catch(Exception ex){
            transStatus.status = 'E';
            transStatus.errorCode = 'Service';
            transStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Transformation Continuation Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        transStatusLog.CalloutEndTime__c = system.now();
        
        transStatusLog.OutputProcessingStartTime__c = system.now();
        try{     
            //dataOutput = transformOutput(operationOutput);
            dataOutput = transformOutput(dataInput, operationOutput);
        }
        catch(Exception ex){
            transStatus.status = 'E';
            transStatus.errorCode = 'Output';
            transStatus.errorDescription = ' Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
            system.debug('@@Error Transformation Continuation Service :' + ex.getMessage() + ex.getstacktracestring());
        }
        transStatusLog.EndTime__c = system.now();
        
        if(this.transStatus.referenceName != null && this.transStatus.referenceName != transStatusLog.MessageReference__c)
            transStatusLog.MessageReference__c = this.transStatus.referenceName;
        
        FW_Service_Log transServiceLog = new FW_Service_Log();
        transServiceLog.transOutput = dataOutput;
        transServiceLog.transSetting = transformationSetting;
        transServiceLog.transStatus = transStatus;          
        transStatusLog = transServiceLog.logTransformationStatus(transStatusLog);
        
        try{
            postTransformProcess();
        }
        catch(Exception ex){
            //DO NOTHING
        }
        
        system.debug('Data Continuation output is...'+dataOutput);
        return dataOutput;
    }
    
}