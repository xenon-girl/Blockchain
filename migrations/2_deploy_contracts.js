const Seller = artifacts.require("Seller");
const Buyer = artifacts.require("Buyer");

module.exports = function (deployer) {
  deployer.deploy(Seller);
  deployer.deploy(Buyer);
};
