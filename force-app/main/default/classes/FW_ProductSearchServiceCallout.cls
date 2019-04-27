public without sharing class FW_ProductSearchServiceCallout extends FW_ServiceIO_REST {

    public override void setEndPointParameters(FW_Service_Settings serviceEndpoint){
        
        FW_ProductSearchServiceInput input = (FW_ProductSearchServiceInput ) serviceInput;
        serviceEndpoint.serviceEndpoint = serviceEndpoint.serviceEndpoint + '?latency=' + input.latency;

    }
    
    /*public object convertInputToRequest(){
        FW_ProductSearchServiceInput input = (FW_ProductSearchServiceInput) serviceInput;		
        //input.tranId = serviceDetails.guid;	
        input.latency = input.latency;
        input.productId = input.productId;	

        return input;		
    }*/
    
    public override object convertResponseToOutput(object serviceInput, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        
        FW_ProductSearchServiceOutput output = new FW_ProductSearchServiceOutput();
        output.tranId = serviceStatus.referenceId;
		output.tranStatus = serviceStatus.status;
        
        try{    		
            if(serviceStatus != null && serviceStatus.status != 'E'){
                output = (FW_ProductSearchServiceOutput) response;
                output.tranId = serviceStatus.referenceId;
		        output.tranStatus = serviceStatus.status;
            }
            else{
                output.tranId = serviceStatus.referenceId;
		        output.tranStatus = serviceStatus.status;
                output.tranCode = 'Interface';
                output.tranStatusDescription = serviceStatus.errorDescription;
            }    		
        }
        catch(Exception ex){  
            output.tranId = serviceStatus.referenceId;          
            output.tranStatus = 'E';
            output.tranCode = 'Output';
            output.tranStatusDescription = 'Processing Error : ' + ex.getMessage() + ex.getstacktracestring();
        }
        return output;
    }
    
    public override object prepareMockOutput(object serviceInput, object response, map<string, string> responseHeader, FW_Service_Status serviceStatus) {
        
        FW_ProductSearchServiceInput input = (FW_ProductSearchServiceInput) serviceInput;

        FW_ProductSearchServiceOutput output = new FW_ProductSearchServiceOutput();
        List<FW_ProductSearchServiceOutput.Product> productList = new List<FW_ProductSearchServiceOutput.Product>();

        FW_ProductSearchServiceOutput.Product product = new FW_ProductSearchServiceOutput.Product();
        product.id = 1;
        product.name = 'Test';
        product.description = 'Test Desc';
        product.msrp = 89;
        product.category = 'Test Category';
        product.picture = 'https://s3-us-west-2.amazonaws.com/nto-products/products1110/2007100.jpg';
        productList.add(product);            
        
        output.products = productList;

        return output;
    }
    
}