public with sharing class FW_Transformation {
    
    private FW_TransformationSetting__mdt transformationSetting;    
    public class StrategyNameException extends Exception{}
    public class TransformationException extends Exception{}
    private FW_Transformation_Interface strategy;
    public static final Map<String, FW_Transformation_Interface> strategies;
    
    public Continuation continuation;
    public FW_Service_ContinuationState continuationState;
    
    public boolean isContinuation;
    public Integer continuationTimeout;
    public string continuationMethod;    
    
    static{        
        List<FW_TransformationSetting__mdt> transformationSettings = [Select 
                                                                        InputClass__c, OutputClass__c, ProcessingClass__c, ServiceContinuation__c, ServiceName__c
                                                                            From FW_TransformationSetting__mdt];      
        List<String> strategyNames = new List<String>();
        
        for(FW_TransformationSetting__mdt ts : transformationSettings){          
            strategyNames.add(ts.ProcessingClass__c);
        }
        strategies = new Map<String, FW_Transformation_Interface>();
        
        for(String name : strategyNames){
            try{
            	strategies.put(name, (FW_Transformation_Interface)Type.forName(name).newInstance());                    
            }
            catch(Exception e){
              system.debug('Transformation Strategy Exception : ' + e.getMessage());              
                continue;
            }
        }
    }   
    
    public FW_Transformation(String transformationName){
        transformationSetting = [Select 
                                QualifiedApiName, ProcessingClass__c, ServiceContinuation__c, ServiceName__c,
                                InputClass__c, OutputClass__c, LogFail__c, LogAdmin__c,
                                LogInput__c, LogOutput__c, LogStatus__c, LogWithCallout__c,
                                ServiceContinuationTimeout__c, ServiceContinuationMethod__c,
                                LogInputPII__c, LogOutputPII__c
                                    From FW_TransformationSetting__mdt
                                        WHERE QualifiedApiName =: transformationName
                                            limit 1];
        if(transformationSetting != null){
            if(!strategies.containsKey(transformationSetting.ProcessingClass__c))
                throw new StrategyNameException(transformationSetting.ProcessingClass__c);
            strategy = strategies.get(transformationSetting.ProcessingClass__c);
          
            isContinuation = transformationSetting.ServiceContinuation__c;
            continuationTimeout = Integer.ValueOf(transformationSetting.ServiceContinuationTimeout__c);
            continuationMethod = transformationSetting.ServiceContinuationMethod__c;
        }
        else
          throw new TransformationException('Error : Transformation Configuration Setup is Missing for : ' + transformationName);          
    }    
    
    public object execute(object dataInput){
        
        FW_Transformation_Settings otherSettings = new FW_Transformation_Settings();
        otherSettings.continuation = continuation;
        otherSettings.continuationState = continuationState;
        
        system.debug('Data Input : '+ dataInput);
        
        return strategy.transformAndExecute(transformationSetting, dataInput, otherSettings);
    }
    
    public object transformContinuationOutput(object continuationOutput){
        
        FW_Transformation_Settings otherSettings = new FW_Transformation_Settings();
        otherSettings.continuationState = continuationState;
        
        return strategy.transformContinuationOutput(transformationSetting, continuationOutput, otherSettings);
    }
    
}