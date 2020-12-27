// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.0 <0.8.0;
pragma experimental ABIEncoderV2;

contract Seller {
    enum TransactionStatus { Sold, Delivered }
    
    struct Buyer {
        address buyerAdd;
        string buyerName;
    }
    
    struct Product {
        string productName;
        uint productId;
        address productSeller;
        string productStatus;
        uint productQuantity;
        uint productPrice;
        uint timeStamp;                     // timestamp for Resgistration 
    }
    
    struct TransitLog {
        uint productId;
        uint timeStamp;
        Buyer buyerInfo;
        TransactionStatus transactionStatus;
        uint amount;
    }

    // Registring the products
    mapping(address => uint[]) productRegisteredBySeller;        // Number of items under a seller's name (address)
    mapping(uint => Product) productDetails;                     // Product details mapped to their product's Id
    uint productRegCount;                                        // number of Product registered by the seller


    // Product Status
     mapping(uint => uint[]) productTransitLog;                 // product Id mapped to mulptiple order id's generated when the product is beng sold / delivered
     mapping(uint => TransitLog) productTransactionStatus;      // Mapping the product Id with the transaction log
     uint productSoldCount;                                     // No. of product sold
     uint productDeliveredCount;                                // No. of product delivered


    function registerProduct(string memory _productName, uint _productQuantity, uint _productPrice) public {
        // Registering the product
        uint _productId = productRegCount ++;
        productRegisteredBySeller[msg.sender].push(_productId);
        productDetails[_productId] = Product(_productName, _productId, msg.sender, "Available", _productQuantity, _productPrice, block.timestamp);
    }
    
    function getRegisteredProductCount() public view returns(uint) {
        return productRegCount;
    }

    function getProductDetails (uint _productId) public view returns(string memory, uint, address, string memory, uint, uint) {
    	return (
        	productDetails[_productId].productName ,
            // "Vida",
        	productDetails[_productId].productId,
        	productDetails[_productId].productSeller,
        	productDetails[_productId].productStatus,
        	productDetails[_productId].productQuantity,
        	productDetails[_productId].productPrice
    	);
	}
    



    // Let's sell it
    function sellProduct(uint _productId, uint _productQuantity, address _buyerAddress, string memory _buyerName)  public {
    	Product memory _product = productDetails[_productId];
    	require(
    	    isAvailable(_productId) && _productQuantity > 0
          && _product.productQuantity >= _productQuantity
        );
    	
    	
        // Update registered product (quantity & price)
    	uint sellingPrice = _productQuantity * _product.productPrice;
    	_product.productQuantity -= _productQuantity;
    	
    	
    	// Update productStatus of product (in case of sold out)
    	if(_product.productQuantity == 0){
            _product.productStatus = "Sold Out";
    	}
   	 
        // Creating order log
        // uint _orderId = uint(keccak256(abi.encodePacked(_productId, _buyerAddress, ProductSoldCount)));
        uint _orderId = productSoldCount++;
        productTransitLog[_productId].push(_orderId);

    	
    	// Update in transit log for sold products (based upon order id)
    	productTransactionStatus[_orderId] = (TransitLog(_productId, block.timestamp, Buyer(_buyerAddress, _buyerName), TransactionStatus.Sold, sellingPrice));
    	
    	
    	// Updating the changes in productDetails map & increasing the ProductSoldCount (quantity sold)
    	productDetails[_productId] = _product;
	}
	
	function isAvailable(uint _productId) private view returns (bool) {
	    if (keccak256(abi.encodePacked(productDetails[_productId].productStatus)) == keccak256(abi.encodePacked("Available"))){
	        return true;
	    }
	    return false;
	}
	
	function getOrderIds(uint _productId) public view returns(uint[] memory) {
        // 	return all the orderIds associated with the given product Id
    	return productTransitLog[_productId];
	}

    function getProductTransactionStatus (uint _orderId) public view returns( uint, string memory, address, TransactionStatus, uint) {
    	return (
        	productTransactionStatus[_orderId].timeStamp,
        	productTransactionStatus[_orderId].buyerInfo.buyerName,
        	productTransactionStatus[_orderId].buyerInfo.buyerAdd,
        	productTransactionStatus[_orderId].transactionStatus,
        	productTransactionStatus[_orderId].amount
    	);
	}
    
	function getSoldCount() public view returns(uint) {
    	return productSoldCount;
	}
    



    // Let's deliver it
    function deliverProduct (uint _orderId, uint _productPrice) public {
        TransitLog memory _order = productTransactionStatus[_orderId];
        
        require (!isDelivered(_orderId) && _order.amount ==  _productPrice);

        
        _order.transactionStatus = TransactionStatus.Delivered;
        _order.timeStamp = block.timestamp;
        productDeliveredCount ++;

        
        productTransactionStatus[_orderId] = _order;
	}
    
    function isDelivered(uint _orderId) private view returns(bool) {
        if (productTransactionStatus[_orderId].transactionStatus == TransactionStatus.Delivered){
            return true;
        }
        return false;
    }
    
    function getDeliveredProductCount() public view returns(uint) {
        return productDeliveredCount;
    }

    function getBalance () public view returns(uint){
    	return msg.sender.balance;
	}
}