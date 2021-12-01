const SecondContract = artifacts.require("./contracts/SecondContract.sol");

module.exports = function(deployer) {
    deployer.deploy(SecondContract);
};