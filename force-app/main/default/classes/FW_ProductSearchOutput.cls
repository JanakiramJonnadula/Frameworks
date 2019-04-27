public with sharing class FW_ProductSearchOutput {

    public string tranId;
	public string tranStatus;
	public string tranCode;
	public string tranStatusDescription;
	public string tranStatusDetails;

    public Integer page;
    public Integer pageSize;
    public Integer total;

    public list<Product> products;

    public class Product {
        public Integer id;
        public String name;
        public String description;
        public Integer msrp;
        public String category;
        public String picture; 
    }
}