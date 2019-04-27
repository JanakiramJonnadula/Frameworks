({
    getProducts : function(component, event, helper) {
        var latency = component.get("v.latency");
        var productSearchRequest = {
            productId: null,
            larency: latency
        };
        var request = $A.get("e.c:FW_Controller_Request");
        request.setParams({            
            requestName: "FW_ProductSearchREST",
            requestInput: productSearchRequest,
            callback: function(result) {
                var plainText = result;//.replace(/&quot;/g, '"').replace(/&#39;/g, "'");
                component.set("v.result", plainText);
            }
        });
        request.fire();
    },

})