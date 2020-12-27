// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.5.0 <0.8.0;
// import "./Supplier.sol";

contract Buyer {

    enum OrderStatus { Placed, Shipped, Delivered }
    
    // Product's Details
    struct Product {
        string productName;
    	uint productId;
    	address payable productSeller;
    	string productStatus;
    	uint productQuantity;
    	uint productPrice;
    }
    
    // Details about the Transactions made by the customers
    struct OrderLog {
        uint productId;
        uint amtpaid;
        uint256 timeStamp;
        OrderStatus orderStatus;
    }

    // Maintain product block history 
    mapping(address => uint[]) productBrought;                  // buyer's address (account) to productId
    mapping(uint => Product) productDetails;                    // ProductId with Product Details
    uint8 productBroughtCount;                                  // number of products ever bought


    // Product Status
    mapping(uint => OrderLog) productOrderStatus;               // Mapping the product Id with the order log
    uint productPlacedCount;                                    // No. of product placed to the customer
    uint productShippedCount;                                   // No. of product shipped to the customer
    uint productDeliveredCount;                                 // No. of orders delivered

    
    
    // function getProductDetailsFromSeller (uint _productId) public {
    //     if (productDetails[_productId].productSeller == 0x0000000000000000000000000000000000000000){
    //         Seller _product = new Seller();
    //         Product memory _getProduct;
    //         (_getProduct.productName, _getProduct.productId, _getProduct.productSeller, _getProduct.productStatus, _getProduct.productQuantity, _getProduct.productPrice) = _product.getProductDetails(_productId);
            
    //         productDetails[_productId] = _getProduct;
    //     }
    // }
    
    function getProductDetailsFromSeller(string memory _productName, uint _productQuantity, uint _productPrice, address payable _productSeller) public {
        // Registering the product
        uint _productId = productBroughtCount ++;
        productDetails[_productId] = Product(_productName, _productId, _productSeller, "Available", _productQuantity, _productPrice);
    }
    
    // place order
    function orderPlaced (uint _productId, uint _productQuantity) public payable returns (address, uint, uint) {
        // Add the item (product's id) into the buyer's bought list
        productBrought[msg.sender].push(_productId);
        // getProductDetailsFromSeller(_productId);
        
        Product memory _getProduct = productDetails[_productId];
        uint _amtpaid = _productQuantity * _getProduct.productPrice;

        
        transferAmount(_getProduct.productSeller, _amtpaid);
        productOrderStatus[_productId] = OrderLog(_productId, _amtpaid, block.timestamp, OrderStatus.Placed);
        
        productPlacedCount++;
        return (_getProduct.productSeller, _getProduct.productPrice, _productQuantity);
    }
    
    function transferAmount(address payable _sellerAdd, uint _amtpaid) private {
        require(_amtpaid <= address(this).balance, "Insufficient balance.");
        _sellerAdd.transfer(_amtpaid);
    }

    function getPlacedProductCount() public view returns(uint) {
        return productPlacedCount;
    }

  

    // order shipped
    function orderShipped (uint _productId) public {
        require (productOrderStatus[_productId].orderStatus == OrderStatus.Placed);
        productOrderStatus[_productId].orderStatus = OrderStatus.Shipped;
        productOrderStatus[_productId].timeStamp = block.timestamp;
        
        productShippedCount++;
    }
    
    function getShippedProductCount() public view returns(uint) {
        return productShippedCount;
        
    }



    // order delivered
    function orderDelivered (uint _productId) public {
        require (productOrderStatus[_productId].orderStatus == OrderStatus.Shipped);
        productOrderStatus[_productId].orderStatus = OrderStatus.Delivered;
        productOrderStatus[_productId].timeStamp = block.timestamp;
        
        productDeliveredCount++;
    }
    
    function getDeliveredProductCount()  public view returns(uint) {
        return productDeliveredCount;
    }



    // miscellaneous function
    function getProductDetails (uint _productId) public view returns(string memory, uint, address, string memory, uint, uint) {
    	return (
        	productDetails[_productId].productName,
        	productDetails[_productId].productId,
        	productDetails[_productId].productSeller,
        	productDetails[_productId].productStatus,
        	productDetails[_productId].productQuantity,
        	productDetails[_productId].productPrice
    	);
	}  
    
    function getOrderLog(uint _productId) public view returns(uint, uint, uint, OrderStatus) {
        return(
            productOrderStatus[_productId].productId,
            productOrderStatus[_productId].amtpaid,
            productOrderStatus[_productId].timeStamp,
            productOrderStatus[_productId].orderStatus
        );
    }
    
    function putMoney() external payable{
        
    }
    
    function getBalance () public view returns(uint){
        return address(this).balance;
    }
}
