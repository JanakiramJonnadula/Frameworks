@isTest
public without sharing class FW_ObjectQueryTest {
    static testMethod void runPositiveTestCase1() {
        FW_ObjectQueryInput input = new FW_ObjectQueryInput();  
        input.objectName = 'Account';
        
        FW_Transformation transformation = new FW_Transformation('FW_ObjectQueryAPEX');
        object output = transformation.execute(input);
    }
}