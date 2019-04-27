public without sharing class FW_ProductSearchHelper  extends FW_Transformation_REMOTING{

    public override object transformInput(Object dataInput){
        
        FW_ProductSearchInput input = (FW_ProductSearchInput) dataInput;
        FW_ProductSearchServiceInput serviceInput = new FW_ProductSearchServiceInput();
        
        serviceInput.productId = input.productId;
        serviceInput.latency = input.latency;
        
        transDetails.messageReference = input.latency;
        
        return serviceInput;
    }

    public override object transformOutput(Object dataInput, Object operationOutput){
		FW_ProductSearchInput input = (FW_ProductSearchInput) dataInput;
        FW_ProductSearchOutput output = new  FW_ProductSearchOutput();
        
        string errorCode;
        try
        {
            if(transStatus != null && transStatus.status == 'S')
            {
                FW_ProductSearchServiceOutput serviceOutput = (FW_ProductSearchServiceOutput) operationOutput;
                output.tranId = serviceOutput.tranId;
                output.tranStatus = serviceOutput.tranStatus;
                output.tranCode = serviceOutput.tranCode;
                output.tranStatusDescription = serviceOutput.tranStatusDescription;

                system.debug('Transformation Status : ' + serviceOutput.tranStatus);

                if(serviceOutput.tranStatus == 'S' || serviceOutput.tranStatus == 'P')
                {   
                    output.page = serviceOutput.page;
                    output.pageSize = serviceOutput.pageSize;
                    output.total = serviceOutput.total;
                    list<FW_ProductSearchOutput.Product> products = new list<FW_ProductSearchOutput.Product>();
                    for (FW_ProductSearchServiceOutput.Product product : serviceOutput.products) {
                        FW_ProductSearchOutput.Product p = new FW_ProductSearchOutput.Product();
                        p.id = product.id;
                        p.name = product.name;
                        p.description = product.description;
                        p.msrp = product.msrp;
                        p.category = product.category;
                        p.picture = product.picture; 
                        products.add(p);
                    }
                    
                    output.products = products;
                }
                else
                {
                    errorCode = 'SERVICE_ERROR';
                    output.tranStatusDetails = transStatus.errorDescription;
                }
            }
        }
        catch(Exception ex)
        {
            errorCode = 'UNABLE_TOPROCESS_THE_REQUEST';
            output.tranStatusDetails = 'Transformation Error : ' + ex.getMessage() + ex.getstacktracestring();
        }
        if(string.isNotBlank(errorCode))
        {
            output.tranId = transDetails.guid;
            output.tranCode = errorCode;
            output.tranStatus = 'E';
        }
        if(string.isNotBlank(output.tranCode))
        {
            output.tranStatusDescription = 'Error Based on Error Code';
        }
        return output;
	}
    
}