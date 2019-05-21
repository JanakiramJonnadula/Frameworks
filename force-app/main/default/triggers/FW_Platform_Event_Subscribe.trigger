trigger FW_Platform_Event_Subscribe on FW_Platform_Event__e (after insert) {

    FW_PlatformEventSubscribeInput input = new FW_PlatformEventSubscribeInput();  
    input.events = Trigger.New;
        
    FW_Transformation transformation = new FW_Transformation('FW_PlatformEventSubscribeAPEX');
    object output = transformation.execute(input);

}