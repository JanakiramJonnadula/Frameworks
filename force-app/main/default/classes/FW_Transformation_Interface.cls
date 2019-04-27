public interface FW_Transformation_Interface {
    
    object transformAndExecute(FW_TransformationSetting__mdt transformationSetting, object dataInput, FW_Transformation_Settings otherSettings);
    
    object transformContinuationOutput(FW_TransformationSetting__mdt transformationSetting, object continuationOutput, FW_Transformation_Settings otherSettings);
    
}