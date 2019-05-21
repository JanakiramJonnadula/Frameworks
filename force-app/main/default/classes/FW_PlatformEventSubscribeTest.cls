@isTest
public without sharing class FW_PlatformEventSubscribeTest {
    static testMethod void runPositiveTestCase1() {
        FW_PlatformEventSubscribeInput input = new FW_PlatformEventSubscribeInput();  
        list<FW_Platform_Event__e> events = new list<FW_Platform_Event__e>();
        FW_Platform_Event__e event = new FW_Platform_Event__e();
        event.Message__c = 'test';
        events.add(event);
        input.events = events;
        
        FW_Transformation transformation = new FW_Transformation('FW_PlatformEventSubscribeAPEX');
        object output = transformation.execute(input);
    }
}
