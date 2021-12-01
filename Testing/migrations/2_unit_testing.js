const MainContract = artifacts.require("./contracts/Game.sol");


module.exports = function(deployer) {
    deployer.deploy(MainContract);
};