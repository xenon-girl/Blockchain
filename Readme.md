# E-commerce Site using Ethereum (truffle and nodejs)

## 1. Dependencies

We need node package manager to download all the other dependencies

1. [Node](https://nodejs.org/en/)

- Backend
  - Truffle --> npm install -g truffle
  - TestRPC (a.k.a. Ganache) --> npm install -g ethereumjs-testrpc

## 2. Smart Contract

It is divided into two parts -

### 1. Supplier (Seller)

It will take the values regarding the details of the product which includes -

(Structure #1: `Product`)

```text
1. Product Id
2. Product Name
3. Product's seller address
4. Category (Available/ Sold Out)
5. Quantity
6. Price
7. Timestamp (for registration)
```

Also, the supplier would get the information about the transaction for an order -

(Structure #2: `TransitLog`)

```text
1. Product Id
2. Timestamp (for transactions - Sold/ Delivered)
3. Buyer's Details (Customer Id and name)
4. Status of Order (Sold/ Delivered)
5. Amount (Money exchanged b/w seller and buyer)
```

#### Understanding Seller's Code

- Registering the product

Each product is registered by a seller. Thus, the seller's address will be mapped to the productId in `productRegisteredBySeller`

```solidity
mapping(address => uint[]) productRegisteredBySeller;
mapping(uint => Product) productDetails;
uint8 ProductRegCount;
```

Now, this `productId` could be used to identify the product and get it's details, which are stored in `productDetails`.

- Transaction Log the product

The seller would require a transaction log which can store the amount being paid, status of delivery (sold / delivered), who bought it, all associated with their `productId`. Moreover for the same `productId` multiple transactions could be made. (Different buyer buying different amount of product until its sold out.)

```solidity
mapping(uint => uint[]) productTransitLog;
mapping(uint => TransitLog) productTransitLog;
uint8 ProductSoldCount;
uint8 ProductDeliveredCount;
```

Here, `productTransitLog` maps `productId` to (an array of) `orderId`. While, `productTransitLog` maps `orderId` to `TransitLog` (see above structure#2: TransitLog).

### 2. Customer (Buyer)

Similar to seller, it will take product's details. Which includes -
(Structure #1: `Product`)

```text
1. Product Id
2. Product Name
3. Product's seller address
4. Category (Available/ Sold Out)
5. Quantity
6. Price
```

Also, the buyer would have an order log for Placed/ Shipped/ Delivered -

(Structure #2 `OrderLog`)

```text
1. Product Id
2. Timestamp (for transactions - Placed/ Shipped/ Delivered)
4. Status of order (laced/ Shipped/ Delivered)
```

#### Understanding Buyer's Code

- Registering the product
  The details of registered product will be extracted by a buyer via productId. These values are stored in `productDetails`

  ```solidity
  mapping(address => uint[]) productBrought;
  mapping(uint => Product) productDetails;
  uint8 ProductBroughtCount;
  ```

Whenever, the product is bought, its productId mapped to the customer's address.

- Order Log the product
  Here, for each product we have three types of status (`orderStatus`), Placed/ Shipped/ Delivered, which would be changed accordingly. The `productId` would be used as the key to identify these `orderLogs`.

  ```solidity
  mapping(uint => OrderLog) productOrderStatus;
  uint8 ProductPlacedCount;
  uint8 ProductShippedCount;
  uint8 ProductDeliveredCount;
  ```
