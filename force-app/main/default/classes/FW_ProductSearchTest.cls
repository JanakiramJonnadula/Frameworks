@isTest
public without sharing class FW_ProductSearchTest {
    static testMethod void runPositiveTestCase1() {
        FW_ProductSearchInput input = new FW_ProductSearchInput();  
        input.latency = '6000';
        
        FW_Transformation transformation = new FW_Transformation('FW_ProductSearchREST');
        object output = transformation.execute(input);
    }
    
}