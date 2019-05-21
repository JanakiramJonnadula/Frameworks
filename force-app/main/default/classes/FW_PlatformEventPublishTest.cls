@isTest
public without sharing class FW_PlatformEventPublishTest {

    static testMethod void runPositiveTestCase1() {
        FW_PlatformEventPublishInput input = new FW_PlatformEventPublishInput();  
        list<FW_Platform_Event__e> events = new list<FW_Platform_Event__e>();
        FW_Platform_Event__e event = new FW_Platform_Event__e();
        event.Message__c = 'test';
        events.add(event);
        input.events = events;
        
        FW_Transformation transformation = new FW_Transformation('FW_PlatformEventPublishAPEX');
        object output = transformation.execute(input);
    }

}
