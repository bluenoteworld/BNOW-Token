// var Migrations = artifacts.require("./Migrations.sol");
var BNOW = artifacts.require("./BNOWToken.sol");

module.exports = function(deployer, network, accounts) {
  // deployer.deploy(BNOW, {from: accounts[0], arguments: ['12500000000000000000000000000']
  deployer.deploy(BNOW, '12500000000000000000000000000');
};
