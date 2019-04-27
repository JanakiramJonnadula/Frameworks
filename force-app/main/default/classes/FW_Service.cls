public with sharing class FW_Service {
    
    private FW_Service_Setting__mdt serviceSetting;
    public Continuation continuation;
    public FW_Service_ContinuationState continuationState;
    public FW_Service_Details serviceDetails;
    
    public class StrategyNameException extends Exception{}
    
    public class ServiceSettingException extends Exception{}
    
    private FW_Service_Interface strategy;    
    
    public static final Map<String, FW_Service_Interface> strategies;    
    
    static{
        
        system.debug('SERVICE - static variables');
        try {
                FW_Global_Setting__mdt serviceStrategies = [Select 
                                                                QualifiedApiName, MasterLabel, Label, Id, DeveloperName, Value__c
                                                                    From FW_Global_Setting__mdt 
                                                                        where QualifiedApiName = : FW_Service_Helper.serviceStrategies 
                                                                            limit 1];
             List<String> strategyNames = new List<String>();
    
            if(serviceStrategies != null && serviceStrategies.Value__c != null)
                strategyNames = serviceStrategies.Value__c.split(',');
                
            strategies = new Map<String, FW_Service_Interface>();
            
            for(String name : strategyNames){
                try{
                    strategies.put(name, (FW_Service_Interface)Type.forName(name).newInstance());                    
                }
                catch(Exception e){
                  system.debug('Service Strategy Exception : ' + e.getMessage());
                    continue;
                }
            }
        } catch(Exception ex) {
            //GEMS_CreateExceptionLog.insertErrorLog(ex, null, null, null, 'FW_Service', 'Case', null, 'FW_Service.staticBlock','High');             
        }
    }   
    
    public FW_Service(String serviceName){
        
        system.debug('SERVICE - Constructor');
                
        serviceSetting = [Select 
                                Timeout__c, Strategy__c, QualifiedApiName, ProcessingClass__c, OutputClass__c, Operation__c,  
                                MasterLabel, LogWithCallout__c, LogStatus__c, LogResponse__c, LogRequest__c, Label, InputClass__c, 
                                Id, HeaderName__c, EndPoint__c, EndPointParameters__c, DeveloperName, Compressed__c, 
                                LogRequestPII__c, LogResponsePII__c, 
                                MockResponse__c, NamedCredential__c, CustomCredential__c,
                                LogFail__c, LogAdmin__c
                                    From FW_Service_Setting__mdt
                                        WHERE QualifiedApiName =: serviceName
                                            limit 1];

        if(serviceSetting != null){
            
          if(!strategies.containsKey(serviceSetting.Strategy__c))
              throw new StrategyNameException(serviceSetting.Strategy__c);
              
          strategy = strategies.get(serviceSetting.Strategy__c);
          
        }
        else
          throw new ServiceSettingException('Error : Service Configuration Setup is Missing for : ' + serviceName);
          
    }   
    
    public Object callout(Object serviceInput){          
        
        FW_Service_Continuation contSettings = new FW_Service_Continuation();
        contSettings.continuation = continuation;
        contSettings.continuationState = continuationState;
        //contSettings.isContinuation = continuation != null? true : false;
        
        return strategy.performServiceCallout(serviceSetting, serviceInput, contSettings, serviceDetails);        
    }
    
    public Object processResponse(Object continuationOutput){  
        
        FW_Service_Continuation contSettings = new FW_Service_Continuation();
        contSettings.continuationState = continuationState;
        contSettings.isContinuation = false;
        
        return strategy.processContinuationResponse(serviceSetting, continuationOutput, contSettings, serviceDetails);   
    }
    
}