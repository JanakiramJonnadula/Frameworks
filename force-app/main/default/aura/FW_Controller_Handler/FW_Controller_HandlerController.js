({
	onControllerRequest : function(component, event, helper) {
        var requestName = event.getParam("requestName");
        var requestInput = event.getParam("requestInput");
        requestInput = JSON.parse(JSON.stringify(requestInput));
        var callback = event.getParam("callback");
        component.find("proxy").invoke(requestName, requestInput, callback);
    }

})